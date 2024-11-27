---
title: EKS
date: 20200504
author: Lyz
---

[Amazon Elastic Kubernetes Service (Amazon
EKS)](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) is
a managed service that makes it easy for you to run [Kubernetes](kubernetes.md) on AWS without
needing to stand up or maintain your own Kubernetes control plane.

# [Pod limit per node](https://www.linkedin.com/pulse/aws-eks-maximum-number-pods-per-ec2-node-instance-george-tsopouridis)

AWS EKS supports native VPC networking with the Amazon VPC Container Network
Interface (CNI) plugin for Kubernetes. Using this plugin allows Kubernetes Pods
to have the same IP address inside the pod as they do on the VPC network.

This is a great feature but it introduces a limitation in the number of Pods per
EC2 Node instance. Whenever you deploy a Pod in the EKS worker Node, EKS creates
a new IP address from VPC subnet and attach to the instance.

The formula for defining the maximum number of pods per instance is as follows:

```
N * (M-1) + 2
```

Where:

* `N` is the number of Elastic Network Interfaces (ENI) of the instance type.
* `M` is the number of IP addresses of a single ENI.

So, for `t3.small`, this calculation is `3 * (4-1) + 2 = 11`. For a list of all
the instance types and their limits see [this document](https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt)

# [Upgrade an EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)

New Kubernetes versions introduce significant changes, so it's recommended that
you test the behavior of your applications against a new Kubernetes version
before performing the update on your production clusters.

The update process consists of Amazon EKS launching new API server nodes with
the updated Kubernetes version to replace the existing ones. Amazon EKS performs
standard infrastructure and readiness health checks for network traffic on these
new nodes to verify that they are working as expected. If any of these checks
fail, Amazon EKS reverts the infrastructure deployment, and your cluster remains
on the prior Kubernetes version. Running applications are not affected, and your
cluster is never left in a non-deterministic or unrecoverable state. Amazon EKS
regularly backs up all managed clusters, and mechanisms exist to recover
clusters if necessary. We are constantly evaluating and improving our Kubernetes
infrastructure management processes.

To upgrade a cluster follow these steps:

* Upgrade all your charts to the latest version with [helmfile](helmfile.md).
    ```bash
    helmfile deps
    helmfile apply
    ```
* Check your current version and compare it with the one you want to upgrade.
    ```bash
    kubectl version --short
    kubectl get nodes
    ```
* Check the
    [docs](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
    to see if the version you want to upgrade requires some special steps.
* If your worker nodes aren't at the same version as the cluster control plane
    upgrade them to the control plane version (never higher).
* Edit the `cluster_version` attribute of the eks terraform module and apply the
    changes (reviewing them first).
    ```bash
    terraform apply
    ```

    This is a long step (approximately 40 minutes)
* Upgrade your charts again.

# References

* [Docs](https://docs.aws.amazon.com/eks/latest/userguide)
