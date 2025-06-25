[unison](https://github.com/bcpierce00/unison) is a file-synchronization tool for POSIX-compliant systems (e.g. \*BSD, GNU/Linux, macOS) and Windows. It allows two replicas of a collection of files and directories to be stored on different hosts (or different disks on the same host), modified separately, and then brought up to date by propagating the changes in each replica to the other.

Unison has been in use for over 20 years and many people use it to synchronize data they care about.

# Usage

## Sync the files between two directories on the same machine

Create the config in `~/.unison/orgfiles.prf`

```ini
# Source and destination directories
root = /home/lyz/.syncthing/Orgmode
root = /home/lyz/projects/cuaderno

# Only sync specific files
path = talk.org
path = plans.org

# Cron-friendly settings
batch = true

# Backup conflicted files with timestamp
backup = Name *.backup-$(now)

# Logging
log = true

# Preserve permissions and timestamps
perms = -1
times = true
```

Sync them with `unison orgfiles`

## Resolve conflicts

Do a manual merge and then copy the result file to the other location with `cp -p` to preserve the timestamp, otherwise it keep on showing merge errors

## Monitor errors

If you're using loki you can monitor any file conflicts with:

```yaml
- alert: OrgmodeUnisonSyncConflictError
  expr: |
    count_over_time({job="systemd-journal", syslog_identifier="clean_orgmode"} |= `Skipped` [1h]) > 0
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: "hay conflictos al sincronizar algunos archivos de orgmode con unison {{ $labels.hostname}}"
- alert: OrgmodeUnisonSyncHasNotCompletedAsExpectedError
  expr: |
    (count_over_time({job="systemd-journal", syslog_identifier="clean_orgmode"} |= `Nothing to do` [3h]) > 0 or on() vector(0)) == 0
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: "el sincronizado de archivos de orgmode con unison no ha terminado bien desde hace un tiempo{{ $labels.hostname}}"

```

# References

- [Source](https://github.com/bcpierce00/unison)
- [Docs](https://github.com/bcpierce00/unison/blob/documentation/unison-manual.txt)
