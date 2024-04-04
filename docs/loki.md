[Loki](https://grafana.com/docs/loki/latest/) is a set of components that can be composed into a fully featured logging stack.

Unlike other logging systems, Loki is built around the idea of only indexing metadata about your logs: labels (just like Prometheus labels). Log data itself is then compressed and stored in chunks in object stores such as Amazon Simple Storage Service (S3) or Google Cloud Storage (GCS), or even locally on the filesystem.

A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

# [Installation](https://grafana.com/docs/loki/latest/setup/install/docker/)

There are [many ways to install Loki](https://grafana.com/docs/loki/latest/setup/install/), we're going to do it using `docker-compose` taking [their example as a starting point](https://raw.githubusercontent.com/grafana/loki/v2.9.1/production/docker-compose.yaml) and complementing our already existent [grafana docker-compose](grafana.md#installation). It uses [the official loki docker](https://hub.docker.com/r/grafana/loki)

## Set up the docker compose

Save the next docker compose at `/data/grafana` or wherever you want:

```yaml
---
version: "3.3"
services:
  grafana:
    image: grafana/grafana-oss:${GRAFANA_VERSION:-latest}
    container_name: grafana
    restart: unless-stopped
    volumes:
      - grafana-config:/etc/grafana
      - grafana-data:/var/lib/grafana
    networks:
      - grafana
      - swag
    env_file:
      - .env
    depends_on:
      - db
  db:
    image: postgres:${DATABASE_VERSION:-15}
    restart: unless-stopped
    container_name: grafana-db
    environment:
      - POSTGRES_DB=${GF_DATABASE_NAME:-grafana}
      - POSTGRES_USER=${GF_DATABASE_USER:-grafana}
      - POSTGRES_PASSWORD=${GF_DATABASE_PASSWORD:?database password required}
    networks:
      - grafana
    volumes:
      - db-data:/var/lib/postgresql/data
    env_file:
      - .env

  loki:
    image: grafana/loki:${LOKI_VERSION:-latest}
    container_name: loki
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml -print-config-stderr
    volumes:
      - loki-data:/loki
    networks:
      - grafana
      - loki
    env_file:
      - .env

  promtail:
    image: grafana/promtail:${PROMTAIL_VERSION:-latest}
    container_name: promtail
    volumes:
      - /var/log:/var/log
    command: -config.file=/etc/promtail/config.yml
    networks:
      - loki
    env_file:
      - .env
networks:
  grafana:
    external:
      name: grafana
  swag:
    external:
      name: swag
  loki:
    external:
      name: loki

volumes:
  grafana-config:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/app/config
  grafana-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/app/data
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/database
  loki-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/loki/data
```
Define the `.env` file similar to:

```env

# Check all configuration options at:
# https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana

# -----------------------------
# --- General configuration ---
# -----------------------------
GRAFANA_VERSION=latest
GF_DEFAULT_INSTANCE_NAME="production"
GF_SERVER_ROOT_URL="https://production.your-domain.org"

# Set this option to true to enable HTTP compression, this can improve transfer
# speed and bandwidth utilization. It is recommended that most users set it to
# true. By default it is set to false for compatibility reasons.
GF_SERVER_ENABLE_GZIP="true"

# ------------------------------
# --- Database configuration ---
# ------------------------------

DATABASE_VERSION=15
GF_DATABASE_TYPE=postgres
GF_DATABASE_HOST=grafana-db:5432
GF_DATABASE_NAME=grafana
GF_DATABASE_USER=grafana
GF_DATABASE_PASSWORD="your-super-secret-password"
GF_DATABASE_SSL_MODE=disable
GF_DATABASE_LOG_QUERIES="false"

# --------------------------
# --- Loki configuration ---
# --------------------------

LOKI_VERSION=latest

# ------------------------------
# --- Promtail configuration ---
# ------------------------------

PROMTAIL_VERSION=latest
```
## Configure Loki

Download and edit [the basic configuration](https://grafana.com/docs/loki/latest/setup/install/docker/)

```bash
wget https://raw.githubusercontent.com/grafana/loki/v2.9.1/cmd/loki/loki-local-config.yaml -O /data/loki/config/loki-config.yaml
```
### Prevent the [too many outstanding requests error](https://github.com/grafana/loki/issues/5123)

Add to your loki config the next options
```yaml

limits_config:
  split_queries_by_interval: 24h
  max_query_parallelism: 100

query_scheduler:
  max_outstanding_requests_per_tenant: 4096

frontend: 
  max_outstanding_per_tenant: 4096
```

## Configure Promtail

Check the [promtail](promtail.md) document.

## Configure Grafana

It makes use of the [environment variables to configure Loki](https://grafana.com/docs/loki/latest/configure/#configuration-file-reference), that's why we have the `-config.expand-env=true` flag in the command line launch.

In the grafana datasources directory add `loki.yaml`:

```yaml
---
apiVersion: 1

datasources:
  - name: Loki
    type: loki
    access: proxy
    orgId: 1
    url: http://loki:3100
    basicAuth: false
    isDefault: true
    version: 1
    editable: false
```

## [Storage configuration](https://grafana.com/docs/loki/latest/storage/)

Unlike other logging systems, Grafana Loki is built around the idea of only indexing metadata about your logs: labels (just like Prometheus labels). Log data itself is then compressed and stored in chunks in object stores such as S3 or GCS, or even locally on the filesystem. A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

Loki 2.0 brings an index mechanism named ‘boltdb-shipper’ and is what we now call Single Store. This type only requires one store, the object store, for both the index and chunks.

Loki 2.8 adds TSDB as a new mode for the Single Store and is now the recommended way to persist data in Loki as it improves query performance, reduces TCO and has the same feature parity as “boltdb-shipper”.

## [Configure alerts and rules](https://grafana.com/docs/loki/latest/alert/)

Grafana Loki includes a component called the ruler. The ruler is responsible for continually evaluating a set of configurable queries and performing an action based on the result.

This example configuration sources rules from a local disk.

```yaml 
ruler:
  alertmanager_url: http://alertmanager:9093
  storage:
    type: local
    local:
      directory: /etc/loki/rules
  rule_path: /tmp/rules
  ring:
    kvstore:
      store: inmemory
  enable_api: true
  enable_alertmanager_v2: true
```

If you only have one Loki instance you need to save the rule yaml files in the `/etc/loki/rules/fake/` otherwise Loki will silently ignore them (it took me a lot of time to figure this out `-.-`).

Surprisingly I haven't found any compilation of Loki alerts. I'll gather here the ones I create.

There are two kinds of rules: alerting rules and recording rules. 

### Alerting rules

Alerting rules allow you to define alert conditions based on LogQL expression language expressions and to send notifications about firing alerts to an external service.

A complete example of a rules file:

```yaml 
groups:
  - name: should_fire
    rules:
      - alert: HighPercentageError
        expr: |
          sum(rate({app="foo", env="production"} |= "error" [5m])) by (job)
            /
          sum(rate({app="foo", env="production"}[5m])) by (job)
            > 0.05
        for: 10m
        labels:
            severity: page
        annotations:
            summary: High request latency
  - name: credentials_leak
    rules: 
      - alert: http-credentials-leaked
        annotations: 
          message: "{{ $labels.job }} is leaking http basic auth credentials."
        expr: 'sum by (cluster, job, pod) (count_over_time({namespace="prod"} |~ "http(s?)://(\\w+):(\\w+)@" [5m]) > 0)'
        for: 10m
        labels: 
          severity: critical
```
More examples of alert rules can be found in the next articles:

- [ECC error alerts](rasdaemon.md#monitorization)
- [ZFS errors](zfs.md#zfs-pool-is-stuck)
- [Sanoid errors](sanoid.md#monitorization)

#### Alert when query returns no data

Sometimes the queries you want to alert happen when the return value is NaN or No Data. For example if you want to monitory the happy path by setting an alert if a string is not found in some logs in a period of time.

```logql
count_over_time({filename="/var/log/mail.log"} |= `Mail is sent` [24h]) < 1
```

This won't trigger the alert because the `count_over_time` doesn't return a `0` but a `NaN`. One way to solve it is to use [the `vector(0)`](https://github.com/grafana/loki/pull/7023) operator with [the operation `or on() vector(0)`](https://stackoverflow.com/questions/76489956/how-to-return-a-zero-vector-in-loki-logql-metric-query-when-grouping-is-used-and)
```logql
(count_over_time({filename="/var/log/mail.log"} |= `Mail is sent` [24h]) or on() vector(0)) < 1
```
### Recording rules
Recording rules allow you to precompute frequently needed or computationally expensive expressions and save their result as a new set of time series.

Querying the precomputed result will then often be much faster than executing the original expression every time it is needed. This is especially useful for dashboards, which need to query the same expression repeatedly every time they refresh.


Loki allows you to run metric queries over your logs, which means that you can derive a numeric aggregation from your logs, like calculating the number of requests over time from your NGINX access log.

```yaml 
name: NginxRules
interval: 1m
rules:
  - record: nginx:requests:rate1m
    expr: |
      sum(
        rate({container="nginx"}[1m])
      )
    labels:
      cluster: "us-central1"
```
This query (`expr`) will be executed every 1 minute (`interval`), the result of which will be stored in the metric name we have defined (`record`). This metric named `nginx:requests:rate1m` can now be sent to Prometheus, where it will be stored just like any other metric.

Here is an example remote-write configuration for sending to a local Prometheus instance:

```yaml 
ruler:
  ... other settings ...
  
  remote_write:
    enabled: true
    client:
      url: http://localhost:9090/api/v1/write
```
## [Build dashboards](https://grafana.com/blog/2020/04/08/loki-quick-tip-how-to-create-a-grafana-dashboard-for-searching-logs-using-loki-and-prometheus/)
# Monitoring
## Monitor loki metrics
Since Loki reuses the Prometheus code for recording rules and WALs, it also gains all of Prometheus’ observability.

To scrape loki metrics with prometheus add the next snippet to the prometheus configuration:

```yaml
  - job_name: loki
    metrics_path: /metrics
    static_configs:
    - targets:
      - loki:3100
```

This assumes that `loki` is a docker in the same network as `prometheus`.

There are some rules in the [awesome prometheus alerts repo](https://samber.github.io/awesome-prometheus-alerts/rules#loki)

```yaml 
---
groups:
- name: Awesome Prometheus loki alert rules
  # https://samber.github.io/awesome-prometheus-alerts/rules#loki
  rules:
  - alert: LokiProcessTooManyRestarts
    expr: changes(process_start_time_seconds{job=~".*loki.*"}[15m]) > 2
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: Loki process too many restarts (instance {{ $labels.instance }})
      description: "A loki process had too many restarts (target {{ $labels.instance }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: LokiRequestErrors
    expr: 100 * sum(rate(loki_request_duration_seconds_count{status_code=~"5.."}[1m])) by (namespace, job, route) / sum(rate(loki_request_duration_seconds_count[1m])) by (namespace, job, route) > 10
    for: 15m
    labels:
      severity: critical
    annotations:
      summary: Loki request errors (instance {{ $labels.instance }})
      description: "The {{ $labels.job }} and {{ $labels.route }} are experiencing errors\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: LokiRequestPanic
    expr: sum(increase(loki_panic_total[10m])) by (namespace, job) > 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: Loki request panic (instance {{ $labels.instance }})
      description: "The {{ $labels.job }} is experiencing {{ printf \"%.2f\" $value }}% increase of panics\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  - alert: LokiRequestLatency
    expr: (histogram_quantile(0.99, sum(rate(loki_request_duration_seconds_bucket{route!~"(?i).*tail.*"}[5m])) by (le)))  > 1
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: Loki request latency (instance {{ $labels.instance }})
      description: "The {{ $labels.job }} {{ $labels.route }} is experiencing {{ printf \"%.2f\" $value }}s 99th percentile latency\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```

And there are some guidelines on the rest of the metrics in [the grafana documentation](https://grafana.com/docs/loki/latest/operations/observability/)

## [Monitor the ruler](https://grafana.com/docs/loki/latest/operations/recording-rules/)

Prometheus exposes a number of metrics for its WAL implementation, and these have all been prefixed with `loki_ruler_wal_`.

For example: `prometheus_remote_storage_bytes_total` → `loki_ruler_wal_prometheus_remote_storage_bytes_total`

Additional metrics are exposed, also with the prefix `loki_ruler_wal_`. All per-tenant metrics contain a tenant label, so be aware that cardinality could begin to be a concern if the number of tenants grows sufficiently large.

Some key metrics to note are:

- `loki_ruler_wal_appender_ready`: whether a WAL appender is ready to accept samples (1) or not (0)
- `loki_ruler_wal_prometheus_remote_storage_samples_total`: number of samples sent per tenant to remote storage
- `loki_ruler_wal_prometheus_remote_storage_samples_pending_total`: samples buffered in memory, waiting to be sent to remote storage
- `loki_ruler_wal_prometheus_remote_storage_samples_failed_total`: samples that failed when sent to remote storage
- `loki_ruler_wal_prometheus_remote_storage_samples_dropped_total`: samples dropped by relabel configurations
- `loki_ruler_wal_prometheus_remote_storage_samples_retried_total`: samples re-resent to remote storage
- `loki_ruler_wal_prometheus_remote_storage_highest_timestamp_in_seconds`: highest timestamp of sample appended to WAL

# Troubleshooting
- `loki_ruler_wal_prometheus_remote_storage_queue_highest_sent_timestamp_seconds`: highest timestamp of sample sent to remote storage.

# Things that don't still work
## [Get a useful Source link in the alertmanager](https://github.com/grafana/loki/issues/4722)
Currently for the ruler `external_url` if you use the URL of your Grafana installation: e.g. `external_url: "https://grafana.example.com"` it creates a Source link in alertmanager similar to https://grafana.example.com/graph?g0.expr=%28sum+by%28thing%29%28count_over_time%28%7Bnamespace%3D%22foo%22%7D+%7C+json+%7C+bar%3D%22maxRetries%22%5B5m%5D%29%29+%3E+0%29&g0.tab=1, which isn't valid.

This url templating (via `/graph?g0.expr=%s&g0.tab=1`) appears to be coming from prometheus. There is not a workaround yet
# References
[This stackoverflow answer](https://stackoverflow.com/questions/74329564/how-configure-recording-and-alerting-rules-with-loki) has some insights on how to debug broken loki rules

- [Docs](https://grafana.com/docs/loki/latest/)
- [Source](https://github.com/grafana/loki)

[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
