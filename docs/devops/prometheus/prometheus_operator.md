---
title: Prometheus Operator
date: 20200212
author: Lyz
---

[Prometheus](prometheus.md) has it's own [kubernetes operator](kubernetes_operators.md),
which makes it simple to install with helm, and enables users
to configure and manage instances of Prometheus using simple declarative
configuration that will, in response, create, configure, and manage Prometheus
monitoring instances.

Once installed the Prometheus Operator provides the following features:

* *Create/Destroy*: Easily launch a Prometheus instance for your Kubernetes
  namespace, a specific application or team easily using the Operator.

* *Simple Configuration*: Configure the fundamentals of Prometheus like
  versions, persistence, retention policies, and replicas from a native
  Kubernetes resource.

* *Target Services via Labels*: Automatically generate monitoring target
  configurations based on familiar Kubernetes label queries; no need to learn
  a Prometheus specific configuration language.

# How it works

The core idea of the Operator is to decouple deployment of Prometheus instances
from the configuration of which entities they are monitoring.

The Operator acts on the following [custom resource definitions](https://github.com/coreos/prometheus-operator/blob/master/README.md#customresourcedefinitions) (CRDs):

* *Prometheus*: Defines the desired Prometheus deployment. The Operator ensures
  at all times that a deployment matching the resource definition is running.
  This entails aspects like the data retention time, persistent volume claims,
  number of replicas, the Prometheus version, and Alertmanager instances to send
  alerts to.
* *ServiceMonitor*: Specifies how metrics can be retrieved from a set of
  services exposing them in a common way. The Operator configures the Prometheus
  instance to monitor all services covered by included ServiceMonitors and keeps
  this configuration synchronized with any changes happening in the cluster.
* *PrometheusRule*: Defines a desired Prometheus rule file, which can be loaded
  by a Prometheus instance containing Prometheus alerting and recording rules.
* *Alertmanager*: Defines a desired Alertmanager deployment. The Operator
  ensures at all times that a deployment matching the resource definition is
  running.

![ ](prometheus_operator_workflow.png)

# Links

* [Homepage](https://github.com/coreos/prometheus-operator)
* [CoreOS Prometheus operator presentation](https://coreos.com/blog/the-prometheus-operator.html)
* [Sysdig Prometheus operator guide part 3](https://sysdig.com/blog/kubernetes-monitoring-prometheus-operator-part3/)
