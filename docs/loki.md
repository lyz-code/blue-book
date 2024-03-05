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
  storage:
    type: local
    local:
      directory: /tmp/rules
  rule_path: /tmp/scratch
  alertmanager_url: http://localhost
  ring:
    kvstore:
      store: inmemory
  enable_api: true
```

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
# Usage

## [Build dashboards](https://grafana.com/blog/2020/04/08/loki-quick-tip-how-to-create-a-grafana-dashboard-for-searching-logs-using-loki-and-prometheus/)
## [Creating alerts](https://grafana.com/docs/loki/latest/alert/)

Surprisingly I haven't found any compilation of Loki alerts. I'll gather here the ones I create.

### Generic docker errors
To catch the errors shown in docker (assuming you're using my same [promtail configuration](promtail.md#scrape-docker-logs)) you can use the next rule (that needs to go into your Loki configuration).
# References

- [Docs](https://grafana.com/docs/loki/latest/)
