[unison](https://github.com/bcpierce00/unison) is a file-synchronization tool for POSIX-compliant systems (e.g. \*BSD, GNU/Linux, macOS) and Windows. It allows two replicas of a collection of files and directories to be stored on different hosts (or different disks on the same host), modified separately, and then brought up to date by propagating the changes in each replica to the other.

Unison has been in use for over 20 years and many people use it to synchronize data they care about.

# Installation

If you are on debian or ubuntu, the version of the repositories [does not allow you to run the program with the file watcher](https://github.com/bcpierce00/unison/issues/208), so you may need to build it yourself:

First install the dependencies:

```bash
sudo apt-get install ocaml-native-compilers
```

```bash
# Manually install Unison (to sync folders) from sources cause Unison in
# the APT repository does not contain 'unison-fsmonitor'.
export UNISON_VERSION=2.53.8
echo "Install Unison." \
    && pushd /tmp \
    && wget https://github.com/bcpierce00/unison/archive/v$UNISON_VERSION.tar.gz \
    && tar -xzvf v$UNISON_VERSION.tar.gz \
    && rm v$UNISON_VERSION.tar.gz \
    && pushd unison-$UNISON_VERSION \
    && make \
    && cp -t /usr/local/bin ./src/unison ./src/unison-fsmonitor \
    && popd \
    && rm -rf unison-$UNISON_VERSION \
    && popd
```

Then remove the ocaml compilers as they take quite some space:

```bash
sudo apt-get remove ocaml-native-compilers
```

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

## Run in the background watching changes

Create the systemd service in: `~/.config/systemd/user/unison.service` (assuming that your profile is orgfiles)

```init
[Unit]
Description=unison

[Service]
ExecStart=/usr/local/bin/unison orgfiles
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
```

## Monitor errors

If you're using loki you can monitor any file conflicts with:

```yaml
- alert: OrgmodeUnisonSyncConflictError
  expr: |
    count_over_time({job="systemd-journal", syslog_identifier="unison"} |= `Skipped` [1h]) > 0
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: "hay conflictos al sincronizar algunos archivos de orgmode con unison {{ $labels.hostname}}"
- alert: OrgmodeUnisonSyncHasNotCompletedAsExpectedError
  expr: |
    (count_over_time({job="systemd-journal", syslog_identifier="unison"} |= `Nothing to do` [3h]) > 0 or on() vector(0)) == 0
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: "el sincronizado de archivos de orgmode con unison no ha terminado bien desde hace un tiempo{{ $labels.hostname}}"
```

# References

- [Source](https://github.com/bcpierce00/unison)
- [Docs](https://github.com/bcpierce00/unison/blob/documentation/unison-manual.txt)
