---
title: Kubernetes Ingress
date: 20200224
author: Lyz
---

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
is An API object that manages external access to the services in a cluster,
typically HTTP.

Ingress provide a centralized way to:

* Load balancing.
* SSL termination.
* Dynamic service discovery.
* Traffic routing.
* Authentication.
* Traffic distribution: canary deployments, A/B testing, mirroring/shadowing.
* Graphical user interface.
* JWT validation.
* WAF and DDOS protection.
* Requests tracing.

An [Ingress controller](kubernetes_ingress_controller.md) is responsible for
fulfilling the Ingress, usually with a load balancer, though it may also
configure your edge router or additional frontends to help handle the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other
than HTTP and HTTPS to the internet typically uses
a [service](kubernetes_services.md) of type
[NodePort](kubernetes_services.md#nodeport) or
[LoadBalancer](kubernetes_services.md#loadbalancer).
