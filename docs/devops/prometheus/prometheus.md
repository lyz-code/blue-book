---
title: Prometheus
date: 20200211
author: Lyz
tags:
  - monitoring
---

[Prometheus](https://en.wikipedia.org/wiki/Prometheus_%28software%29) is a free
software application used for event monitoring and alerting. It records
real-time metrics in a time series database (allowing for high dimensionality)
built using a HTTP pull model, with flexible queries and real-time
alerting. The project is written in Go and licensed under the Apache
2 License, with source code available on GitHub, and is a graduated project
of the Cloud Native Computing Foundation, along with Kubernetes and Envoy.

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

# Installation

There are [several ways to install
prometheus](https://prometheus.io/docs/prometheus/latest/installation/), but I'd
recommend using the [Kubernetes operator](prometheus_operator.md).

# Links

* [Homepage](https://prometheus.io/).
* [Docs](https://prometheus.io/docs/introduction/overview/).
* [Awesome Prometheus](https://github.com/roaldnefs/awesome-prometheus).

* [Soundcloud
  introduction](https://developers.soundcloud.com/blog/prometheus-monitoring-at-soundcloud).
* [Sysdig guide](https://sysdig.com/blog/kubernetes-monitoring-prometheus/).
* [Prometheus monitoring solutions
  comparison](https://prometheus.io/docs/introduction/comparison/).
