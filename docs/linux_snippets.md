---
title: Linux snippets
date: 20200826
author: Lyz
---

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
