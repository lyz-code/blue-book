
[LogQL](https://grafana.com/docs/loki/latest/logql/) is Grafana Loki’s PromQL-inspired query language. Queries act as if they are a distributed `grep` to aggregate log sources. LogQL uses labels and operators for filtering.

There are two types of LogQL queries:

- Log queries: Return the contents of log lines.
- Metric queries: Extend log queries to calculate values based on query results.

# Usage

## Apply a pattern to the value of a label

Some logs are sent in json and then one of their fields can contain other structured data. You may want to use that structured data to further filter the logs.

```logql
{app="ingress-nginx"} | json | line_format `{{.log}}` | pattern `<_> - - <_> "<method> <_> <_>" <status> <_> <_> "<_>" <_>` | method != `GET`
```

- `{app="ingress-nginx"}`: Show only the logs of the `ingress-nginx`.
- `| json`:  Interpret the line as a json.
- ```| line_format `{{.log}}` | pattern `<_> - - <_> "<method> <_> <_>" <status> <_> <_> "<_>" <_>````: interpret the `log` json field of the trace with the selected pattern
- ```| method != `GET````: Filter the line using a key extracted by the pattern.

## Count the unique values of a label

Sometimes you want to alert on the values of a log. For example if you want to make sure that you're receiving the logs from more than 20 hosts (otherwise something is wrong). Assuming that your logs attach a `host` label you can run

```logql
sum(count by(host) (rate({host=~".+"} [24h])) > bool 0)
```

This query will:
- `{host=~".+"}`: Fetch all log lines that contain the label `host`
- `count by(host) (rate({host=~".+"} [24h])`: Calculates the number of entries in the last 24h.
- `count by(host) (rate({host=~".+"} [24h])) > bool 0`: Converts to `1` all the vector elements that have more than 1 message.
- `sum(count by(host) (rate({host=~".+"} [24h])) > bool 0)`: Sums all the vector elements to get the number of hosts that have more than one message. 

`journald` promtail parser is known to fail between upgrades, it's useful too to make an alert to make sure that all your hosts are sending the traces. You can do it with: `sum(count by(host) (rate({job="systemd-journal"} [24h])) > bool 0)`

# References

- [Docs](https://grafana.com/docs/loki/latest/logql/)
