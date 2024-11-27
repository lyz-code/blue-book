---
title: Kubernetes Storage Driver
date: 20200303
author: Lyz
---

Storage drivers are pods that through the [Container Storage
Interface](https://kubernetes-csi.github.io/docs/introduction.html) or CSI
provide an interface to use external storage services from within Kubernetes.

# [Amazon EBS CSI storage driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)

Allows Kubernetes clusters to manage the lifecycle of Amazon EBS volumes for
persistent volumes with the [`awsElasticBlockStore` volume
type](kubernetes_volumes.md#awselasticblockstore).

To install it, you first need to attach the [`Amazon_EBS_CSI_Driver` IAM
policy](https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.4.0/docs/example-iam-policy.json)
to the worker nodes. Then you can use the
[`aws-ebs-csi-driver`](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
[helm](helm.md) chart.

To test it worked follow [the
steps](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) under *To
deploy a sample application and verify that the CSI driver is working*.
