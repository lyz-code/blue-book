---
title: AlertManager
date: 20200316
author: Lyz
---

The [Alertmanager](https://github.com/prometheus/alertmanager) handles alerts
sent by client applications such as the Prometheus server. It takes care of
deduplicating, grouping, and routing them to the correct receiver integrations
such as email, PagerDuty, or OpsGenie. It also takes care of silencing and
inhibition of alerts.

It is configured through the `alertmanager.config` key of the `values.yaml`
of the [helm](helm.md) chart.

As stated in the [configuration
file](https://prometheus.io/docs/alerting/configuration/#configuration-file), it
has four main keys (as `templates` is handled in
`alertmanager.config.templateFiles`):

* `global`: SMTP and API main configuration, it will be inherited by the other
    elements.
* `route`: Route tree definition.
* `receivers`: Notification integrations configuration.
* `inhibit_rules`: Alert inhibition configuration.

# [Route](https://prometheus.io/docs/alerting/configuration/#route)

A route block defines a node in a routing tree and its children. Its optional
configuration parameters are inherited from its parent node if not set.

Every alert enters the routing tree at the configured top-level route, which
must match all alerts (i.e. not have any configured matchers). It then traverses
the child nodes. If continue is set to false, it stops after the first matching
child. If continue is true on a matching node, the alert will continue matching
against subsequent siblings. If an alert does not match any children of a node
(no matching child nodes, or none exist), the alert is handled based on the
configuration parameters of the current node.

# [Receivers](https://prometheus.io/docs/alerting/configuration/#receiver)

Notification receivers are the named configurations of one or more notification
integrations.

## Email notifications

To configure email notifications, set up the following in your `config`:

```yaml
  config:
    global:
      smtp_from: {{ from_email_address }}
      smtp_smarthost: {{ smtp_server_endpoint }}:{{ smtp_server_port }}
      smtp_auth_username: {{ smpt_authentication_username }}
      smtp_auth_password: {{ smpt_authentication_password }}
    receivers:
    - name: 'email'
      email_configs:
        - to: {{ receiver_email }}
          send_resolved: true
```

If you need to set `smtp_auth_username` and `smtp_auth_password` you should
value using [helm secrets](helm_secrets.md).

`send_resolved`, set to `False` by default, defines whether or not to notify
about resolved alerts.

## [Rocketchat Notifications](https://rocket.chat/docs/administrator-guides/integrations/prometheus/)

!!! note ""
    Go to [pavel-kazhavets AlertmanagerRocketChat
    repo](https://github.com/pavel-kazhavets/AlertmanagerRocketChat) for the
    updated rules.

In RocketChat:

* Login as admin user and go to: Administration => Integrations => New
Integration => Incoming WebHook.
* Set "Enabled" and "Script Enabled" to "True".
* Set all channel, icons, etc. as you need.
* Paste contents of the official
[AlertmanagerIntegrations.js](https://github.com/pavel-kazhavets/AlertmanagerRocketChar/blob/master/AlertmanagerIntegration.js)
or my version into Script field.

??? note "AlertmanagerIntegrations.js"
    ```javascript
    class Script {
        process_incoming_request({
            request
        }) {
            console.log(request.content);

            var alertColor = "warning";
            if (request.content.status == "resolved") {
                alertColor = "good";
            } else if (request.content.status == "firing") {
                alertColor = "danger";
            }

            let finFields = [];
            for (i = 0; i < request.content.alerts.length; i++) {
                var endVal = request.content.alerts[i];
                var elem = {
                    title: "alertname: " + endVal.labels.alertname,
                    value: "*instance:* " + endVal.labels.instance,
                    short: false
                };

                finFields.push(elem);

                if (!!endVal.annotations.summary) {
                    finFields.push({
                        title: "summary",
                        value: endVal.annotations.summary
                    });
                }

                if (!!endVal.annotations.severity) {
                    finFields.push({
                        title: "severity",
                        value: endVal.labels.severity
                    });
                }

                if (!!endVal.annotations.grafana) {
                    finFields.push({
                        title: "grafana",
                        value: endVal.annotations.grafana
                    });
                }

                if (!!endVal.annotations.prometheus) {
                    finFields.push({
                        title: "prometheus",
                        value: endVal.annotations.prometheus
                    });
                }

                if (!!endVal.annotations.message) {
                    finFields.push({
                        title: "message",
                        value: endVal.annotations.message
                    });
                }

                if (!!endVal.annotations.description) {
                    finFields.push({
                        title: "description",
                        value: endVal.annotations.description
                    });
                }
            }

            return {
                content: {
                    username: "Prometheus Alert",
                    attachments: [{
                        color: alertColor,
                        title_link: request.content.externalURL,
                        title: "Prometheus notification",
                        fields: finFields
                    }]
                }
            };

            return {
                error: {
                    success: false
                }
            };
        }
    }
    ```
* Create Integration. The field `Webhook URL` will appear in the Integration
configuration.

In Alertmanager:

* Create new receiver or modify config of existing one. You'll need to add
`webhooks_config` to it. Small example:

```yaml
route:
    repeat_interval: 30m
    group_interval: 30m
    receiver: 'rocketchat'

receivers:
    - name: 'rocketchat'
      webhook_configs:
          - send_resolved: false
            url: '${WEBHOOK_URL}'
```

* Reload/restart alertmanager.

In order to test the webhook you can use the following curl (replace
`{{ webhook-url }}`):

```bash
curl -X POST -H 'Content-Type: application/json' --data '
{
  "text": "Example message",
  "attachments": [
    {
      "title": "Rocket.Chat",
      "title_link": "https://rocket.chat",
      "text": "Rocket.Chat, the best open source chat",
      "image_url": "https://rocket.cha t/images/mockup.png",
      "color": "#764FA5"
    }
  ],
  "status": "firing",
  "alerts": [
    {
      "labels": {
        "alertname": "high_load",
        "severity": "major",
        "instance": "node-exporter:9100"
      },
      "annotations": {
        "message": "node-exporter:9100 of job xxxx is under high load.",
        "summary": "node-exporter:9100 under high load."
      }
    }
  ]
}
' {{ webhook-url }}
```

# [Inhibit rules](https://prometheus.io/docs/alerting/configuration/#inhibit_rule)

Inhibit rules define which alerts triggered by Prometheus shouldn't be forwarded to
the notification integrations. For example the `Watchdog` alert is meant to test
that everything works as expected, but is not meant to be used by the users.
Similarly, if you are using EKS, you'll probably have an `KubeVersionMismatch`,
because Kubernetes [allows a certain version
skew](https://kubernetes.io/docs/setup/release/version-skew-policy) between
their components. So the alert is more strict than the Kubernetes policy.

To disable both alerts, set a `match` rule in `config.inhibit_rules`:

```yaml

  config:
    inhibit_rules:
      - target_match:
          alertname: Watchdog
      - target_match:
          alertname: KubeVersionMismatch
```

# Alert rules

Alert rules are a special kind of Prometheus Rules that trigger alerts based on
PromQL expressions. People have gathered several examples under [Awesome
prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules)

Alerts must be configured in the [Prometheus operator](prometheus_operator.md)
helm chart, under the `additionalPrometheusRulesMap`. For example:

```yaml
additionalPrometheusRulesMap:
  - groups:
      - name: alert-rules
        rules:
          - alert: BlackboxProbeFailed
            expr: probe_success == 0
            for: 5m
            labels:
              severity: error
            annotations:
              summary: "Blackbox probe failed (instance {{ $labels.target }})"
              description: "Probe failed\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

Other examples of rules are:

* [Blackbox Exporter rules](blackbox_exporter.md#blackbox-exporter-alerts)

# Silences

To silence an alert with a regular expression use the matcher
`alertname=~".*Condition"`.

# References

* [Awesome prometheus alert rules](https://awesome-prometheus-alerts.grep.to/rules)
