---
title: Blackbox Exporter
date: 20200218
author: Lyz
---

The [elasticsearch exporter](https://github.com/prometheus-community/elasticsearch_exporter) allows
monitoring [Elasticsearch](elasticsearch.md) clusters with [Prometheus](prometheus.md).

# Installation

To install the exporter we'll use [helmfile](helmfile.md) to install the
[prometheus-elasticsearch-exporter
chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-elasticsearch-exporter).

Add the following lines to your `helmfile.yaml`.

```yaml
- name: prometheus-elasticsearch-exporter
  namespace: monitoring
  chart: prometheus-community/prometheus-elasticsearch-exporter
  values:
    - prometheus-elasticsearch-exporter/values.yaml
```

Edit the chart values.
```bash
mkdir prometheus-elasticsearch-exporter
helm inspect values prometheus-community/prometheus-elasticsearch-exporter > prometheus-elasticsearch-exporter/values.yaml
vi prometheus-elasticsearch-exporter/values.yaml
```

Comment out all the values you don't edit, so that the chart doesn't break when
you upgrade it.

Make sure that the `serviceMonitor` labels [match your Prometheus
`serviceMonitorSelector`](prometheus_troubleshooting.md#service-monitor-not-being-recognized)
otherwise they won't be added to the configuration.

```yaml
es:
  ## Address (host and port) of the Elasticsearch node we should connect to.
  ## This could be a local node (localhost:9200, for instance), or the address
  ## of a remote Elasticsearch server. When basic auth is needed,
  ## specify as: <proto>://<user>:<password>@<host>:<port>. e.g., http://admin:pass@localhost:9200.
  ##
  uri: http://localhost:9200

serviceMonitor:
  ## If true, a ServiceMonitor CRD is created for a prometheus operator
  ## https://github.com/coreos/prometheus-operator
  ##
  enabled: true
  #  namespace: monitoring
  labels:
    release: prometheus-operator
  interval: 30s
  # scrapeTimeout: 10s
  # scheme: http
  # relabelings: []
  # targetLabels: []
  metricRelabelings:
    - sourceLabels: [cluster]
      targetLabel: cluster_name
      regex: '.*:(.*)'
  # sampleLimit: 0
```

You can build the `cluster` label following [this
instructions](https://github.com/prometheus-community/elasticsearch_exporter#alerts--recording-rules),
I didn't find the required meta tags, so I've built the `cluster_name` label for
alerting purposes.

The grafana dashboard I chose is [`2322`](https://grafana.com/dashboards/2322). Taking as reference
the
[grafana](https://github.com/helm/charts/blob/master/stable/grafana/values.yaml)
helm chart values, add the next yaml under the `grafana` key in the
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
      elasticsearch:
        # Ref: https://grafana.com/dashboards/2322
        gnetId: 2322
        revision: 4
        datasource: Prometheus
```

And install.

```bash
helmfile diff
helmfile apply
```

# Elasticsearch exporter alerts

Now that we've got the metrics, we can define the [alert
rules](alertmanager.md#alert-rules). Most have been tweaked from the [Awesome
prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules)
collection.

## Availability alerts

The most basic probes, test if the service is healthy

```yaml
- alert: ElasticsearchClusterRed
  expr: elasticsearch_cluster_health_status{color="red"} == 1
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Cluster Red
      (cluster {{ $labels.cluster_name }})
    description: |
      Elastic Cluster Red status
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchClusterYellow
  expr: elasticsearch_cluster_health_status{color="yellow"} == 1
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch Cluster Yellow
      (cluster {{ $labels.cluster_name }})
    description: |
      Elastic Cluster Yellow status
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchHealthyNodes
  expr: elasticsearch_cluster_health_number_of_nodes < 3
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Healthy Nodes
      (cluster {{ $labels.cluster_name }})
    description: |
      Missing node in Elasticsearch cluster
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchHealthyMasterNodes
  expr: >
    elasticsearch_cluster_health_number_of_nodes
    - elasticsearch_cluster_health_number_of_data_nodes > 0 < 3
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Healthy Master Nodes < 3
      (cluster {{ $labels.cluster_name }})
    description: |
      Missing master node in Elasticsearch cluster
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchHealthyDataNodes
  expr: elasticsearch_cluster_health_number_of_data_nodes < 3
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Healthy Data Nodes
      (cluster {{ $labels.cluster_name }})
    description: |
      Missing data node in Elasticsearch cluster
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
```

## Performance alerts

```yaml
- alert: ElasticsearchCPUUsageTooHigh
  expr: elasticsearch_os_cpu_percent > 90
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Node CPU Usage Too High
      (cluster {{ $labels.cluster_name }} node {{ $labels.name }})
    description: |
      The CPU usage of node {{ $labels.name }} is over 90%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchCPUUsageWarning
  expr: elasticsearch_os_cpu_percent > 80
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch Node CPU Usage Too High
      (cluster {{ $labels.cluster_name }} node {{ $labels.name }})
    description: |
      The CPU usage of node {{ $labels.name }} is over 90%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchHeapUsageTooHigh
  expr: >
    (
      elasticsearch_jvm_memory_used_bytes{area="heap"}
      / elasticsearch_jvm_memory_max_bytes{area="heap"}
    ) * 100 > 90
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch Node Heap Usage Critical
      (cluster {{ $labels.cluster_name }} node {{ $labels.name }})
    description: |
      The heap usage of node {{ $labels.name }} is over 90%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchHeapUsageWarning
  expr: >
    (
      elasticsearch_jvm_memory_used_bytes{area="heap"}
      / elasticsearch_jvm_memory_max_bytes{area="heap"}
    ) * 100 > 80
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch Node Heap Usage Warning
      (cluster {{ $labels.cluster_name }} node {{ $labels.name }})
    description: |
      The heap usage of node {{ $labels.name }} is over 80%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchDiskOutOfSpace
  expr: >
    elasticsearch_filesystem_data_available_bytes
    / elasticsearch_filesystem_data_size_bytes * 100 < 10
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch disk out of space
      (cluster {{ $labels.cluster_name }})
    description: |
      The disk usage is over 90%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchDiskSpaceLow
  expr: >
    elasticsearch_filesystem_data_available_bytes
    / elasticsearch_filesystem_data_size_bytes * 100 < 20
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch disk space low
      (cluster {{ $labels.cluster_name }})
    description: |
      The disk usage is over 80%
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchRelocatingShardsTooLong
  expr: elasticsearch_cluster_health_relocating_shards > 0
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch relocating shards too long
      (cluster {{ $labels.cluster_name }})
    description: |
      Elasticsearch has been relocating shards for 15min
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchInitializingShardsTooLong
  expr: elasticsearch_cluster_health_initializing_shards > 0
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch initializing shards too long
      (cluster_name {{ $labels.cluster }})
    description: |
      Elasticsearch has been initializing shards for 15 min
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchUnassignedShards
  expr: elasticsearch_cluster_health_unassigned_shards > 0
  for: 0m
  labels:
    severity: critical
  annotations:
    summary: >
      Elasticsearch unassigned shards
      (cluster {{ $labels.cluster_name }})
    description: |
      Elasticsearch has unassigned shards
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchPendingTasks
  expr: elasticsearch_cluster_health_number_of_pending_tasks > 0
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch pending tasks
      (cluster {{ $labels.cluster_name }})
    description: |
      Elasticsearch has pending tasks. Cluster works slowly.
      VALUE = {{ $value }}
      LABELS = {{ $labels }}

- alert: ElasticsearchCountOfJVMGarbageCollectorRuns
  expr: rate(elasticsearch_jvm_gc_collection_seconds_count{}[5m]) > 5
  for: 1m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch JVM Garbage Collector runs > 5
      (cluster {{ $labels.cluster_name }})
    description: |
      Elastic Cluster JVM Garbage Collector runs > 5
      VALUE = {{ $value }}
      LABELS = {{ $labels }}

- alert: ElasticsearchCountOfJVMGarbageCollectorTime
  expr: rate(elasticsearch_jvm_gc_collection_seconds_sum[5m]) > 0.3
  for: 1m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch JVM Garbage Collector time > 0.3
      (cluster {{ $labels.cluster_name }})
    description: |
      Elastic Cluster JVM Garbage Collector runs > 0.3
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchJSONParseErrors
  expr: elasticsearch_cluster_health_json_parse_failures > 0
  for: 1m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch json parse error
      (cluster {{ $labels.cluster_name }})
    description: |
      Elasticsearch json parse error
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
- alert: ElasticsearchCircuitBreakerTripped
  expr: rate(elasticsearch_breakers_tripped{}[5m])>0
  for: 1m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch breaker {{ $labels.breaker }} tripped
      (cluster {{ $labels.cluster_name }}, node {{ $labels.name }})
    description: |
      Elasticsearch breaker {{ $labels.breaker }} tripped
      (cluster {{ $labels.cluster_name }}, node {{ $labels.name }})
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
```

## Snapshot alerts

```yaml
- alert: ElasticsearchMonthlySnapshot
  expr: >
    time() -
    elasticsearch_snapshot_stats_snapshot_end_time_timestamp{state="SUCCESS"}
    > (3600 * 24 * 32)
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch monthly snapshot failed
      (cluster {{ $labels.cluster_name }},
      snapshot {{ $labels.repository }})
    description: |
      Last successful elasticsearch snapshot
      of repository {{ $labels.repository}} is older than 32 days.
      VALUE = {{ $value }}
      LABELS = {{ $labels }}

- record: elasticsearch_indices_search_latency:rate1m
  expr: |
    increase(elasticsearch_indices_search_query_time_seconds[1m])/
    increase(elasticsearch_indices_search_query_total[1m])
- record: elasticsearch_indices_search_rate:rate1m
  expr: increase(elasticsearch_indices_search_query_total[1m])/60
- alert: ElasticsearchSlowSearchLatency
  expr: elasticsearch_indices_search_latency:rate1m > 1
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: >
      Elasticsearch search latency is greater than 1 s
      (cluster {{ $labels.cluster_name }}, node {{ $labels.name }})
    description: |
      Elasticsearch search latency is greater than 1 s
      (cluster {{ $labels.cluster_name }}, node {{ $labels.name }})
      VALUE = {{ $value }}
      LABELS = {{ $labels }}
```

# Links

* [Git](https://github.com/prometheus-community/elasticsearch_exporter)
