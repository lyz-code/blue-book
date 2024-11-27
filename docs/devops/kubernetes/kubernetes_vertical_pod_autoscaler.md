---
title: Vertical Pod Autoscaler
date: 20200303
author: Lyz
---

Kubernetes knows the amount of resources a pod needs to operate through some
metadata specified in the deployment. Generally this values change and manually
maintaining all the resources requested and limits is a nightmare.

The [Vertical pod
autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
does data analysis on the pod metrics to automatically adjust these values.

Nevertheless it's still not suggested to use it in conjunction with the
[horizontal pod autoscaler](kubernetes_hpa.md), so we'll need to watch out for
future improvements.
