---
title: Node Exporter
date: 20200624
author: Lyz
---

[Node Exporter](https://github.com/prometheus/node_exporter) is a Prometheus
exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with
pluggable metric collectors.

# Install

To install in kubernetes nodes, use [this
chart](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter).
Elsewhere use [this ansible
role](https://github.com/cloudalchemy/ansible-node-exporter).

If you use node exporter agents outside kubernetes, you need to configure
a prometheus service discovery to scrap the information from them.

To [auto discover EC2
instances](https://kbild.ch/blog/2019-02-18-awsprometheus/) use the
[ec2_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
configuration. It can be added in the helm chart values.yaml under the key
`prometheus.prometheusSpec.additionalScrapeConfigs`

```yaml
      - job_name: node_exporter
        ec2_sd_configs:
          - region: us-east-1
            port: 9100
            refresh_interval: 1m
```

If the worker nodes already have an IAM role with the `ec2:DescribeInstances`
permission there is no need to specify the `role_arn` or `access_keys` and
`secret_key`.

# References

* [Git](https://github.com/prometheus/node_exporter)
* [Prometheus guide](https://prometheus.io/docs/guides/node-exporter/)
