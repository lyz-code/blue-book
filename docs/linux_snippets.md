---
title: Linux snippets
date: 20200826
author: Lyz
---

# [Automatic reboot after power failure](https://askubuntu.com/questions/111907/automatic-reboot-after-power-failure)

That's not something you can control in your operating system. That's what the BIOS is for. In most BIOS setups there'll be an option like After power loss with possible values like Power off and Reboot.

You can also edit `/etc/default/grub` and add:

```
GRUB_RECORDFAIL_TIMEOUT=5
```

Then run:

```bash
sudo update-grub
```

This will make your machine display the boot options for 5 seconds before it boot the default option (instead of waiting forever for you to choose one).

# SSH tunnel 

```bash
ssh -D 9090 -N -f user@host
```

If you need a more powerful solution you can try [sshuttle](https://sshuttle.readthedocs.io/en/stable/overview.html)

# [Fix the SSH client kex_exchange_identification: read: Connection reset by peer error](https://stackoverflow.com/questions/69394001/how-can-i-fix-kex-exchange-identification-read-connection-reset-by-peer)

Restart the `ssh` service.

# [Get class of a window](https://unix.stackexchange.com/questions/703084/how-to-get-current-window-class-name-from-script)

Use `xprop` and click the window.

# Change the brightness of the screen

Get the current brightness level with `cat /sys/class/backlight/intel_backlight/brightness`. Imagine it's `1550`, then if you want to lower the brightness use:

```bash
sudo echo 500 > /sys/class/backlight/intel_backlight/brightness
```

# [Force umount nfs mounted directory](https://stackoverflow.com/questions/40317/force-unmount-of-nfs-mounted-directory)

```bash
umount -l path/to/mounted/dir
```

# [Configure fstab to mount nfs](https://linuxopsys.com/topics/linux-nfs-mount-entry-in-fstab-with-example)

NFS stands for ‘Network File System’. This mechanism allows Unix machines to share files and directories over the network. Using this feature, a Linux machine can mount a remote directory (residing in a NFS server machine) just like a local directory and can access files from it.

An NFS share can be mounted on a machine by adding a line to the `/etc/fstab` file.

The default syntax for `fstab` entry of NFS mounts is as follows.

```
Server:/path/to/export /local_mountpoint nfs <options> 0 0
```

Where:

* `Server`: The hostname or IP address of the NFS server where the exported directory resides.
* `/path/to/export`: The shared directory (exported folder) path.
* `/local_mountpoint`: Existing directory in the host where you want to mount the NFS share.

You can specify a number of options that you want to set on the NFS mount:

* `soft/hard`: When the mount option `hard` is set, if the NFS server crashes or becomes unresponsive, the NFS requests will be retried indefinitely. You can set the mount option `intr`, so that the process can be interrupted. When the NFS server comes back online, the process can be continued from where it was while the server became unresponsive.

  When the option `soft` is set, the process will be reported an error when the NFS server is unresponsive after waiting for a period of time (defined by the `timeo` option). In certain cases `soft` option can cause data corruption and loss of data. So, it is recommended to use `hard` and `intr` options.

* `noexec`: Prevents execution of binaries on mounted file systems. This is useful if the system is mounting a non-Linux file system via NFS containing incompatible binaries.
* `nosuid`: Disables set-user-identifier or set-group-identifier bits. This prevents remote users from gaining higher privileges by running a setuid program.
* `tcp`: Specifies the NFS mount to use the TCP protocol.
* `udp`: Specifies the NFS mount to use the UDP protocol.
* `nofail`: Prevent issues when rebooting the host. The downside is that if you have services that depend on the volume to be mounted they won't behave as expected.

# [Fix limit on the number of inotify watches](https://stackoverflow.com/questions/47075661/error-user-limit-of-inotify-watches-reached-extreact-build)

Programs that sync files such as dropbox, git etc use inotify to notice changes to the file system. The limit can be see by -

```bash
cat /proc/sys/fs/inotify/max_user_watches
```

For me, it shows `65536`. When this limit is not enough to monitor all files inside a directory it throws this error.

If you want to increase the amount of inotify watchers, run the following in a terminal:

```bash
echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

Where `100000` is the desired number of inotify watches.

# [What is `/var/log/tallylog`](https://www.tecmint.com/use-pam_tally2-to-lock-and-unlock-ssh-failed-login-attempts/)

`/var/log/tallylog` is the file where the `PAM` linux module (used for authentication of the machine) keeps track of the failed ssh logins in order to temporarily block users.

# Manage users

* Change main group of user

  ```bash
  usermod -g {{ group_name }} {{ user_name }}
  ```

* Add user to group

  ```bash
  usermod -a -G {{ group_name }} {{ user_name }}
  ```

* Remove user from group.

  ```bash
  usermod -G {{ remaining_group_names }} {{ user_name }}
  ```

  You have to execute `groups {{ user }}` get the list and pass the remaining to the above command

* Change uid and gid of the user

  ```bash
  usermod -u {{ newuid }} {{ login }}
  groupmod -g {{ newgid }} {{ group }}
  find / -user {{ olduid }} -exec chown -h {{ newuid }} {} \;
  find / -group {{ oldgid }} -exec chgrp -h {{ newgid }} {} \;
  usermod -g {{ newgid }} {{ login }}
  ```

# Manage ssh keys

*  Generate ed25519 key

   ```bash
   ssh-keygen -t ed25519 -f {{ path_to_keyfile }}
   ```

* Generate RSA key

  ```bash
  ssh-keygen -t rsa -b 4096 -o -a 100 -f {{ path_to_keyfile }}
  ```

* Generate different comment

  ```bash
  ssh-keygen -t ed25519 -f {{ path_to_keyfile }} -C {{ email }}
  ```

* Generate key headless, batch

  ```bash
  ssh-keygen -t ed25519 -f {{ path_to_keyfile }} -q -N ""
  ```

* Generate public key from private key

  ```bash
  ssh-keygen -y -f {{ path_to_keyfile }} > {{ path_to_public_key_file }}
  ```

* Get fingerprint of key
  ```bash
  ssh-keygen -lf {{ path_to_key }}
  ```

# [Measure the network performance between two machines](https://sidhion.com/blog/posts/zfs-syncoid-slow/)

Install `iperf3` with `apt-get install iperf3` on both server and client.

On the server system run:

```bash
server#: iperf3 -i 10 -s
```

Where:

* `-i`: the interval to provide periodic bandwidth updates
* `-s`: listen as a server

On the client system:

```bash
client#: iperf3 -i 10 -w 1M -t 60 -c [server hostname or ip address]
```

Where:

* `-i`: the interval to provide periodic bandwidth updates
* `-w`: the socket buffer size (which affects the TCP Window). The buffer size is also set on the server by this client command.
* `-t`: the time to run the test in seconds
* `-c`: connect to a listening server at…


Sometimes is interesting to test both ways as they may return different outcomes

I've got the next results at home:

* From new NAS to laptop through wifi 67.5 MB/s
* From laptop to new NAS 59.25 MB/s
* From intel Nuc to new NAS 116.75 MB/s (934Mbit/s)
* From old NAS to new NAS 11 MB/s

# [Measure the performance, IOPS of a disk](https://woshub.com/check-disk-performance-iops-latency-linux/)

To measure disk IOPS performance in Linux, you can use the `fio` tool. Install it with

```bash
apt-get install fio
```

Then you need to go to the directory where your disk is mounted. The test is done by performing read/write operations in this directory.

To do a random read/write operation test an 8 GB file will be created. Then `fio` will read/write a 4KB block (a standard block size) with the 75/25% by the number of reads and writes operations and measure the performance. 

```bash
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=testfio --bs=4k --iodepth=64 --size=8G --readwrite=randrw --rwmixread=75
```

I've run this test in different environments with awesome results:

* New NAS server NVME: 
  ```
  read: IOPS=297k, BW=1159MiB/s (1215MB/s)(3070MiB/2649msec)
   bw (  MiB/s): min= 1096, max= 1197, per=99.80%, avg=1156.61, stdev=45.31, samples=5
   iops        : min=280708, max=306542, avg=296092.00, stdev=11598.11, samples=5
  write: IOPS=99.2k, BW=387MiB/s (406MB/s)(1026MiB/2649msec); 0 zone resets
   bw (  KiB/s): min=373600, max=408136, per=99.91%, avg=396248.00, stdev=15836.85, samples=5
   iops        : min=93400, max=102034, avg=99062.00, stdev=3959.21, samples=5
  cpu          : usr=15.67%, sys=67.18%, ctx=233314, majf=0, minf=8
  ```

* New NAS server ZFS pool with RAIDZ:

  ```
  read: IOPS=271k, BW=1059MiB/s (1111MB/s)(3070MiB/2898msec)
   bw (  MiB/s): min=  490, max= 1205, per=98.05%, avg=1038.65, stdev=306.74, samples=5
   iops        : min=125672, max=308484, avg=265893.20, stdev=78526.52, samples=5
  write: IOPS=90.6k, BW=354MiB/s (371MB/s)(1026MiB/2898msec); 0 zone resets
   bw (  KiB/s): min=167168, max=411776, per=98.26%, avg=356236.80, stdev=105826.16, samples=5
   iops        : min=41792, max=102944, avg=89059.20, stdev=26456.54, samples=5
  cpu          : usr=12.84%, sys=63.20%, ctx=234345, majf=0, minf=6
  ```

* Laptop NVME:

  ```
  read: IOPS=36.8k, BW=144MiB/s (151MB/s)(3070MiB/21357msec)
   bw (  KiB/s): min=129368, max=160304, per=100.00%, avg=147315.43, stdev=6640.40, samples=42
   iops        : min=32342, max=40076, avg=36828.86, stdev=1660.10, samples=42
  write: IOPS=12.3k, BW=48.0MiB/s (50.4MB/s)(1026MiB/21357msec); 0 zone resets
   bw (  KiB/s): min=42952, max=53376, per=100.00%, avg=49241.33, stdev=2151.40, samples=42
   iops        : min=10738, max=13344, avg=12310.33, stdev=537.85, samples=42
  cpu          : usr=14.32%, sys=32.17%, ctx=356674, majf=0, minf=7
  ```

* Laptop ZFS pool through NFS (running in parallel with other network processes):
  
  ```
  read: IOPS=4917, BW=19.2MiB/s (20.1MB/s)(3070MiB/159812msec)
   bw (  KiB/s): min=16304, max=22368, per=100.00%, avg=19681.46, stdev=951.52, samples=319
   iops        : min= 4076, max= 5592, avg=4920.34, stdev=237.87, samples=319
  write: IOPS=1643, BW=6574KiB/s (6732kB/s)(1026MiB/159812msec); 0 zone resets
   bw (  KiB/s): min= 5288, max= 7560, per=100.00%, avg=6577.35, stdev=363.32, samples=319
   iops        : min= 1322, max= 1890, avg=1644.32, stdev=90.82, samples=319
  cpu          : usr=5.21%, sys=10.59%, ctx=175825, majf=0, minf=8
  ```

* Intel Nuc server disk SSD:
  ```
    read: IOPS=11.0k, BW=46.9MiB/s (49.1MB/s)(3070MiB/65525msec)
   bw (  KiB/s): min=  280, max=73504, per=100.00%, avg=48332.30, stdev=25165.49, samples=130
   iops        : min=   70, max=18376, avg=12083.04, stdev=6291.41, samples=130
  write: IOPS=4008, BW=15.7MiB/s (16.4MB/s)(1026MiB/65525msec); 0 zone resets
   bw (  KiB/s): min=   55, max=24176, per=100.00%, avg=16153.84, stdev=8405.53, samples=130
   iops        : min=   13, max= 6044, avg=4038.40, stdev=2101.42, samples=130
  cpu          : usr=8.04%, sys=25.87%, ctx=268055, majf=0, minf=8
  ```

* Intel Nuc server external HD usb disk :
  ```
  ```

* Intel Nuc ZFS pool through NFS (running in parallel with other network processes):

  ```
    read: IOPS=18.7k, BW=73.2MiB/s (76.8MB/s)(3070MiB/41929msec)
   bw (  KiB/s): min=43008, max=103504, per=99.80%, avg=74822.75, stdev=16708.40, samples=83
   iops        : min=10752, max=25876, avg=18705.65, stdev=4177.11, samples=83
  write: IOPS=6264, BW=24.5MiB/s (25.7MB/s)(1026MiB/41929msec); 0 zone resets
   bw (  KiB/s): min=14312, max=35216, per=99.79%, avg=25003.55, stdev=5585.54, samples=83
   iops        : min= 3578, max= 8804, avg=6250.88, stdev=1396.40, samples=83
  cpu          : usr=6.29%, sys=13.21%, ctx=575927, majf=0, minf=10
  ```

* Old NAS with RAID5:
  ```
  read : io=785812KB, bw=405434B/s, iops=98, runt=1984714msec
  write: io=262764KB, bw=135571B/s, iops=33, runt=1984714msec
  cpu          : usr=0.16%, sys=0.59%, ctx=212447, majf=0, minf=8
  ```

Conclusions:

* New NVME are **super fast** (1215MB/s read, 406MB/s write)
* ZFS rocks, with a RAIDZ1, L2ARC and ZLOG it returned almost the same performance as the NVME ( 1111MB/s read, 371MB/s write)
* Old NAS with RAID is **super slow** (0.4KB/s read, 0.1KB/s write!)
* I should replace the laptop's NVME, the NAS one has 10x performace both on read and write.

There is a huge difference between ZFS in local and through NFS. In local you get (1111MB/s read and 371MB/s write) while through NFS I got (20.1MB/s read and 6.7MB/s write). I've measured the network performance between both machines with `iperf3` and got:

* From NAS to laptop 67.5 MB/s
* From laptop to NAS 59.25 MB/s

It was because I was running it over wifi.

From the Intel nuc to the new server I get 76MB/s read and 25.7MB/s write. Still a huge difference though against the local transfer. The network speed measured with `iperf3` are 116 MB/s.

# [Use a `pass` password in a Makefile](https://stackoverflow.com/questions/20671511/how-do-i-get-make-to-prompt-the-user-for-a-password-and-store-it-in-a-makefile)

```makefile
TOKEN ?= $(shell bash -c '/usr/bin/pass show path/to/token')

diff:
	@AUTHENTIK_TOKEN=$(TOKEN) terraform plan
```

# [Install a new font](https://wiki.debian.org/Fonts)

Install a font manually by downloading the appropriate `.ttf` or `otf` files and placing them into `/usr/local/share/fonts` (system-wide), `~/.local/share/fonts` (user-specific) or `~/.fonts` (user-specific). These files should have the permission 644 (`-rw-r--r--`), otherwise they may not be usable.

# [Get VPN password from `pass`](https://stackoverflow.com/questions/38869427/openvpn-on-linux-passing-username-and-password-in-command-line)

To be able to retrieve the user and password from pass you need to run the openvpn
command with the next flags:

```bash
sudo bash -c "openvpn --config config.ovpn  --auth-user-pass <(echo -e 'user_name\n$(pass show vpn)')"
```

Assuming that `vpn` is an entry of your `pass` password store.


# Download TS streams

Some sites give stream content with small `.ts` files that you can't download
directly. Instead open the developer tools, reload the page and search for a
request with extension `.m3u8`, that gives you the playlist of all the chunks of
`.ts` files. Once you have that url you can use `yt-dlp` to download it.

# [df and du showing different results](https://www.cyberciti.biz/tips/freebsd-why-command-df-and-du-reports-different-output.html)

Sometimes on a linux machine you will notice that both `df` command (display
free disk space) and `du` command (display disk usage statistics) report
different output. Usually, `df` will output a bigger disk usage than `du`.

The `du` command estimates file space usage, and the `df` command shows file
system disk space usage.

There are many reasons why this could be happening:

## Disk mounted over data

If you mount a disk on a directory that already holds data, then when you run
`du` that data won't show, but `df` knows it's there.

To troubleshoot this, umount one by one of your disks, and do an `ls` to see if
there's any remaining data in the mount point.

## Used deleted files

When a file is deleted under Unix/Linux, the disk space occupied by the file
will not be released immediately in some cases. The result of the command `du`
doesn’t include the size of the deleting file. But the impact of the command
`df` for the deleting file’s size due to its disk space is not released
immediately. Hence, after deleting the file, the results of `df` and `du` are
different until the disk space is freed.

Open file descriptor is main causes of such wrong information. For example, if a
file called `/tmp/application.log` is open by a third-party application OR by a
user and the same file is deleted, both `df` and `du` report different outputs.
You can use the `lsof` command to verify this:

```bash
lsof | grep tmp
```

To fix it:

- Use the `lsof` command as discussed above to find a deleted file opened by
  other users and apps. See how to list all users in the system for more info.
- Then, close those apps and log out of those Linux and Unix users.
- As a sysadmin you restart any process or `kill` the process under Linux and
  Unix that did not release the deleted file.
- Flush the filesystem using the `sync` command that synchronizes cached writes
  to persistent disk storage.
- If everything else fails, try restarting the system using the `reboot` command
  or `shutdown` command.

# Scan a physical page in Linux

Install `xsane` and run it.

# [Git checkout to main with master as a fallback](https://stackoverflow.com/questions/66232497/git-alias-which-works-for-main-or-master-or-other)

I usually use the alias `gcm` to change to the main branch of the repository,
given the change from [main to master](git.md#renaming-from-master-to-main) now
I have some repos that use one or the other, but I still want `gcm` to go to the
correct one. The solution is to use:

```bash
alias gcm='git checkout "$(git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4)"'
```

# [Create QR code](https://www.linux-magazine.com/Online/Features/Generating-QR-Codes-in-Linux)

```bash
qrencode -o qrcode.png 'Hello World!'
```

# [Trim silences of sound files](https://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/)

To trim all silence longer than 2 seconds down to only 2 seconds long.

```bash
sox in.wav out6.wav silence -l 1 0.1 1% -1 2.0 1%
```

Note that SoX does nothing to bits of silence shorter than 2 seconds.

If you encounter the `sox FAIL formats: no handler for file extension 'mp3'`
error you'll need to install the `libsox-fmt-all` package.

# [Adjust the replay gain of many sound files](https://askubuntu.com/questions/246242/how-to-normalize-sound-in-mp3-files)

```bash
sudo apt-get install python-rgain
replaygain -f *.mp3
```

# Check vulnerabilities in Node.js applications

With `yarn audit` you'll see the vulnerabilities, with `yarn outdated` you can
see the packages that you need to update.

# [Check vulnerabilities in rails dependencies](https://github.com/rubysec/bundler-audit)

```bash
gem install bundler-audit
cd project_with_gem_lock
bundler-audit
```

# [Create Basic Auth header](https://majgis.github.io/2017/09/13/Create-Authorization-Basic-Header/)

```bash
$ echo -n user:password | base64
dXNlcjpwYXNzd29yZA==
```

Without the `-n` it won't work well.

# [Install one package from Debian unstable](https://linuxaria.com/howto/how-to-install-a-single-package-from-debian-sid-or-debian-testing)

- Add the `unstable` repository to your `/etc/apt/sources.list`

  ```bash
  # Unstable
  deb http://deb.debian.org/debian/ unstable main contrib non-free
  deb-src http://deb.debian.org/debian/ unstable main contrib non-free
  ```

- Configure `apt` to only use `unstable` when specified

!!! note "File: `/etc/apt/preferences`" \`\`\` Package: * Pin: release a=stable
Pin-Priority: 700

````
Package: *
Pin: release  a=testing
Pin-Priority: 600

Package: *
Pin: release a=unstable
Pin-Priority: 100
```
````

- Update the package data with `apt-get update`.
- See that the new versions are available with
  `apt-cache policy   <package_name>`
- To install a package from unstable you can run
  `apt-get install -t unstable   <package_name>`.

# [Fix the following packages have been kept back](https://askubuntu.com/questions/601/the-following-packages-have-been-kept-back-why-and-how-do-i-solve-it)

```bash
sudo apt-get --with-new-pkgs upgrade
```

# [Monitor outgoing traffic](https://fedingo.com/how-to-monitor-outgoing-http-requests-in-linux/)

## Easy and quick way watch & lsof

You can simply use a combination of `watch` & `lsof` command in Linux to get an
idea of outgoing traffic on specific ports. Here is an example of outgoing
traffic on ports `80` and `443`.

```bash
$ watch -n1 lsof -i TCP:80,443
```

Here is a sample output.

```bash
dropbox    2280 saml   23u  IPv4 56015285      0t0  TCP www.example.local:56003->snt-re3-6c.sjc.dropbox.com:http (ESTABLISHED)
thunderbi  2306 saml   60u  IPv4 56093767      0t0  TCP www.example.local:34788->ord08s09-in-f20.1e100.net:https (ESTABLISHED)
mono       2322 saml   15u  IPv4 56012349      0t0  TCP www.example.local:54018->204-62-14-135.static.6sync.net:https (ESTABLISHED)
chrome    4068 saml  175u  IPv4 56021419      0t0  TCP www.example.local:42182->stackoverflow.com:http (ESTABLISHED)
```

You'll miss the short lived connections though.

## Fine grained with tcpdump

You can also use `tcpdump` command to capture all raw packets, on all
interfaces, on all ports, and write them to file.

```bash
sudo tcpdump -tttt -i any -w /tmp/http.log
```

Or you can limit it to a specific port adding the arguments `port 443 or 80`.
The `-tttt` flag is used to capture the packets with a human readable timestamp.

To read the recorded information, run the `tcpdump` command with `-A` option. It
will print ASCII text in recorded packets, that you can browse using page
up/down keys.

```bash
tcpdump -A -r /tmp/http.log | less
```

However, `tcpdump` cannot decrypt information, so you cannot view information
about HTTPS requests in it.

# [Clean up system space](https://ownyourbits.com/2017/02/18/squeeze-disk-space-on-a-debian-system/)

## Clean package data

There is a couple of things to do when we want to free space in a no-brainer
way. First, we want to remove those deb packages that get cached every time we
do `apt-get install`.

```bash
apt-get clean
```

Also, the system might keep packages that were downloaded as dependencies but
are not needed anymore. We can get rid of them with

```bash
apt-get autoremove
```

Remove
[data of unpurged packages](https://askubuntu.com/questions/687295/how-to-purge-previously-only-removed-packages).

```bash
sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
```

If we want things tidy, we must know that whenever we `apt-get remove` a
package, the configuration will be kept in case we want to install it again. In
most cases we want to use `apt-get purge`. To clean those configurations from
removed packages, we can use

```bash
dpkg --list | grep "^rc" | cut -d " " -f 3 | xargs --no-run-if-empty sudo dpkg --purge
```

So far we have not uninstalled anything. If now we want to inspect what packages
are consuming the most space, we can type

```bash
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n
```

## [Clean snap data](https://www.debugpoint.com/2021/03/clean-up-snap/)

If you're using `snap` you can clean space by:

- Reduce the number of versions kept of a package with
  `snap set system refresh.retain=2`

- Remove the old versions with `clean_snap.sh`

  ```bash
  #!/bin/bash
  #Removes old revisions of snaps
  #CLOSE ALL SNAPS BEFORE RUNNING THIS
  set -eu
  LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
  while read snapname revision; do
      snap remove "$snapname" --revision="$revision"
  done
  ```

## [Clean journalctl data](https://linuxhandbook.com/clear-systemd-journal-logs/)

- Check how much space it's using: `journalctl --disk-usage`
- Rotate the logs: `journalctl --rotate`

Then you have three ways to reduce the data:

1. Clear journal log older than X days: `journalctl --vacuum-time=2d`
1. Restrict logs to a certain size: `journalctl --vacuum-size=100M`
1. Restrict number of log files: `journactl --vacuum-files=5`.

The operations above will affect the logs you have right now, but it won't solve
the problem in the future. To let `journalctl` know the space you want to use
open the `/etc/systemd/journald.conf` file and set the `SystemMaxUse` to the
amount you want (for example `1000M` for a gigabyte). Once edited restart the
service with `sudo systemctl restart systemd-journald`.

## Clean up docker data

To remove unused `docker` data you can run `docker system prune -a`. This will
remove:

- All stopped containers
- All networks not used by at least one container
- All images without at least one container associated to them
- All build cache

Sometimes that's not enough, and your `/var/lib/docker` directory still weights
more than it should. In those cases:

- Stop the `docker` service.
- Remove or move the data to another directory
- Start the `docker` service.

In order not to loose your persisted data, you need to configure your dockers to
mount the data from a directory that's not within `/var/lib/docker`.

### [Set up docker logs rotation](https://medium.com/free-code-camp/how-to-setup-log-rotation-for-a-docker-container-a508093912b2)

By default, the stdout and stderr of the container are written in a JSON file
located in `/var/lib/docker/containers/[container-id]/[container-id]-json.log`.
If you leave it unattended, it can take up a large amount of disk space.

If this JSON log file takes up a significant amount of the disk, we can purge it
using the next command.

```bash
truncate -s 0 <logfile>
```

We could setup a cronjob to purge these JSON log files regularly. But for the
long term, it would be better to setup log rotation. This can be done by adding
the following values in `/etc/docker/daemon.json`.

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  }
}
```

## [Clean old kernels](https://tuxtweaks.com/2010/10/remove-old-kernels-in-ubuntu-with-one-command/)

!!! warning "I don't recommend using this step, rely on `apt-get autoremove`,
it' safer"

The full command is

```bash
dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e [0-9] | grep -E "(image|headers)" | xargs sudo apt-get -y purge
```

To test what packages will it remove use:

```bash
dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e [0-9] | grep -e "(image|headers)" | xargs sudo apt-get --dry-run remove
```

Remember that your running kernel can be obtained by `uname -r`.

# [Replace a string with sed recursively](https://victoria.dev/blog/how-to-replace-a-string-with-sed-in-current-and-recursive-subdirectories/)

```bash
find . -type f -exec sed -i 's/foo/bar/g' {} +
```

# Bypass client SSL certificate with cli tool

Websites that require clients to authorize with an TLS certificate are difficult
to interact with through command line tools that don't support this feature.

To solve it, we can use a transparent proxy that does the exchange for us.

- Export your certificate: If you have a `p12` certificate, you first need to
  extract the key, crt and the ca from the certificate into the `site.pem`.

  ```bash
  openssl pkcs12 -in certificate.p12 -out site.key.pem -nocerts -nodes # It asks for the p12 password
  openssl pkcs12 -in certificate.p12 -out site.crt.pem -clcerts -nokeys
  openssl pkcs12 -cacerts -nokeys -in certificate.p12 -out site-ca-cert.ca

  cat site.key.pem site.crt.pem site-ca-cert.ca > site.pem
  ```

- Build the proxy ca: Then we merge the site and the client ca's into the
  `site-ca-file.cert` file:

  ```bash
  openssl s_client -connect www.site.org:443 2>/dev/null  | openssl x509 -text > site-ca-file.cert
  cat site-ca-cert.ca >> web-ca-file.cert
  ```

- Change your hosts file to redirect all requests to the proxy.

  ```vim
  # vim /etc/hosts
  [...]
  0.0.0.0 www.site.org
  ```

- Run the proxy

  ```bash
  docker run --rm \
      -v $(pwd):/certs/ \
      -p 3001:3001 \
      -it ghostunnel/ghostunnel \
      client \
      --listen 0.0.0.0:3001 \
      --target www.site.org:443 \
      --keystore /certs/site.pem \
      --cacert /certs/site-ca-file.cert \
      --unsafe-listen
  ```

- Run the command line tool using the http protocol on the port 3001:

  ```bash
  wpscan  --url http://www.site.org:3001/ --disable-tls-checks
  ```

Remember to clean up your env afterwards.

# [Allocate space for a virtual filesystem](https://askubuntu.com/questions/506910/creating-a-large-size-file-in-less-time)

Also useful to simulate big files

```bash
fallocate -l 20G /path/to/file
```

# [Identify what a string or file contains](https://github.com/bee-san/pyWhat)

Identify anything. `pyWhat` easily lets you identify emails, IP addresses, and
more. Feed it a .pcap file or some text and it'll tell you what it is.

# [Split a file into many with equal number of lines](https://stackoverflow.com/questions/2016894/how-to-split-a-large-text-file-into-smaller-files-with-equal-number-of-lines)

You could do something like this:

```bash
split -l 200000 filename
```

Which will create files each with 200000 lines named `xaa`, `xab`, `xac`, ...

# Check if an rsync command has gone well

Sometimes after you do an `rsync` between two directories of different devices
(an usb and your hard drive for example), the sizes of the directories don't
match. I've seen a difference of a 30% less on the destination. `du`, `ncdu` and
`and` have a long story of reporting wrong sizes with advanced filesystems (ZFS,
VxFS or compressing filesystems), these do a lot of things to reduce the disk
usage (deduplication, compression, extents, files with holes...) which may lead
to the difference in space.

To check if everything went alright run `diff -r --brief source/ dest/`, and
check that there is no output.

# [List all process swap usage](https://www.cyberciti.biz/faq/linux-which-process-is-using-swap/)

```bash
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```
