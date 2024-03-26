Increasing the resilience of the servers is critical when hosting services for others. This is the roadmap I'm following for my servers.

# Autostart services if the system reboots
Using init system services to manage your services
# Get basic metrics traceability and alerts 
Set up [Prometheus](prometheus.md) with:

- The [blackbox exporter](blackbox_exporter.md) to track if the services are available to your users and to monitor SSL certificates health.
- The [node exporter](node_exporter.md) to keep track on the resource usage of your machines and set alerts to get notified when concerning events happen (disks are getting filled, CPU usage is too high)

# Get basic logs traceability and alerts 

Set up [Loki](loki.md) and clear up your system log errors.

# Improve the resilience of your data
If you're still using `ext4` for your filesystems instead of [`zfs`](zfs.md) you're missing a big improvement. To set it up:

- [Plan your zfs storage architecture](zfs_storage_planning.md)
- [Install ZFS](zfs.md)
- [Create ZFS local and remote backups](sanoid.md)
- [Monitor your ZFS ]

# Automatically react on system failures
- [Kernel panics](https://www.supertechcrew.com/kernel-panics-and-lockups/)
- [watchdog](watchdog.md)

# Future undeveloped improvements
- Handle the system reboots after kernel upgrades
