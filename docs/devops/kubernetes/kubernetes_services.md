---
title: Kubernetes Services
date: 20200302
author: Lyz
---

A [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
defines a policy to access a logical set of Pods using a reliable endpoint.
Users and other programs can access pods running on your cluster seamlessly.
Therefore allowing a loose coupling between dependent Pods.

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
