---
title: Prometheus Troubleshooting
date: 20200317
author: Lyz
---

Solutions for problems with Prometheus.

# Service monitor not being recognized

Probably the service monitor labels aren't properly configured. Each prometheus
monitors it's own targets, to see how you need to label your resources, describe
the prometheus instance and search for `Service Monitor Selector`.

```bash
kubectl get prometheus -n monitoring
kubectl describe prometheus prometheus-operator-prometheus -n monitoring
```

The last one will return something like:

```yaml
  Service Monitor Selector:
    Match Labels:
      Release:  prometheus-operator
```

Which means you need to label your service monitors with `release:
prometheus-operator`, **be careful** if you use `Release: prometheus-operator`
it won't work.

# Failed calling webhook prometheusrulemutate.monitoring.coreos.com

```
  Error: UPGRADE FAILED: failed to create resource: Internal error occurred: failed calling webhook "prometheusrulemutate.monitoring.coreos.com": Post https://prometheus-operator-operator.monitoring.svc:443/admission-prometheusrules/mutate?timeout=30s: no endpoints available for service "prometheus-operator-operator"
```

Since version 0.30 of the operator, there is an [admission
webhook](https://github.com/helm/charts/tree/master/stable/prometheus-operator#prometheusrules-admission-webhooks)
to prevent malformed rules from being added to the cluster. Without this
validation, creating an invalid resource will cause Prometheus not to load it.
If the container then restarts, it will go into a crashloop.

For the webhook to work, the control plane needs to be able to access the
webhook service. That means the addition of a firewall rule in EKS and GKE
deployments. People have succeeded with
[GKE](https://github.com/helm/charts/issues/16249#issuecomment-520795222), but
people struggling with [EKS](https://github.com/helm/charts/issues/16174) have
decided to disable the webhook.

To disable it, the following options have to be set:

* `prometheusOperator.admissionWebhooks.enabled=false`
* `prometheusOperator.admissionWebhooks.patch.enabled=false`
* `prometheusOperator.tlsProxy.enabled=false`

If you have deployed your release with the webhook enabled, you also need to
remove all the resources that match the following:

```bash
kubectl get validatingwebhookconfigurations.admissionregistration.k8s.io
kubectl get MutatingWebhookConfiguration
```

Before executing `helmfile apply` again.
