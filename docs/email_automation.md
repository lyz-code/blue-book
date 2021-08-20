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

# Installation

First you need a program that syncs your mailboxes, following [pazz's advice
](https://github.com/pazz/alot/wiki/pazz's-mail-setup#fetching-mail-mbsync),
I'll use [mbsync](mbsync.md). Follow the steps under
[installation](mbsync.md#installation) to configure your accounts, taking as an
example an account called `lyz` you should be able to sync all your emails with:

```bash
mbsync -V lyz
```

Now we need to install [`notmuch`](notmuch.md) a tool to index, search, read,
and tag large collections of email messages. Follow the steps under
[installation](notmuch.md#installation) under you have created the database that
indexes your emails.

Once we have that, we need a tool to tag the emails following our desired rules.
[afew](afew.md) is one way to go. Follow the steps under
[installation](afew.md#installation).

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
