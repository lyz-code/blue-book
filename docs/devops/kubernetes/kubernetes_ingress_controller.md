---
title: Kubernetes Ingress Controller
date: 20200303
author: Lyz
---

Ingress controllers monitor the cluster events for the creation or modification
of [Ingress](kubernetes_ingress.md) resources, modifying accordingly the
underlying load balancers. They are not part of the master
[kube-controller-manager](kubernetes_architecture.md#kube-controller-manager),
so you'll need to install them manually.

There are different Ingress controllers, such as AWS ALB, Nginx, HAProxy or
Traefik, using one or other depends on your needs.

Almost all controllers are open sourced and support dynamic service discovery,
SSL termination or WebSockets. But they differ in:

* *Supported protocols*: HTTP, HTTPS, gRPC, HTTP/2.0, TCP (with SNI) or UDP.
* *Underlying software*: NGINX, Traefik, HAProxy or Envoy.
* *Traffic routing*: host and path, regular expression support.
* *Namespace limitations*: supported or not.
* *Upstream probes*: active checks, passive checks, retries, circuit breakers,
    custom health checks...
* *Load balancing algorithms*: round-robin, sticky sessions, rdp-cookie...
* *Authentication*: Basic, digest, Oauth, external auth, SSL certificate...
* *Traffic distribution*: canary deployments, A/B testing, mirroring/shadowing.
* *Paid subscription*: extended functionality or technical support.
* *Graphical user interface*:
* *JWT validation*:
* *Customization of configuration*:
* *Basic DDOS protection mechanisms*: rate limit, traffic filtering.
* *WAF*:
* *Requests tracing*: monitor, trace and debug requests via OpenTracing or other
    options.

Both
[ITNext](https://itnext.io/kubernetes-ingress-controllers-how-to-choose-the-right-one-part-1-41d3554978d2)
and
[Flant](https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b)
provide good ingress controller comparisons, a synoptical resume of both
articles follows.

![ ](ingress_controller_comparison.png)

# [Kubernetes Ingress controller](https://github.com/kubernetes/ingress-nginx)

The “official” Kubernetes controller. Not to be confused with the one offered by
the NGINX company. Developed by the community, it's based on the Nginx web
server with a set of Lua plugins to implement extra features.

Thanks to the popularity of NGINX and minimal modifications over it when using
as a controller, it can be the simplest and most straightforward option for an
average engineer dealing with K8s.

# [Traefik](https://github.com/containous/traefik)

Originally, this proxy was created for the routing of requests for microservices
and their dynamic environment, hence many of its useful features:

* Continuous update of configuration (no restarts) .
* Support for multiple load balancing algorithms.
* Web UI.
* Metrics export.
* Support for various protocols.
* REST API.
* Canary releases.
* Let’s Encrypt certificates support.
* TCP/SSL with SNI.
* Traffic mirroring/shadowing.

The main disadvantage is that in order to organize the high availability of the
controller you have to install and connect its own KV-storage.

In 2019, the same developers have developed
[Maesh](https://github.com/containous/maesh). Another service mesh solution
built on top of Traefik.

# [HAProxy](https://github.com/jcmoraisjr/haproxy-ingress)

HAProxy is well known as a proxy server and load balancer. As part of the
Kubernetes cluster, it offers:
* “soft” configuration update (without traffic loss)
* DNS-based service discovery
* Dynamic configuration through API.
* Full customization of a config-files template (via replacing a ConfigMap).
* Using Spring Boot functions.
* Great number of supported balancing algorithms.

In general, developers put emphasis on high speed, optimization, and efficiency
in consumed resources.

It’s worth mentioning a lot of new features have appeared in a recent (June’19)
v2.0 release, and even more (including OpenTracing support) is expected with
upcoming v2.1.

# [Istio Ingress](https://istio.io/docs/tasks/traffic-management/ingress/)

Istio is a comprehensive service mesh solution. It can manage not just all
incoming outside traffic (as an Ingress controller) but control all traffic
inside the cluster as well. Under the hood, Istio uses Envoy as a sidecar-proxy
for each service. In essence, it is a large processor that can do almost
anything. Its central idea is maximum control, extensibility, security, and
transparency.

With Istio Ingress, you can fine tune traffic routing, access authorization
between services, balancing, monitoring, canary releases and much more.

“[Back to microservices with
Istio](https://medium.com/google-cloud/back-to-microservices-with-istio-p1-827c872daa53)” is
a great intro to learn about Istio.

# [ALB Ingress controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller)

The AWS ALB Ingress Controller satisfies Kubernetes ingress resources by
provisioning [Application Load
Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).

It's advantages are:

* AWS managed loadbalancer.
* Authentication with OIDC or Cognito.
* AWS WAF support.
* Natively redirect HTTP to HTTPS.
* Supports fixed response without forwarding to the application..

It has also the potential advantage of using IP traffic mode. ALB support two
types of traffic:

* *instance mode*: Ingress traffic starts from the ALB and reaches the NodePort
  opened for your service. Traffic is then routed to the container Pods within
  the cluster. The number of hops for the packet to reach its destination in
  this mode is always two.
* *IP mode*: Ingress traffic starts from the ALB and reaches the container Pods
  within cluster directly. In order to use this mode, the networking plugin for
  the K8s cluster must use a secondary IP address on ENI as pod IP, aka AWS CNI
  plugin for K8s. The number of hops for the packet to reach its destination is
  always one.

The *IP mode* gives the following advantages:

* The load balancer can be pod location-aware: reduce the chance to route
  traffic to an irrelevant node and then rely on kube-proxy and network agent.
* The number of hops for the packet to reach its destination is *always one*
* *No extra overlay network* comparing to using Network plugins (Calico, Flannel)
  directly int he cloud (AWS).

It also has it's disadvantages:

* Even though AWS [guides you on it's
    deployment](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html),
    after two months of AWS Support cases, I wasn't able to deploy it using
    terraform and [helm](helm.md).
* You can't [reuse existing ALBs instead of creating new ALB per
  ingress](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/issues/298).

    Therefore `ingress: false` needs to be specified in the service helm chart and
    manually edit the ALB ingress helm chart to add each new service.

## ALB ingress deployment

!!! warning ""
    This section is a defunct work in progress. I wasn't able to make it work,
    but it can be useful if you want to deploy it yourself. If you success,
    please make a [PR](https://github.com/lyz-code/blue-book).

I've used the [AWS
Guide](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/controller/config/),
in conjunction with the [AWS general ALB controller
documentation](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
and the [AWS general ALB
documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html)
to define the properties of the [incubator helm
chart](https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller).

Before that you need to an IAM policy
[ALBIngressControllerIAMPolicy](https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/iam-policy.json)
to give the required permissions to manage the certificates, ALB creation and
WAF integration. That IAM policy needs to be attached to the
`eks-alb-ingress-controller` IAM role.

You also had to create an IAM OIDC provider, which are entities in IAM that
describe an external identity provider (IdP) service that supports the OpenID
Connect (OIDC) standard, such as Google or Github. You use an IAM OIDC
identity provider when you want to establish trust between an OIDC compatible
IdP and your AWS account. This is useful when creating a mobile app or web
application that requires access to AWS resources, but you don't want to create
custom sign in code or manage your own user identities.

The IAM OIDC provider is going to be used by the [AWS EKS pod identity admission
controller](https://github.com/aws/amazon-eks-pod-identity-webhook/) to attach
IAM roles to specific service accounts. This will prevent the attachment of the
IAM role to the whole node group. So instead of allowing every pod inside the
worker groups to create the ALB, only the ones attached to the eks-alb-ingress-controller
service account will be able to do so.

# Links

* [ITNext ingress controller
  comparison](https://itnext.io/kubernetes-ingress-controllers-how-to-choose-the-right-one-part-1-41d3554978d2)
* [Flant ingress controller comparison](https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b)
