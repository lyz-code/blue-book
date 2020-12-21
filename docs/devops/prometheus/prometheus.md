---
title: Prometheus
date: 20200211
author: Lyz
---

[Prometheus](https://en.wikipedia.org/wiki/Prometheus_%28software%29) is a free
software application used for event monitoring and alerting. It records
real-time metrics in a time series database (allowing for high dimensionality)
built using a HTTP pull model, with flexible queries and real-time
alerting. The project is written in Go and licensed under the Apache
2 License, with source code available on GitHub, and is a graduated project
of the Cloud Native Computing Foundation, along with Kubernetes and Envoy.

<p align="center">
    <img src="/blue-book/images/prometheus_logo.png">
</p>


A quick overview of Prometheus would be, as stated in the [coreos article](https://coreos.com/blog/coreos-and-prometheus-improve-cluster-monitoring.html):

> At the core of the Prometheus monitoring system is the main server, which
> ingests samples from monitoring targets. A target is any application that
> exposes metrics according to the open specification understood by Prometheus.
> Since Prometheus pulls data, rather than expecting targets to actively push
> stats into the monitoring system, it supports a variety of service discovery
> integrations, like that with Kubernetes, to immediately adapt to changes in
> the set of targets.

> The second core component is the Alertmanager, implementing the idea of time
> series based alerting. It intelligently removes duplicate alerts sent by
> Prometheus servers, groups the alerts into informative notifications, and
> dispatches them to a variety of integrations, like those with PagerDuty and
> Slack. It also handles silencing of selected alerts and advanced routing
> configurations for notifications.

> There are several additional Prometheus components, such as client libraries
> for different programming languages, and a growing number of exporters.
> Exporters are small programs that provide Prometheus compatible metrics from
> systems that are not natively instrumented.

Go to the [Prometheus architecture post](prometheus_architecture.md) for more details.

We are living a shift to the DevOps culture, containers and Kubernetes. So
nowadays:

* Developers need to integrate app and business related metrics as an organic
  part of the infrastructure. So monitoring needs to be democratized, made more
  accessible and cover additional layers of the stack.
* Container based infrastructures are changing how we monitor the resources.
  Now we have a huge number of volatile software entities, services, virtual
  network addresses, exposed metrics that suddenly appear or vanish. Traditional
  monitoring tools are not designed to handle this.

These reasons pushed Soundcloud to build a new monitoring system that had the
following features

* *Multi-dimensional data model*: The model is based on key-value pairs, similar
  to how Kubernetes itself organizes infrastructure metadata using labels. It
  allows for flexible and accurate time series data, powering its Prometheus
  query language.
* *Accessible format and protocols*: Exposing prometheus metrics is a pretty
  straightforward task. Metrics are human readable, are in a self-explanatory
  format, and are published using a standard HTTP transport. You can check that
  the metrics are correctly exposed just using your web browser.
* *Service discovery*: The Prometheus server is in charge of periodically
  scraping the targets, so that applications and services don’t need to worry
  about emitting data (metrics are pulled, not pushed). These Prometheus servers
  have several methods to auto-discover scrape targets, some of them can be
  configured to filter and match container metadata, making it an excellent fit
  for ephemeral Kubernetes workloads.
* *Modular and highly available components*: Metric collection, alerting,
  graphical visualization, etc, are performed by different composable services.
  All these services are designed to support redundancy and sharding.
* *Pull based metrics*: Most monitoring systems are *pushing* metrics to
    a centralized collection platform. Prometheus flips this model on it's head
    with the following advantages:
    * No need to install custom software in the physical servers or containers.
    * Doesn't require applications to use CPU cycles pushing metrics.
    * Handles service failure/unavailability gracefully. If a target goes down,
        Prometheus can record it was unable to retrieve data.
    * You can use the Pushgateway if pulling metrics is not feasible.

# Installation

There are [several ways to install
prometheus](https://prometheus.io/docs/prometheus/latest/installation/), but I'd
recommend using the [Kubernetes](kubernetes.md) [Prometheus
operator](prometheus_installation.md).

To install it outside Kubernetes, use the [cloudalchemy ansible
role](https://github.com/cloudalchemy/ansible-prometheus) for host installations
or the [prom/prometheus](https://hub.docker.com/r/prom/prometheus/) docker with
the following command:

```bash
/usr/bin/docker run --rm \
    --name prometheus \
    -v /data/prometheus:/etc/prometheus \
    prom/prometheus:latest \
    --storage.tsdb.retention.time=30d \
    --config.file=/etc/prometheus/prometheus.yml \
```

With a basic prometheus configuration:

!!! note "File: /data/prometheus/prometheus.yml"
    ```yaml
    ---
    # http://prometheus.io/docs/operating/configuration/

    global:
      evaluation_interval: 1m
      scrape_interval: 1m
      scrape_timeout: 10s
      external_labels:
        environment: helm
    rule_files:
      - /etc/prometheus/rules/*.rules
    scrape_configs:
      - job_name: prometheus
        metrics_path: /metrics
        static_configs:
        - targets:
          - prometheus:9090
    ```

And some basic rules:

!!! note "File: /data/prometheus/rules/"
```yaml
groups:
- name: ansible managed alert rules
  rules:
  - alert: Watchdog
    annotations:
      description: |-
        This is an alert meant to ensure that the entire alerting pipeline is functional.
        This alert is always firing, therefore it should always be firing in Alertmanager
        and always fire against a receiver. There are integrations with various notification
        mechanisms that send a notification when this alert is not firing. For example the
        "DeadMansSnitch" integration in PagerDuty.
      summary: Ensure entire alerting pipeline is functional
    expr: vector(1)
    for: 10m
    labels:
      severity: warning
  - alert: InstanceDown
    annotations:
      description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for
        more than 5 minutes.'
      summary: Instance {{ $labels.instance }} down
    expr: up == 0
    for: 5m
    labels:
      severity: critical
  - alert: RebootRequired
    annotations:
      description: '{{ $labels.instance }} requires a reboot.'
      summary: Instance {{ $labels.instance }} - reboot required
    expr: node_reboot_required > 0
    labels:
      severity: warning
  - alert: NodeFilesystemSpaceFillingUp
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available space left and is filling up.
      summary: Filesystem is predicted to run out of space within the next 24 hours.
    expr: |-
      (
        node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 40
      and
        predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 24*60*60) < 0
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: warning
  - alert: NodeFilesystemSpaceFillingUp
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available space left and is filling up fast.
      summary: Filesystem is predicted to run out of space within the next 4 hours.
    expr: |-
      (
        node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 20
      and
        predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 4*60*60) < 0
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: critical
  - alert: NodeFilesystemAlmostOutOfSpace
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available space left.
      summary: Filesystem has less than 5% space left.
    expr: |-
      (
        node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 5
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: warning
  - alert: NodeFilesystemAlmostOutOfSpace
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available space left.
      summary: Filesystem has less than 3% space left.
    expr: |-
      (
        node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 3
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: critical
  - alert: NodeFilesystemFilesFillingUp
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available inodes left and is filling up.
      summary: Filesystem is predicted to run out of inodes within the next 24 hours.
    expr: |-
      (
        node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 40
      and
        predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 24*60*60) < 0
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: warning
  - alert: NodeFilesystemFilesFillingUp
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available inodes left and is filling up fast.
      summary: Filesystem is predicted to run out of inodes within the next 4 hours.
    expr: |-
      (
        node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 20
      and
        predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 4*60*60) < 0
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: critical
  - alert: NodeFilesystemAlmostOutOfFiles
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available inodes left.
      summary: Filesystem has less than 5% inodes left.
    expr: |-
      (
        node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 5
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: warning
  - alert: NodeFilesystemAlmostOutOfFiles
    annotations:
      description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
        only {{ printf "%.2f" $value }}% available inodes left.
      summary: Filesystem has less than 3% inodes left.
    expr: |-
      (
        node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 3
      and
        node_filesystem_readonly{job="node",fstype!=""} == 0
      )
    for: 1h
    labels:
      severity: critical
  - alert: NodeNetworkReceiveErrs
    annotations:
      description: '{{ $labels.instance }} interface {{ $labels.device }} has encountered
        {{ printf "%.0f" $value }} receive errors in the last two minutes.'
      summary: Network interface is reporting many receive errors.
    expr: |-
      increase(node_network_receive_errs_total[2m]) > 10
    for: 1h
    labels:
      severity: warning
  - alert: NodeNetworkTransmitErrs
    annotations:
      description: '{{ $labels.instance }} interface {{ $labels.device }} has encountered
        {{ printf "%.0f" $value }} transmit errors in the last two minutes.'
      summary: Network interface is reporting many transmit errors.
    expr: |-
      increase(node_network_transmit_errs_total[2m]) > 10
    for: 1h
    labels:
      severity: warning
  - alert: NodeHighNumberConntrackEntriesUsed
    annotations:
      description: '{{ $value | humanizePercentage }} of conntrack entries are used'
      summary: Number of conntrack are getting close to the limit
    expr: |-
      (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
    labels:
      severity: warning
  - alert: NodeClockSkewDetected
    annotations:
      message: Clock on {{ $labels.instance }} is out of sync by more than 300s. Ensure
        NTP is configured correctly on this host.
      summary: Clock skew detected.
    expr: |-
      (
        node_timex_offset_seconds > 0.05
      and
        deriv(node_timex_offset_seconds[5m]) >= 0
      )
      or
      (
        node_timex_offset_seconds < -0.05
      and
        deriv(node_timex_offset_seconds[5m]) <= 0
      )
    for: 10m
    labels:
      severity: warning
  - alert: NodeClockNotSynchronising
    annotations:
      message: Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured
        on this host.
      summary: Clock not synchronising.
    expr: |-
      min_over_time(node_timex_sync_status[5m]) == 0
    for: 10m
    labels:
      severity: warning
```


# Exposing your metrics

Prometheus defines a very nice text-based format for its metrics:

```
# HELP prometheus_engine_query_duration_seconds Query timings
# TYPE prometheus_engine_query_duration_seconds summary
prometheus_engine_query_duration_seconds{slice="inner_eval",quantile="0.5"} 7.0442e-05
prometheus_engine_query_duration_seconds{slice="inner_eval",quantile="0.9"} 0.0084092
prometheus_engine_query_duration_seconds{slice="inner_eval",quantile="0.99"} 0.389403939
```

The data is relatively human readable and we even have TYPE and HELP decorators
to increase the readability.

To expose application metrics to the Prometheus server, use one of the [client
libraries](https://prometheus.io/docs/instrumenting/clientlibs/) and follow the
suggested [naming and units conventions for
metrics](https://prometheus.io/docs/practices/naming/#metric-names).

## Metric types

There are these metric types:

* *Counter*: A simple monotonically incrementing type; basically use this for
  situations where you want to know “how many times has x happened”.
* *Gauge*: A representation of a metric that can go both up and down. Think of
  a speedometer in a car, this type provides a snapshot of “what is the current
  value of x now”.
* *Histogram*: It represents observed metrics sharded into distinct buckets.
  Think of this as a mechanism to track “how long something took” or “how big
  something was”.
* *Summary*: Similar to a histogram, except the bins are converted into an
    aggregate immediately.

## Using labels

Prometheus metrics support the concept of Labels to provide extra dimensions to
your data. By using Labels efficiently we can essentially provide more insights
into our data whilst having to manage less actual metrics.

## [Prometheus rules](https://prometheus.io/docs/practices/rules/)

Prometheus supports two types of rules which may be configured and then
evaluated at regular intervals: recording rules and alerting rules.

[Recording rules](https://prometheus.io/docs/practices/rules/) allow you to
precompute frequently needed or computationally expensive expressions and save
their result as a new set of time series. Querying the precomputed result will
then often be much faster than executing the original expression every time it
is needed.

A simple example rules file would be:

```yaml
groups:
  - name: example
    rules:
    - record: job:http_inprogress_requests:sum
      expr: sum by (job) (http_inprogress_requests)
```

Regarding [naming and aggregation
conventions](https://prometheus.io/docs/practices/rules/#naming-and-aggregation),
Recording rules should be of the general form `level:metric:operations`. `level`
represents the aggregation level and labels of the rule output. `metric` is the
metric name and should be unchanged other than stripping `_total` off counters
when using `rate()` or `irate()`. `operations` is a list of operations (splitted
by `:`) that were applied to the metric, newest operation first.

If you want to add extra labels to the calculated rule use the
[`labels`](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
tag like the following example:

```yaml
groups:
  - name: example
    rules:
      - record: instance_path:wrong_resource_size
        expr: >
          instance_path:node_memory_MemAvailable_percent:avg_plus_stddev_over_time_2w < 60
        labels:
          type: EC2
          metric: RAM
          problem: oversized
```

# Finding a metric

You can use `{__name__=~".*deploy.*"}` to find the metrics that have `deploy`
somewhere in the name.

# Links

* [Homepage](https://prometheus.io/).
* [Docs](https://prometheus.io/docs/introduction/overview/).
* [Awesome Prometheus](https://github.com/roaldnefs/awesome-prometheus).
* Prometheus rules [best
    practices](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
    and [configuration](https://prometheus.io/docs/practices/rules/).

## Diving deeper

* [Architecture](prometheus_architecture.md)
* [Prometheus Operator](prometheus_operator.md)
* [Prometheus Installation](prometheus_installation.md)
* [Blackbox Exporter](blackbox_exporter.md)
* [Node Exporter](node_exporter.md)
* [Prometheus Troubleshooting](prometheus_troubleshooting.md)

## Introduction posts

* [Soundcloud
  introduction](https://developers.soundcloud.com/blog/prometheus-monitoring-at-soundcloud).
* [Sysdig guide](https://sysdig.com/blog/kubernetes-monitoring-prometheus/).
* [Prometheus monitoring solutions
  comparison](https://prometheus.io/docs/introduction/comparison/).
* [ITNEXT overview](https://itnext.io/prometheus-for-beginners-5f20c2e89b6c)

## Books

* [Prometheus Up & Running](http://shop.oreilly.com/product/0636920147343.do).
* [Monitoring With Prometheus](https://www.prometheusbook.com/).
