---
title: Kubernetes Deployments
date: 20200302
author: Lyz
---

The [different types of
deployments](https://medium.com/google-cloud/running-workloads-in-kubernetes-86194d133593)
configure a ReplicaSet and a PodSchema for your application.

Depending on the type of application we'll use one of the following types.

# [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

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

# [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

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

# [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

DaemonSets are the controller for applications that need to be run in each node.
It's useful for recollecting log or monitoring purposes.

DaemonSet makes sure that every node runs a copy of a pod. If you add or remove
nodes, pods will be created or removed on them automatically. If you just want
to run the daemons on some of the nodes, use node labels to control it.

Concrete examples: fluentd, linkerd

# [Job](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/)

Jobs are the controller to run batch processing workloads. It creates multiple
pods running in parallel to process independent but related work items. This can
be the emails to be sent or frames to be rendered.
