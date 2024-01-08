---
title: Bash Snippets
date: 20220827
author: Lyz
---

# Show the progresion of a long running task with dots

```bash
echo -n "Process X is running."

# Process is running
sleep 1 
echo -n "."
sleep 1 
echo -n "."

# Process ended
echo ""
```

# [Loop through a list of files found by find](https://stackoverflow.com/questions/9612090/how-to-loop-through-file-names-returned-by-find)

For simple loops use the `find -exec` syntax:

```bash
# execute `process` once for each file
find . -name '*.txt' -exec process {} \;
```

For more complex loops use a `while read` construct:

```bash
find . -name "*.txt" -print0 | while read -r -d $'\0' file
do
    …code using "$file"
done
```

The loop will execute while the `find` command is executing. Plus, this command will work even if a file name is returned with whitespace in it. And, you won't overflow your command line buffer.

The `-print0` will use the NULL as a file separator instead of a newline and the `-d $'\0'` will use NULL as the separator while reading.

## How not to do it

If you try to run the next snippet:

```bash
# Don't do this
for file in $(find . -name "*.txt")
do
    …code using "$file"
done
```

You'll get the next [`shellcheck`](shellcheck.md) warning:

```
SC2044: For loops over find output are fragile. Use find -exec or a while read loop.
```

You should not do this because:

Three reasons:

- For the for loop to even start, the find must run to completion.
- If a file name has any whitespace (including space, tab or newline) in it, it will be treated as two separate names.
- Although now unlikely, you can overrun your command line buffer. Imagine if your command line buffer holds 32KB, and your for loop returns 40KB of text. That last 8KB will be dropped right off your for loop and you'll never know it.

# [Remove the lock screen in ubuntu](https://askubuntu.com/questions/1140079/completely-remove-lockscreen)

Create the `/usr/share/glib-2.0/schemas/90_ubuntu-settings.gschema.override` file with the next content:

```ini
[org.gnome.desktop.screensaver]
lock-enabled = false
[org.gnome.settings-daemon.plugins.power]
idle-dim = false
```

Then reload the schemas with:

```bash
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
```

# [How to deal with HostContextSwitching alertmanager alert](https://access.redhat.com/solutions/69271)

A context switch is described as the kernel suspending execution of one process on the CPU and resuming execution of some other process that had previously been suspended. A context switch is required for every interrupt and every task that the scheduler picks.

Context switching can be due to multitasking, Interrupt handling , user & kernel mode switching. The interrupt rate will naturally go high, if there is higher network traffic, or higher disk traffic. Also it is dependent on the application which every now and then invoking system calls.

If the cores/CPU's are not sufficient to handle load of threads created by application will also result in context switching.

It is not a cause of concern until performance breaks down. This is expected that CPU will do context switching. One shouldn't verify these data at first place since there are many statistical data which should be analyzed prior to looking into kernel activities. Verify the CPU, memory and network usage during this time. 

You can see which process is causing issue with the next command:

