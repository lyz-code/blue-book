---
title: Email automation
date: 20210820
author: Lyz
---

Most of the received emails require repetitive actions that can be automated,
and you may also want to access your emails through a command line interface and
be able to search through them.

One of the ways to achieve that goals is to use a combination of tools to
synchronize the mailboxes, tag them, and run scripts automatically based on the
tags.

# Fetch emails

First you need a program that syncs your mailboxes, following [pazz's advice
](https://github.com/pazz/alot/wiki/pazz's-mail-setup#fetching-mail-mbsync),
I'll use [mbsync](mbsync.md). Follow the steps under
[installation](mbsync.md#installation) to configure your accounts, taking as an
example an account called `lyz` you should be able to sync all your emails with:

```bash
mbsync -V lyz
```

# Tag and index emails

If you want to use [`alot`](alot.md) (which I no longer do) you need to install [`notmuch`](notmuch.md) a tool to index, search, read,
and tag large collections of email messages. Follow the steps under
[installation](notmuch.md#installation) under you have created the database that
indexes your emails.

Once we have that, we need a tool to tag the emails following our desired rules.
[afew](afew.md) is one way to go. Follow the steps under
[installation](afew.md#installation).

# Automatically sync emails 

## The new way

I have many emails, and I want to fetch them with different frequencies, in the background and be notified if anything goes wrong.

For that purpose I've created a python script, a systemd service and some loki rules to monitor it.

### Script to sync emails and calendars with different frequencies

The script iterates over the configured accounts in `accounts_config` and runs `mbsync` for email accounts and `vdirsyncer` for email accounts based on some cron expressions. It logs the output in `logfmt` format so that it's easily handled by [loki](loki.md)

To run it you'll first need to create a virtualenv, I use `mkvirtualenv account_syncer` which creates a virtualenv in `~/.local/share/virtualenv/account_syncer`.

Then install the dependencies:

```bash
pip install aiocron
```

Then place this script somewhere, for example (`~/.local/bin/account_syncer.py`)

```python
import asyncio
import logging
from datetime import datetime
import asyncio.subprocess
import aiocron

# Dependencies:
# pip install aiocron

# Configuration for accounts (example)
accounts_config = {
    "emails": [
      {
          "account_name": "lyz",
          "cron_expressions": ["*/15 9-23 * * *"],
      },
      {
          "account_name": "work",
          "cron_expressions": ["*/60 8-17 * * 1-5"],  # Monday-Friday
      },
      {
          "account_name": "monitorization",
          "cron_expressions": ["*/5 * * * *"],
      },
    ],
    "calendars": [
      {
          "account_name": "lyz",
          "cron_expressions": ["*/15 9-23 * * *"],
      },
      {
          "account_name": "work",
          "cron_expressions": ["*/60 8-17 * * 1-5"],  # Monday-Friday
      },
    ],
}


class LogfmtFormatter(logging.Formatter):
    """Custom formatter to output logs in logfmt style."""

    def format(self, record: logging.LogRecord) -> str:
        log_message = (
            f"level={record.levelname.lower()} "
            f"logger={record.name} "
            f'msg="{record.getMessage()}"'
        )
        return log_message


def setup_logging(logging_name: str) -> logging.Logger:
    """Configure logging to use logfmt format.
    Args:
        logging_name (str): The logger's name and identifier in the systemd journal.
    Returns:
        Logger: The configured logger.
    """
    console_handler = logging.StreamHandler()
    logfmt_formatter = LogfmtFormatter()
    console_handler.setFormatter(logfmt_formatter)
    logger = logging.getLogger(logging_name)
    logger.setLevel(logging.INFO)
    logger.addHandler(console_handler)
    return logger


log = setup_logging("account_syncer")


async def run_mbsync(account_name: str) -> None:
    """Run mbsync command asynchronously for email accounts.

    Args:
        account_name (str): The name of the email account to sync.
    """
    command = f"mbsync {account_name}"
    log.info(f"Syncing emails for {account_name}...")
    process = await asyncio.create_subprocess_shell(
        command, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await process.communicate()
    if stdout:
        log.info(f"Output for {account_name}: {stdout.decode()}")
    if stderr:
        log.error(f"Error for {account_name}: {stderr.decode()}")


async def run_vdirsyncer(account_name: str) -> None:
    """Run vdirsyncer command asynchronously for calendar accounts.

    Args:
        account_name (str): The name of the calendar account to sync.
    """
    command = f"vdirsyncer sync {account_name}"
    log.info(f"Syncing calendar for {account_name}...")
    process = await asyncio.create_subprocess_shell(
        command, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )
    _, stderr = await process.communicate()
    if stderr:
        command_log = stderr.decode().strip()
        if "error" in command_log or "critical" in command_log:
            log.error(f"Output for {account_name}: {command_log}")
        elif len(command_log.splitlines()) > 1:
            log.info(f"Output for {account_name}: {command_log}")


def should_i_sync_today(cron_expr: str) -> bool:
    """Check if the current time matches the cron expression day and hour constraints."""
    _, hour, _, _, day_of_week = cron_expr.split()
    now = datetime.now()
    if "*" in hour:
        return True
    elif not (int(hour.split("-")[0]) <= now.hour <= int(hour.split("-")[1])):
        return False
    if day_of_week != "*" and str(now.weekday()) not in day_of_week.split(","):
        return False
    return True


async def main():
    log.info("Starting account syncer for emails and calendars")
    accounts_to_sync = {"emails": [], "calendars": []}

    # Schedule email accounts
    for account in accounts_config["emails"]:
        account_name = account["account_name"]
        for cron_expression in account["cron_expressions"]:
            if (
                should_i_sync_today(cron_expression)
                and account_name not in accounts_to_sync["emails"]
            ):
                accounts_to_sync["emails"].append(account_name)
            aiocron.crontab(cron_expression, func=run_mbsync, args=[account_name])
            log.info(
                f"Scheduled mbsync for {account_name} with cron expression: {cron_expression}"
            )

    # Schedule calendar accounts
    for account in accounts_config["calendars"]:
        account_name = account["account_name"]
        for cron_expression in account["cron_expressions"]:
            if (
                should_i_sync_today(cron_expression)
                and account_name not in accounts_to_sync["calendars"]
            ):
                accounts_to_sync["calendars"].append(account_name)
            aiocron.crontab(cron_expression, func=run_vdirsyncer, args=[account_name])
            log.info(
                f"Scheduled vdirsyncer for {account_name} with cron expression: {cron_expression}"
            )

    log.info("Running an initial fetch on today's accounts")
    for account_name in accounts_to_sync["emails"]:
        await run_mbsync(account_name)
    for account_name in accounts_to_sync["calendars"]:
        await run_vdirsyncer(account_name)

    log.info("Finished loading accounts")
    while True:
        await asyncio.sleep(60)


# Run the main async loop
if __name__ == "__main__":
    asyncio.run(main())
```

Where:

- `accounts_config`: Holds your account configuration. Each account must contain an `account_name` which should be the name of the `mbsync` or `vdirsyncer` profile, and `cron_expressions` must be a list of cron valid expressions you want the email to be synced.

### Create the systemd service

We're using a non-root systemd service. You can follow [these instructions](linux_snippets.md#create-a-systemd-service-for-a-non-root-user) to configure this service:

```ini 
[Unit]
Description=Account Sync Service for emails and calendars
After=graphical-session.target

[Service]
Type=simple
# Run the script using the virtual environment's Python interpreter
ExecStart=/home/lyz/.local/share/virtualenvs/account_syncer/bin/python /home/lyz/.local/bin/
WorkingDirectory=/home/lyz/.local/bin
Restart=on-failure
StandardOutput=journal
StandardError=journal
SyslogIdentifier=account_syncer
# Set the virtual environment's bin directory in the PATH
Environment="PATH=/home/lyz/.local/share/virtualenvs/account_syncer/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Environment variable to use the current user's DISPLAY and DBUS_SESSION
Environment="DISPLAY=:0"
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"

[Install]
WantedBy=graphical-session.target
```

Remember to tweak the service to match your current case and paths.

As we'll probably need to enter our `pass` password we need the service to start once we've logged into the graphical interface.

### Monitor the automation

It's always nice to know if the system is working as expected without adding mental load. To do that I'm creating the next [loki](loki.md) rules:

```yaml
groups: 
  - name: account_sync
    rules:
      - alert: AccountSyncIsNotRunningWarning
        expr: |
          (sum by(hostname) (count_over_time({job="systemd-journal", syslog_identifier="account_syncer"}[15m])) or sum by(hostname) (count_over_time({hostname="my_computer"} [15m])) * 0 ) == 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "The account sync script is not running {{ $labels.hostname}}"
      - alert: AccountSyncIsNotRunningError
        expr: |
          (sum by(hostname) (count_over_time({job="systemd-journal", syslog_identifier="account_syncer"}[3h])) or sum by(hostname) (count_over_time({hostname="my_computer"} [3h])) * 0 ) == 0
        for: 0m
        labels:
          severity: error
        annotations:
          summary: "The account sync script has been down for at least 3 hours {{ $labels.hostname}}"
      - alert: AccountSyncError
        expr: |
          count(rate({job="systemd-journal", syslog_identifier="account_syncer"} |= `` | logfmt | level_extracted=`error` [5m])) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "There are errors in the account sync log at {{ $labels.hostname}}"

      - alert: EmailAccountIsOutOfSyncLyz
        expr: |
          (sum by(hostname) (count_over_time({job="systemd-journal", syslog_identifier="account_syncer"} | logfmt | msg=`Syncing emails for lyz...`[1h])) or sum by(hostname) (count_over_time({hostname="my_computer"} [1h])) * 0 ) == 0
        for: 0m
        labels:
          severity: error
        annotations:
          summary: "The email account lyz has been out of sync for 1h {{ $labels.hostname}}"

      - alert: CalendarAccountIsOutOfSyncLyz
        expr: |
          (sum by(hostname) (count_over_time({job="systemd-journal", syslog_identifier="account_syncer"} | logfmt | msg=`Syncing calendar for lyz...`[3h])) or sum by(hostname) (count_over_time({hostname="my_computer"} [3h])) * 0 ) == 0
        for: 0m
        labels:
          severity: error
        annotations:
          summary: "The calendar account lyz has been out of sync for 3h {{ $labels.hostname}}"
```
Where:
- You need to change `my_computer` for the hostname of the device running the service
- Tweak the OutOfSync alerts to match your account (change the `lyz` part).

These rules will raise:
- A warning if the sync has not shown any activity in the last 15 minutes.
- An error if the sync has not shown any activity in the last 3 hours.
- An error if there is an error in the logs of the automation.

## The old way 
The remaining step to keep the inboxes synced and tagged is to run all the steps
above in a cron. Particularize [pazz's
script](https://github.com/pazz/alot/wiki/pazz's-mail-setup#automation) for your
usecase:

```bash
#!/bin/bash
#
# Download and index new mail.
#
# Copyright (c) 2017 Patrick Totzke
# Dependencies: flock, nm-online, mbsync, notmuch, afew
# Example crontab entry:
#
#   */2 * * * * /usr/bin/flock -n /home/pazz/.pullmail.lock /home/pazz/bin/pullmail.sh > /home/pazz/.pullmail.log
#

PATH=/home/pazz/.local/bin:/usr/local/bin/:$PATH
ACCOUNTDIR=/home/pazz/.pullmail/

# this makes the keyring daemon accessible
function keyring-control() {
        local -a vars=( \
                DBUS_SESSION_BUS_ADDRESS \
                GNOME_KEYRING_CONTROL \
                GNOME_KEYRING_PID \
                XDG_SESSION_COOKIE \
                GPG_AGENT_INFO \
                SSH_AUTH_SOCK \
        )
        local pid=$(ps -C i3 -o pid --no-heading)
        eval "unset ${vars[@]}; $(printf "export %s;" $(sed 's/\x00/\n/g' /proc/${pid//[^0-9]/}/environ | grep $(printf -- "-e ^%s= " "${vars[@]}")) )"
}

function log() {
    notify-send -t 2000  'mail sync:' "$@"
}

function die() {
    notify-send -t 2000 -u critical 'mail sync:' "$@"
    exit 1
}

# Let's Do stuff
keyring-control

# abort as soon as something fails
set -e

# abort if not online
nm-online -x -t 0

echo ---------------------------------------------------------
date
for accfile in `ls $ACCOUNTDIR`;
do
    ACC=$(basename $accfile)
    echo ------------------------  $ACC   ------------------------
    mbsync -V $ACC || log "$ACC failed"
done

# index and tag new mails
echo ------------------------ NOTMUCH ------------------------
notmuch new 2>/dev/null || die "NOTMUCH new failed"

echo ------------------------  AFEW   ------------------------
afew -v --tag --new || die "AFEW died"

echo ---------------------------------------------------------
echo "all done, goodbye."
```

Where [`flock`](https://linux.die.net/man/1/flock) is a tool to manage locks
from shell scripts.

And add the entry in your `crontab -e`.

If you want to process your emails with this system through a command line
interface, you can configure [alot](alot.md).
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
