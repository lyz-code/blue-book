# Linux loki alerts
```yaml
      - alert: TooManyLogs
        expr: |
          sum by(hostname) (count_over_time({job="systemd-journal"} [1d])) / sum by(hostname) (count_over_time({job="systemd-journal"} [1d] offset 1d)) > 1.5
        for: 0m
        labels:
            severity: warning
        annotations:
            summary: "The server {{ $labels.hostname}} is generating too many logs"

      - alert: TooFewLogs
        expr: |
          sum by(hostname) (count_over_time({job="systemd-journal"} [1d])) / sum by(hostname) (count_over_time({job="systemd-journal"} [1d] offset 1d)) < 0.5
        for: 0m
        labels:
            severity: warning
        annotations:
            summary: "The server {{ $labels.hostname}} is generating too few logs"

```
# References

## Learning

- https://explainshell.com/
- https://linuxcommandlibrary.com/
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
