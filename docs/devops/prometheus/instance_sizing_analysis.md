---
title: Instance sizing analysis
date: 20201019
author: Lyz
---

Once we gather the instance metrics with the [Node exporter](node_exporter.md),
we can do statistical analysis on the evolution of time to detect the instances
that are undersized or oversized.

# RAM analysis

Instance RAM percent usage metric can be calculated with the following
[Prometheus rule](prometheus.md#prometheus-rules):

```yaml
  - record: instance_path:node_memory_MemAvailable_percent
    expr: (1 - node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes ) * 100
```

The [average](https://en.wikipedia.org/wiki/Average), [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation) and the [standard
score](https://en.wikipedia.org/wiki/Standard_score) of the last two
weeks would be:

```yaml
  - record: instance_path:node_memory_MemAvailable_percent:avg_over_time_2w
    expr: avg_over_time(instance_path:node_memory_MemAvailable_percent[2w])
  - record: instance_path:node_memory_MemAvailable_percent:stddev_over_time_2w
    expr: stddev_over_time(instance_path:node_memory_MemAvailable_percent[2w])
  - record: instance_path:node_memory_MemAvailable_percent:z_score
    expr: >
      (
        instance_path:node_memory_MemAvailable_percent
        - instance_path:node_memory_MemAvailable_percent:avg_over_time_2w
      ) / instance_path:node_memory_MemAvailable_percent:stddev_over_time_2w
```

With that data we can define that an instance is oversized if the average plus
the standard deviation is less than 60% and undersized if its greater than 90%.

With the average we take into account the nominal RAM consumption, and with the
standard deviation we take into account the spikes.

!!! warning "Tweak this rule to your use case"

    The criteria of undersized and oversized is just a first approximation I'm
    going to use. You can use it as a base criteria, but don't go through with
    it blindly.

    See the [disclaimer](#disclaimer) below for more information.

```yaml
  # RAM
  - record: instance_path:wrong_resource_size
    expr: >
      instance_path:node_memory_MemAvailable_percent:avg_plus_stddev_over_time_2w < 60
    labels:
      type: EC2
      metric: RAM
      problem: oversized
  - record: instance_path:wrong_resource_size
    expr: >
      instance_path:node_memory_MemAvailable_percent:avg_plus_stddev_over_time_2w > 90
    labels:
      type: EC2
      metric: RAM
      problem: undersized
```

Where `avg_plus_stddev_over_time_2w` is:

```yaml
  - record: instance_path:node_memory_MemAvailable_percent:avg_plus_stddev_over_time_2w
    expr: >
      instance_path:node_memory_MemAvailable_percent:avg_over_time_2w
      + instance_path:node_memory_MemAvailable_percent:stddev_over_time_2w
```

# CPU analysis

Instance CPU percent usage metric can be calculated with the following
[Prometheus rule](prometheus.md#prometheus-rules):

```yaml
  - record: instance_path:node_cpu_percent:rate1m
    expr: >
      (1 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])))) * 100
```

The `node_cpu_seconds_total` doesn't give us the percent of usage, that is why
we need to do the average of the
[`rate`](https://prometheus.io/docs/prometheus/latest/querying/functions/#rate)
of the last minute.

The [average](https://en.wikipedia.org/wiki/Average), [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation), the [standard
score](https://en.wikipedia.org/wiki/Standard_score) and the undersize or
oversize criteria is similar to the RAM case, so I'm adding it folded for
reference only.

??? note "CPU usage rules"

    ```yaml
    # ---------------------------------------
    # -- Resource consumption calculations --
    # ---------------------------------------

    # CPU
    - record: instance_path:node_cpu_percent:rate1m
      expr: >
        (1 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])))) * 100
    - record: instance_path:node_cpu_percent:rate1m:avg_over_time_2w
      expr: avg_over_time(instance_path:node_cpu_percent:rate1m[2w])
    - record: instance_path:node_cpu_percent:rate1m:stddev_over_time_2w
      expr: stddev_over_time(instance_path:node_cpu_percent:rate1m[2w])
    - record: instance_path:node_cpu_percent:rate1m:avg_plus_stddev_over_time_2w
      expr: >
        instance_path:node_cpu_percent:rate1m:avg_over_time_2w
        + instance_path:node_cpu_percent:rate1m:stddev_over_time_2w
    - record: instance_path:node_cpu_percent:rate1m:z_score
      expr: >
        (
          instance_path:node_cpu_percent:rate1m
          - instance_path:node_cpu_percent:rate1m:avg_over_time_2w
        ) / instance_path:node_cpu_percent:rate1m:stddev_over_time_2w

    # ----------------------------------
    # -- Resource sizing calculations --
    # ----------------------------------

    # CPU
    - record: instance_path:wrong_resource_size
      expr: instance_path:node_cpu_percent:rate1m:avg_plus_stddev_over_time_2w < 60
      labels:
        type: EC2
        metric: CPU
        problem: oversized
    - record: instance_path:wrong_resource_size
      expr: instance_path:node_cpu_percent:rate1m:avg_plus_stddev_over_time_2w > 80
      labels:
        type: EC2
        metric: CPU
        problem: undersized
    ```

# Network analysis

We can deduce the network usage from the `node_network_receive_bytes_total` and
`node_network_transmit_bytes_total` metrics. For example for the transmit, the
Gigabits per second transmitted can be calculated with the following
[Prometheus rule](prometheus.md#prometheus-rules):

```yaml
  - record: instance_path:node_network_transmit_gigabits_per_second:rate5m
    expr: >
      increase(
        node_network_transmit_bytes_total{device=~"(eth0|ens.*)"}[1m]
      ) * 7.450580596923828 * 10^-9 / 60
```

Where we:

* Filter the traffic only to the external network interfaces
    `node_network_transmit_bytes_total{device=~"(eth0|ens.*)"}`. Those are the
    ones used by [AWS](aws.md), but you'll need to tweak that for your case.
* Convert the `increase` of Kilobytes per minute `[1m]` to Gigabits per second
    by multiplying it by `7.450580596923828 * 10^-9 / 60`.

The [average](https://en.wikipedia.org/wiki/Average), [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation), the [standard
score](https://en.wikipedia.org/wiki/Standard_score) and the undersize or
oversize criteria is similar to the RAM case, so I'm adding it folded for
reference only.

??? note "Network usage rules"

    ```yaml
    # ---------------------------------------
    # -- Resource consumption calculations --
    # ---------------------------------------

    # NetworkReceive
    - record: instance_path:node_network_receive_gigabits_per_second:rate1m
      expr: >
        increase(
          node_network_receive_bytes_total{device=~"(eth0|ens.*)"}[1m]
        ) * 7.450580596923828 * 10^-9 / 60
    - record: instance_path:node_network_receive_gigabits_per_second:rate1m:avg_over_time_2w
      expr: >
        avg_over_time(
          instance_path:node_network_receive_gigabits_per_second:rate1m[2w]
        )
    - record: instance_path:node_network_receive_gigabits_per_second:rate1m:stddev_over_time_2w
      expr: >
        stddev_over_time(
          instance_path:node_network_receive_gigabits_per_second:rate1m[2w]
        )
    - record: instance_path:node_network_receive_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w
      expr: >
        instance_path:node_network_receive_gigabits_per_second:rate1m:avg_over_time_2w
        + instance_path:node_network_receive_gigabits_per_second:rate1m:stddev_over_time_2w
    - record: instance_path:node_network_receive_gigabits_per_second:rate1m:z_score
      expr: >
        (
          instance_path:node_network_receive_gigabits_per_second:rate1m
          - instance_path:node_network_receive_gigabits_per_second:rate1m:avg_over_time_2w
        ) / instance_path:node_network_receive_gigabits_per_second:rate1m:stddev_over_time_2w

    # NetworkTransmit
    - record: instance_path:node_network_transmit_gigabits_per_second:rate1m
      expr: >
        increase(
          node_network_transmit_bytes_total{device=~"(eth0|ens.*)"}[1m]
        ) * 7.450580596923828 * 10^-9 / 60
    - record: instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_over_time_2w
      expr: >
        avg_over_time(
          instance_path:node_network_transmit_gigabits_per_second:rate1m[2w]
        )
    - record: instance_path:node_network_transmit_gigabits_per_second:rate1m:stddev_over_time_2w
      expr: >
        stddev_over_time(
          instance_path:node_network_transmit_gigabits_per_second:rate1m[2w]
        )
    - record: instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w
      expr: >
        instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_over_time_2w
        + instance_path:node_network_transmit_gigabits_per_second:rate1m:stddev_over_time_2w
    - record: instance_path:node_network_transmit_gigabits_per_second:rate1m:z_score
      expr: >
        (
          instance_path:node_network_transmit_gigabits_per_second:rate1m
          - instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_over_time_2w
        ) / instance_path:node_network_transmit_gigabits_per_second:rate1m:stddev_over_time_2w

    # ----------------------------------
    # -- Resource sizing calculations --
    # ----------------------------------
    # NetworkReceive
    - record: instance_path:wrong_resource_size
      expr: >
        instance_path:node_network_receive_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w < 0.5
      labels:
        type: EC2
        metric: NetworkReceive
        problem: oversized
    - record: instance_path:wrong_resource_size
      expr: >
        instance_path:node_network_receive_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w > 3
      labels:
        type: EC2
        metric: NetworkReceive
        problem: undersized

    # NetworkTransmit
    - record: instance_path:wrong_resource_size
      expr: >
        instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w < 0.5
      labels:
        type: EC2
        metric: NetworkTransmit
        problem: oversized
    - record: instance_path:wrong_resource_size
      expr: >
        instance_path:node_network_transmit_gigabits_per_second:rate1m:avg_plus_stddev_over_time_2w > 3
      labels:
        type: EC2
        metric: NetworkTransmit
        problem: undersized
    ```

    The difference with network is that we don't have a percent of the total
    instance bandwidth, In my case, my instances support from 0.5 to 5 Gbps
    which is more than I need, so most of my instances are marked as oversized
    with the `< 0.5` rule. I will manually study the ones that go over 3 Gbps.

    The correct way to do it, is to tag the baseline, burst or/and maximum
    network performance by instance type. In the [AWS](aws.md) case, the data
    can be extracted using the [AWS
    docs](https://aws.amazon.com/ec2/instance-types/) or [external
    benchmarks](https://cloudonaut.io/ec2-network-performance-cheat-sheet/).

    Once you know the network performance per instance type, you can use
    [relabeling](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
    in the [Node exporter service monitor](node_exporter.md#install) to add
    a label like `max_network_performance` and use it later in the rules.

    If you do follow this path, please [contact me](contact.md) or do a [pull
    request](https://github.com/lyz-code/blue-book/pulls) so I can test
    your solution.

# Overall analysis

Now that we have all the analysis under the metric
`instance_path:wrong_resource_size` with labels, we can aggregate them to see
the number of rules each instance is breaking with the following rule:

```yaml
  # Mark the number of oversize rules matched by each instance
  - record: instance_path:wrong_instance_size
    expr: count by (instance) (sum by (metric, instance) (instance_path:wrong_resource_size))
```

By executing `sort_desc(instance_path:wrong_instance_size)` in the Prometheus
web application, we'll be able to see such instances.

```prometheus
instance_path:wrong_instance_size{instance="frontend-production:192.168.1.2"}	4
instance_path:wrong_instance_size{instance="backend-production-instance:172.30.0.195"}	2
...
```

To see the detail of what rules is our instance breaking we can use something
like `instance_path:wrong_resource_size{instance =~'frontend.*'}`

```prometheus
instance_path:wrong_resource_size{instance="fronted-production:192.168.1.2",instance_type="c4.2xlarge",job="node-exporter",metric="RAM",problem="oversized",type="EC2"}	5.126602454544287
instance_path:wrong_resource_size{instance="fronted-production:192.168.1.2",metric="CPU",problem="oversized",type="EC2"}	0.815639209497615
instance_path:wrong_resource_size{device="ens3",instance="fronted-production:192.168.1.2",instance_type="c4.2xlarge",job="node-exporter",metric="NetworkReceive",problem="oversized",type="EC2"}	0.02973250128744766
instance_path:wrong_resource_size{device="ens3",instance="fronted-production:192.168.1.2",instance_type="c4.2xlarge",job="node-exporter",metric="NetworkTransmit",problem="oversized",type="EC2"}	0.01586461503849804
```

Here we see that the `frontend-production` is a `c4.2xlarge` instance that is
consuming an average plus standard deviation of CPU of 0.81%, RAM 5.12%,
NetworkTransmit 0.015Gbps and NetworkReceive 0.029Gbps, which results in an
`oversized` alert on all four metrics.

If you want to see the evolution over the time, instead of `Console` click on
`Graph` under the text box where you have entered the query.

With this information, we can decide which is the correct instance for each
application. Once all instances are migrated to their ideal size, we can add
alerts on these metrics so we can have a continuous analysis of our instances.
Once I've done it, I'll add the alerts here.

# Disclaimer

We haven't tested this rules yet in production to resize our infrastructure
(will do soon), so use all the information in this document cautiously.

What I can expect to fail is that the assumption of average plus a standard
deviation criteria can not be enough, maybe I need to increase the resolution of
the standard deviation so it can be more sensible to the spikes, or we need to
use a safety factor of 2 or 3. We'll see :)

Read throughly the [Gitlab post on anomaly detection using
Prometheus](https://about.gitlab.com/blog/2019/07/23/anomaly-detection-using-prometheus/),
it's awesome and it may give you insights on why this approach is not working
with you, as well as other algorithms that for example take into account the
seasonality of the metrics.

In particular it's interesting to analyze your resources `z-score` evolution
over time, if all values fall in the `+4` to `-4` range, you can
statistically assert that your metric similarly follows the normal distribution,
and can assume that any value of z_score above 3 is an anomaly. If your results
return with a range of `+20` to `-20`, the tail is too long and your results will be
skewed.

To test it you can use the following queries to test the RAM behaviour, adapt
them for the rest of the resources:

```promql
# Minimum z_score value

sort_desc(abs((min_over_time(instance_path:node_memory_MemAvailable_percent[1w]) - instance_path:node_memory_MemAvailable_percent:avg_over_time_2w) / instance_path:node_memory_MemAvailable_percent:stddev_over_time_2w))

# Maximum z_score value

sort_desc(abs((max_over_time(instance_path:node_memory_MemAvailable_percent[1w]) - instance_path:node_memory_MemAvailable_percent:avg_over_time_2w) / instance_path:node_memory_MemAvailable_percent:stddev_over_time_2w))
```

For a less exhaustive but more graphical analysis, execute
`instance_path:node_memory_MemAvailable_percent:z_score` in `Graph` mode. In my
case the RAM is in the +-5 interval, with some peaks of 20, but after reviewing
`instance_path:node_memory_MemAvailable_percent:avg_plus_stddev_over_time_2w` in
those periods, I feel it's still safe to use the assumption.

Same criteria applies to `instance_path:node_cpu_percent:rate1m:z_score`,
`instance_path:node_network_receive_gigabits_per_second:rate1m:z_score`, and
`instance_path:node_network_transmit_gigabits_per_second:rate1m:z_score`,
metrics.

# References

* [Gitlab post on anomaly detection using
    Prometheus](https://about.gitlab.com/blog/2019/07/23/anomaly-detection-using-prometheus/).
