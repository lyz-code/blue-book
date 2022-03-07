---
title: Introduction to Kubernetes
date: 20200210
author: Lyz
---

[Kubernetes](https://en.wikipedia.org/wiki/Kubernetes) (commonly stylized as
k8s) is an open-source container-orchestration system for automating application
deployment, scaling, and management. Developed by Google in Go under the Apache
2.0 license, it was first released on June 7, 2014 reaching 1.0 by July 21,
2015. It works with a range of container tools, including Docker. Many cloud
services offer a Kubernetes-based platform or infrastructure as a service
([PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service) or
[IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service)) on which
Kubernetes can be deployed as a platform-providing service.  Many vendors also
provide their own branded Kubernetes distributions.

<p align="center">
    <img src="/blue-book/img/kubernetes_logo.png">
</p>

It has become the standard infrastructure to manage containers in production
environments. [Docker Swarm](https://docs.docker.com/engine/swarm/) would be an
alternative but it falls short in features compared with Kubernetes.

These are some of the advantages of using Kubernetes:

* Widely used in production and actively developed.
* Ensure high availability of your services with autohealing and autoscaling.
* Easy, quickly and predictable deployment and promotion of applications.
* Seamless roll out of features.
* Optimize hardware use while guaranteeing resource isolation.
* Easiest way to build multi-cloud and baremetal environments.

Several companies have used Kubernetes to release their own
[PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service):

* [OpenShift](https://en.wikipedia.org/wiki/OpenShift) by Red Hat.
* [Tectonic](https://coreos.com/tectonic/) by CoreOS.
* [Rancher labs](https://en.wikipedia.org/wiki/Rancher_Labs) by Rancher.

# Learn roadmap

K8s is huge, and growing at a pace that most mortals can't stay updated unless
you work with it daily.

This is how I learnt, but probably [there are better resources
now](https://github.com/ramitsurana/awesome-kubernetes#starting-point):

* Read [containing container chaos kubernetes](
  https://opensource.com/life/16/9/containing-container-chaos-kubernetes).
* Test the [katacoda lab](https://www.katacoda.com/courses/kubernetes).
* Install Kubernetes in laptop with
  [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/).
* Read [K8s concepts](https://kubernetes.io/docs/concepts).
* Then [K8s tasks](https://kubernetes.io/docs/tasks/).
* I didn't like the book [Getting started with kubernetes](https://www.packtpub.com/eu/virtualization-and-cloud/getting-started-kubernetes-third-edition)
* I'd personally avoid the book [Getting started with
  kubernetes](https://www.packtpub.com/eu/virtualization-and-cloud/getting-started-kubernetes-third-edition),
  I didn't like it `¯\(°_o)/¯`.

# [Tools to test](https://filippobuletto.github.io/kubernetes-toolbox/)

* [Velero](https://velero.io/): To backup and migrate Kubernetes resources and
    persistent volumes.

* [Popeye](https://github.com/derailed/popeye) is a utility that scans live
    Kubernetes cluster and reports potential issues with deployed resources and
    configurations. It sanitizes your cluster based on what's deployed and not
    what's sitting on disk. By scanning your cluster, it detects
    misconfigurations and helps you to ensure that best practices are in place,
    thus preventing future headaches. It aims at reducing the cognitive overload
    one faces when operating a Kubernetes cluster in the wild. Furthermore, if
    your cluster employs a metric-server, it reports potential resources
    over/under allocations and attempts to warn you should your cluster run out
    of capacity.

    Popeye is a readonly tool, it does not alter any of your Kubernetes
    resources in any way!

* [Stern](https://github.com/wercker/stern) allows you to tail multiple pods on
    Kubernetes and multiple containers within the pod. Each result is color
    coded for quicker debugging.

    The query is a regular expression so the pod name can easily be filtered and
    you don't need to specify the exact id (for instance omitting the deployment
    id). If a pod is deleted it gets removed from tail and if a new pod is added
    it automatically gets tailed.

    When a pod contains multiple containers Stern can tail all of them too
    without having to do this manually for each one. Simply specify the
    container flag to limit what containers to show. By default all containers
    are listened to.

* [Fairwinds' Polaris](https://github.com/FairwindsOps/polaris) keeps your
    clusters sailing smoothly. It runs a variety of checks to ensure that
    Kubernetes pods and controllers are configured using best practices, helping
    you avoid problems in the future.

* [kube-hunter](https://github.com/aquasecurity/kube-hunter) hunts for security
    weaknesses in Kubernetes clusters. The tool was developed to increase
    awareness and visibility for security issues in Kubernetes environments.

# References

* [Docs](https://kubernetes.io/docs/)
* [Awesome K8s](https://github.com/ramitsurana/awesome-kubernetes)
* [Katacoda playground](https://www.katacoda.com/courses/kubernetes/playground)
* [Comic](https://cloud.google.com/kubernetes-engine/kubernetes-comic)

## Diving deeper

* [Architecture](kubernetes_architecture.md)
* [Resources](kubernetes_namespaces.md)
* [Kubectl](kubectl.md)
* [Additional Components](kubernetes_namespaces.md)
* [Networking](kubernetes_networking.md)
* [Helm](helm.md)
* [Tools](kubernetes_tools.md)
* [Debugging](kubernetes_debugging.md)

## Reference

* [References](https://kubernetes.io/docs/reference/)
* [API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md)
