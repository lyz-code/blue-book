---
title: PromQL
date: 20200212
author: Lyz
---

# [Usage](https://promlabs.com/promql-cheat-sheet/)

## Selecting series

Select latest sample for series with a given metric name:

```promql
node_cpu_seconds_total
```

Select 5-minute range of samples for series with a given metric name:

```promql
node_cpu_seconds_total[5m]
```

Only series with given label values:

```promql
node_cpu_seconds_total{cpu="0",mode="idle"}
```

Complex label matchers (`=`: equality, `!=`: non-equality, `=~`: regex match, `!~`: negative regex match):

```promql
node_cpu_seconds_total{cpu!="0",mode=~"user|system"}
```

Select data from one day ago and shift it to the current time:

```promql
process_resident_memory_bytes offset 1d
```

## Rates of increase for counters

Per-second rate of increase, averaged over last 5 minutes:

```promql
rate(demo_api_request_duration_seconds_count[5m])
```

Per-second rate of increase, calculated over last two samples in a 1-minute time window:

```promql
irate(demo_api_request_duration_seconds_count[1m])
```

Absolute increase over last hour:

```promql
increase(demo_api_request_duration_seconds_count[1h])
```

## Aggregating over multiple series

Sum over all series:

```promql
sum(node_filesystem_size_bytes)
```

Preserve the instance and job label dimensions:

```promql
sum by(job, instance) (node_filesystem_size_bytes)
```

Aggregate away the instance and job label dimensions:

```promql
sum without(instance, job) (node_filesystem_size_bytes)
```

Available aggregation operators: `sum()`, `min()`, `max()`, `avg()`, `stddev()`, `stdvar()`, `count()`, `count_values()`, `group()`, `bottomk()`, `topk()`, `quantile()`.

## Time

Get the Unix time in seconds at each resolution step:

```promql
time()
```

Get the age of the last successful batch job run:

```promql
time() - demo_batch_last_success_timestamp_seconds
```

Find batch jobs which haven't succeeded in an hour:

```promql
time() - demo_batch_last_success_timestamp_seconds > 3600
```

# Snippets

## [Generating range vectors from return values in Prometheus queries](https://stackoverflow.com/questions/40717605/generating-range-vectors-from-return-values-in-prometheus-queries)

Use the
[subquery-syntax](https://prometheus.io/docs/prometheus/latest/querying/basics/#subquery)

Warning: These subqueries are expensive, i.e. create very high load on
Prometheus. Use recording-rules when you use these queries regularly.

### Subquery syntax

`<instant_query>[<range>:<resolution>]`

- `instant_query`: A PromQL-function which returns an instant-vector).
- `range`: Offset (back in time) to start the first subquery.
- `resolution`: The size of each of the subqueries.

It returns a range-vector.

For example:

```promql
deriv(rate(varnish_main_client_req[2m])[5m:10s])
```

In the example above, Prometheus runs `rate()` (= `instant_query`) 30 times (the
first from 5 minutes ago to -4:50, ..., the last -0:10 to now). The resulting
range-vector is input to the `deriv()` function.

# Links

- [Prometheus cheatsheet](https://promlabs.com/promql-cheat-sheet/)
