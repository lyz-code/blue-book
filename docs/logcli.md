[`logcli`](https://grafana.com/docs/loki/latest/query/logcli/) is the command-line interface to Grafana Loki. It facilitates running LogQL queries against a Loki instance.

# [Installation](https://grafana.com/docs/loki/latest/query/logcli/#installation)
Download the logcli binary from the [Loki releases page](https://github.com/grafana/loki/releases) and install it somewhere in your `$PATH`.

# [Usage](https://grafana.com/docs/loki/latest/query/logcli/#logcli-usage)
`logcli` points to the local instance `http://localhost:3100` directly, if you want another one export the `LOKI_ADDR` environment variable.

## Run a query
```bash
logcli query '{job="loki-ops/consul"}'
```

You can also set the time range and output format

```bash
logcli query \
     --timezone=UTC  \
     --from="2024-06-10T07:23:36Z" \
     --to="2024-06-12T16:23:58Z" \
     --output=jsonl \
     '{job="docker", container="aleph_ingest-file_1"} | json | __error__=`` | severity =~ `WARNING|ERROR` | message !~ `Queueing failed task for retry.*` | logger!=`ingestors.manager`'
```
# References
- [Docs](https://grafana.com/docs/loki/latest/query/logcli/)
