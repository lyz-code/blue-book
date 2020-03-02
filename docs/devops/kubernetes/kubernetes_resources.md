---
title: Kubernetes Resources
date: 20200302
author: Lyz
---

Kubernetes define it's different internal objects through YAML manifests.

# [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

Namespaces are virtual clusters backed by the same physical cluster. It's the
first level of isolation between applications.

## When to Use Multiple Namespaces

Namespaces are intended for use in environments with many users spread across
multiple teams, or projects. For clusters with a few to tens of users, you
should not need to create or think about namespaces at all. Start using
namespaces when you need the features they provide.

Namespaces provide a scope for names. Names of resources need to be unique
within a namespace, but not across namespaces.

Namespaces are a way to divide cluster resources between multiple uses (via
resource quota).

It is not necessary to use multiple namespaces just to separate slightly
different resources, such as different versions of the same software: use
labels to distinguish resources within the same namespace.

# [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/)

A Pod is the basic building block of Kubernetes, the smallest and simplest unit
in the object model that you create or deploy. A Pod represents
a running process on your cluster.

A Pod represents a unit of deployment. It encapsulates:

* An application container (or, in some cases, multiple tightly coupled containers).
* Storage resources.
* A unique network IP.
* Options that govern how the container(s) should run.

# [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

A ReplicaSet maintains a stable set of replica Pods running at any given time.
As such, it is often used to guarantee the availability of a specified number of
identical Pods.

