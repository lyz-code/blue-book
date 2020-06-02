---
title: Kong
date: 20200310
author: Lyz
---

[Kong](https://konghq.com/) is a lua application API platform running in Nginx.

# Installation

Kong supports [several platforms](https://konghq.com/install/) of which we'll
use Kubernetes with the [helm](helm.md)
[chart](https://github.com/Kong/charts/blob/master/charts/kong/README.md), as it
gives the following advantages:

* Kong is configured dynamically and responds to the changes in your
    infrastructure.
* Kong is deployed onto Kubernetes with a Controller, which is responsible for
    configuring Kong.
* All of Kong’s configuration is done using Kubernetes resources, stored in
    Kubernetes’ data-store (etcd).
* Use the power of kubectl (or any custom tooling around kubectl) to configure
    Kong and get benefits of all Kubernetes, such as declarative configuration,
    cloud-provider agnostic deployments, RBAC, reconciliation of desired state,
    and elastic scalability.
* Kong is configured using a combination of Ingress Resource and Custom Resource
    Definitions(CRDs).
* DB-less by default, meaning Kong has the capability of running without
    a database and using only memory storage for entities.

In the `helmfile.yaml` add the repository and the release:

```yaml
repositories:
- name: kong
  url: https://charts.konghq.com
releases:
- name: kong
  namespace: api-manager
  chart: kong/kong
  values:
    - kong/values.yaml
  secrets:
    - kong/secrets.yaml
```

While particularizing the `values.yaml` keep in mind that:

* If you don't want the ingress controller set up `ingressController.enabled:
    false`, and in `proxy` set `service: ClusterIP` and `ingress.enabled:
    true`.
* Kong can be run with or without a database. By default the chart installs it
    without database.
* If you deploy it without database and without the ingress controller, you have
    to provide a declarative configuration for Kong to run. It can be provided
    using an existing ConfigMap `dblessConfig.configMap` or the whole
    configuration can be put into the `values.yaml` file for deployment itself,
    under the `dblessConfig.config` parameter.

* Although kong supports it's own [Kubernetes resources
    (CRD)](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/concepts/custom-resources.md)
    for
    [plugins](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/concepts/custom-resources.md#kongplugin)
    and
    [consumers](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/concepts/custom-resources.md#kongconsumer),
    I've found now way of integrating them into the helm chart, therefore I'm
    going to specify everything in the `dblessConfig.config`.

So the general kong configuration `values.yaml` would be:

```yaml
dblessConfig:
  config:
    _format_version: "1.1"
    services:
      - name: example.com
        url: https://api.example.com
        plugins:
          - name: key-auth
          - name: rate-limiting
            config:
              second: 10
              hour: 1000
              policy: local
        routes:
        - name: example
          paths:
           - /example
```

And the `secrets.yaml`:

```yaml
consumers:
  - username: lyz
    keyauth_credentials:
      - key: vRQO6xfBbTY3KRvNV7TbeFUUW7kjBmPhIFcUUxvkm4
```

To test that everything works use

```bash
curl -I https://api.example.com/example -H 'apikey: vRQO6xfBbTY3KRvNV7TbeFUUW7kjBmPhIFcUUxvkm4'
```

To add the prometheus monitorization, enable the `serviceMonitor.enabled: true`
and make sure you set [the correct
labels](../prometheus/prometheus_troubleshooting.md#service-monitor-not-being-recognized).
There is a [grafana official
dashboard](https://grafana.com/grafana/dashboards/7424) you can also use.

# Links

* [Homepage](https://konghq.com/)
* [Docs](https://docs.konghq.com/?itm_source=website&itm_medium=nav)
