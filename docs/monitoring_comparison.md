---
title: Monitoring Comparison
date: 20210222
author: Lyz
---

As with any technology, when you want to adopt it, you first need to analyze
your options. In this article we're going to compare the two most popular
solutions at the moment, Nagios and Prometheus. Zabbix is similar in
architecture and features to Nagios, so for the first iteration we're going to
skip it.

!!! note "TL;DR: Prometheus is better, but it needs more effort."

    Nagios is suitable for basic monitoring of small and/or static systems where
    blackbox probing is sufficient.

    If you want to do whitebox monitoring, or have a dynamic or cloud based
    environment, then Prometheus is a good choice.

# Nagios

[Nagios](https://www.nagios.org/) is an industry leader in IT infrastructure
monitoring. It has four different products to choose from:

* Nagios XI: Is an enterprise-ready server and network monitoring system that
    supplies data to track app or network infrastructure health, performance,
    availability, of the components, protocols, and services. It has
    a user-friendly interface that allows UI configuration, customized
    visualizations, and alert preferences.

* Nagios Log Server: It's used for log management and analysis of user
    scenarios. It has the ability to correlate logged events across different
    services and servers in real time, which helps with the investigation of
    incidents and the performance of root cause analysis.

    Because Nagios Log Server’s design is specifically for network security and
    audits, it lets users generate alerts for suspicious operations and
    commands. Log Server retains historical data from all events, supplying
    organizations with everything they need to pass a security audit.

* Nagios Network Analyzer: It's a tool for collecting and displaying either
    metrics or extra information about an application network. It identifies
    which IPs are communicating with the application servers and what requests
    they’re sending. The Network Analyzer maintains a record of all server
    traffic, including who connected a specific server, to a specific port and
    the specific request.

    This helps plan out server and network capacity, plus understand various
    kinds of security breaches likes unauthorized access, data leaks, DDoS, and
    viruses or malwares on servers.

* Nagios Fusion: is a compilation of the three tools Nagios offers. It provides
    a complete solution that assists businesses in satisfying any and all of
    their monitoring requirements. Its design is for scalability and for
    visibility of the application and all of its dependencies.

# Prometheus

[Prometheus](prometheus.md) is a free software application used for event
monitoring and alerting. It records real-time metrics in a time series database
(allowing for high dimensionality) built using a HTTP pull model, with flexible
queries and real-time alerting. The project is written in Go and licensed under
the Apache 2 License, with source code available on GitHub, and is a graduated
project of the Cloud Native Computing Foundation, along with Kubernetes and
Envoy.

At the core of the Prometheus monitoring system is the main server, which
ingests samples from monitoring targets. A target is any application that
exposes metrics according to the open specification understood by Prometheus.
Since Prometheus pulls data, rather than expecting targets to actively push
stats into the monitoring system, it supports a variety of service discovery
integrations, like that with Kubernetes, to immediately adapt to changes in
the set of targets.

The second core component is the Alertmanager, implementing the idea of time
series based alerting. It intelligently removes duplicate alerts sent by
Prometheus servers, groups the alerts into informative notifications, and
dispatches them to a variety of integrations, like those with PagerDuty and
Slack. It also handles silencing of selected alerts and advanced routing
configurations for notifications.

There are several additional Prometheus components, such as client libraries
for different programming languages, and a growing number of exporters.
Exporters are small programs that provide Prometheus compatible metrics from
systems that are not natively instrumented.

# Comparison

For each dimension we'll check how each solution meets the criteria. An
aggregation of all the results can be found in the [summary](#summary).

## Open source

Only the Nagios Core is [open sourced](https://en.wikipedia.org/wiki/Nagios), it
provides basic monitoring but it's enhanced by [community
contributions](https://exchange.nagios.org/). It's also the base of the rest
solutions, which are proprietary.

Prometheus is completely open source under the Apache 2.0 license.

## Community

In Nagios, only the Nagios Core is an open-source tool. The rest are proprietary, so
there is no community behind them.

Community contributions to Nagios are gathered in the [Nagios
Exchange](https://exchange.nagios.org/), it's hard to get other activity
statistics than the overall number of contributions, but there are more than 850
addons, 4.5k plugins and 300 documentation contributions.

Overall metrics (2021-02-22):

| Metric        | [Nagios Core](https://github.com/NagiosEnterprises/nagioscore) | [Prometheus](https://github.com/prometheus/prometheus) |
| ---           | ---         | ---        |
| Stars         | 932         | 35.4k      |
| Forks         | 341         | 5.7k       |
| Watch         | 121         | 1.2k       |
| Commits       | 3.4k        | 8.5k       |
| Open Issues   | 195         | 290        |
| Closed Issues | 455         | 3.5k       |
| Open PR       | 9           | 116        |
| Closed PR     | 155         | 4.5k       |

Last month metrics (2021-02-22):

| Metric        | [Nagios Core](https://github.com/NagiosEnterprises/nagioscore/pulse/monthly) | [Prometheus](https://github.com/prometheus/prometheus/pulse/monthly) |
| ---           | ---         | ---        |
| Active PR     | 1           | 80         |
| Active Issues | 3           | 64         |
| Commits       | 0           | 74         |
| Authors       | 0           | 35         |

We can see that Prometheus in comparison with Nagios Core is:

* More popular in terms of community contributions.
* More maintained.
* Growing more.
* Development is more distributed.
* Manages the issues collaboratively.

This comparison is biased though, because Nagios comes from a time where GitHub
and Git (and Youtube!) did not exist, and the communities formed around
different sites.

Also, given that Nagios has almost 20 years of existence, and that it forked
from a previous monitoring project (NetSaint), the low number contributions
indicate a stable and mature product, whereas the high numbers for Prometheus
are indicators of a young, still in development product.

Keep in mind that this comparison only analyzes the core, it doesn't take into
account the metrics of the community contributions, as it is not easy to
aggregate their statistics.

Which makes Prometheus one of the biggest open-source projects in existence. It
actually has hundreds of contributors maintaining it. The tool continues to be
up-to-date to contemporary and popular apps, extending its list of exporters and
responding to requests.

On [16 January
2014](https://en.wikipedia.org/wiki/Nagios#2014_controversy_over_plugins_website),
Nagios Enterprises redirected the nagios-plugins.org domain to a web server
controlled by Nagios Enterprises without explicitly notifying the Nagios Plugins
community team the consequences of their actions. Nagios Enterprises
replaced the nagios-plugins team with a group of new, different members. The
community team members who were replaced continued their work under the name
Monitoring Plugins along with a new website with the new domain of
monitoring-plugins.org. Which is a nasty move against the community.

## Configuration and usage

Neither solution is easy to configure, you need to invest time in them.

Nagios is easier to use for non technical users though.

## Visualizations

The graphs and dashboards Prometheus provides don't meet today's needs. As
a result, users resort to other visualization tools to display metrics collected
by Prometheus, often Grafana.

Nagios comes with a set of dashboards that fit the requirements of monitoring
networks and infrastructure components. Yet, it still lacks graphs for more
applicative-related issues.

Personally I find Grafana dashboards more beautiful and easier to change. It
also has a massive community behind providing customizable dashboards for free.

## Installation

Nagios comes as a downloadable bundle with dedicated packages for every product
with Windows or Linux distributions. After downloading and installing the tool,
a set of first-time configurations is required. Once you’ve installed the Nagios
agents, data should start streaming into Nagios and its generic dashboards.

Prometheus deployment is done through Docker containers that can spin up on
every machine type, or through pre-compiled or self-compiled binaries.

There are community maintained ansible roles for both solutions, doing a quick
search I've found a Prometheus one that it's more maintained.

For Kubernetes installation, I've only found helm charts for Prometheus.

## Kubernetes integration

Prometheus, as Kubernetes are leading projects of the [Cloud Native Computing
Foundation](https://www.cncf.io/), [which
is](https://en.wikipedia.org/wiki/Cloud_Native_Computing_Foundation) a Linux
Foundation project that was founded in 2015 to help advance container technology
and align the tech industry around its evolution.

Prometheus has native support to be run in and to monitor Kubernetes clusters.
Although Nagios [can
monitor](https://exchange.nagios.org/directory/Plugins/Containers/kubernetes-2Dnagios/details)
Kubernetes, it's not meant to be run inside it.

## Documentation

I haven't used much the [Nagios
documentation](https://www.nagios.org/documentation/), but I can tell you that
even though it's improving
[Prometheus](https://prometheus.io/docs/introduction/overview/)' is not very
complete, and you find yourself often looking at issues and stackoverflow.

## Integrations

Official Prometheus’ integrations are [practically
boundless](https://prometheus.io/docs/instrumenting/exporters/). The long list
of existing exporters combined with the user’s ability to write new exporters
allows integration with any tool, and PromQL allows users to query Prometheus
data from any visualization tool that supports it.

Nagios has a [very limited list of official
integrations](https://www.nagios.com/integrations/). Most of them are operating
systems which use the agents to monitor other network components. Others include
MongoDB, Oracle, Selenium, and VMware. Once again, the community comes to rescue
us with [their contributions](https://exchange.nagios.org/), keep in mind that
you'll need to dive into the exchange for special monitoring needs.

## Alerts

Prometheus offers Alertmanager, a simple service that allows users to set
thresholds and push alerts when breaches occur.

Nagios uses a variety of media channels for alerts, including email, SMS, and
audio alerts. Because its integration with the operating system is swift, Nagios
even knows to generate a WinPopup message with the alert details.

On a side note, there is an alert Nagios plugin that alerts for Prometheus query
results.

As Nagios doesn't support labels for the metrics, so there is [no grouping,
routing or
deduplication](https://prometheus.io/docs/introduction/comparison/#scope-2) of
alerts as Prometheus do. Also the silence of alerts is done individually on
each alert, while in Prometheus it's done using labels, which is more powerful.

## Advanced monitorization

Nagios alerting is based on the return codes of scripts, Prometheus on the other
hand alerts based on metrics, this fact together with the easy and powerful
query language PromQL allows the user to make much more rich alerts that better
represent the state of the system to monitor.

In Nagios there is no concept of making queries to the gathered data.

## Data storage

Nagios has no storage per-se, beyond the current check state. There are plugins
which can store data such as for [visualisation](https://docs.pnp4nagios.org/).

Prometheus has a defined amount of data that's available (for example 30 days),
to be able to store more you need to use Thanos, the prometheus long term
storage solution.

## High availability

Nagios servers are standalone, they are not meant to collaborate with other
instances, so to achieve high availability you need to do it the old way, with
multiple independent instances with a loadbalancer upfront.

Prometheus can have different servers running collaboratively, monitoring
between themselves. So you get high availability for free without any special
configuration.

## Dynamic infrastructure

In the past, infrastructure had a low rate of change, it was strange that you
needed to add something to the monitorization system. Nowadays, with cloud
infrastructures and kubernetes, instances are spawned and killed continuously.

In Nagios, you need to manually configure each new service following the push
architecture. In prometheus, thanks to the pull architecture and service
discovery, new services are added and dead one removed automatically.

## Custom script execution

Nagios alerting is based on the return codes of scripts, therefore it's
straightforward to create an alert based on a custom script.

If you need to monitor something in Prometheus, and nobody has done it before,
the development costs of an ad-hoc solutions are incredibly high, compared to
Nagios. You'd need either to:

* Use the [script_exporter](https://github.com/adhocteam/script_exporter) with
    your script.  I've seen their repo, and the last commit is from March, and
    they [don't have a helm chart to install
    it](https://github.com/adhocteam/script_exporter/issues/42). I've searched
    other alternative exporters, but this one seems to be the best for this
    approach.

    The advantages of this approach is that you don't need to create and
    maintain a new prometheus exporter.

    The disadvantages though are that you'd have to:

    * Manually install the required exporter resources in the cluster until a helm chart
        exists.
    * Create the helm charts yourself if they don't develop it.
    * Integrate your tool inside the script_exporter docker through one of these
        ways:

        * Changing the exporter Docker image to add it. Which would mean a Docker image
            to maintain.
        * Mounting the binary through a volume inside kubernetes. Which would mean
            defining a way on how to upload it and assume the high availability penalty
            that a stateful kubernetes service entail with the cluster configuration right
            now.
    * If it's not already in your stack, it would mean adding a new exporter to
        maintain and a new development team to depend on.

    Alternatively you can use the script exporter binary in a baremetal or
    virtualized server instead of using a docker, that way you wouldn't need to
    maintain the different dockers for the different solutions, but you'd need
    a "dedicated" server for this purpose.

* Create your own exporter. You'd need to create a docker that exposes the
command line functionality through a `metrics` endpoint. You wouldn't depend on
a third party development team and would be able to use your script. On the
other side it has the following disadvantages:

    * We would need to create and maintain a new prometheus exporter. That would mean
        creating and maintaining the Docker with the command line tool and a simple http
        server that exposes the `/metrics` endpoint, that will run the command whenever the
        Prometheus server accesses this endpoint.
    * We add a new exporter to maintain but we develop it ourselves, so we don't depend on
        third party developers.

* Use other exporters to do the check. For example, if you can deduce the
    critical API call that will decide if the script fails or succeeds, you
    could use the blackbox exporter to monitor it instead. The advantages of
    this solution are:

    * We don't add new infrastructure to develop or maintain.
    * We don't depend on third party development teams.

    And the disadvantage is that if the logic changes, we would need to update
    how we do the check.

## Network monitorization

[Both](https://prometheus.io/docs/introduction/faq/#can-i-monitor-network-devices)
can use the Simple Network Management Protocol (SNMP) to communicate with
network switches or other components by using SNMP protocol to query their
status.

Not being an expert on the topic, knowing it's been one of the core focus of
Nagios in the past years and as I've not been able to find good comparison
between both, I'm going to suppose that even though both support network
monitoring, Nagios does a better job.

## Summary

| Metric                                              | Nagios | Prometheus |
| ---                                                 | ---    | ---        |
| [Open Source](#open-source)                         | ✓*     | ✓✓         |
| [Community](#community)                             | ✓      | ✓✓         |
| [Configuration and usage](#configuration-and-usage) | ✓      | x          |
| [Visualizations](#visualizations)                   | ✓      | ✓✓         |
| [Ansible Role](#installation)                       | ✓      | ✓✓         |
| [Helm chart](#installation)                         | x      | ✓          |
| [Kubernetes](#kubernetes)                           | x      | ✓          |
| [Documentation](#documentation)                     | ✓      | x          |
| [Integrations](#integrations)                       | ✓      | ✓✓         |
| [Alerts](#alerts)                                   | ✓      | ✓✓         |
| [Advanced monitoring](#advanced-monitoring)         | x      | ✓          |
| [Custom script execution](#custom-script-execution) | ✓✓     | ✓          |
| [Data storage](#data-storage)                       | x      | ✓          |
| [Dynamic infrastructure](#dynamic-infrastructure)   | x      | ✓          |
| [High availability](#high-availability)             | ✓      | ✓✓         |
| [Network Monitoring](#network-monitoring)           | ✓      | ✓          |

\* Only Nagios Core and the community contributions are open sourced.

Where each symbol means:

* x: Doesn't meet the criteria.
* ✓: Meets the criteria.
* ✓✓: Meets the criteria and it's better than the other solution.
* ?: I'm not sure.

Nagios is the reference of the old-school monitoring solutions, suitable for
basic monitoring of small, static and/or old-school systems where blackbox
probing is sufficient.

Prometheus is the reference of the new-wave monitoring solutions, suitable for
more advanced monitoring of dynamic, new-wave systems (web applications, cloud,
containers or Kubernetes) where whitebox monitoring is desired.

# References

* [Logz io post on Prometheus vs Nagios](https://logz.io/blog/prometheus-vs-nagios-metrics/)
