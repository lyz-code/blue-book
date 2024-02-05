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

# Usage

## [Build dashboards](https://grafana.com/blog/2020/04/08/loki-quick-tip-how-to-create-a-grafana-dashboard-for-searching-logs-using-loki-and-prometheus/)

# References

- [Docs](https://grafana.com/docs/loki/latest/)
