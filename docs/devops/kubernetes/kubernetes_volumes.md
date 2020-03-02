---
title: Kubernetes Volumes
date: 20200302
author: Lyz
---

On disk files in a Container are ephemeral by default, which presents the
following issues:

* When a Container crashes, kubelet will restart it, but the files will be lost.
* When running Containers together in a Pod it is often necessary to share files
  between those Containers.

The [Kubernetes Volume](https://kubernetes.io/docs/concepts/storage/volumes/)
abstraction solves both of these problems with [several
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

