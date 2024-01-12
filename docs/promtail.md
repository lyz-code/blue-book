# Promtail

[Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) is an agent which ships the contents of local logs to a [Loki](loki.md) instance.

It is usually deployed to every machine that runs applications which need to be monitored.

It primarily:

    Discovers targets
    Attaches labels to log streams
    Pushes them to the Loki instance.

# [Configuration](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/)

Promtail is configured in a YAML file (usually referred to as config.yaml) which contains information on the Promtail server, where positions are stored, and how to scrape logs from files.

To see the configuration that is being loaded at promtail use one of the next flags:

- `-print-config-stderr` is nice when running Promtail directly e.g. ./promtail as you can get a quick output of the entire Promtail config.

- `-log-config-reverse-order` is the flag we run Promtail with in all our environments, the config entries are reversed so that the order of configs reads correctly top to bottom when viewed in Grafana’s Explore.

## [Scraping configs](https://grafana.com/docs/loki/latest/send-data/promtail/scraping/)

Promtail borrows the same [service discovery mechanism from Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config). `promtail` is configured using a `scrape_configs` stanza. `relabel_configs` allows for fine-grained control of what to ingest, what to drop, and the final metadata to attach to the log line. 

Once Promtail has a set of targets (i.e., things to read from, like files) and all labels are set correctly, it will start tailing (continuously reading) the logs from targets. Once enough data is read into memory or after a configurable timeout, it is flushed as a single batch to Loki.

As Promtail reads data from sources (files and systemd journal, if configured), it will track the last offset it read in a positions file. By default, the positions file is stored at `/var/log/positions.yaml`. The positions file helps Promtail continue reading from where it left off in the case of the Promtail instance restarting.

### [The file target discovery](https://grafana.com/docs/loki/latest/send-data/promtail/scraping/#file-target-discovery)

Promtail discovers locations of log files and extract labels from them through the `scrape_configs` section in the config YAML.

```yaml

# Basic concepts

## API

Promtail features an embedded web server exposing a web console at `/` and the following API endpoints:

- GET `/ready`: This endpoint returns 200 when Promtail is up and running, and there’s at least one working target.
- GET `/metrics`: This endpoint returns Promtail metrics for Prometheus. 

# References

- [Docs](https://grafana.com/docs/loki/latest/send-data/promtail/)
