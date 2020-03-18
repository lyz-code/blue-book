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
instance is searching for](prometheus_troubleshooting.md#service-monitor-not-being-recognized).

If you want to use the `icmp` probe, make sure to allow `allowIcmp: true`.

If you want to probe endpoints protected behind client SSL certificates, until this [chart
issue](https://github.com/helm/charts/issues/21345) is solved, you need to create
them manually as the Prometheus blackbox exporter helm chart doesn't yet create
the required secrets.

```bash
kubectl create secret generic monitor-certificates \
    --from-file=monitor.crt.pem \
    --from-file=monitor.key.pem \
    -n monitoring
```

Where `monitor.crt.pem` and `monitor.key.pem` are the SSL certificate and key
for the monitor account.

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

# Blackbox exporter probes

Modules define how blackbox exporter is going to query the endpoint, therefore
you need to create one for each request type under the `config.modules` section
of the chart.

## HTTP endpoint working correctly

```yaml
http_2xx:
  prober: http
  timeout: 5s
  http:
    valid_http_versions: ["HTTP/1.1", "HTTP/2"]
    valid_status_codes: [200]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
```

## HTTPS endpoint

```yaml
https_2xx:
  prober: http
  timeout: 5s
  http:
    method: GET
    fail_if_ssl: false
    fail_if_not_ssl: true
    valid_http_versions: ["HTTP/1.1", "HTTP/2"]
    valid_status_codes: [200]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
```

## HTTPS endpoint behind client SSL certificate

```yaml
https_client_2xx:
  prober: http
  timeout: 5s
  http:
    method: GET
    fail_if_ssl: false
    fail_if_not_ssl: true
    valid_http_versions: ["HTTP/1.1", "HTTP/2"]
    valid_status_codes: [200]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
    tls_config:
      cert_file: /etc/secrets/monitor.crt.pem
      key_file: /etc/secrets/monitor.key.pem
```

Where the secrets have been created throughout the installation.

## HTTPS endpoint with an specific error

If you don't want to configure the authentication for example for an API, you
can fetch the expected error.

```yaml
https_client_api:
  prober: http
  timeout: 5s
  http:
    method: GET
    fail_if_ssl: false
    fail_if_not_ssl: true
    valid_http_versions: ["HTTP/1.1", "HTTP/2"]
    valid_status_codes: [404]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
    fail_if_body_not_matches_regexp:
      - '.*ERROR route not.*'
```

## HTTP endpoint not working as expected

```yaml
http_4xx:
  prober: http
  timeout: 5s
  http:
    method: HEAD
    valid_status_codes: [404, 403]
    valid_http_versions: ["HTTP/1.1", "HTTP/2"]
    no_follow_redirects: false
```

## Check open port

```yaml
tcp_connect:
  prober: tcp
```

The port is specified when using the module.

```yaml
- name: lyz-code.github.io
  url: lyz-code.github.io:389
  module: tcp_connect
```

## Ping to the resource

Test if the target is alive. It's useful When you don't know what port to check
or if it uses UDP.

```yaml
ping:
  prober: icmp
  timeout: 5s
  icmp:
    preferred_ip_protocol: "ip4"
```

# Blackbox exporter alerts

Now that we've got the metrics, we can define the [alert
rules](alertmanager.md#alert-rules). Most have been tweaked from the [Awesome
prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules)
collection.

## Blackbox probe failed

Blackbox probe failed.

```yaml
  - alert: BlackboxProbeFailed
    expr: probe_success == 0
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox probe failed (instance {{ $labels.target }})"
      description: "Probe failed\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_success+%3D%3D+0&g0.tab=1"
```

## Blackbox slow probe

Blackbox probe took more than 1s to complete.

```yaml
  - alert: BlackboxSlowProbe
    expr: avg_over_time(probe_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox slow probe (target {{ $labels.target }})"
      description: "Blackbox probe took more than 1s to complete\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

## Blackbox probe HTTP failure

HTTP status code is not 200-399.

```yaml
  - alert: BlackboxProbeHttpFailure
    expr: probe_http_status_code <= 199 OR probe_http_status_code >= 400
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox probe HTTP failure (instance {{ $labels.target }})"
      description: "HTTP status code is not 200-399\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+30&g0.tab=1"
```

## Blackbox SSL certificate will expire soon

SSL certificate expires in 30 days.

```yaml
  - alert: BlackboxSslCertificateWillExpireSoon
    expr: probe_ssl_earliest_cert_expiry - time() < 86400 * 30
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox SSL certificate will expire soon (instance {{ $labels.target }})"
      description: "SSL certificate expires in 30 days\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+30&g0.tab=1"
```

## Blackbox SSL certificate will expire soon

SSL certificate expires in 3 days.

```yaml
  - alert: BlackboxSslCertificateWillExpireSoon
    expr: probe_ssl_earliest_cert_expiry - time() < 86400 * 3
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox SSL certificate will expire soon (instance {{ $labels.target }})"
      description: "SSL certificate expires in 3 days\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+3&g0.tab=1"
```

## Blackbox SSL certificate expired

SSL certificate has expired already.

```yaml
  - alert: BlackboxSslCertificateExpired
    expr: probe_ssl_earliest_cert_expiry - time() <= 0
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox SSL certificate expired (instance {{ $labels.target }})"
      description: "SSL certificate has expired already\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

## Blackbox probe slow HTTP

HTTP request took more than 1s.

```yaml
  - alert: BlackboxProbeSlowHttp
    expr: avg_over_time(probe_http_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox probe slow HTTP (instance {{ $labels.target }})"
      description: "HTTP request took more than 1s\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_http_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

## Blackbox probe slow ping

Blackbox ping took more than 1s.

```yaml
  - alert: BlackboxProbeSlowPing
    expr: avg_over_time(probe_icmp_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox probe slow ping (instance {{ $labels.target }})"
      description: "Blackbox ping took more than 1s\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_icmp_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

# Troubleshooting

## [Service monitors are not being created](https://github.com/helm/charts/issues/20398)

When running `helmfile apply` several times to update the resources, some are
not being correctly created. Until the bug is solved, a workaround is to remove
the chart release `helm delete --purge prometeus-blackbox-exporter` and running
`helmfile apply` again.

# Links

* [Git](https://github.com/prometheus/blackbox_exporter).
* [Blackbox exporter modules
  configuration](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md).
* [Devconnected introduction to blackbox
  exporter](https://devconnected.com/how-to-install-and-configure-blackbox-exporter-for-prometheus/).
