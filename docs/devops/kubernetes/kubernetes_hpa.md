---
title: Kubernetes Horizontal pod autoscaling
date: 20200302
author: Lyz
---

With [Horizontal pod
autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/),
Kubernetes automatically scales the number of pods in a deployment or
replication controller based on observed CPU utilization or on some other
application provided metrics.

The Horizontal Pod Autoscaler is implemented as a Kubernetes API resource and
a controller. The resource determines the behavior of the controller. The
controller periodically adjusts the number of replicas in a replication
controller or deployment to match the observed average CPU utilization to the
target specified by user.

To make it work, the definition of [pod resource
consumption](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
needs to be specified.

