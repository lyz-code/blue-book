---
title: Kubernetes ReplicaSets
date: 20200302
author: Lyz
---

[ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
maintains a stable set of replica Pods running at any given time.  As such, it
is often used to guarantee the availability of a specified number of identical
Pods.

You'll probably never manually use these resources, as they are defined inside
the [deployments](kubernetes_deployments.md). The older version of this resource are the
[Replication
controllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/).
