---
title: PromQL
date: 20200212
author: Lyz
---

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

- [Prometheus cheatsheet](https://files.timber.io/pdfs/PromQL+Cheatsheet.pdf)
