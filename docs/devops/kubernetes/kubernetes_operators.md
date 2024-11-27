---
title: Kubernetes Operators
date: 20200212
author: Lyz
---

[Operators](https://coreos.com/blog/introducing-operators.html) are
Kubernetes specific applications (pods) that configure, manage and optimize
other Kubernetes deployments automatically.

A Kubernetes Operator might be able to:

* Install and provide sane initial configuration and sizing for your deployment,
  according to the specs of your Kubernetes cluster.
* Perform live reloading of deployments and pods to accommodate for any
  user requested parameter modification (hot config reloading).
* Safe coordination of application upgrades.
* Automatically scale up or down according to performance metrics.
* Service discovery via native Kubernetes APIs
* Application TLS certificate configuration
* Disaster recovery.
* Perform backups to offsite storage, integrity checks or any other maintenance task.

# How do they work?

An Operator encodes this domain knowledge and extends the Kubernetes API through
the third party resources mechanism, enabling users to create, configure, and
manage applications. Like Kubernetes's built-in resources, an Operator doesn't
manage just a single instance of the application, but multiple instances across
the cluster.

Operators build upon two central Kubernetes concepts: Resources and Controllers.
As an example, the built-in ReplicaSet resource lets users set a desired number
number of Pods to run, and controllers inside Kubernetes ensure the desired
state set in the ReplicaSet resource remains true by creating or removing
running Pods. There are many fundamental controllers and resources in Kubernetes
that work in this manner, including Services, Deployments, and Daemon Sets.

An Operator builds upon the basic Kubernetes resource and controller concepts
and adds a set of knowledge or configuration that allows the Operator to execute
common application tasks. For example, when scaling an etcd cluster manually,
a user has to perform a number of steps: create a DNS name for the new etcd
member, launch the new etcd instance, and then use the etcd administrative tools
(etcdctl member add) to tell the existing cluster about this new member. Instead
with the etcd Operator a user can simply increase the etcd cluster size field by
1.

# Links

* [CoreOS introduction to Operators](https://coreos.com/blog/introducing-operators.html)
* [Sysdig Prometheus Operator guide part 3](https://sysdig.com/blog/kubernetes-monitoring-prometheus-operator-part3/)
