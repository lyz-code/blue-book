---
title: Kubernetes Ingress
date: 20200224
author: Lyz
tags:
  - WIP
---

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
is An API object that manages external access to the services in a cluster,
typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

An [Ingress
controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
is responsible for fulfilling the Ingress, usually with a load balancer, though
it may also configure your edge router or additional frontends to help handle
the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other
than HTTP and HTTPS to the internet typically uses
a [service](kubernetes_services.md) of type
[NodePort](kubernetes_services.md#nodeport) or
[LoadBalancer](kubernetes_services.md#loadbalancer).

## Ingress controllers comparison

There are different Ingress controllers, such as AWS ALB, Nginx, HAProxy or
Traeffik, using one or other depends on your needs.

# Links

* [ITNext ingress
  comparison](https://itnext.io/kubernetes-ingress-controllers-how-to-choose-the-right-one-part-1-41d3554978d2)

