---
title: Prometheus Installation
date: 20200212
author: Lyz
---

To install the operator we'll use [helmfile](helmfile.md) to install the
[stable/prometheus-operator
chart](https://github.com/helm/charts/tree/master/stable/prometheus-operator).

Add the following lines to your `helmfile.yaml`.
```yaml
- name: prometheus-operator
  namespace: monitoring
  chart: stable/prometheus-operator
  values:
    - prometheus-operator/values.yaml
```

Edit the chart values.
```bash
mkdir prometheus-operator
helm inspect values stable/prometheus-operator > prometheus-operator/values.yaml
vi prometheus-operator/values.yaml
```

I've implemented the following changes:

* If you are using a managed solution like EKS, the provider will hide
    `kube-scheduler` and `kube-controller-manager` so those metrics will fail.
    Therefore you need to disable:

    * `defaultRules.rules.kubeScheduler: false`.
    * `kubeScheduler.enabled: false`.
    * `kubeControllerManager.enabled: false`.
* [Configure the alertmanager](alertmanager.md).
* Enabled the ingress of `alertmanager`, `grafana` and `prometheus`.
* Set up the `storage` of `alertmanager` and `prometheus` with
  `storageClassName: gp2` (for AWS).
* Configure the grafana dashboards:

    * [Blackbox grafana dashboard](blackbox_exporter.md)
* Change `additionalPrometheusRules` to `additionalPrometheusRulesMap` as the
    former is going to be deprecated in future releases.
* For [private clusters, disable the admission
  webhook](prometheus_troubleshooting.md#failed-calling-webhook-prometheusrulemutate.monitoring.coreos.com).

    * `prometheusOperator.admissionWebhooks.enabled=false`
    * `prometheusOperator.admissionWebhooks.patch.enabled=false`
    * `prometheusOperator.tlsProxy.enabled=false`

And install.

```bash
helmfile diff
helmfile apply
```

Once it's installed you can check everything is working by accessing the grafana
dashboard.

First of all get the pod name (we'll asume you've used the `monitoring`
namespace).
```bash
kubectl get pods -n monitoring | grep grafana
```

Then set up the proxies
```bash
kubectl port-forward {{ grafana_pod }} -n monitoring 3000:3000
kubectl port-forward -n monitoring \
  prometheus-prometheus-operator-prometheus-0 9090:9090
```

To access grafana, go to http://localhost:3000 through your browser
and at the top left, click on Home and select any dashboard. To access
prometheus, go to http://localhost:9090.

If you're using the EKS helm chart, you'll need to manually edit the
kube-proxy-config configmap until [this
bug](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/742) has
been solved.

Edit the `127.0.0.1` value to `0.0.0.0` for the key `metricsBindAddress` in
```bash
kubectl -n kube-system edit cm kube-proxy-config
```

And restart the DaemonSet:
```bash
kubectl rollout restart -n kube-system daemonset.apps/kube-proxy
```

# Creating alerts

Alerts are configured in

# Installing other exporters

* [Blackbox Exporter](blackbox_exporter.md)

