[`rasdaemon`](https://github.com/mchehab/rasdaemon) is a RAS (Reliability, Availability and Serviceability) logging tool. It records memory errors, using the EDAC tracing events. EDAC is a Linux kernel subsystem with handles detection of ECC errors from memory controllers for most chipsets on i386 and x86_64 architectures. EDAC drivers for other architectures like arm also exists. 

# Installation
```bash
apt-get install rasdaemon
```

The output will be available via syslog but you can show it to the foreground (`-f`) or to an sqlite3 database (`-r`)

To post-process and decode received MCA errors on AMD SMCA systems, run:

```bash
rasdaemon -p --status <STATUS_reg> --ipid <IPID_reg> --smca --family <CPU Family> --model <CPU Model> --bank <BANK_NUM>
```

Status and IPID Register values (in hex) are mandatory. The smca flag with family and model are required if not decoding locally. Bank parameter is optional.

You may also start it via systemd:

```bash
systemctl start rasdaemon
```

The rasdaemon will then output the messages to journald.

# [Usage](https://www.setphaserstostun.org/posts/monitoring-ecc-memory-on-linux-with-rasdaemon/)
At this point `rasdaemon` should already be running on your system. You can now use the `ras-mc-ctl` tool to query the errors that have been detected. If everything is well configured you'll see something like:

```bash
$: ras-mc-ctl --error-count
Label                 CE      UE
mc#0csrow#2channel#0  0   0
mc#0csrow#2channel#1  0   0
mc#0csrow#3channel#1  0   0
mc#0csrow#3channel#0  0   0
```

If it's not you'll see:

```bash
ras-mc-ctl: Error: No DIMMs found in /sys or new sysfs EDAC interface not found.
```

The `CE` column represents the number of corrected errors for a given DIMM, `UE` represents uncorrectable errors that were detected. The label on the left shows the EDAC path under `/sys/devices/system/edac/mc/` of every DIMM. This is not very readable, if you wish to improve the labeling [read this article](https://www.setphaserstostun.org/posts/monitoring-ecc-memory-on-linux-with-rasdaemon/)

More ways to check is to run:

```bash
$: ras-mc-ctl --status
ras-mc-ctl: drivers are loaded.
```

You can also see a summary of the state with:

```bash
$: ras-mc-ctl --summary
No Memory errors.

No PCIe AER errors.

No Extlog errors.

DBD::SQLite::db prepare failed: no such table: devlink_event at /usr/sbin/ras-mc-ctl line 1183.
Can't call method "execute" on an undefined value at /usr/sbin/ras-mc-ctl line 1184.
```

# Monitorization

You can use [loki](loki.md) to monitor ECC errors shown in the logs with the next alerts:

```yaml
groups: 
  - name: ecc
    rules:
      - alert: ECCError
        expr: |
          count_over_time({job="systemd-journal", unit="rasdaemon.service", level="error"} [5m])  > 0
        for: 1m
        labels:
            severity: critical
        annotations:
            summary: "Possible ECC error detected in {{ $labels.hostname}}"

      - alert: ECCWarning
        expr: |
          count_over_time({job="systemd-journal", unit="rasdaemon.service", level="warning"} [5m])  > 0 
        for: 1m
        labels:
            severity: warning
        annotations:
            summary: "Possible ECC warning detected in {{ $labels.hostname}}"
      - alert: ECCAlert
        expr: |
          count_over_time({job="systemd-journal", unit="rasdaemon.service", level!~"info|error|warning"} [5m]) > 0
        for: 1m
        labels:
            severity: info
        annotations:
            summary: "ECC log trace with unknown severity level detected in {{ $labels.hostname}}"
```
# References

- [Source](https://github.com/mchehab/rasdaemon)
