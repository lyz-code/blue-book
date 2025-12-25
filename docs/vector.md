Vector is a lightweight, ultra-fast tool for building observability pipelines

# Installation

## [On debian](https://vector.dev/docs/setup/installation/package-managers/apt/)

First, add the Vector repo:

```bash
bash -c "$(curl -L https://setup.vector.dev)"
```

Then you can install the vector package:

```bash
sudo apt-get install vector
```

Tweak the configuration and then enable the service.

To be sure that vector is able to push to loki create the `/usr/local/bin/wait-for-loki.sh` file

```bash
#!/bin/bash
while true; do
  response=$(curl -s http://localhost:3100/ready 2>/dev/null)
  if [ "$response" = "ready" ]; then
    break
  fi
  sleep 1
done
```

Make it executable `chmod +x /usr/local/bin/wait-for-loki.sh`

Then update your `vector.service` (`/usr/lib/systemd/system/vector.service`)

```
ExecStartPre=/usr/local/bin/wait-for-loki.sh
ExecStartPre=/usr/bin/vector validate
```

Run `systemctl daemon-reload` to reload the service configuration.

# [Configuration](https://vector.dev/docs/reference/configuration/)

The config lives at `/etc/vector/vector.yaml`.

## [Docker](https://vector.dev/docs/reference/configuration/sources/docker_logs/)

First add `vector` to the `docker` group: `usermod -a -G docker vector`

```yaml
sources:
  docker:
    type: docker_logs

transforms:
  docker_labels:
    type: remap
    inputs:
      - docker
    source: |
      .service_name = get(.label, ["com.docker.compose.project"]) ?? "unknown"
sinks:
  loki_docker:
    type: loki
    inputs:
      - docker_labels
    endpoint: http://localhost:3100/
    encoding:
      codec: json
    labels:
      source: docker
      host: "{{ host }}"
      container: "{{ container_name }}"
      service_name: "{{ service_name }}"
```

## [journald](https://vector.dev/docs/reference/configuration/sources/journald/)

To avoid the services that run docker to be indexed twice

```yaml
sources:
  journald:
    type: journald

transforms:
  journald_filter:
    type: filter
    inputs:
      - journald
    condition: |
      # Exclude docker-compose systemd services
      !contains(string!(.SYSLOG_IDENTIFIER), "docker-compose") &&
      !contains(string!(.SYSLOG_IDENTIFIER), "docker")

  journald_labels:
    type: remap
    inputs:
      - journald_filter
    source: |
      .service_name = ._SYSTEMD_UNIT || "unknown"

sinks:
  loki_systemd:
    type: loki
    inputs:
      - journald_labels
    endpoint: http://localhost:3100/
    encoding:
      codec: json
    labels:
      source: journald
      host: "{{ host }}"
      service_name: "{{ service_name }}"
```

## ZFS

Prepare the file to be readable by vector:

```bash
chown root:vector /proc/spl/kstat/zfs/dbgmsg
chmod 640 /proc/spl/kstat/zfs/dbgmsg
```
```yaml
sources:
  zfs_log:
    type: file
    include:
      - /proc/spl/kstat/zfs/dbgmsg
  zfs_files:
    type: loki
    inputs:
      - zfs_log
    endpoint: http://localhost:3100/
    encoding:
      codec: json
    labels:
      source: file
      service_name: zfs
      host: "{{ host }}"
      filename: "{{ file }}"
sinks:
```


# Troubleshooting

## Vector Permission Debugging with systemd tmpfiles

Vector fails to read log files after reboots or log rotation with permission errors:

```
ERROR: Failed reading file for fingerprinting. error=Permission denied (os error 13)
```

## Solution with tmpfiles

Create `/etc/tmpfiles.d/vector-permissions.conf`:

```
# Set permissions on existing files (z = adjust ownership/permissions)
z /data/apps/myapp/logs/logfile.log 0644 vector vector -
z /path/to/another/logfile.log 0644 vector vector -
```

Apply immediately:

```bash
systemd-tmpfiles --create /etc/tmpfiles.d/vector-permissions.conf
```

### What is tmpfiles

systemd tmpfiles.d is a mechanism for managing temporary files, directories, and their permissions at boot time and periodically during system operation.

What it does:

- Creates/removes files and directories
- Sets ownership and permissions
- Runs at boot via systemd-tmpfiles-setup.service
- Can be triggered manually or periodically

Configuration format:

```
Type Path Mode UID GID Age Argument
```

Common types:

- `d` - Create directory
- `f` - Create file
- `z` - Set ownership/permissions on existing path
- `Z` - Recursively set ownership/permissions
- `x` - Ignore/exclude path

Example:

```
# /etc/tmpfiles.d/example.conf
d /var/run/myapp 0755 myuser mygroup -
f /var/log/myapp.log 0644 myuser mygroup -
z /existing/file 0644 myuser mygroup -
```

Files in /etc/tmpfiles.d/ with .conf extension are processed automatically at boot and can be manually applied with systemd-tmpfiles --create. Also, if the `systemd-tmpfiles-clean.timer` is enabled (which is by default) it will be check each day.

## Unable to open checkpoint file. path="/var/lib/vector/journald/checkpoint.txt"

```
ERROR source{component_kind="source" component_id=journald component_type=journald}: vector::internal_events::journald: Unable to open checkpoint file. path="/var/lib/vector/journald/checkpoint.txt" error=Permission denied (os error 13) error_type="io_failed" stage="receiving"
```

```bash
sudo mkdir -p /var/lib/vector/journald
sudo chown -R vector:vector /var/lib/vector
sudo chmod 755 /var/lib/vector
sudo chmod 755 /var/lib/vector/journald
```

# References

- [Home](https://vector.dev/)
