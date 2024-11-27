---
title: Kubernetes cluster autoscaler
date: 20200303
author: Lyz
---

While [Horizontal pod autoscaling](kubernetes_hpa.md) allows
a deployment to scale given the resources needed, they are limited to the
kubernetes existing working nodes.

To autoscale the number of working nodes we need the [cluster
autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/README.md).

For AWS, there are the [Amazon guidelines to enable
it](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html).
But I'd use the
[`cluster-autoscaler`](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler)
[helm](helm.md) chart.
