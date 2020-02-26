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
services offer a Kubernetes-based platform or infrastructure as a service (PaaS
or IaaS) on which Kubernetes can be deployed as a platform-providing service.
Many vendors also provide their own branded Kubernetes distributions.

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

This is how I learnt, but probably [there are better resources now](https://github.com/ramitsurana/awesome-kubernetes#starting-point):

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

# Tools

## Tried

* [K3s](https://k3s.io): Recommended small kubernetes, like hyperkube.

## To try

* [crossplane](https://github.com/crossplaneio/crossplane): Crossplane is an
  open source multicloud control plane. It introduces workload and resource
  abstractions on-top of existing managed services that enables a high degree of
  workload portability across cloud providers. A single crossplane enables the
  provisioning and full-lifecycle management of services and infrastructure
  across a wide range of providers, offerings, vendors, regions, and clusters.
  Crossplane offers a universal API for cloud computing, a workload scheduler,
  and a set of smart controllers that can automate work across clouds.
* [razee](https://razee.io): A multi-cluster continuous delivery tool for Kubernetes
  Automate the rollout process of Kubernetes resources across multiple clusters,
  environments, and cloud providers, and gain insight into what applications and
  versions run in your cluster.
* [kube-ops-view](https://github.com/hjacobs/kube-ops-view): it shows how are
  the ops on the nodes
* [kubediff](https://github.com/weaveworks/kubediff): a tool for Kubernetes to
  show differences between running state and version controlled configuration.
* [ksniff](https://github.com/eldadru/ksniff): A kubectl plugin that utilize
  tcpdump and Wireshark to start a remote capture on any pod in your Kubernetes
  cluster.
* [kubeview](https://learnk8s.io/visualise-dependencies-kubernetes/): Visualize
  dependencies kubernetes

# Links

* [Docs](https://kubernetes.io/docs/)
* [Awesome K8s](https://github.com/ramitsurana/awesome-kubernetes)
* [Katacoda playground](https://www.katacoda.com/courses/kubernetes/playground)
* [Comic](https://cloud.google.com/kubernetes-engine/kubernetes-comic)

## Diving deeper

* [Networking](kubernetes_networking.md)
* [Ingress](kubernetes_ingress.md)
* [Operators](kubernetes_operators.md)
* [Dashboard](kubernetes_dashboard.md)


## Reference

* [References](https://kubernetes.io/docs/reference/)
* [API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md)
