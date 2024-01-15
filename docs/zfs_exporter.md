You can use a [zfs exporter](https://github.com/pdf/zfs_exporter) to create alerts on your ZFS pools, filesystems, snapshots and volumes.

# Available metrics

It's not easy to match the exporter metrics with the output of `zfs list -o space`. Here is a correlation table:

- USED: `zfs_dataset_used_bytes{type="filesystem"}`
- AVAIL: `zfs_dataset_available_bytes{type="filesystem"}`
- LUSED: `zfs_dataset_logical_used_bytes{type="filesystem"}`
- USEDDS: `zfs_dataset_used_by_dataset_bytes="filesystem"}`
- USEDSNAP: Currently there [is no published metric](https://github.com/pdf/zfs_exporter/issues/32) to get this data. You can either use `zfs_dataset_used_bytes - zfs_dataset_used_by_dataset_bytes` which will show wrong data if the dataset has children or try to do `sum by (hostname,filesystem) (zfs_dataset_used_bytes{type='snapshot'})` which returns smaller sizes than expected.

# [Installation](https://github.com/pdf/zfs_exporter#installation)

## Install the exporter

Download the [latest release](https://github.com/pdf/zfs_exporter/releases/latest) for your platform, and unpack it somewhere on your filesystem.

If you use ansible you can use the next task:

```yaml
---
- name: Test if zfs_exporter binary exists
  stat:
    path: /usr/local/bin/zfs_exporter
  register: zfs_exporter_binary

- name: Install the zfs exporter
  block:
    - name: Download the zfs exporter
      delegate_to: localhost
      ansible.builtin.unarchive:
        src: https://github.com/pdf/zfs_exporter/releases/download/v{{ zfs_exporter_version }}/zfs_exporter-{{ zfs_exporter_version }}.linux-amd64.tar.gz
        dest: /tmp/
        remote_src: yes

    - name: Upload the zfs exporter to the server
      become: true
      copy:
        src: /tmp/zfs_exporter-{{ zfs_exporter_version }}.linux-amd64/zfs_exporter
        dest: /usr/local/bin
        mode: 0755
  when: not zfs_exporter_binary.stat.exists

- name: Create the systemd service
  become: true
  template:
    src: service.j2
    dest: /etc/systemd/system/zfs_exporter.service
  notify: Restart the service
```

With this service template

```yaml
[Unit]
Description=zfs_exporter
After=network-online.target

[Service]
Restart=always
RestartSec=5
TimeoutSec=5
User=root
Group=root
ExecStart=/usr/local/bin/zfs_exporter {{ zfs_exporter_arguments }}

[Install]
WantedBy=multi-user.target
```

This defaults file:

```yaml
---
zfs_exporter_version: 2.2.8
zfs_exporter_arguments: --collector.dataset-snapshot
```

And this handler:

```yaml
- name: Restart the service
  become: true
  systemd:
    name: zfs_exporter
    enabled: true
    daemon_reload: true
    state: restarted
```

I know I should publish a role, but I'm lazy right now :P

## Configure the exporter

Configure the scraping in your prometheus configuration:

```yaml
  - job_name: zfs_exporter
    metrics_path: /metrics
    scrape_timeout: 60s
    static_configs:
    - targets: [192.168.3.236:9134] 
    metric_relabel_configs:
      - source_labels: ['name']
        regex: ^([^@]*).*$
        target_label: filesystem
        replacement: ${1}
      - source_labels: ['name']
        regex: ^.*:.._(.*)$
        target_label: snapshot_type
        replacement: ${1}
```

Remember to set the `scrape_timeout` to at least of `60s` as the exporter is sometimes slow to answer, specially on low hardware resources.

The relabelings are done to be able to extract the `filesystem` and the backup type of the snapshots'  metrics. This assumes that you are using [`sanoid`](sanoid.md) to do the backups, which gives metrics such as:

```
zfs_dataset_written_bytes{name="main/apps/nginx_public@autosnap_2023-06-03_00:00:18_daily",pool="main",type="snapshot"} 0
```

For that metric you'll get that the `filesystem` is `main/apps/nginx_public` and the backup type is `daily`.

## Configure the alerts

The people of [Awesome Prometheus Alerts](https://samber.github.io/awesome-prometheus-alerts/rules.html#zfs) give some good ZFS alerts for this exporter:

```yaml
  - alert: ZfsPoolOutOfSpace
    expr: zfs_pool_free_bytes * 100 / zfs_pool_size_bytes < 10 and ON (instance, device, mountpoint) zfs_pool_readonly == 0
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: ZFS pool out of space (instance {{ $labels.instance }})
      description: "Disk is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsPoolUnhealthy
    expr: zfs_pool_health > 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: ZFS pool unhealthy (instance {{ $labels.instance }})
      description: "ZFS pool state is {{ $value }}. Where:\n  - 0: ONLINE\n  - 1: DEGRADED\n  - 2: FAULTED\n  - 3: OFFLINE\n  - 4: UNAVAIL\n  - 5: REMOVED\n  - 6: SUSPENDED\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsCollectorFailed
    expr: zfs_scrape_collector_success != 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: ZFS collector failed (instance {{ $labels.instance }})
      description: "ZFS collector for {{ $labels.instance }} has failed to collect information\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

```

### Snapshot alerts

You can also monitor the status of the snapshots.

```yaml
  - alert: ZfsDatasetWithNoSnapshotsError
    expr: zfs_dataset_used_by_dataset_bytes{type="filesystem"} > 200e3 unless on (hostname,filesystem) count by (hostname, filesystem, job) (zfs_dataset_used_bytes{type="snapshot"}) > 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The dataset {{ $labels.filesystem }} at {{ $labels.hostname }} doesn't have any snapshot.
      description: "There might be an error on the snapshot system\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeFrequentlySizeError
    expr: increase(sum by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='frequently'})[60m:15m]) == 0 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[60m:15m]) == 4
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The size of the frequently snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system or the data has not changed in the last hour\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeHourlySizeError
    expr: increase(sum by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='hourly'})[2h:30m]) == 0 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[2h:30m]) == 4
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The size of the hourly snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system or the data has not changed in the last hour\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeDailySizeError
    expr: increase(sum by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='daily'})[2d:12h]) == 0 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[2d:12h]) == 4
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The size of the daily snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system or the data has not changed in the last hour\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeMonthlySizeError
    expr: increase(sum by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='monthly'})[60d:15d]) == 0 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[60d:15d]) == 4
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The size of the monthly snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system or the data has not changed in the last hour\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeFrequentlyUnexpectedNumberError
    expr: increase((count by (hostname, filesystem, job) (zfs_dataset_used_bytes{snapshot_type="frequently",type="snapshot"}) < 4)[16m:8m]) < 1 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[16m:8m]) == 2
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The number of the frequent snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeHourlyUnexpectedNumberError
    expr: increase((count by (hostname, filesystem, job) (zfs_dataset_used_bytes{snapshot_type="hourly",type="snapshot"}) < 24)[1h10m:10m]) < 1 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[1h10m:10m]) == 7
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The number of the hourly snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeDailyUnexpectedNumberError
    expr: increase((count by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='daily'}) < 30)[1d2h:2h]) < 1 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[1d2h:2h]) == 13
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The number of the hourly snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - alert: ZfsSnapshotTypeMonthlyUnexpectedNumberError
    expr: increase((count by (hostname, filesystem, job) (zfs_dataset_used_bytes{type='snapshot',snapshot_type='monthly'}) < 6)[31d:1d]) < 1 and count_over_time(zfs_dataset_used_bytes{type="filesystem"}[31d:1d]) == 31
    for: 5m
    labels:
      severity: error
    annotations:
      summary: The number of the monthly snapshots has not changed for the dataset {{ $labels.filesystem }} at {{ $labels.hostname }}.
      description: "There might be an error on the snapshot system\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

  - record: zfs_dataset_snapshot_bytes
    # This expression is not real for datasets that have children, so we're going to create this metric only for those datasets that don't have children
    # I'm also going to assume that the datasets that have children don't hold data
    expr: zfs_dataset_used_bytes - zfs_dataset_used_by_dataset_bytes and zfs_dataset_used_by_dataset_bytes > 200e3
  - alert: ZfsSnapshotTooMuchSize
    expr: zfs_dataset_snapshot_bytes / zfs_dataset_used_by_dataset_bytes > 2 and zfs_dataset_snapshot_bytes > 10e9
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: The snapshots of the dataset {{ $labels.filesystem }} at {{ $labels.hostname }} use more than two times the data space
      description: "The snapshots of the dataset {{ $labels.filesystem }} at {{ $labels.hostname }} use more than two times the data space\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

### Useful inhibits

Some you may want to inhibit some of these rules for some of your datasets. These subsections should be added to the `alertmanager.yml` file under the `inhibit_rules` field.

#### Ignore snapshots on some datasets

Sometimes you don't want to do snapshots on a dataset

```yaml
- target_matchers:
    - alertname = ZfsDatasetWithNoSnapshotsError
    - hostname = my_server_1
    - filesystem = tmp
```

#### Ignore snapshots growth 

Sometimes you don't mind if the size of the data saved in the filesystems doesn't change too much between snapshots doesn't change much specially in the most frequent backups because you prefer to keep the backup cadence. It's interesting to have the alert though so that you can get notified of the datasets that don't change that much so you can tweak your backup policy (even if zfs snapshots are almost free).

```yaml
  - target_matchers:
    - alertname =~ "ZfsSnapshotType(Frequently|Hourly)SizeError"
    - filesystem =~ "(media/(docs|music))"
```

# References

- [Source](https://github.com/pdf/zfs_exporter)
