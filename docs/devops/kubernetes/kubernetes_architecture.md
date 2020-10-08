---
title: Kubernetes architecture
date: 20200226
author: Lyz
---

[Kubernetes](kubernetes.md) is a [combination of
components](https://kubernetes.io/docs/concepts/overview/components/)
distributed between two kind of nodes, [Masters](#master-nodes) and
[Workers](#worker-nodes).

![kubernetes core architecture diagram](k8s.core.architecture.png)

# Master Nodes

Master nodes or Kubernetes Control Plane are the controlling unit for the
cluster. They manage scheduling of new containers, configure networking and
provide health information.

To do so it uses:

* [kube-api-server](https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver)
  exposes the Kubernetes control plane API validating and configuring data for
  the different API objects. It's used by all the components to interact between
  themselves.

* [etcd](https://en.wikipedia.org/wiki/Container_Linux#ETCD) is a "Distributed
  reliable key-value store for the most critical data of a distributed system".
  Kubernetes uses Etcd to store state about the cluster and service discovery
  between nodes. This state includes what nodes exist in the cluster, which
  nodes they are running on and what containers should be running.

* [kube-scheduler](https://kubernetes.io/docs/concepts/overview/components/#kube-scheduler)
  watches for newly created pods with no assigned node, and selects a node for
  them to run on.

    Factors taken into account for scheduling decisions include individual and
    collective resource requirements, hardware/software/policy constraints,
    affinity and anti-affinity specifications, data locality, inter-workload
    interference and deadlines.

* [kube-controller-manager](https://kubernetes.io/docs/concepts/overview/components/#kube-controller-manager)
  runs the following controllers:
    * *Node Controller*: Responsible for noticing and responding when nodes go
      down.
    * *Replication Controller*: Responsible for maintaining the correct number
      of pods for every replication controller object in the system.
    * *Endpoints Controller*: Populates the Endpoints object (that is, joins
      Services & Pods).
    * *Service Account & Token Controllers*: Create default accounts and API
      access tokens for new namespaces.

* [cloud-controller-manager](https://kubernetes.io/docs/concepts/overview/components/#cloud-controller-manager)
  runs controllers that interact with the underlying cloud providers.
    * *Node Controller*: For checking the cloud provider to determine if a node
      has been deleted in the cloud after it stops responding.
    * *Route Controller*: For setting up routes in the underlying cloud
      infrastructure.
    * *Service Controller*: For creating, updating and deleting cloud provider
      load balancers.
    * *Volume Controller*: For creating, attaching, and mounting volumes, and
      interacting with the cloud provider to orchestrate volumes.

# Worker Nodes

Worker nodes are the units that hold the application data of the
cluster. There can be different types of nodes: CPU architecture, amount of
resources (CPU, RAM, GPU) or cloud provider.

Each node has the services necessary to run pods:

* [Container
  Runtime](https://kubernetes.io/docs/concepts/overview/components/#container-runtime):
  The software responsible for running containers (Docker, rkt, containerd,
  CRI-O).
* [kubelet](https://kubernetes.io/docs/admin/kubelet/): The primary “node
  agent”. It works in terms of a PodSpec (a YAML or JSON object that describes
  it). `kubelet` takes a set of PodSpecs from the masters `kube-api-server` and
  ensures that the containers described are running and healthy.
* [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/) is
  the network proxy that runs on each node. This reflects services as defined in
  the Kubernetes API on each node and can do simple TCP and UDP stream
  forwarding or round robin across a set of backends.

    `kube-proxy` maintains network rules on nodes. These network rules allow
    network communication to your Pods from network sessions inside or outside
    of your cluster.

    `kube-proxy` uses the operating system packet filtering layer if there is
    one and it's available. Otherwise, it will forward the traffic itself.

## kube-proxy operation modes

`kube-proxy` currently supports three different operation modes:

* *User space*: This mode gets its name because the service routing takes place in
  kube-proxy in the user process space instead of in the kernel network stack.
  It is not commonly used as it is slow and outdated.
* *iptables*: This mode uses Linux kernel-level Netfilter rules to configure all
  routing for Kubernetes Services. This mode is the default for kube-proxy on
  most platforms. When load balancing for multiple backend pods, it uses
  unweighted round-robin scheduling.
* *IPVS (IP Virtual Server)*: Built on the Netfilter framework, IPVS implements
  Layer-4 load balancing in the Linux kernel, supporting multiple load-balancing
  algorithms, including least connections and shortest expected delay. This
  kube-proxy mode became generally available in Kubernetes 1.11, but it requires
  the Linux kernel to have the IPVS modules loaded. It is also not as widely
  supported by various Kubernetes networking projects as the iptables mode.

# Kubectl

The *kubectl* is the command line client used to communicate with the Masters.

# Links

* [Kubernetes components overview](https://kubernetes.io/docs/concepts/overview/components/)
