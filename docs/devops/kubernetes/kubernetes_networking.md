---
title: Networking
date: 20200210
author: Lyz
---

*Container networking* is the mechanism through which containers can optionally
connect to other containers, the host, and outside networks like the internet.

If you want to get a quickly grasp on how k8s networking works, I suggest you to
read [StackRox's Kubernetes networking demystified
article](https://www.stackrox.com/post/2020/01/kubernetes-networking-demystified/).

# CNI comparison

*Container networking* is the mechanism through which containers can optionally
connect to other containers, the host, and outside networks like the internet.

There are different container networking plugins you can use for your cluster.
To ensure that you choose the best one for your use case, I've made a summary
based on the following resources:

* [Rancher k8s CNI comparison](https://rancher.com/blog/2019/2019-03-21-comparing-kubernetes-cni-providers-flannel-calico-canal-and-weave/).
* [ITnext k8s CNI
  comparison](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-updated-april-2019-4a9886efe9c4).
* [Mark Ramm-Christensen AWS CNI
  analysis](https://dzone.com/articles/aws-and-kubernetes-networking-options-and-trade-of).

## TL;DR

When using EKS, if you have no networking experience and understand and accept
their [disadvantages](#disadvantages-of-the-aws-cni) I'd use the AWS VPC CNI as
it's installed by default. Nevertheless, the pod limit per node and the vendor
locking makes interesting to migrate in the future to Calico. To make the
transition smoother, you can enable Calico Network Policies with the AWS VPC CNI
and get used to them before fully migrating to Calico.

Calico seems to be the best solution when you need a greater control of the
networking inside k8s, as it supports security features (NetworkPolicies or
encryption), that can be improved even more with the integration with Istio.
It's known to be easy to debug and has commercial support.

If you aren't using EKS, you could evaluate to first use Canal as it uses Flannel
simple network overlay but with Calico's Network Policies. If you do this, you
could first focus in getting used to Network Policies and then dive further into
the network configuration with Calico. But a deeper analysis should be done to
assess if the compared difficulty justifies the need of this step.

I don't recommend to use Flannel alone even though it's simple as you'll
probably need security features such as NetworkPolicies, although they say, it's
the best insecure solution for low resource or several architecture nodes.

I wouldn't use Weave either unless you need  encryption throughout all the
internal network and multicast.

## Flannel

[Flannel](https://github.com/coreos/flannel), a project developed by the CoreOS,
is perhaps the most straightforward and popular CNI plugin available. It is one
of the most mature examples of networking fabric for container orchestration
systems, intended to allow for better inter-container and inter-host networking.
As the CNI concept took off, a CNI plugin for Flannel was an early entry.

Flannel is relatively easy to install and configure. It is packaged as a single
binary called flanneld and can be installed by default by many common Kubernetes
cluster deployment tools and in many Kubernetes distributions. Flannel can use
the Kubernetes cluster’s existing etcd cluster to store its state information
using the API to avoid having to provision a dedicated data store.

Flannel configures a layer 3 IPv4 overlay network. A large internal network is
created that spans across every node within the cluster. Within this overlay
network, each node is given a subnet to allocate IP addresses internally. As
pods are provisioned, the Docker bridge interface on each node allocates an
address for each new container. Pods within the same host can communicate using
the Docker bridge, while pods on different hosts will have their traffic
encapsulated in UDP packets by flanneld for routing to the appropriate
destination.

Flannel has several different types of backends available for encapsulation and
routing. The default and recommended approach is to use VXLAN, as it offers both
good performance and is less manual intervention than other options.

Overall, Flannel is a good choice for most users. From an administrative
perspective, it offers a simple networking model that sets up an environment
that’s suitable for most use cases when you only need the basics. In general,
it’s a safe bet to start out with Flannel until you need something that it
cannot provide or you need security features, such as NetworkPolicies or
encryption.

It's also recommended if you have low resource nodes in your cluster (only a few
GB of RAM, a few cores). Moreover, it is compatible with a very large number of
architectures (amd64, arm, arm64, etc.). It is the only one, along with Cilium,
that is able to correctly auto-detect your MTU, so you don’t have to configure
anything to let it work.

## Calico

[Calico](https://www.projectcalico.org/), is another popular networking option
in the Kubernetes ecosystem. While Flannel is positioned as the simple choice,
Calico is best known for its performance, flexibility, and power. Calico takes
a more holistic view of networking, concerning itself not only with providing
network connectivity between hosts and pods, but also with network security and
administration.

On a freshly provisioned Kubernetes cluster that meets the system requirements,
Calico can be deployed quickly by applying a single manifest file. If you are
interested in Calico’s optional network policy capabilities, you can enable them
by applying an additional manifest to your cluster.

Unlike Flannel, Calico does not use an overlay network. Instead, Calico
configures a layer 3 network that uses the BGP routing protocol to route packets
between hosts. This means that packets do not need to be wrapped in an extra
layer of encapsulation when moving between hosts. The BGP routing mechanism can
direct packets natively without an extra step of wrapping traffic in an
additional layer of traffic.

Besides the performance that this offers, one side effect of this is that it
allows for more conventional troubleshooting when network problems arise. While
encapsulated solutions using technologies like VXLAN work well, the process
manipulates packets in a way that can make tracing difficult. With Calico, the
standard debugging tools have access to the same information they would in
simple environments, making it easier for a wider range of developers and
administrators to understand behavior.

In addition to networking connectivity, Calico is well known for its advanced
network features. Network policy is one of its most sought after capabilities.
In addition, Calico can also integrate with [Istio](https://istio.io/),
a service mesh, to interpret and enforce policy for workloads within the cluster
both at the service mesh layer and the network infrastructure layer. This means
that you can configure powerful rules describing how pods should be able to send
and accept traffic, improving security and control over your networking
environment.

Project Calico is a good choice for environments that support its requirements
and when performance and features like network policy are important.
Additionally, Calico offers commercial support if you’re seeking a support
contract or want to keep that option open for the future. In general, it’s
a good choice for when you want to be able to control your network instead of
just configuring it once and forgetting about it.

If you are looking on how to install Calico, you can start with [Calico guide
for clusters with less than 50 nodes](https://docs.projectcalico.org/v3.7/getting-started/kubernetes/installation/calico#installing-with-the-kubernetes-api-datastore50-nodes-or-less)
or if you use EKS with [AWS
guide](https://docs.aws.amazon.com/eks/latest/userguide/calico.html).

## Canal

[Canal](https://github.com/projectcalico/canal) is an interesting option for
quite a few reasons.

First of all, Canal was the name for a project that sought to integrate the
networking layer provided by flannel with the networking policy capabilities of
Calico. As the contributors worked through the details however, it became
apparent that a full integration was not necessarily needed if work was done on
both projects to ensure standardization and flexibility. As a result, the
official project became somewhat defunct, but the intended ability to deploy the
two technology together was achieved. For this reason, it’s still sometimes
easiest to refer to the combination as “Canal” even if the project no longer
exists.

Because Canal is a combination of Flannel and Calico, its benefits are also at
the intersection of these two technologies. The networking layer is the simple
overlay provided by Flannel that works across many different deployment
environments without much additional configuration. The network policy
capabilities layered on top supplement the base network with Calico’s powerful
networking rule evaluation to provide additional security and control.

After ensuring that the cluster fulfills the necessary system requirements,
Canal can be deployed by applying two manifests, making it no more difficult to
configure than either of the projects on their own. Canal is a good way for
teams to start to experiment and gain experience with network policy before
they’re ready to experiment with changing their actual networking.

In general, Canal is a good choice if you like the networking model that Flannel
provides but find some of Calico’s features enticing. The ability define network
policy rules is a huge advantage from a security perspective and is, in many
ways, Calico’s killer feature. Being able to apply that technology onto
a familiar networking layer means that you can get a more capable environment
without having to go through much of a transition.

## Weave Net

[Weave Net](https://www.weave.works/oss/net/) by Weaveworks is a CNI-capable
networking option for Kubernetes that offers a different paradigm than the
others we’ve discussed so far. Weave creates a mesh overlay network between each
of the nodes in the cluster, allowing for flexible routing between participants.
This, coupled with a few other unique features, allows Weave to intelligently
route in situations that might otherwise cause problems.

To create its network, Weave relies on a routing component installed on each
host in the network. These routers then exchange topology information to
maintain an up-to-date view of the available network landscape. When looking to
send traffic to a pod located on a different node, the weave router makes an
automatic decision whether to send it via “fast datapath” or to fall back on the
“sleeve” packet forwarding method.

Fast datapath is an approach that relies on the kernel’s native Open vSwitch
datapath module to forward packets to the appropriate pod without moving in and
out of userspace multiple times. The Weave router updates the Open vSwitch
configuration to ensure that the kernel layer has accurate information about how
to route incoming packets. In contrast, sleeve mode is available as a backup
when the networking topology isn’t suitable for fast datapath routing. It is
a slower encapsulation mode that can route packets in instances where fast
datapath does not have the necessary routing information or connectivity. As
traffic flows through the routers, they learn which peers are associated with
which MAC addresses, allowing them to route more intelligently with fewer hops
for subsequent traffic. This same mechanism helps each node self-correct when
a network change alters the available routes.

Like Calico, Weave also provides network policy capabilities for your cluster.
This is automatically installed and configured when you set up Weave, so no
additional configuration is necessary beyond adding your network rules. One
thing that Weave provides that the other options do not is easy encryption for
the entire network. While it adds quite a bit of network overhead, Weave can be
configured to automatically encrypt all routed traffic by using NaCl encryption
for sleeve traffic and, since it needs to encrypt VXLAN traffic in the kernel,
IPsec ESP for fast datapath traffic.

Another advantage of Weave is that it's the only CNI that supports multicast. In
case you need it.

Weave is a great option for those looking for feature rich encrypted networking
without adding a large amount of complexity or management at the expense of
worse overall performance.  It is relatively easy to set up, offers many
built in and automatically configured features, and can provide routing in
scenarios where other solutions might fail. The mesh topography does put a limit
on the size of the network that can be reasonably accommodated, but for most
users, this won’t be a problem. Additionally, Weave offers paid support for
organizations that prefer to be able to have someone to contact for help and
troubleshooting.

## AWS CNI

AWS developed [their own CNI](https://github.com/aws/amazon-vpc-cni-k8s) that
uses [Elastic Network
Interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)
for pod networking.

It's the default CNI if you use EKS.

### Advantages of the AWS CNI

Amazon native networking provides a number of significant advantages over some
of the more traditional overlay network solutions for Kubernetes:

* Raw AWS network performance.
* Integration of tools familiar to AWS developers and admins, like AWS VPC flow
  logs and Security Groups — allowing users with existing VPC networks and
  networking best practices to carry those over directly to Kubernetes.
* The ability to enforce network policy decisions at the Kubernetes layer if you
  install Calico.

If your team has significant experience with AWS networking, and/or your
application is sensitive to network performance all of this makes VPC CNI very
attractive.

### Disadvantages of the AWS CNI

On the other hand, there are a couple of limitations that may be significant to
you. There are three primary reasons why you might instead choose an overlay
network.

* Makes the multi-cloud k8s advantage more difficult.
* the CNI limits the number of pods that can be scheduled on each k8s node
  according to the number of IP Addresses available to each EC2 instance type so
  that each pod can be allocated an IP.
* Doesn't support encryption on the network.
* Multicast requirements.
* It eats up the number of IP Addresses available within your VPC unless you
  give it an alternate subnet.

#### VPC CNI Pod Density Limitations

First, the VPC CNI plugin is designed to use/abuse ENI interfaces to get each
pod in your cluster its own IP address from Amazon directly.

This means that you will be network limited in the number of pods that you can
run on any given worker node in the cluster.

The primary IP for each ENI is used for cluster communication purposes. New pods
are assigned to one of the secondary IPs for that ENI. VPC CNI has a custom
[DaemonSet](kubernetes_deployments.md#daemonset) that manages the assignment of
IPs to pods. Because ENI and IP allocation requests can take time, this l-ipam
daemon creates a warm pool of ENIs and IPs on each node and uses one of the
available IPs for each new pod as it is assigned. This yields the following
formula for maximum pod density for any given instance:

```
ENIs * (IPs_per_ENI - 1)
```

Each instance type in Amazon has unique limitations in the number of ENIs and
IPs per ENI allowed. For example, an m5.large worker node allows 25 pod IP
addresses per node at an approximate cost of $2.66/month per pod.

Stepping up to an m5.xlarge allows for a theoretical maximum of 55 pods, for
a monthly cost of $2.62, making the m5.large the more cost effective node choice
by a small amount for clusters bound by IP address limitations.

And if that set of calculations is not enough, there are a few other factors to
consider. Kubernetes clusters generally run a set of services on each node. VPC
CNI itself uses an l-ipam DaemonSet, and if you want Kubernetes network
policies, calico requires another. Furthermore, production clusters generally
also have DaemonSets for metrics collection, log aggregation, and other
cluster-wide services. Each of these uses an IP address per node.

So now the formula is:

```
(ENIs * (IPs_per_ENI - 1) - 1 * DaemonSets
```

This makes some of the cheaper instances on Amazon completely unusable because
there are no IP addresses left for application pods.

On the other hand, Kubernetes itself has a supported limit of 100 pods per node,
making some of the larger instances with lots of available addresses less
attractive. However, the pod per node limit IS configurable, and in my
experience, this limit can be increased without much increase in Kubernetes
overhead.

Weave people made a [quick Google
sheet](https://docs.google.com/spreadsheets/d/1MCdsmN7fWbebscGizcK6dAaPGS-8T_dYxWp0IdwkMKI/edit#gid=1549051942)
with each of the Amazon instance types, and the maximum pod densities for each
based on the VPC CNI network plugin restrictions:

* A 100 pod/node limit setting in Kubernetes,
* A default of 4 DaemonSets (2 for AWS networking, 1 for log aggregation, and
  1 for metric collection),
* A simple cost calculation for per-pod pricing.

This sheet is not intended to provide a definitive answer on pod economics for
AWS VPC based Kubernetes clusters. There are a number of important caveats to
the use of this sheet:

* CPU and memory requirements will often dictate lower pod density than the
  theoretical maximum here.
* Beyond DaemonSets, Kubernetes System pods, and other “system level”
  operational tools used in your cluster will consume Pod IP’s and limit the
  number of application pods that you can run.
* Each instance type also has network performance limitations which may impact
  performance often far before theoretical pod limits are reached.

#### Cloud Portability

Hybrid cloud, disaster recovery, and other requirements often push users away
from custom cloud vendor solutions and towards open solutions.

However, in this case the level of lock-in is quite low. The CNI layer provides
a level of abstraction on top of the underlying network, and it is possible to
deploy the same workloads using the same deployment configurations with
different CNI backends. Which from my point of view, seems a bad and ugly idea.

# Links

* [StackRox Kubernetes networking demystified
article](https://www.stackrox.com/post/2020/01/kubernetes-networking-demystified/).
* [Writing your own simple CNI plug
  in](https://www.altoros.com/blog/kubernetes-networking-writing-your-own-simple-cni-plug-in-with-bash/).
