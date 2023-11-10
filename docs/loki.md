[Loki](https://grafana.com/docs/loki/latest/) is a set of components that can be composed into a fully featured logging stack.

Unlike other logging systems, Loki is built around the idea of only indexing metadata about your logs: labels (just like Prometheus labels). Log data itself is then compressed and stored in chunks in object stores such as Amazon Simple Storage Service (S3) or Google Cloud Storage (GCS), or even locally on the filesystem.

A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

# [Installation](https://grafana.com/docs/loki/latest/setup/install/docker/)

There are [many ways to install Loki](https://grafana.com/docs/loki/latest/setup/install/), we're going to do it using `docker-compose` taking [their example as a starting point](https://raw.githubusercontent.com/grafana/loki/v2.9.1/production/docker-compose.yaml) and complementing our already existent [grafana docker-compose](grafana.md#installation).

```yaml
```

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
