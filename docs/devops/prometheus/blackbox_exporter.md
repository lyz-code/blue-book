---
title: Blackbox Exporter
date: 20200218
author: Lyz
---

The [blackbox exporter](https://github.com/prometheus/blackbox_exporter) allows
blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP and ICMP.

It can be used to test:

* Website accessibility.
* Website loading time.
* DNS response times to diagnose network latency issues.
* SSL certificates expiration.
* ICMP requests to gather network health information.

When running, the Blackbox exporter is going to expose a HTTP endpoint that can
be used in order to monitor targets over the network. By default, the Blackbox
exporter exposes the `/probe` endpoint that is used to retrieve those metrics.

The blackbox exporter is configured with a YAML configuration file made of
[modules](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md).

# Installation

To install the exporter we'll use [helmfile](helmfile.md) to install the
[stable/prometheus-blackbox-exporter
chart](https://github.com/helm/charts/tree/master/stable/prometheus-blackbox-exporter).

Add the following lines to your `helmfile.yaml`.

```yaml
- name: prometheus-blackbox-exporter
  namespace: monitoring
  chart: stable/prometheus-blackbox-exporter
  values:
    - prometheus-blackbox-exporter/values.yaml
```

Edit the chart values.
```bash
mkdir prometheus-blackbox-exporter
helm inspect values stable/prometheus-blackbox-exporter > prometheus-blackbox-exporter/values.yaml
vi prometheus-blackbox-exporter/values.yaml
```

Make sure to enable the `serviceMonitor` in the values and target at least one
page:

```yaml

serviceMonitor:
  enabled: true

  # Default values that will be used for all ServiceMonitors created by `targets`
  defaults:
    labels:
      release: prometheus-operator
    interval: 30s
    scrapeTimeout: 30s
    module: http_2xx

  targets:
   - name: lyz-code.github.io/blue-book
     url: https://lyz-code.github.io/blue-book
```

The label `release: prometheus-operator` must be the [one your prometheus
instance is searching for](prometheus.md#service-monitor-not-being-recognized).

If you want to use the `icmp` probe, make sure to allow `allowIcmp: true`.

I've found two grafana dashboards for the blackbox exporter.
[`7587`](https://grafana.com/dashboards/7587) didn't work straight out of the
box while [`5345`](https://grafana.com/dashboards/5345) did. Taking as reference
the
[grafana](https://github.com/helm/charts/blob/master/stable/grafana/values.yaml)
helm chart values, add the following yaml under the `grafana` key in the
`prometheus-operator` `values.yaml`.

```yaml
grafana:
  enabled: true
  defaultDashboardsEnabled: true
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
  dashboards:
    default:
      blackbox-exporter:
        # Ref: https://grafana.com/dashboards/5345
        gnetId: 5345
        revision: 3
        datasource: Prometheus
```

And install.

```bash
helmfile diff
helmfile apply
```

# Links

* [Git](https://github.com/prometheus/blackbox_exporter).
* [Blackbox exporter modules
  configuration](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md).
* [Devconnected introduction to blackbox
  exporter](https://devconnected.com/how-to-install-and-configure-blackbox-exporter-for-prometheus/).
