[Watchtower](https://containrrr.dev/watchtower/) is a container-based solution for automating Docker container base image updates.

With watchtower you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry. Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially. Run the watchtower container with the following command:

```bash
$ docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower
```

# Usage

## Exclude image from being pruned

Add to the dockerfile:

```Dockerfile
LABEL com.centurylinklabs.watchtower.enable=false
```

# Monitorization

To make sure that watchtower is working as expected you can use the next alerts:

```yaml
groups:
  - name: watchtower
    rules:
      - alert: WatchtowerError
        expr: |
          count_over_time({container="watchtower"} |= `` | logfmt level | level=`error` [15m]) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Error in watchtower logs {{ $labels.container }} at {{ $labels.hostname}}"
      - alert: WatchtowerNotRunningError
        expr: |
          (sum by(hostname) (count_over_time({job="systemd-journal"} [1h])) 
          unless 
          sum by(hostname) (count_over_time({unit="watchtower.service"} [1d]))) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Watchtower has not shown any logs in {{ $labels.hostname}} in the last day"
```

# References

- [Source](https://github.com/containrrr/watchtower)
- [Docs](https://containrrr.dev/watchtower/)
