# Promtail

[Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) is an agent which ships the contents of local logs to a [Loki](loki.md) instance.

It is usually deployed to every machine that runs applications which need to be monitored.

It primarily:

    Discovers targets
    Attaches labels to log streams
    Pushes them to the Loki instance.

# Installation
Use [patrickjahns ansible role](https://github.com/patrickjahns/ansible-role-promtail). Some interesting variables are:

```yaml
loki_url: localhost
promtail_system_user: root

promtail_config_clients:
  - url: "http://{{ loki_url }}:3100/loki/api/v1/push"
    external_labels:
      hostname: "{{ ansible_hostname }}"
```
# [Configuration](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/)

Promtail is configured in a YAML file (usually referred to as config.yaml) which contains information on the Promtail server, where positions are stored, and how to scrape logs from files.

To see the configuration that is being loaded at promtail use one of the next flags:

- `-print-config-stderr` is nice when running Promtail directly e.g. ./promtail as you can get a quick output of the entire Promtail config.

- `-log-config-reverse-order` is the flag we run Promtail with in all our environments, the config entries are reversed so that the order of configs reads correctly top to bottom when viewed in Grafana’s Explore.


You can start from [this basic configuration](https://grafana.com/docs/loki/latest/setup/install/docker/)

```bash
wget https://raw.githubusercontent.com/grafana/loki/v2.9.1/clients/cmd/promtail/promtail-docker-config.yaml -O /data/promtail/promtail-config.yaml
```

## [Scraping configs](https://grafana.com/docs/loki/latest/send-data/promtail/scraping/)

Promtail borrows the same [service discovery mechanism from Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config). `promtail` is configured using a `scrape_configs` stanza. `relabel_configs` allows for fine-grained control of what to ingest, what to drop, and the final metadata to attach to the log line. 

Once Promtail has a set of targets (i.e., things to read from, like files) and all labels are set correctly, it will start tailing (continuously reading) the logs from targets. Once enough data is read into memory or after a configurable timeout, it is flushed as a single batch to Loki.

As Promtail reads data from sources (files and systemd journal, if configured), it will track the last offset it read in a positions file. By default, the positions file is stored at `/var/log/positions.yaml`. The positions file helps Promtail continue reading from where it left off in the case of the Promtail instance restarting.

### [The file target discovery](https://grafana.com/docs/loki/latest/send-data/promtail/scraping/#file-target-discovery)

Promtail discovers locations of log files and extract labels from them through the `scrape_configs` section in the config YAML.

If you're going to use `journald` for your logs you can skip this section.

```yaml
scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
```

### [Scrape journald logs](https://grafana.com/docs/loki/latest/send-data/promtail/scraping/#journal-scraping-linux-only)

On systems with `systemd`, Promtail also supports reading from the journal. Unlike file scraping which is defined in the `static_configs` stanza, journal scraping is defined in a `journal` stanza:

```yaml
scrape_configs:
  - job_name: journal
    journal:
      json: false
      max_age: 12h
      path: /var/log/journal
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: unit
      - source_labels: ['__journal__hostname']
        target_label: hostname
      - source_labels: ['__journal_syslog_identifier']
        target_label: syslog_identifier
      - source_labels: ['__journal_transport']
        target_label: transport
      - source_labels: ['__journal_priority_keyword']
        target_label: keyword
```

All fields defined in the journal section are optional, and are just provided here for reference. 

- `max_age` ensures that no older entry than the time specified will be sent to Loki; this circumvents `entry too old` errors. 
- `path` tells Promtail where to read journal entries from. 
- `labels` map defines a constant list of labels to add to every journal entry that Promtail reads.
- `matches` field adds journal filters. If multiple filters are specified matching different fields, the log entries are filtered by both, if two filters apply to the same field, then they are automatically matched as alternatives.
- When the `json` field is set to true, messages from the journal will be passed through the pipeline as JSON, keeping all of the original fields from the journal entry. This is useful when you don’t want to index some fields but you still want to know what values they contained.
- When Promtail reads from the journal, it brings in all fields prefixed with `__journal_` as internal labels. Like in the example above, the `_SYSTEMD_UNIT` field from the journal was transformed into a label called `unit` through `relabel_configs`. Keep in mind that labels prefixed with `__` will be dropped, so relabeling is required to keep these labels. Look at the [systemd man pages](https://www.freedesktop.org/software/systemd/man/latest/systemd.journal-fields.html) for a list of fields exposed by the journal.

By default, Promtail reads from the journal by looking in the `/var/log/journal` and `/run/log/journal` paths. If running Promtail inside of a Docker container, the path appropriate to your distribution should be bind mounted inside of Promtail along with binding `/etc/machine-id`. Bind mounting `/etc/machine-id` to the path of the same name is required for the journal reader to know which specific journal to read from.

```bash
docker run \
  -v /var/log/journal/:/var/log/journal/ \
  -v /run/log/journal/:/run/log/journal/ \
  -v /etc/machine-id:/etc/machine-id \
  grafana/promtail:latest \
  -config.file=/path/to/config/file.yaml
```

### [Scrape docker logs](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#docker_sd_config)

Docker service discovery allows retrieving targets from a Docker daemon. It will only watch containers of the Docker daemon referenced with the host parameter. Docker service discovery should run on each node in a distributed setup. The containers must run with either the `json-file` or `journald` logging driver.

Note that the discovery will not pick up finished containers. That means Promtail will not scrape the remaining logs from finished containers after a restart.

```yaml
scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
    pipeline_stages:
      - static_labels:
          job: docker
```
The available meta labels are:

- `__meta_docker_container_id`: the ID of the container
- `__meta_docker_container_name`: the name of the container
- `__meta_docker_container_network_mode`: the network mode of the container
- `__meta_docker_container_label_<labelname>`: each label of the container
- `__meta_docker_container_log_stream`: the log stream type stdout or stderr
- `__meta_docker_network_id`: the ID of the network
- `__meta_docker_network_name`: the name of the network
- `__meta_docker_network_ingress`: whether the network is ingress
- `__meta_docker_network_internal`: whether the network is internal
- `__meta_docker_network_label_<labelname>`: each label of the network
- `__meta_docker_network_scope`: the scope of the network
- `__meta_docker_network_ip`: the IP of the container in this network
- `__meta_docker_port_private`: the port on the container
- `__meta_docker_port_public`: the external port if a port-mapping exists
- `__meta_docker_port_public_ip`: the public IP if a port-mapping exists

If you've set some systemd services that run docker-compose it's a good idea not to ingest them with promtail so as not to have duplicate log lines:

```yaml 
scrape_configs:
  - job_name: journal
    journal:
      json: false
      max_age: 12h
      path: /var/log/journal
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: unit
      - source_labels: ['__journal__hostname']
        target_label: hostname
      - source_labels: ['__journal_syslog_identifier']
        target_label: syslog_identifier
      - source_labels: ['__journal_transport']
        target_label: transport
      - source_labels: ['__journal_priority_keyword']
        target_label: level
    pipeline_stages:
      - drop:
          source: syslog_identifier
          value: docker-compose
```
#### Fetch only some docker logs

The labels can be used during relabeling. For instance, the following configuration scrapes the container named `flog` and removes the leading slash (/) from the container name.
yaml

```yaml
scrape_configs:
  - job_name: flog_scrape
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
        filters:
          - name: name
            values: [flog]
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
```
## Set the hostname label on all logs

There are many ways to do it:

- [Setting the label in the promtail launch command](https://community.grafana.com/t/how-to-add-variable-hostname-label-to-static-config-in-promtail/68352/11)
  ```bash
  sudo ./promtail-linux-amd64 --client.url=http://xxxx:3100/loki/api/v1/push --client.external-labels=hostname=$(hostname) --config.file=./config.yaml
    ```

  This won't work if you're using promtail within a docker-compose because you can't use bash expansion in the `docker-compose.yaml` file
- [Allowing env expansion and setting it in the promtail conf](https://github.com/grafana/loki/issues/634). You can launch the promtail command with `-config.expand-env` and then set in each scrape jobs:
  ```yaml 
  labels:
      host: ${HOSTNAME}
  ```
  This won't work either if you're using `promtail` within a docker as it will give you the ID of the docker
- Set it in the `promtail_config_clients` field as `external_labels` of each promtail config:
  ```yaml
  promtail_config_clients:
    - url: "http://{{ loki_url }}:3100/loki/api/v1/push"
      external_labels:
        hostname: "{{ ansible_hostname }}"
  ```
- Hardcode it for each promtail config scraping config as static labels. If you're using ansible or any deployment method that supports jinja expansion set it that way
  ```yaml 
  labels:
      host: {{ ansible_hostname }}
  ```
## Monitorization
Promtail exposes prometheus metrics on port 80 [under the `/metrics` endpoint](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#metrics) if you're using docker or 9080 if you're using the program directly. The most interesting [metrics are](https://grafana.com/docs/loki/latest/operations/observability/):

- `promtail_read_bytes_total`(Gauge): Number of bytes read.
- `promtail_read_lines_total`(Counter): Number of lines read.
- `promtail_dropped_bytes_total`(Counter): Number of bytes dropped because failed to be sent to the ingester after all retries.
- `promtail_dropped_entries_total`(Counter): Number of log entries dropped because failed to be sent to the ingester after all retries.
- `promtail_encoded_bytes_total`(Counter): Number of bytes encoded and ready to send.
- `promtail_file_bytes_total`(Gauge): Number of bytes read from files.
- `promtail_files_active_total`(Gauge): Number of active files.
- `promtail_request_duration_seconds`(Histogram): Number of send requests.
- `promtail_sent_bytes_total`(Counter): Number of bytes sent.
- `promtail_sent_entries_total`(Counter): Number of log entries sent to the ingester.
- `promtail_targets_active_total`(Gauge): Number of total active targets.
- `promtail_targets_failed_total`(Counter): Number of total failed targets.

Once you add the target on prometheus you'll be able to monitor if the service is down. Other alerts can be:

### Monitor errors when sending logs
You can monitor this either through loki or prometheus. I feel that using loki may give you more insights. Then you can monitor it either on the promtail logs or the loki logs. After checking the traces on both sides I feel that the labels of the promtail one are cleaner.

```yaml

```
# Pipeline building

In [this issue](https://github.com/grafana/loki/issues/6165) there are nice examples on different pipelines.

## [Drop logs](https://grafana.com/docs/loki/latest/send-data/promtail/stages/drop/)

If you don't want the logs that have the keyword `systemd-journal` and value `docker-compose` you can add the next pipeline stage:

```yaml
pipeline_stages:
  - drop:
      source: syslog_identifier
      value: docker-compose
```
# Basic concepts
## API

Promtail features an embedded web server exposing a web console at `/` and the following API endpoints:

- GET `/ready`: This endpoint returns 200 when Promtail is up and running, and there’s at least one working target.
- GET `/metrics`: This endpoint returns Promtail metrics for Prometheus. 
# [Troubleshooting](https://grafana.com/docs/loki/latest/send-data/promtail/troubleshooting/)

Find where is the `positions.yaml` file and see if it evolves. 

Sometimes if you are not seeing the logs in loki it's because the query you're running is not correct.

## [Entry too far behind, oldest acceptable timestamp]
# References

- [Docs](https://grafana.com/docs/loki/latest/send-data/promtail/)

