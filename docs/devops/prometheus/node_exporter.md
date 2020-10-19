---
title: Node Exporter
date: 20200624
author: Lyz
---

[Node Exporter](https://github.com/prometheus/node_exporter) is a Prometheus
exporter for hardware and OS metrics exposed by \*NIX kernels, written in Go with
pluggable metric collectors.

# Install

To install in kubernetes nodes, use [this
chart](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter).
Elsewhere use [this ansible
role](https://github.com/cloudalchemy/ansible-node-exporter).

If you use node exporter agents outside kubernetes, you need to configure
a prometheus service discovery to scrap the information from them.

To [auto discover EC2
instances](https://kbild.ch/blog/2019-02-18-awsprometheus/) use the
[ec2_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
configuration. It can be added in the helm chart values.yaml under the key
`prometheus.prometheusSpec.additionalScrapeConfigs`

```yaml
      - job_name: node_exporter
        ec2_sd_configs:
          - region: us-east-1
            port: 9100
            refresh_interval: 1m
        relabel_configs:
          - source_labels: ['__meta_ec2_tag_Name', '__meta_ec2_private_ip']
            separator: ':'
            target_label: instance
          -   source_labels:
            - __meta_ec2_instance_type
            target_label: instance_type
```

The `relabel_configs` part will substitute the `instance` label of each target
from `{{ instance_ip }}:9100` to `{{ instance_name }}:{{ instance_ip }}`.

If the worker nodes already have an IAM role with the `ec2:DescribeInstances`
permission there is no need to specify the `role_arn` or `access_keys` and
`secret_key`.

If you have stopped instances, the node exporter will raise an alert because it
won't be able to scrape the metrics from them. To only fetch data from running
instances add a filter:

```yaml
        ec2_sd_configs:
          - region: us-east-1
            filters:
            - name: instance-state-name
              values:
              - running
```

To monitor only the instances of a list of VPCs use this filter:

```yaml
        ec2_sd_configs:
          - region: us-east-1
            filters:
            - name: vpc-id
              values:
              - vpc-xxxxxxxxxxxxxxxxx
              - vpc-yyyyyyyyyyyyyyyyy
```

By default, prometheus will try to scrape the private instance ip. To use the
public one you need to relabel it with the following snippet:

```yaml

        ec2_sd_configs:
          - region: us-east-1
        relabel_configs:
          - source_labels: ['__meta_ec2_public_ip']
            regex: ^(.*)$
            target_label: __address__
            replacement: ${1}:9100
```

I'm using the [`11074`](https://grafana.com/dashboards/11074) grafana dashboards
for the blackbox exporter,  which worked straight out of the box. Taking as
reference the
[grafana](https://github.com/helm/charts/blob/master/stable/grafana/values.yaml)
helm chart values, add the following yaml under the `grafana` key in the
`prometheus-operator` `values.yaml`.

```yaml
grafana:
  enabled: true
  defaultDashboardsEnabled: true
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
  dashboards:
    default:
      node_exporter:
        # Ref: https://grafana.com/dashboards/11074
        gnetId: 11074
        revision: 4
        datasource: Prometheus
```

And install.

```bash
helmfile diff
helmfile apply
```

# [Node exporter size analysis](instance_sizing_analysis.md)

Once the instance metrics are being ingested, we can do a periodic
[analysis](instance_sizing_analysis.md) to deduce which instances are undersized
or oversized.

# [Node exporter alerts](https://awesome-prometheus-alerts.grep.to/rules)

Now that we've got the metrics, we can define the [alert
rules](alertmanager.md#alert-rules). Most have been tweaked from the [Awesome
prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules)
collection.

## Host out of memory

Node memory is filling up (`< 10%` left).

```yaml
- alert: HostOutOfMemory
  expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host out of memory (instance {{ $labels.instance }})"
    message: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host memory under memory pressure

The node is under heavy memory pressure. High rate of major page faults.

```yaml
- alert: HostMemoryUnderMemoryPressure
  expr: rate(node_vmstat_pgmajfault[1m]) > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host memory under memory pressure (instance {{ $labels.instance }})"
    message: "The node is under heavy memory pressure. High rate of major page faults."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual network throughput in

Host network interfaces are probably receiving too much data (> 100 MB/s)

```yaml
- alert: HostUnusualNetworkThroughputIn
  expr: sum by (instance) (irate(node_network_receive_bytes_total[2m])) / 1024 / 1024 > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual network throughput in (instance {{ $labels.instance }})"
    message: "Host network interfaces are probably receiving too much data (> 100 MB/s)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual network throughput out

Host network interfaces are probably sending too much data (> 100 MB/s)

```yaml
- alert: HostUnusualNetworkThroughputOut
  expr: sum by (instance) (irate(node_network_transmit_bytes_total[2m])) / 1024 / 1024 > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual network throughput out (instance {{ $labels.instance }})"
    message: "Host network interfaces are probably sending too much data (> 100 MB/s)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual disk read rate

Disk is probably reading too much data (> 50 MB/s)

```yaml
- alert: HostUnusualDiskReadRate
  expr: sum by (instance) (irate(node_disk_read_bytes_total[2m])) / 1024 / 1024 > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual disk read rate (instance {{ $labels.instance }})"
    message: "Disk is probably reading too much data (> 50 MB/s)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual disk write rate

Disk is probably writing too much data (> 50 MB/s)

```yaml
- alert: HostUnusualDiskWriteRate
  expr: sum by (instance) (irate(node_disk_written_bytes_total[2m])) / 1024 / 1024 > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual disk write rate (instance {{ $labels.instance }})"
    message: "Disk is probably writing too much data (> 50 MB/s)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host out of disk space

Disk is worryingly almost full (`< 10% left`).

```yaml
- alert: HostOutOfDiskSpace
  expr: (node_filesystem_avail_bytes{fstype!~"tmpfs"}  * 100) / node_filesystem_size_bytes{fstype!~"tmpfs"} < 10
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Host out of disk space (instance {{ $labels.instance }})"
    message: "Host disk is almost full (< 10% left)\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

Disk is almost full (`< 20% left`)

```yaml
- alert: HostReachingOutOfDiskSpace
  expr: (node_filesystem_avail_bytes{fstype!~"tmpfs"}  * 100) / node_filesystem_size_bytes{fstype!~"tmpfs"} < 20
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host reaching out of disk space (instance {{ $labels.instance }})"
    message: "Host disk is almost full (< 20% left)\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host disk will fill in 4 hours

Disk will fill in 4 hours at current write rate

```yaml
- alert: HostDiskWillFillIn4Hours
  expr: predict_linear(node_filesystem_free_bytes{fstype!~"tmpfs"}[1h], 4 * 3600) < 0
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Host disk will fill in 4 hours (instance {{ $labels.instance }})"
    message: "Disk will fill in 4 hours at current write rate\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host out of inodes

Disk is almost running out of available inodes (`< 10% left`).

```yaml
- alert: HostOutOfInodes
  expr: node_filesystem_files_free{fstype!~"tmpfs"} / node_filesystem_files{fstype!~"tmpfs"} * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host out of inodes (instance {{ $labels.instance }})"
    message: "Disk is almost running out of available inodes (< 10% left)\n VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual disk read latency

Disk latency is growing (read operations > 100ms).

```yaml
- alert: HostUnusualDiskReadLatency
  expr: rate(node_disk_read_time_seconds_total[1m]) / rate(node_disk_reads_completed_total[1m]) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual disk read latency (instance {{ $labels.instance }})"
    message: "Disk latency is growing (read operations > 100ms)\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host unusual disk write latency

Disk latency is growing (write operations > 100ms)

```yaml
- alert: HostUnusualDiskWriteLatency
  expr: rate(node_disk_write_time_seconds_total[1m]) / rate(node_disk_writes_completed_total[1m]) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host unusual disk write latency (instance {{ $labels.instance }})"
    message: "Disk latency is growing (write operations > 100ms)\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host high CPU load

CPU load is > 80%

```yaml
- alert: HostHighCpuLoad
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host high CPU load (instance {{ $labels.instance }})"
    message: "CPU load is > 80%\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host context switching

Context switching is growing on node (> 1000 / s)

```yaml
# 1000 context switches is an arbitrary number.
# Alert threshold depends on nature of application.
# Please read: https://github.com/samber/awesome-prometheus-alerts/issues/58
- alert: HostContextSwitching
  expr: (rate(node_context_switches_total[5m])) / (count without(cpu, mode) (node_cpu_seconds_total{mode="idle"})) > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host context switching (instance {{ $labels.instance }})"
    message: "Context switching is growing on node (> 1000 / s)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host swap is filling up

Swap is filling up (>80%)

```yaml
- alert: HostSwapIsFillingUp
  expr: (1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host swap is filling up (instance {{ $labels.instance }})"
    message: "Swap is filling up (>80%)\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host SystemD service crashed

SystemD service crashed

```yaml
- alert: HostSystemdServiceCrashed
  expr: node_systemd_unit_state{state="failed"} == 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host SystemD service crashed (instance {{ $labels.instance }})"
    message: "SystemD service crashed\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host physical component too hot

Physical hardware component too hot

```yaml
- alert: HostPhysicalComponentTooHot
  expr: node_hwmon_temp_celsius > 75
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host physical component too hot (instance {{ $labels.instance }})"
    message: "Physical hardware component too hot\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host node overtemperature alarm

Physical node temperature alarm triggered

```yaml
- alert: HostNodeOvertemperatureAlarm
  expr: node_hwmon_temp_alarm == 1
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Host node overtemperature alarm (instance {{ $labels.instance }})"
    message: "Physical node temperature alarm triggered\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host RAID array got inactive

RAID array `{{ $labels.device }}` is in degraded state due to one or more disks
failures. Number of spare drives is insufficient to fix issue automatically.

```yaml
- alert: HostRaidArrayGotInactive
  expr: node_md_state{state="inactive"} > 0
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Host RAID array got inactive (instance {{ $labels.instance }})"
    message: "RAID array {{ $labels.device }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically.\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host RAID disk failure

At least one device in RAID array on `{{ $labels.instance }}` failed. Array `{{
$labels.md_device }}` needs attention and possibly a disk swap.

```yaml
- alert: HostRaidDiskFailure
  expr: node_md_disks{state="fail"} > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host RAID disk failure (instance {{ $labels.instance }})"
    message: "At least one device in RAID array on {{ $labels.instance }} failed. Array {{ $labels.md_device }} needs attention and possibly a disk swap\n  VALUE = {{ $value }}."
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host kernel version deviations

Different kernel versions are running.

```yaml
- alert: HostKernelVersionDeviations
  expr: count(sum(label_replace(node_uname_info, "kernel", "$1", "release", "([0-9]+.[0-9]+.[0-9]+).*")) by (kernel)) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host kernel version deviations (instance {{ $labels.instance }})"
    message: "Different kernel versions are running\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host OOM kill detected

OOM kill detected

```yaml
- alert: HostOomKillDetected
  expr: increase(node_vmstat_oom_kill[5m]) > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host OOM kill detected (instance {{ $labels.instance }})"
    message: "OOM kill detected\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host Network Receive Errors
`{{ $labels.instance }}` interface `{{ $labels.device }}` has encountered `{{
printf "%.0f" $value }}` receive errors in the last five minutes.

```yaml
- alert: HostNetworkReceiveErrors
  expr: increase(node_network_receive_errs_total[5m]) > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host Network Receive Errors (instance {{ $labels.instance }})"
    message: "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf '%.0f' $value }} receive errors in the last five minutes.\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

## Host Network Transmit Errors
`{{ $labels.instance }}` interface `{{ $labels.device }}` has encountered `{{
printf "%.0f" $value }}` transmit errors in the last five minutes.

```yaml
- alert: HostNetworkTransmitErrors
  expr: increase(node_network_transmit_errs_total[5m]) > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Host Network Transmit Errors (instance {{ $labels.instance }})"
    message: "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf '%.0f' $value }} transmit errors in the last five minutes.\n  VALUE = {{ $value }}"
    grafana: "{{ grafana_url}}?var-job=node_exporter&var-hostname=All&var-node={{ $labels.instance }}"
```

# References

* [Git](https://github.com/prometheus/node_exporter)
* [Prometheus node exporter guide](https://prometheus.io/docs/guides/node-exporter/)
* [Node exporter alerts](https://awesome-prometheus-alerts.grep.to/rules)
