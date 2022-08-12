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
    <img src="/blue-book/img/prometheus_logo.png">
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
recommend using the [Kubernetes](kubernetes.md) or Docker [Prometheus
operator](prometheus_installation.md).


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

# [Accessing Prometheus metrics through python](https://stackoverflow.com/questions/60050507/reading-prometheus-metric-using-python)

```python
import requests

response = requests.get(
    "http://127.0.0.1:9090/api/v1/query",
    params={"query": "container_cpu_user_seconds_total"},
)
```

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