```bash
# pidstat -w 3 10   > /tmp/pidstat.out

10:15:24 AM     UID     PID     cswch/s         nvcswch/s       Command 
10:15:27 AM     0       1       162656.7        16656.7         systemd
10:15:27 AM     0       9       165451.04       15451.04        ksoftirqd/0
10:15:27 AM     0       10      158628.87       15828.87        rcu_sched
10:15:27 AM     0       11      156147.47       15647.47        migration/0
10:15:27 AM     0       17      150135.71       15035.71        ksoftirqd/1
10:15:27 AM     0       23      129769.61       12979.61        ksoftirqd/2
10:15:27 AM     0       29      2238.38         238.38          ksoftirqd/3
10:15:27 AM     0       43      1753            753             khugepaged
10:15:27 AM     0       443     1659            165             usb-storage
10:15:27 AM     0       456     1956.12         156.12          i915/signal:0
10:15:27 AM     0       465     29550           29550           kworker/3:1H-xfs-log/dm-3
10:15:27 AM     0       490     164700          14700           kworker/0:1H-kblockd
10:15:27 AM     0       506     163741.24       16741.24        kworker/1:1H-xfs-log/dm-3
10:15:27 AM     0       594     154742          154742          dmcrypt_write/2
10:15:27 AM     0       629     162021.65       16021.65        kworker/2:1H-kblockd
10:15:27 AM     0       715     147852.48       14852.48        xfsaild/dm-1
10:15:27 AM     0       886     150706.86       15706.86        irq/131-iwlwifi
10:15:27 AM     0       966     135597.92       13597.92        xfsaild/dm-3
10:15:27 AM     81      1037    2325.25         225.25          dbus-daemon
10:15:27 AM     998     1052    118755.1        11755.1         polkitd
10:15:27 AM     70      1056    158248.51       15848.51        avahi-daemon
10:15:27 AM     0       1061    133512.12       455.12          rngd
10:15:27 AM     0       1110    156230          16230           cupsd
10:15:27 AM     0       1192    152298.02       1598.02         sssd_nss
10:15:27 AM     0       1247    166132.99       16632.99        systemd-logind
10:15:27 AM     0       1265    165311.34       16511.34        cups-browsed
10:15:27 AM     0       1408    10556.57        1556.57         wpa_supplicant
10:15:27 AM     0       1687    3835            3835            splunkd
10:15:27 AM     42      1773    3728            3728            Xorg
10:15:27 AM     42      1996    3266.67         266.67          gsd-color
10:15:27 AM     0       3166    32036.36        3036.36         sssd_kcm
10:15:27 AM     119349  3194    151763.64       11763.64        dbus-daemon
10:15:27 AM     119349  3199    158306          18306           Xorg
10:15:27 AM     119349  3242    15.28           5.8             gnome-shell

# pidstat -wt 3 10  > /tmp/pidstat-t.out

Linux 4.18.0-80.11.2.el8_0.x86_64 (hostname)    09/08/2020  _x86_64_    (4 CPU)

10:15:15 AM   UID      TGID       TID   cswch/s   nvcswch/s  Command
10:15:19 AM     0         1         -   152656.7   16656.7   systemd
10:15:19 AM     0         -         1   152656.7   16656.7   |__systemd
10:15:19 AM     0         9         -   165451.04  15451.04  ksoftirqd/0
10:15:19 AM     0         -         9   165451.04  15451.04  |__ksoftirqd/0
10:15:19 AM     0        10         -   158628.87  15828.87  rcu_sched
10:15:19 AM     0         -        10   158628.87  15828.87  |__rcu_sched
10:15:19 AM     0        23         -   129769.61  12979.61  ksoftirqd/2
10:15:19 AM     0         -        23   129769.61  12979.33  |__ksoftirqd/2
10:15:19 AM     0        29         -   32424.5    2445      ksoftirqd/3
10:15:19 AM     0         -        29   32424.5    2445      |__ksoftirqd/3
10:15:19 AM     0        43         -   334        34        khugepaged
10:15:19 AM     0         -        43   334        34        |__khugepaged
10:15:19 AM     0       443         -   11465      566       usb-storage
10:15:19 AM     0         -       443   6433       93        |__usb-storage
10:15:19 AM     0       456         -   15.41      0.00      i915/signal:0
10:15:19 AM     0         -       456   15.41      0.00      |__i915/signal:0
10:15:19 AM     0       715         -   19.34      0.00      xfsaild/dm-1
10:15:19 AM     0         -       715   19.34      0.00      |__xfsaild/dm-1
10:15:19 AM     0       886         -   23.28      0.00      irq/131-iwlwifi
10:15:19 AM     0         -       886   23.28      0.00      |__irq/131-iwlwifi
10:15:19 AM     0       966         -   19.67      0.00      xfsaild/dm-3
10:15:19 AM     0         -       966   19.67      0.00      |__xfsaild/dm-3
10:15:19 AM    81      1037         -   6.89       0.33      dbus-daemon
10:15:19 AM    81         -      1037   6.89       0.33      |__dbus-daemon
10:15:19 AM     0      1038         -   11567.31   4436      NetworkManager
10:15:19 AM     0         -      1038   1.31       0.00      |__NetworkManager
10:15:19 AM     0         -      1088   0.33       0.00      |__gmain
10:15:19 AM     0         -      1094   1340.66    0.00      |__gdbus
10:15:19 AM   998      1052         -   118755.1   11755.1   polkitd
10:15:19 AM   998         -      1052   32420.66   25545     |__polkitd
10:15:19 AM   998         -      1132   0.66       0.00      |__gdbus
```

Then with help of PID which is causing issue, one can get all system calls details:
Raw

```bash
# strace -c -f -p <pid of process/thread>
```

Let this command run for a few minutes while the load/context switch rates are high. It is safe to run this on a production system so you could run it on a good system as well to provide a comparative baseline. Through strace, one can debug & troubleshoot the issue, by looking at system calls the process has made.

# [Redirect stderr of all subsequent commands of a script to a file](https://unix.stackexchange.com/questions/61931/redirect-all-subsequent-commands-stderr-using-exec)

```bash
{
    somecommand 
    somecommand2
    somecommand3
} 2>&1 | tee -a $DEBUGLOG
```

# [Get the root path of a git repository](https://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command)

```bash
git rev-parse --show-toplevel
```

# [Get epoch gmt time](https://unix.stackexchange.com/questions/384672/getting-epoch-time-from-gmt-time-stamp)

```bash
date -u '+%s'
```

# [Check the length of an array with jq](https://phpfog.com/count-json-array-elements-with-jq/)

```
echo '[{"username":"user1"},{"username":"user2"}]' | jq '. | length'
```

# [Exit the script if there is an error](https://unix.stackexchange.com/questions/595249/what-does-the-eu-mean-in-bin-bash-eu-at-the-top-of-a-bash-script-or-a)

```bash
set -eu
```

# [Prompt the user for data](https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script)

```bash
read -p "Ask whatever" choice
```
# [Parse csv with bash](https://www.baeldung.com/linux/csv-parsing)

# [Do the remainder or modulus of a number](https://stackoverflow.com/questions/39006278/how-does-bash-modulus-remainder-work)

```bash
expr 5 % 3
```

# [Update a json file with jq](https://stackoverflow.com/questions/36565295/jq-to-replace-text-directly-on-file-like-sed-i)

Save the next snippet to a file, for example `jqr` and add it to your `$PATH`.

```bash
#!/bin/zsh

query="$1"
file=$2

temp_file="$(mktemp)"

# Update the content
jq "$query" $file > "$temp_file"

# Check if the file has changed
cmp -s "$file" "$temp_file"
if [[ $? -eq 0 ]] ; then
  /bin/rm "$temp_file"
else
  /bin/mv "$temp_file" "$file"
fi
```

Imagine you have the next json file:

```json
{
  "property": true,
  "other_property": "value"
}
```

Then you can run:

```bash
jqr '.property = false' status.json
```

And then you'll have:

```json
{
  "property": false,
  "other_property": "value"
}
```
