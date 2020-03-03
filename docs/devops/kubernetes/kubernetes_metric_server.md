---
title: Kubernetes Metric server
date: 20200303
author: Lyz
---

The metrics server monitors the resource consumption inside the cluster. It
populates the information in `kubectl top nodes` to get the node status and
gives the information to automatically autoscale deployments with
[Horizontal pod autoscaling](kubernetes_hpa.md).

To install it, you can use the [`metrics-server`](https://github.com/helm/charts/tree/master/stable/metrics-server)
[helm](helm.md) chart.

To test that the horizontal pod autoscaling is working, follow the [AWS EKS
guide](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html).

