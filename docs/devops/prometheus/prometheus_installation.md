---
title: Prometheus Installation
date: 20200212
author: Lyz
---

# Kubernetes

!!! warning "Helm 2 is not supported anymore."

    Later versions of the chart return an [Error: apiVersion 'v2' is not valid.
    The value must be
    "v1"](https://github.com/prometheus-community/helm-charts/issues/607) when
    using helm 2.

    [Diving
    deeper](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack/#from-11-x-to-12-x),
    it seems that from 11.1.7 support for helm 2 was dropped.

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
* Enabled the ingress of `alertmanager`, `grafana` and `prometheus`.
* Set up the `storage` of `alertmanager` and `prometheus` with
  `storageClassName: gp2` (for AWS).
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

## Upgrading notes

### 10.x -> 11.1.7

If you have a private cluster in EKS, you are not able to use the admission
webhooks as the nodes are not able to reach the master.

Between those versions, [something
changed](https://github.com/prometheus-community/helm-charts/issues/418) and you
need to disable tls too with:

```yaml
prometheusOperator:
  tls:
    enabled: false
  admissionWebhooks:
    enabled: false
```

If you run `helmfile apply` without that flag, the deployment gets tainted, and
you may need to edit the deployment to remove the `tls-secret` volume.

# Docker

To install it outside Kubernetes, use the [cloudalchemy ansible
role](https://github.com/cloudalchemy/ansible-prometheus) for host installations
or the [prom/prometheus](https://hub.docker.com/r/prom/prometheus/) docker with
the following command:

```bash
/usr/bin/docker run --rm \
    --name prometheus \
    -v /data/prometheus:/etc/prometheus \
    prom/prometheus:latest \
    --storage.tsdb.retention.time=30d \
    --config.file=/etc/prometheus/prometheus.yml \
```

With a basic prometheus configuration:

!!! note "File: /data/prometheus/prometheus.yml"

    ```yaml
    ---
    # http://prometheus.io/docs/operating/configuration/

    global:
      evaluation_interval: 1m
      scrape_interval: 1m
      scrape_timeout: 10s
      external_labels:
        environment: helm
    rule_files:
      - /etc/prometheus/rules/*.rules
    scrape_configs:
      - job_name: prometheus
        metrics_path: /metrics
        static_configs:
        - targets:
          - prometheus:9090
     ```

And some basic rules:

??? note "File: /data/prometheus/rules/"

    ```yaml
    groups:
    - name: ansible managed alert rules
      rules:
      - alert: Watchdog
        annotations:
          description: |-
            This is an alert meant to ensure that the entire alerting pipeline is functional.
            This alert is always firing, therefore it should always be firing in Alertmanager
            and always fire against a receiver. There are integrations with various notification
            mechanisms that send a notification when this alert is not firing. For example the
            "DeadMansSnitch" integration in PagerDuty.
          summary: Ensure entire alerting pipeline is functional
        expr: vector(1)
        for: 10m
        labels:
          severity: warning
      - alert: InstanceDown
        annotations:
          description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for
            more than 5 minutes.'
          summary: Instance {{ $labels.instance }} down
        expr: up == 0
        for: 5m
        labels:
          severity: critical
      - alert: RebootRequired
        annotations:
          description: '{{ $labels.instance }} requires a reboot.'
          summary: Instance {{ $labels.instance }} - reboot required
        expr: node_reboot_required > 0
        labels:
          severity: warning
      - alert: NodeFilesystemSpaceFillingUp
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available space left and is filling up.
          summary: Filesystem is predicted to run out of space within the next 24 hours.
        expr: |-
          (
            node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 40
          and
            predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 24*60*60) < 0
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: warning
      - alert: NodeFilesystemSpaceFillingUp
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available space left and is filling up fast.
          summary: Filesystem is predicted to run out of space within the next 4 hours.
        expr: |-
          (
            node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 20
          and
            predict_linear(node_filesystem_avail_bytes{job="node",fstype!=""}[6h], 4*60*60) < 0
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: critical
      - alert: NodeFilesystemAlmostOutOfSpace
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available space left.
          summary: Filesystem has less than 5% space left.
        expr: |-
          (
            node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 5
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: warning
      - alert: NodeFilesystemAlmostOutOfSpace
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available space left.
          summary: Filesystem has less than 3% space left.
        expr: |-
          (
            node_filesystem_avail_bytes{job="node",fstype!=""} / node_filesystem_size_bytes{job="node",fstype!=""} * 100 < 3
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: critical
      - alert: NodeFilesystemFilesFillingUp
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available inodes left and is filling up.
          summary: Filesystem is predicted to run out of inodes within the next 24 hours.
        expr: |-
          (
            node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 40
          and
            predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 24*60*60) < 0
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: warning
      - alert: NodeFilesystemFilesFillingUp
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available inodes left and is filling up fast.
          summary: Filesystem is predicted to run out of inodes within the next 4 hours.
        expr: |-
          (
            node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 20
          and
            predict_linear(node_filesystem_files_free{job="node",fstype!=""}[6h], 4*60*60) < 0
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: critical
      - alert: NodeFilesystemAlmostOutOfFiles
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available inodes left.
          summary: Filesystem has less than 5% inodes left.
        expr: |-
          (
            node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 5
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: warning
      - alert: NodeFilesystemAlmostOutOfFiles
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has
            only {{ printf "%.2f" $value }}% available inodes left.
          summary: Filesystem has less than 3% inodes left.
        expr: |-
          (
            node_filesystem_files_free{job="node",fstype!=""} / node_filesystem_files{job="node",fstype!=""} * 100 < 3
          and
            node_filesystem_readonly{job="node",fstype!=""} == 0
          )
        for: 1h
        labels:
          severity: critical
      - alert: NodeNetworkReceiveErrs
        annotations:
          description: '{{ $labels.instance }} interface {{ $labels.device }} has encountered
            {{ printf "%.0f" $value }} receive errors in the last two minutes.'
          summary: Network interface is reporting many receive errors.
        expr: |-
          increase(node_network_receive_errs_total[2m]) > 10
        for: 1h
        labels:
          severity: warning
      - alert: NodeNetworkTransmitErrs
        annotations:
          description: '{{ $labels.instance }} interface {{ $labels.device }} has encountered
            {{ printf "%.0f" $value }} transmit errors in the last two minutes.'
          summary: Network interface is reporting many transmit errors.
        expr: |-
          increase(node_network_transmit_errs_total[2m]) > 10
        for: 1h
        labels:
          severity: warning
      - alert: NodeHighNumberConntrackEntriesUsed
        annotations:
          description: '{{ $value | humanizePercentage }} of conntrack entries are used'
          summary: Number of conntrack are getting close to the limit
        expr: |-
          (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
        labels:
          severity: warning
      - alert: NodeClockSkewDetected
        annotations:
          message: Clock on {{ $labels.instance }} is out of sync by more than 300s. Ensure
            NTP is configured correctly on this host.
          summary: Clock skew detected.
        expr: |-
          (
            node_timex_offset_seconds > 0.05
          and
            deriv(node_timex_offset_seconds[5m]) >= 0
          )
          or
          (
            node_timex_offset_seconds < -0.05
          and
            deriv(node_timex_offset_seconds[5m]) <= 0
          )
        for: 10m
        labels:
          severity: warning
      - alert: NodeClockNotSynchronising
        annotations:
          message: Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured
            on this host.
          summary: Clock not synchronising.
        expr: |-
          min_over_time(node_timex_sync_status[5m]) == 0
        for: 10m
        labels:
          severity: warning
    ```

# Next steps

* [Configure the alertmanager alerts](alertmanager.md).
* Configure the [Blackbox Exporter](blackbox_exporter.md).
* Configure the grafana dashboards.

# Issues

* [Error: apiVersion 'v2' is not valid.  The value must be
    "v1"](https://github.com/prometheus-community/helm-charts/issues/607):
    Update the warning above and update the clusters.
