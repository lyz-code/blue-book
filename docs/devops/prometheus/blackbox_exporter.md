---
title: Blackbox Exporter
date: 20200218
author: Lyz
---

The [blackbox exporter](https://github.com/prometheus/blackbox_exporter) allows
blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP and ICMP.

It can be used to test:

* [Website accessibility](#availability-alerts). Both for availability and
      security purposes.
* [Website loading time](#performance-alerts).
* DNS response times to diagnose network latency issues.
* [SSL certificates expiration](#ssl-certificate-alerts).
* [ICMP requests to gather network health information](#blackbox-probe-slow-ping).
* [Security protections](#security-alerts) such as if and endpoint stops being
    protected by VPN, WAF or SSL client certificate.
* [Unauthorized read or write S3 buckets](#unauthorized-read-of-s3-buckets).

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
one needs to be created for each request type under the `config.modules` section
of the chart.

The modules are then used in the `targets` section for the desired endpoints.

```yaml
  targets:
   - name: lyz-code.github.io/blue-book
     url: https://lyz-code.github.io/blue-book
     module: https_2xx
```

## HTTP endpoint working correctly

```yaml
http_2xx:
  prober: http
  timeout: 5s
  http:
    valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
    valid_status_codes: [200]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
```

## HTTPS endpoint working correctly

```yaml
https_2xx:
  prober: http
  timeout: 5s
  http:
    method: GET
    fail_if_ssl: false
    fail_if_not_ssl: true
    valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
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
    valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
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
    valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
    valid_status_codes: [404]
    no_follow_redirects: false
    preferred_ip_protocol: "ip4"
    fail_if_body_not_matches_regexp:
      - '.*ERROR route not.*'
```

## HTTP endpoint returning an error

```yaml
http_4xx:
  prober: http
  timeout: 5s
  http:
    method: HEAD
    valid_status_codes: [404, 403]
    valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
    no_follow_redirects: false
```

## HTTPS endpoint through an HTTP proxy

```yaml
https_external_2xx:
  prober: http
  timeout: 5s
  http:
    method: GET
    fail_if_ssl: false
    fail_if_not_ssl: true
    valid_http_versions: ["HTTP/1.0", "HTTP/1.1", "HTTP/2.0"]
    valid_status_codes: [200]
    no_follow_redirects: false
    proxy_url: "http://{{ proxy_url }}:{{ proxy_port }}"
    preferred_ip_protocol: "ip4"
```

## HTTPS endpoint with basic auth

```yaml
https_basic_auth_2xx:
    prober: http
    timeout: 5s
    http:
        method: GET
        fail_if_ssl: false
        fail_if_not_ssl: true
        valid_http_versions:
        - HTTP/1.1
        - HTTP/2.0
        valid_status_codes:
        - 200
        no_follow_redirects: false
        preferred_ip_protocol: ip4
        basic_auth:
          username: {{ username }}
          password: {{ password }}
```

## HTTPs endpoint with API key

```yaml
https_api_2xx:
    prober: http
    timeout: 5s
    http:
        method: GET
        fail_if_ssl: false
        fail_if_not_ssl: true
        valid_http_versions:
        - HTTP/1.1
        - HTTP/2.0
        valid_status_codes:
        - 200
        no_follow_redirects: false
        preferred_ip_protocol: ip4
        headers:
            apikey: {{ api_key }}
```

## HTTPS Put file

Test if the probe can upload a file.

```yaml
    https_put_file_2xx:
      prober: http
      timeout: 5s
      http:
        method: PUT
        body: hi
        fail_if_ssl: false
        fail_if_not_ssl: true
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        valid_status_codes: [200]
        no_follow_redirects: false
        preferred_ip_protocol: "ip4"
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

To make security tests

## Availability alerts

The most basic probes, test if the service is up and returning.

### Blackbox probe failed

Blackbox probe failed.

```yaml
  - alert: BlackboxProbeFailed
    expr: probe_success == 0
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox probe failed (instance {{ $labels.target }})"
      message: "Probe failed\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_success+%3D%3D+0&g0.tab=1"
```

If you use the [security alerts](#security-alerts), use the following `expr:`
instead

```yaml
    expr: probe_success{target!~".*-fail-.*$"} == 0
```

### Blackbox probe HTTP failure

HTTP status code is not 200-399.

```yaml
  - alert: BlackboxProbeHttpFailure
    expr: probe_http_status_code <= 199 OR probe_http_status_code >= 400
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox probe HTTP failure (instance {{ $labels.target }})"
      message: "HTTP status code is not 200-399\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+30&g0.tab=1"
```

## Performance alerts

### Blackbox slow probe

Blackbox probe took more than 1s to complete.

```yaml
  - alert: BlackboxSlowProbe
    expr: avg_over_time(probe_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox slow probe (target {{ $labels.target }})"
      message: "Blackbox probe took more than 1s to complete\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

If you use the [security alerts](#security-alerts), use the following `expr:`
instead

```yaml
    expr: avg_over_time(probe_duration_seconds{,target!~".*-fail-.*"}[1m]) > 1
```

### Blackbox probe slow HTTP

HTTP request took more than 1s.

```yaml
  - alert: BlackboxProbeSlowHttp
    expr: avg_over_time(probe_http_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox probe slow HTTP (instance {{ $labels.target }})"
      message: "HTTP request took more than 1s\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_http_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

If you use the [security alerts](#security-alerts), use the following `expr:`
instead

```yaml
    expr: avg_over_time(probe_http_duration_seconds{,target!~".*-fail-.*"}[1m]) > 1
```

### Blackbox probe slow ping

Blackbox ping took more than 1s.

```yaml
  - alert: BlackboxProbeSlowPing
    expr: avg_over_time(probe_icmp_duration_seconds[1m]) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox probe slow ping (instance {{ $labels.target }})"
      message: "Blackbox ping took more than 1s\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=avg_over_time%28probe_icmp_duration_seconds%5B1m%5D%29+%3E+1&g0.tab=1"
```

## SSL certificate alerts

### Blackbox SSL certificate will expire in a month

SSL certificate expires in 30 days.

```yaml
  - alert: BlackboxSslCertificateWillExpireSoon
    expr: probe_ssl_earliest_cert_expiry - time() < 86400 * 30
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Blackbox SSL certificate will expire soon (instance {{ $labels.target }})"
      message: "SSL certificate expires in 30 days\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+30&g0.tab=1"
```

### Blackbox SSL certificate will expire in a few days

SSL certificate expires in 3 days.

```yaml
  - alert: BlackboxSslCertificateWillExpireSoon
    expr: probe_ssl_earliest_cert_expiry - time() < 86400 * 3
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox SSL certificate will expire soon (instance {{ $labels.target }})"
      message: "SSL certificate expires in 3 days\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C+86400+%2A+3&g0.tab=1"
```

### Blackbox SSL certificate expired

SSL certificate has expired already.

```yaml
  - alert: BlackboxSslCertificateExpired
    expr: probe_ssl_earliest_cert_expiry - time() <= 0
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Blackbox SSL certificate expired (instance {{ $labels.target }})"
      message: "SSL certificate has expired already\n  VALUE = {{ $value }}"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

## Security alerts

To define the security alerts, I've found easier to create a probe with the
action I want to prevent and make sure that the probe fails.

This probes contain the `-fail-` key in the target name, followed by the test
it's performing. This convention allows the concatenation of tests. For example,
when testing if and endpoint is accessible without basic auth and without vpn
we'd use:

```yaml
- name: protected.endpoint.org-fail-without-ssl-and-without-credentials
  url: protected.endpoint.org
  module: https_external_2xx
```

### Test endpoints protected with network policies

Assuming that the blackbox exporter is in the internal network and that there is
an http proxy on the external network we want to test. Create a working probe
with the `https_external_2xx` module containing the `-fail-without-vpn` key in
the target name.

```yaml
  - alert: BlackboxVPNProtectionRemoved
    expr: probe_success{target=~".*-fail-.*without-vpn.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "VPN protection was removed from (instance {{ $labels.target }})"
      message: "Successful probe to the endpoint from outside the internal network"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

### Test endpoints protected with SSL client certificate

Create a working probe with a module without the SSL client certificate
configured, such as `https_2xx` and set the `-fail-without-ssl` key in
the target name.

```yaml
  - alert: BlackboxClientSSLProtectionRemoved
    expr: probe_success{target=~".*-fail-.*without-ssl.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "SSL client certificate protection was removed from (instance {{ $labels.target }})"
      message: "Successful probe to the endpoint without SSL certificate"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

### Test endpoints protected with credentials.

Create a working probe with a module without the basic auth credentials
configured, such as `https_2xx` and set the `-fail-without-credentials` key in
the target name.

```yaml
  - alert: BlackboxCredentialsProtectionRemoved
    expr: probe_success{target=~".*-fail-.*without-credentials.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Credentials protection was removed from (instance {{ $labels.target }})"
      message: "Successful probe to the endpoint without credentials"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

### Test endpoints protected with WAF.

Create a working probe with a module bypassing the WAF, for example directly
attacking the service and set the `-fail-without-waf` key in the target name.

```yaml
  - alert: BlackboxWAFProtectionRemoved
    expr: probe_success{target=~".*-fail-.*without-waf.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "WAF protection was removed from (instance {{ $labels.target }})"
      message: "Successful probe to the haproxy endpoint from the internal network (bypassed the WAF)"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

### Unauthorized read of S3 buckets

Create a working probe to an existent private object in an [S3](s3.md) bucket
and set the `-fail-read-object` key in the target name.

```yaml
  - alert: BlackboxS3BucketWrongReadPermissions
    expr: probe_success{target=~".*-fail-.*read-object.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Wrong read permissions on S3 bucket (instance {{ $labels.target }})"
      message: "Successful read of a private object with an unauthenticated user"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

### Unauthorized write of S3 buckets

Create a working probe using the `https_put_file_2xx` module to try to create
a file in an [S3](s3.md) bucket and set the `-fail-write-object` key in the
target name.

```yaml
  - alert: BlackboxS3BucketWrongWritePermissions
    expr: probe_success{target=~".*-fail-.*write-object.*"} == 1
    for: 5m
    labels:
      severity: error
    annotations:
      summary: "Wrong write permissions on S3 bucket (instance {{ $labels.target }})"
      message: "Successful write of a private object with an unauthenticated user"
      grafana: "{{ grafana_url }}&var-targets={{ $labels.target }}"
      prometheus: "{{ prometheus_url }}/graph?g0.expr=probe_ssl_earliest_cert_expiry+-+time%28%29+%3C%3D+0&g0.tab=1"
```

# Monitoring external access to internal services

There are two possible solutions to simulate traffic from outside your
infrastructure to the internal services. Both require the installation of an
agent outside of your internal infrastructure, it can be:

* An HTTP proxy.
* A blackbox exporter instance.

Using the proxy you have following advantages:

* It's really easy to set up a [transparent http
    proxy](https://hub.docker.com/r/vimagick/tinyproxy).
* All probe configuration goes in the same blackbox exporter instance
    `values.yaml`.

With the following disadvantages:

* When using an external http proxy, [the probe runs the DNS resolution
locally]((https://github.com/prometheus/blackbox_exporter/pull/554)). Therefore
if the record doesn't exist in the local server the probe will fail, even if the
proxy DNS resolver has the correct record.

    The ugly workaround I've implemented is to create a "fake" DNS record in my
    internal DNS server so the probe sees it exist.
* There is no way to do `tcp` or `ping` probes to simulate external traffic.
* The latency between the blackbox exporter and the proxy is added to all the
    external probes.

While using an external blackbox exporter gives the following advantages:

* Traffic is completely external to the infrastructure, so the proxy
    disadvantages would be solved.

And the following disadvantages:

* Simulation of external traffic in AWS could be done by spawning the blackbox
    exporter instance in another region, but as there is no way of using EKS
    worker nodes in different regions, there is no way of managing the exporter
    from within Kubernetes. This means:

    * The loose of the advantages of the [Prometheus
      operator](prometheus_operator.md), so we have to write the configuration
      manually.
    * Configuration can't be managed with [Helm](helm.md), so two solutions
        should be used to manage the monitorization (Ansible could be used).
* Even if it's possible to host the second external blackbox exporter within
    Kubernetes, two independent [Helm](helm.md) charts are needed, with the
    consequent configuration management burden.

In conclusion, when using a Kubernetes cluster that allows the creation of
worker nodes outside the main infrastructure, or if several non HTTP/HTTPS
endpoints need to be probed with the `tcp` or `ping` modules, install an
external blackbox exporter instance. Otherwise install an HTTP proxy and assume
that you can only simulate external HTTP/HTTPS traffic.

# Troubleshooting

To [get more debugging
information](https://www.robustperception.io/debugging-blackbox-exporter-failures)
of the blackbox probes, add `&debug=true` to the probe url, for example
http://localhost:9115/probe?module=http_2xx&target=https://www.prometheus.io/&debug=true
.

## [Service monitors are not being created](https://github.com/helm/charts/issues/20398)

When running `helmfile apply` several times to update the resources, some are
not being correctly created. Until the bug is solved, a workaround is to remove
the chart release `helm delete --purge prometeus-blackbox-exporter` and running
`helmfile apply` again.

## [probe_success == 0 when using an http proxy](https://github.com/prometheus/blackbox_exporter/pull/554)

Even when using an external http proxy, the probe runs the DNS resolution
locally. Therefore if the record doesn't exist in the local server the probe
will fail, even if the proxy DNS resolver has the correct record.

The ugly workaround I've implemented is to create a "fake" DNS record in my
internal DNS server so the probe sees it exist.

# Links

* [Git](https://github.com/prometheus/blackbox_exporter).
* [Blackbox exporter modules
  configuration](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md).
* [Devconnected introduction to blackbox
  exporter](https://devconnected.com/how-to-install-and-configure-blackbox-exporter-for-prometheus/).