You'll probably never manually use these resources, as they are defined inside
the [deployments](#deployments). The older version of this resource are the
[Replication
controllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/).

# [Deployment types](https://medium.com/google-cloud/running-workloads-in-kubernetes-86194d133593)

The different types of deployments configure a ReplicaSet and a PodSchema for
your application.

Depending on the type of application we'll use one of the following types.

## [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

Deployments are the controller for stateless applications, therefore it favors
availability over consistency.

It provides availability by creating multiple copies of the same pod. Those pods
are disposable — if they become unhealthy, Deployment will just create new
replacements. What’s more, you can update Deployment at a controlled rate,
without a service outage. When an incident like the AWS outage happens, your
workloads will automatically recover.

Pods created by Deployment won't have the same identity after being killed and
recreated, and they don't have unique persistent storage either.

Concrete examples: Nginx, Tomcat

A typical use case is:

* Create a Deployment to bring up a Replica Set and Pods.
* Check the status of a Deployment to see if it succeeds or not.
* Later, update that Deployment to recreate the Pods (for example, to use a new
  image).
* Rollback to an earlier Deployment revision if the current Deployment isn't
  stable.
* Pause and resume a Deployment.

Deployment example

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

## [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

StatefulSets are the controller for stateful applications, therefore it favors
consistency over availability.

If your applications need to store data, like databases, cache, and message
queues, each of your stateful pod will need a stronger notion of identity. Unlike
[Deployment](#deployments), StatefulSets creates pods with stable, unique, and sticky identity
and storage. You can deploy, scale, and delete pods in order. Which is safer,
and makes it easier for you to reason about your stateful applications.

Concrete examples: Zookeeper, MongoDB, MySQL

The tricky part of the StatefulSets is that in multi node cluster on different
regions in AWS, as the persistence is achieved with EBS volumes and
they are fixed to a region. Your pod will always spawn in the same node. If
there is a failure in that node, the pod will be marked as unschedulable and
the service will be down.

So as of 2020-03-02 is still not advised to host your databases inside kubernetes
unless you have an [operator](kubernetes_operators.md).

## [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

DaemonSets are the controller for applications that need to be run in each node.
It's useful for recollecting log or monitoring purposes.

DaemonSet makes sure that every node runs a copy of a pod. If you add or remove
nodes, pods will be created or removed on them automatically. If you just want
to run the daemons on some of the nodes, use node labels to control it.

Concrete examples: fluentd, linkerd

## [Job](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/)

Jobs are the controller to run batch processing workloads. It creates multiple
pods running in parallel to process independent but related work items. This can
be the emails to be sent or frames to be rendered.

# [Horizontal pod autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

With Horizontal Pod Autoscaling, Kubernetes automatically scales the number of
pods in a deployment or replication controller based on observed
CPU utilization or on some other application provided metrics.

The Horizontal Pod Autoscaler is implemented as a Kubernetes API resource and
a controller. The resource determines the behavior of the controller. The
controller periodically adjusts the number of replicas in a replication
controller or deployment to match the observed average CPU utilization to the
target specified by user.

To make it work, the definition of [pod resource
consumption](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
needs to be specified.

# [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

On disk files in a Container are ephemeral by default, which presents the
following issues:

* When a Container crashes, kubelet will restart it, but the files will be lost.
* When running Containers together in a Pod it is often necessary to share files
  between those Containers.

The Kubernetes Volume abstraction solves both of these problems with [several
types](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes).

## [configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

The `configMap` resource provides a way to inject configuration data into Pods.
The data stored in a ConfigMap object can be referenced in a volume of type
`configMap` and then consumed by containerized applications running in a Pod.

## [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

An `emptyDir` volume is first created when a Pod is assigned to a Node, and exists
as long as that Pod is running on that node. As the name says, it is initially
empty. Containers in the Pod can all read and write the same files in the
`emptyDir` volume. When a Pod is removed from a node for any reason, the data in
the `emptyDir` is deleted forever.

## [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)

A `hostPath` volume mounts a file or directory from the host node’s filesystem
into your Pod. This is not something that most Pods will need, but it offers
a powerful escape hatch for some applications.

For example, some uses for a hostPath are:

* Running a Container that needs access to Docker internals; use a hostPath of
  `/var/lib/docker`.
* Running cAdvisor in a Container; use a hostPath of `/sys`.

## [secret](https://kubernetes.io/docs/user-guide/secrets)

A `secret` volume is used to pass sensitive information, such as passwords, to
Pods. You can store secrets in the Kubernetes API and mount them as files for
use by Pods without coupling to Kubernetes directly. `secret` volumes are backed
by tmpfs (a RAM-backed filesystem) so they are never written to non-volatile
storage.

## [awsElasticBlockStore](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)

An `awsElasticBlockStore` volume mounts an Amazon Web Services (AWS) EBS Volume
into your Pod. Unlike `emptyDir`, which is erased when a Pod is removed, the
contents of an EBS volume are preserved and the volume is merely unmounted. This
means that an EBS volume can be pre-populated with data, and that data can be
“handed off” between Pods.

There are some restrictions when using an awsElasticBlockStore volume:

* The nodes on which Pods are running must be AWS EC2 instances.
* Those instances need to be in the same region and availability-zone as the EBS
  volume.
* EBS only supports a single EC2 instance mounting a volume.

## [nfs](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)

An `nfs` volume allows an existing NFS (Network File System) share to be mounted
into your Pod. Unlike emptyDir, which is erased when a Pod is removed, the
contents of an `nfs` volume are preserved and the volume is merely unmounted. This
means that an NFS volume can be pre-populated with data, and that data can be
“handed off” between Pods. NFS can be mounted by multiple writers
simultaneously.

## [local](https://kubernetes.io/docs/concepts/storage/volumes/#local)

A `local` volume represents a mounted local storage device such as a disk,
partition or directory.

Local volumes can only be used as a statically created PersistentVolume. Dynamic
provisioning is not supported yet.

Compared to `hostPath` volumes, local volumes can be used in a durable and
portable manner without manually scheduling Pods to nodes, as the system is
aware of the volume’s node constraints by looking at the node affinity on the
PersistentVolume.

However, local volumes are still subject to the availability of the underlying
node and are not suitable for all applications. If a node becomes unhealthy,
then the local volume will also become inaccessible, and a Pod using it will not
be able to run. Applications using local volumes must be able to tolerate this
reduced availability, as well as potential data loss, depending on the
durability characteristics of the underlying disk.

## Others

* [glusterfs](https://kubernetes.io/docs/concepts/storage/volumes/#glusterfs)
* [cephfs](https://kubernetes.io/docs/concepts/storage/volumes/#cephfs)

# [Services](https://kubernetes.io/docs/concepts/services-networking/service/)

A Service defines a logical set of Pods and a policy by which to access them.
Using a reliable endpoint, users and other programs can access pods running on
your cluster seamlessly. Therefore allowing a loose coupling between dependent
Pods.

When a request arrives the endpoint, the kube-proxy pod of the node forwards the
request to the Pods that match the service LabelSelector.

Services can be exposed in different ways by specifying a type in the
ServiceSpec:

* *ClusterIP* (default): Exposes the Service on an internal IP in the cluster.
  This type makes the Service only reachable from within the cluster.

* *NodePort*: Exposes the Service on the same port of each selected Node in the
  cluster using NAT to the outside.

* *LoadBalancer*: Creates an external load balancer in the current cloud
  and assigns a fixed, external IP to the Service.

    To create an internal ELB of AWs add to the annotations:
    ```yaml
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
    ```

* *ExternalName*: Exposes the Service using an arbitrary name by returning
  a CNAME record with the name. No proxy is used.

If no [RBAC](#rbac) or [NetworkPolicies](kubernetes_networking.md) are applied,
you can call a service of another namespace with the following nomenclature.

```bash
curl {{ service_name}}.{{ service_namespace }}.svc.cluster.local
```

# [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

Labels are identifying metadata key/value pairs attached to objects, such as
pods. Labels are intended to give meaningful and relevant information to users,
but which do not directly imply semantics to the core system.

```yaml
"labels": {
  "key1" : "value1",
  "key2" : "value2"
}
```

# [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

Annotations are non-identifying metadata key/value pairs attached to objects,
such as pods. Annotations are intended to give meaningful and relevant information
to libraries and tools.

Annotations, like labels, are key/value maps:

```yaml
"annotations": {
  "key1" : "value1",
  "key2" : "value2"
}
```

Here are some examples of information that could be recorded in annotations:

* Fields managed by a declarative configuration layer. Attaching these fields
  as annotations distinguishes them from default values set by clients or
  servers, and from auto generated fields and fields set by auto sizing or
  auto scaling systems.
* Build, release, or image information like timestamps, release IDs, git
  branch, PR numbers, image hashes, and registry address.
* Pointers to logging, monitoring, analytics, or audit repositories.
* Client library or tool information that can be used for debugging purposes,
  for example, name, version, and build information.
* User or tool/system provenance information, such as URLs of related objects
  from other ecosystem components.
* Lightweight rollout tool metadata: for example, config or checkpoints.

# [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

An API object that manages external access to the services in a cluster, typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

An [Ingress
controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
is responsible for fulfilling the Ingress, usually with a load balancer, though
it may also configure your edge router or additional frontends to help handle
the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other
than HTTP and HTTPS to the internet typically uses a [service](#services) of type
[NodePort](#nodeport) or [LoadBalancer](#loadbalancer).
