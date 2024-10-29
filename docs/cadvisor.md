[cAdvisor](https://github.com/google/cadvisor) (Container Advisor) provides container users an understanding of the resource usage and performance characteristics of their running containers. It is a running daemon that collects, aggregates, processes, and exports information about running containers. Specifically, for each container it keeps resource isolation parameters, historical resource usage, histograms of complete historical resource usage and network statistics. This data is exported by container and machine-wide.

cAdvisor has native support for Docker containers and should support just about any other container type out of the box. 

# Try it out

To quickly tryout cAdvisor on your machine with Docker, we have a Docker image that includes everything you need to get started. You can run a single cAdvisor to monitor the whole machine. Simply run:

```bash
VERSION=v0.49.1 # use the latest release version from https://github.com/google/cadvisor/releases
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:$VERSION
```
# Installation

You can check all the configuration flags [here](https://github.com/google/cadvisor/blob/master/docs/runtime_options.md#metrics).
 
## With docker compose

* Create the data directories: 
  ```bash
  mkdir -p /data/cadvisor/
  ```
* Copy the `docker/docker-compose.yaml` to `/data/cadvisor/docker-compose.yaml`.
  ```yaml
  ---
  services:
    cadvisor:
      image: gcr.io/cadvisor/cadvisor:latest
      restart: unless-stopped
      privileged: true
      # command:
      # # tcp and udp create high CPU usage, disk does CPU hungry ``zfs list``
      # - '--disable_metrics=tcp,udp,disk'
      volumes:
        - /:/rootfs:ro
        - /var/run:/var/run:ro
        - /sys:/sys:ro
        - /var/lib/docker/:/var/lib/docker:ro
        - /dev/disk:/dev/disk:ro
      # ports:
      #   - "8080:8080"
      devices:
        - /dev/kmsg:/dev/kmsg
      networks:
        - monitorization

  networks:
    monitorization:
      external: true
  ```

  If the prometheus is not in the same instance as the cadvisor expose the port and remove the network.
  ```
* Create the docker networks (if they don't exist):
    * `docker network create monitorization`
* Copy the `service/cadvisor.service` into `/etc/systemd/system/`
  ```
  [Unit]
  Description=cadvisor
  Requires=docker.service
  After=docker.service

  [Service]
  Restart=always
  User=root
  Group=docker
  WorkingDirectory=/data/cadvisor
  TimeoutStartSec=100
  RestartSec=2s
  ExecStart=/usr/bin/docker compose -f docker-compose.yaml up
  ExecStop=/usr/bin/docker compose -f docker-compose.yaml down

  [Install]
  WantedBy=multi-user.target
  ```
* Start the service `systemctl start cadvisor`
* If needed enable the service `systemctl enable cadvisor`.
- Scrape the metrics with prometheus
  - If both dockers share machine and docker network:
    ```yaml
    scrape_configs:
      - job_name: cadvisor
        metrics_path: /metrics
        static_configs:
          - targets:
            - cadvisor:8080
        # Relabels needed for the grafana dashboard 
        # https://grafana.com/grafana/dashboards/15798-docker-monitoring/
        metric_relabel_configs:
          - source_labels: ['container_label_com_docker_compose_project']
            target_label: 'service'
          - source_labels: ['name']
            target_label: 'container'
    ```
## [Deploy the alerts](https://samber.github.io/awesome-prometheus-alerts/rules#docker-containers)

```yaml
---
# Most are taken from https://samber.github.io/awesome-prometheus-alerts/rules#docker-containers
groups:
- name: cAdvisor rules
  rules:
    # This rule can be very noisy in dynamic infra with legitimate container start/stop/deployment.
    - alert: ContainerKilled
      expr: min by (name, service) (time() - container_last_seen{container=~".*"}) > 60
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Container killed (instance {{ $labels.instance }})
        description: "A container has disappeared\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    # This rule can be very noisy in dynamic infra with legitimate container start/stop/deployment.
    - alert: ContainerAbsent
      expr: absent(container_last_seen{container=~".*"})
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Container absent (instance {{ $labels.instance }})
        description: "A container is absent for 5 min\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: ContainerHighCpuUtilization
      expr: (sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod, container) / sum(container_spec_cpu_quota{container!=""}/container_spec_cpu_period{container!=""}) by (pod, container) * 100) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Container High CPU utilization (instance {{ $labels.instance }})
        description: "Container CPU utilization is above 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
      
      # See https://medium.com/faun/how-much-is-too-much-the-linux-oomkiller-and-used-memory-d32186f29c9d
    - alert: ContainerHighMemoryUsage
      expr: (sum(container_memory_working_set_bytes{name!=""}) BY (instance, name) / sum(container_spec_memory_limit_bytes > 0) BY (instance, name) * 100) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Container High Memory usage (instance {{ $labels.instance }})
        description: "Container Memory usage is above 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    # I feel that this is monitored well with the node exporter
    # - alert: ContainerVolumeUsage
    #   expr: (1 - (sum(container_fs_inodes_free{name!=""}) BY (instance) / sum(container_fs_inodes_total) BY (instance))) * 100 > 80
    #   for: 2m
    #   labels:
    #     severity: warning
    #   annotations:
    #     summary: Container Volume usage (instance {{ $labels.instance }})
    #     description: "Container Volume usage is above 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: ContainerHighThrottleRate
      expr: sum(increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) by (container, pod, namespace) / sum(increase(container_cpu_cfs_periods_total[5m])) by (container, pod, namespace) > ( 25 / 100 )
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Container high throttle rate (instance {{ $labels.instance }})
        description: "Container is being throttled\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: ContainerLowCpuUtilization
      expr: (sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod, container) / sum(container_spec_cpu_quota{container!=""}/container_spec_cpu_period{container!=""}) by (pod, container) * 100) < 20
      for: 7d
      labels:
        severity: info
      annotations:
        summary: Container Low CPU utilization (instance {{ $labels.instance }})
        description: "Container CPU utilization is under 20% for 1 week. Consider reducing the allocated CPU.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: ContainerLowMemoryUsage
      expr: (sum(container_memory_working_set_bytes{name!=""}) BY (instance, name) / sum(container_spec_memory_limit_bytes > 0) BY (instance, name) * 100) < 20
      for: 7d
      labels:
        severity: info
      annotations:
        summary: Container Low Memory usage (instance {{ $labels.instance }})
        description: "Container Memory usage is under 20% for 1 week. Consider reducing the all"

    - alert: Container (Compose) Too Many Restarts
      expr: count by (instance, name) (count_over_time(container_last_seen{name!="", container_label_restartcount!=""}[15m])) - 1 >= 5
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Too many restarts ({{ $value }}) for container \"{{ $labels.name }}\""
```
## Deploy the dashboard

There are many grafana dashboards for cAdvisor, of them all I've chosen [this one](https://grafana.com/grafana/dashboards/15798-docker-monitoring/)

Once you've imported and selected your prometheus datasource you can press on "Share" to get the json and add it to your provisioned dashboards.

## Make it work with ZFS

There are many issues about it ([1](https://github.com/google/cadvisor/issues/1579))

Solution seems to be to use `--device /dev/zfs:/dev/zfs`

# References
- [Source](https://github.com/google/cadvisor)
