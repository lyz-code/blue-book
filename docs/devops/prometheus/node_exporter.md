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

# References

* [Git](https://github.com/prometheus/node_exporter)
* [Prometheus guide](https://prometheus.io/docs/guides/node-exporter/)
