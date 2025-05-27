---
title: Linux snippets
date: 20200826
author: Lyz
---

# [Check the file encoding](https://stackoverflow.com/questions/805418/how-can-i-find-encoding-of-a-file-via-a-script-on-linux)

```bash
file -i <path_to_file>
```

# [Simulate the environment of a cron job](https://stackoverflow.com/questions/2135478/how-to-simulate-the-environment-cron-executes-a-script-with)

Add this to your crontab (temporarily):

```cron
* * * * * env > ~/cronenv
```

After it runs, do this:

```bash
env - `cat ~/cronenv` /bin/sh
```

This assumes that your cron runs /bin/sh, which is the default regardless of the user's default shell.

Footnote: if env contains more advanced config, eg `PS1=$(__git_ps1 " (%s)")$`, it will error cryptically `env: ": No such file or directory`.

# Use lftp

Connect with:

```bash
lftp -p <port> user@host
```

Navigate with `ls` and `cd`. Get with `mget` for multiple things

# [Difference between apt-get upgrate and apt-get full-upgrade](https://superuser.com/questions/1653079/whats-the-difference-between-apt-full-upgrade-and-apt-upgrade-when-this-site-sa)

The difference between `upgrade` and `full-upgrade` is that the later will remove the installed packages if that is needed to upgrade the whole system. Be extra careful when using this command

I will more frequently use `autoremove` to remove old packages and then just use `upgrade`.

# [Upgrade debian](https://wiki.debian.org/DebianUpgrade)

```bash
# First, ensure your system is up-to-date in it's current release.
sudo apt-get update
sudo apt-get upgrade
sudo apt-get full-upgrade

# If you haven't already, ensure all backups are up-to-date.

# In a text editor, replace the codename of your release with that of the next release in APT's package sources
# For instance, the line
#    deb https://deb.debian.org/debian/ buster main
# should be replaced with
#    deb https://deb.debian.org/debian/ bullseye main
sudo vi /etc/apt/sources.list /etc/apt/sources.list.d/*

# If you are migrating to Bookworm or later, then a new repo for non-free firmware is available.
# If you wish, you can add non-free and non-free-firmware, depending on your specific needs.
# For instance, the line
#    deb https://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
# or
#    deb https://deb.debian.org/debian/ stable main contrib non-free non-free-firmware

# Clean and update package lists
sudo apt-get clean
sudo apt-get update

# Perform the major release upgrade, removing packages if required
# Interrupting this step after downloading has completed is an excellent way to stress-test your backups
sudo apt-get upgrade
sudo apt-get full-upgrade

# Remove packages that are not required anymore
# Be sure to review this list: you may want to keep some of them
sudo apt-get autoremove

# Reboot to make changes effective (optional, but recommended)
sudo shutdown -r now
```

# Get a list of extensions by file type

There are community made lists such as [dyne's file extension list](https://github.com/dyne/file-extension-list/)

# Download videos from rtve.es

Use [descargavideos.tv](https://www.descargavideos.tv/) ([source](https://github.com/forestrf/Descargavideos))

# Check if a domain is in a list of known disposable email domains

You can check in known lists

```bash
wget https://raw.githubusercontent.com/andreis/disposable-email-domains/master/domains.txt
grep -i homapin.com domains.txt
```

Or using web services that either use the IPs (obtained by whois/dig)

```
https://www.blocklist.de/en/search.html?ip=142.132.166.12&action=search&send=start+search 👍
https://www.blocklist.de/en/search.html?ip=188.166.111.252&action=search&send=start+search 👍
https://www.blocklist.de/en/search.html?ip=46.101.111.206&action=search&send=start+search 👍
https://www.blocklist.de/en/search.html?ip=116.202.9.167&action=search&send=start+search 👍
https://check.spamhaus.org/results/?query=homapin.com 👍
https://verifymail.io/domain/homapin.com 👎
https://www.ipqualityscore.com/domain-reputation/homapin.com 👎
https://quickemailverification.com/tools/disposable-email-address-detector for
  - homapin.com 👎
```

# [Upgrade ubuntu](https://www.cyberciti.biz/faq/how-to-upgrade-from-ubuntu-22-04-lts-to-ubuntu-24-04-lts/)

Upgrade your system:

```bash
sudo apt update
sudo apt upgrade
reboot
```

You must install ubuntu-release-upgrader-core package:

```bash
sudo apt install ubuntu-release-upgrader-core
```

Ensure the Prompt line in `/etc/update-manager/release-upgrades` is set to ‘lts‘ using the “grep” or “cat”

```bash
grep 'lts' /etc/update-manager/release-upgrades
cat /etc/update-manager/release-upgrades
```

Opening up TCP port 1022

For those using ssh-based sessions, open an additional SSH port using the ufw command, starting at port 1022. This is the default port set by the upgrade procedure as a fallback if the default SSH port dies during upgrades.

```bash
sudo /sbin/iptables -I INPUT -p tcp --dport 1022 -j ACCEPT

```

Finally, start the upgrade from Ubuntu 22.04 to 24.04 LTS version. Type:

```bash
sudo do-release-upgrade -d
```

# [Mount a cdrom or dvd](https://www.cyberciti.biz/faq/mounting-cdrom-in-linux/)

TL;DR: The syntax is as follows for the mount command:

```bash
mount -t iso9660 -o ro /dev/deviceName /path/to/mount/point
```

Use the following command to find out the name Of DVD / CD-ROM / Writer / Blu-ray device on a Linux based system:

```bash
lsblk
```

OR use the combination of the dmesg command and grep/egrep as follow to print your CD/DVD device name. For example:

```bash
dmesg | grep -E -i --color 'cdrom|dvd|cd/rw|writer'
```

Sample outputs indicating that the /dev/sr0 is my device name:

```
[    5.437164] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[    5.437307] cdrom: Uniform CD-ROM driver Revision: 3.20
```

Create a mount point, type mkdir command as follows:

```bash
mkdir -p /mnt/cdrom
```

Mount the /dev/cdrom or /dev/sr0 as follows:

```bash
mount -t iso9660 -o ro /dev/cdrom /mnt/cdrom
```

# Record the audio from your computer

You can record audio being played in a browser using `ffmpeg`

1. Check your default audio source:

   ```sh
   pactl list sources | grep -E 'Name|Description'
   ```

2. Record using `ffmpeg`:

   ```sh
   ffmpeg -f pulse -i <your_monitor_source> output.wav
   ```

   Example:

   ```sh
   ffmpeg -f pulse -i alsa_output.pci-0000_00_1b.0.analog-stereo.monitor output.wav
   ```

3. Stop recording with **Ctrl+C**.

# [Prevent the screen from turning off](https://wiki.archlinux.org/title/Display_Power_Management_Signaling#Runtime_settings)

VESA Display Power Management Signaling (DPMS) enables power saving behaviour of monitors when the computer is not in use. The time of inactivity before the monitor enters into a given saving power level—standby, suspend or off—can be set as described in DPMSSetTimeouts(3).

It is possible to turn off your monitor with the xset command

```bash
xset s off -dpms
```

It will disable DPMS and prevent screen from blanking

To query the current settings:

```bash
xset q
```

If that doesn't work you can use the [keep-presence](https://github.com/carrot69/keep-presence/) program

```bash
pip install keep-presence
keep-presence -c -s 10
```

That will move the mouse or cursor one pixel in circles each 300s, if you need to move it more often use the `-s` flag.

# [Protect the edition of a pdf with a password](https://askubuntu.com/questions/258848/is-there-a-tool-that-can-add-a-password-to-a-pdf-file)

Use `pdftk`. From its man page:

Encrypt a PDF using 128-Bit Strength (the Default) and Withhold All Permissions (the Default)

```bash
$ pdftk [mydoc].pdf output [mydoc.128].pdf owner_pw [foopass]
```

Same as Above, Except a Password is Required to Open the PDF

```bash
$ pdftk [mydoc].pdf output [mydoc.128].pdf owner_pw [foo] user_pw [baz]
```

Same as Above, Except Printing is Allowed (after the PDF is Open)

```bash
$ pdftk [mydoc].pdf output [mydoc.128].pdf owner_pw [foo] user_pw [baz] allow pri
```

To check if it has set the password correctly you [can run](https://stackoverflow.com/questions/4039659/is-it-possible-to-check-if-pdf-is-password-protected-using-ghostscript):

```bash
pdftk "input.pdf" dump_data output /dev/null dont_ask
```

# [Reduce the size of an image](https://www.digitalocean.com/community/tutorials/reduce-file-size-of-images-linux)

The simplest way of reducing the size of the image is by degrading the quality of the image.

```bash
convert <INPUT_FILE> -quality 50% <OUTPUT_FILE>
```

The main difference between `convert` and `mogrify` command is that `mogrify` command applies the operations on the original image file, whereas convert does not.

```bash
mogrify -quality 50 *.jpg
```

# Change the default shell of a user using the command line

```bash
chsh -s /usr/bin/zsh lyz
```

# Convert an html to a pdf

## Using weasyprint

Install it with `pip install weasyprint PyMuPDF`

```bash
weasyprint input.html output.pdf
```

It gave me better result than `wkhtmltopdf`

## Using wkhtmltopdf

To convert the given HTML into a PDF with proper styling and formatting using a simple method on Linux, you can use `wkhtmltopdf` with some custom options.

First, ensure that you have `wkhtmltopdf` installed on your system. If not, install it using your package manager (e.g., Debian: `sudo apt-get install wkhtmltopdf`).

Then, convert the HTML to PDF using `wkhtmltopdf` with the following command:

```bash
wkhtmltopdf --page-size A4 --margin-top 15mm --margin-bottom 15mm --encoding utf8 input.html output.pdf
```

In this command:

- `--page-size A4`: Sets the paper size to A4.
- `--margin-top 15mm` and `--margin-bottom 15mm`: Adds top and bottom margins of 15 mm to the PDF.

After running the command, you should have a nicely formatted `output.pdf` file in your current directory. This method preserves most of the original HTML styling while providing a simple way to export it as a PDF on Linux.

If you need to zoom in, you can use the `--zoom 1.2` flag. For this to work you need your css to be using the `em` sizes.

# Format a drive to use a FAT32 system

```bash
sudo mkfs.vfat -F 32 /dev/sdX
```

Replace /dev/sdX with your actual drive identifier

# Get the newest file of a directory with nested directories and files

```bash
find . -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "
```

# How to debug a CPU Throttling high alert

It may be because it has hit a limit set by kubernetes or docker. If the metrics don't show that it may be because the machine has run out of CPU credits.

If the docker is using less resources than the limits but they are still small (for example 0.1 CPUs) the issue may be that the CPU spikes are being throttle before they are shown in the CPU usage, the solution is then to increase the CPU limits

# Create a systemd service for a non-root user

To set up a systemd service as a **non-root user**, you can create a user-specific service file under your home directory. User services are defined in `~/.config/systemd/user/` and can be managed without root privileges.

1. Create the service file:

   Open a terminal and create a new service file in `~/.config/systemd/user/`. For example, if you want to create a service for a script named `my_script.py`, follow these steps:

   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/my_script.service
   ```

2. Edit the service file:

   In the `my_script.service` file, add the following configuration:

   ```ini
   [Unit]
   Description=My Python Script Service
   After=network.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/python3 /path/to/your/script/my_script.py
   WorkingDirectory=/path/to/your/script/
   SyslogIdentifier=my_script
   Restart=on-failure
   StandardOutput=journal
   StandardError=journal

   [Install]
   WantedBy=default.target
   ```

   - **Description**: A short description of what the service does.
   - **ExecStart**: The command to run your script. Replace `/path/to/your/script/my_script.py` with the full path to your Python script. If you want to run the script within a virtualenv you can use `/path/to/virtualenv/bin/python` instead of `/usr/bin/python3`.

     You'll need to add the virtualenv path to Path

     ```ini
     # Add virtualenv's bin directory to PATH
     Environment="PATH=/path/to/virtualenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     ```

   - **WorkingDirectory**: Set the working directory to where your script is located (optional).
   - **Restart**: Restart the service if it fails.
   - **StandardOutput** and **StandardError**: This ensures that the output is captured in the systemd journal.
   - **WantedBy**: Specifies the target to which this service belongs. `default.target` is commonly used for user services.

3. Reload systemd to recognize the new service:

   Run the following command to reload systemd's user service files:

   ```bash
   systemctl --user daemon-reload
   ```

4. Enable and start the service:

   To start the service immediately and enable it to run on boot (for your user session), use the following commands:

   ```bash
   systemctl --user start my_script.service
   systemctl --user enable my_script.service
   ```

5. Check the status and logs:

   - To check if the service is running:

     ```bash
     systemctl --user status my_script.service
     ```

   - To view logs specific to your service:

     ```bash
     journalctl --user -u my_script.service -f
     ```

     To view the logs of the last 15 mins you can append the `--since "15 minutes ago"` flag.

## If you need to use the graphical interface

If your script requires user interaction (like entering a GPG passphrase), it’s crucial to ensure that the service is tied to your graphical user session, which ensures that prompts can be displayed and interacted with.

To handle this situation, you should make a few adjustments to your systemd service:

### Ensure service is bound to graphical session

Change the `WantedBy` target to `graphical-session.target` instead of `default.target`. This makes sure the service waits for the full graphical environment to be available.

### Use `Type=forking` instead of `Type=simple` (optional)

If you need the service to wait until the user is logged in and has a desktop session ready, you might need to tweak the service type. Usually, `Type=simple` is fine, but you can also experiment with `Type=forking` if you notice any issues with user prompts.

### Updated Service File

Here’s how you should modify your `mbsync_syncer.service` file:

```ini
[Unit]
Description=My Python Script Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /path/to/your/script/my_script.py
WorkingDirectory=/path/to/your/script/
Restart=on-failure
StandardOutput=journal
StandardError=journal
SyslogIdentifier=my_script
# Environment variable to use the current user's DISPLAY and DBUS_SESSION
Environment="DISPLAY=:0"
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"

[Install]
WantedBy=graphical-session.target
```

After modifying the service, reload and restart it:

```bash
systemctl --user daemon-reload
systemctl --user restart my_script.service
```

# Debugging high IOwait

High I/O wait (`iowait`) on the CPU, especially at 50%, typically indicates that your system is spending a large portion of its time waiting for I/O operations (such as disk access) to complete. This can be caused by a variety of factors, including disk bottlenecks, overloaded storage systems, or inefficient applications making disk-intensive operations.

Here’s a structured approach to debug and analyze high I/O wait on your server:

## Monitor disk I/O

First, verify if disk I/O is indeed the cause. Tools like `iostat`, `iotop`, and `dstat` can give you an overview of disk activity:

- **`iostat`**: This tool reports CPU and I/O statistics. You can install it with `apt-get install sysstat`. Run the following command to check disk I/O stats:

  ```bash
  iostat -x 1
  ```

  The `-x` flag provides extended statistics, and `1` means it will report every second. Look for high values in the `%util` and `await` columns, which represent:

  - `%util`: Percentage of time the disk is busy (ideally should be below 90% for most systems).
  - `await`: Average time for I/O requests to complete.

  If either of these values is unusually high, it indicates that the disk subsystem is likely overloaded.

- **`iotop`**: If you want a more granular look at which processes are consuming disk I/O, use `iotop`:

  ```bash
  sudo iotop -o
  ```

  This will show you the processes that are actively performing I/O operations.

- **`dstat`**: Another useful tool for monitoring disk I/O in real-time:

  ```bash
  dstat -cdl 1
  ```

  This shows CPU, disk, and load stats, refreshing every second. Pay attention to the `dsk/await` value.

### Check disk health

Disk issues such as bad sectors or failing drives can also lead to high I/O wait times. To check the health of your disks:

- **Use `smartctl`**: This tool can give you a health check of your disks if they support S.M.A.R.T.

  ```bash
  sudo smartctl -a /dev/sda
  ```

  Check for any errors or warnings in the output. Particularly look for things like reallocated sectors or increasing "pending sectors."

- **`dmesg` logs**: Look at the system logs for disk errors or warnings:

  ```bash
  dmesg | grep -i "error"
  ```

  If there are frequent disk errors, it may be time to replace the disk or investigate hardware issues.

### Look for disk saturation

If the disk is saturated, no matter how fast the CPU is, it will be stuck waiting for data to come back from the disk. To further investigate disk saturation:

- **`df -h`**: Check if your disk partitions are full or close to full.

  ```bash
  df -h
  ```

- **`lsblk`**: Check how your disks are partitioned and how much data is written to each partition:

  ```bash
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
  ```

- **`blktrace`**: For advanced debugging, you can use `blktrace`, which traces block layer events on your system.

  ```bash
  sudo blktrace -d /dev/sda -o - | blkparse -i -
  ```

  This will give you very detailed insights into how the system is interacting with the block device.

### Check for heavy disk-intensive processes

Identify processes that might be using excessive disk I/O. You can use tools like `iotop` (as mentioned earlier) or `pidstat` to look for processes with high disk usage:

- **`pidstat`**: Track per-process disk activity:

  ```bash
  pidstat -d 1
  ```

  This command will give you I/O statistics per process every second. Look for processes with high `I/O` values (`r/s` and `w/s`).

- **`top`** or **`htop`**: While `top` or `htop` can show CPU usage, they can also show process-level disk activity. Focus on processes consuming high CPU or memory, as they might also be performing heavy I/O operations.

### check file system issues

Sometimes the file system itself can be the source of I/O bottlenecks. Check for any file system issues that might be causing high I/O wait.

- **Check file system consistency**: If you suspect the file system is causing issues (e.g., due to corruption), run a file system check. For `ext4`:

  ```bash
  sudo fsck /dev/sda1
  ```

  Ensure you unmount the disk first or do this in single-user mode.

- **Check disk scheduling**: Some disk schedulers (like `cfq` or `deadline`) might perform poorly depending on your workload. You can check the scheduler used by your disk with:

  ```bash
  cat /sys/block/sda/queue/scheduler
  ```

  You can change the scheduler with:

  ```bash
  echo deadline > /sys/block/sda/queue/scheduler
  ```

  This might improve disk performance, especially for certain workloads.

### Examine system logs

The system logs (`/var/log/syslog` or `/var/log/messages`) may contain additional information about hardware issues, I/O bottlenecks, or kernel-related warnings:

```bash
sudo tail -f /var/log/syslog
```

or

```bash
sudo tail -f /var/log/messages
```

Look for I/O or disk-related warnings or errors.

### Consider hardware upgrades or tuning

- **SSD vs HDD**: If you're using HDDs, consider upgrading to SSDs. HDDs can be much slower in terms of I/O, especially if you have a high number of random read/write operations.
- **RAID Configuration**: If you are using RAID, check the RAID configuration and ensure it's properly tuned for performance (e.g., using RAID-10 for a good balance of speed and redundancy).
- **Memory and CPU Tuning**: If the server is swapping due to insufficient RAM, it can result in increased I/O wait. You might need to add more RAM or optimize the system to avoid excessive swapping.

### Check for swapping issues

Excessive swapping can contribute to high I/O wait times. If your system is swapping (which happens when physical RAM is exhausted), I/O wait spikes as the system reads from and writes to swap space on disk.

- **Check swap usage**:

  ```bash
  free -h
  ```

  If swap usage is high, you may need to add more physical RAM or optimize applications to reduce memory pressure.

---

# Create a file with random data

Of 3.5 GB

```bash
dd if=/dev/urandom of=random_file.bin bs=1M count=3584
```

# [Set the vim filetype syntax in a comment](https://unix.stackexchange.com/questions/19867/is-there-a-way-to-place-a-comment-in-a-file-which-vim-will-process-in-order-to-s)

Add somewhere in your file:

```
# vi: ft=yaml
```

# Export environment variables in a crontab

If you need to expand the `PATH` in theory you can do it like this:

```
PATH=$PATH:/usr/local/bin

* * * * * /path/to/my/script
```

I've found however that sometimes this doesn't work and you need to specify it in the crontab line:

```
* * * * * PATH=$PATH:/usr/local/bin /path/to/my/script
```

# [Clean the logs of a unit of the journal](https://stackoverflow.com/questions/36718019/journalctl-remove-logs-of-a-specific-unit)

```bash
journalctl --vacuum-time=1s --unit=your.service

```

If you wish to clear all logs use `journalctl --vacuum-time=1s`

# [Send logs of a cronjob to journal](https://stackoverflow.com/questions/52200878/crontab-journalctl-extra-messages)

You can use `systemd-cat` to send the logs of a script or cron to the journal to the unit specified after the `-t` flag. It works better than piping the output to `logger -t`

```bash
systemd-cat -t syncoid_send_backups /root/send_backups.sh
```

# [Set dependencies between systemd services](https://stackoverflow.com/questions/21830670/start-systemd-service-after-specific-service)

Use `Wants` or `Requires`:

```ini
website.service
[Unit]
Wants=mongodb.service
After=mongodb.service
```

# [Set environment variable in systemd service](https://www.baeldung.com/linux/systemd-services-environment-variables)

```ini
[Service]
# ...
Environment="FOO=foo"
```

# [Get info of a mkv file](https://superuser.com/questions/595177/how-to-retrieve-video-file-information-from-command-line-under-linux)

```bash
ffprobe file.mkv
```

# [Send multiline messages with notify-send](https://stackoverflow.com/questions/35628702/display-multi-line-notification-using-notify-send-in-python)

The title can't have new lines, but the body can.

```bash
notify-send "Title" "This is the first line.\nAnd this is the second.")
```

# [Find BIOS version](https://www.cyberciti.biz/faq/check-bios-version-linux/)

```bash
dmidecode | less
```

# [Reboot server on kernel panic ](https://www.supertechcrew.com/kernel-panics-and-lockups/)

The `proc/sys/kernel/panic` file gives read/write access to the kernel variable `panic_timeout`. If this is zero, the kernel will loop on a panic; if nonzero it indicates that the kernel should autoreboot after this number of seconds. When you use the software watchdog device driver, the recommended setting is `60`.

To set the value add the next contents to the `/etc/sysctl.d/99-panic.conf`

```
kernel.panic = 60
```

Or with an ansible task:

```yaml
- name: Configure reboot on kernel panic
  become: true
  lineinfile:
    path: /etc/sysctl.d/99-panic.conf
    line: kernel.panic = 60
    create: true
    state: present
```

There are other things that can cause a machine to lock up or become unstable. Some of them will even make a machine responsive to pings and network heartbeat monitors, but will cause programs to crash and internal systems to lockup.

If you want the machine to automatically reboot, make sure you set `kernel.panic` to something above 0. Otherwise these settings could cause a hung machine that you will have to reboot manually.

```
# Panic if the kernel detects an I/O channel
# check (IOCHK). 0=no | 1=yes
kernel.panic_on_io_nmi = 1

# Panic if a hung task was found. 0=no, 1=yes
kernel.hung_task_panic = 1

# Setup timeout for hung task,
# in seconds (suggested 300)
kernel.hung_task_timeout_secs = 300

# Panic on out of memory.
# 0=no | 1=usually | 2=always
vm.panic_on_oom=2

# Panic when the kernel detects an NMI
# that usually indicates an uncorrectable
# parity or ECC memory error. 0=no | 1=yes
kernel.panic_on_unrecovered_nmi=1

# Panic if the kernel detects a soft-lockup
# error (1). Otherwise it lets the watchdog
# process skip it's update (0)
# kernel.softlockup_panic=0

# Panic on oops too. Use with caution.
# kernel.panic_on_oops=30
```

# [Share a calculated value between github actions steps](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter)

You need to set a step's output parameter. Note that the step will need an `id` to be defined to later retrieve the output value.

```bash
echo "{name}={value}" >> "$GITHUB_OUTPUT"
```

For example:

```yaml
- name: Set color
  id: color-selector
  run: echo "SELECTED_COLOR=green" >> "$GITHUB_OUTPUT"
- name: Get color
  env:
    SELECTED_COLOR: ${{ steps.color-selector.outputs.SELECTED_COLOR }}
  run: echo "The selected color is $SELECTED_COLOR"
```

# [Split a zip into sizes with restricted size ](https://unix.stackexchange.com/questions/198982/zip-files-with-size-limit)

Something like:

```bash
zip -9 myfile.zip *
zipsplit -n 250000000 myfile.zip
```

Would produce `myfile1.zip`, `myfile2.zip`, etc., all independent of each other, and none larger than 250MB (in powers of ten). `zipsplit` will even try to organize the contents so that each resulting archive is as close as possible to the maximum size.

# [find files that were modified between dates](https://unix.stackexchange.com/questions/29245/how-to-list-files-that-were-changed-in-a-certain-range-of-time)

The best option is the `-newerXY`. The m and t flags can be used.

- `m` The modification time of the file reference
- `t` reference is interpreted directly as a time

So the solution is

```bash
find . -type f -newermt 20111222 \! -newermt 20111225
```

The lower bound in inclusive, and upper bound is exclusive, so I added 1 day to it. And it is recursive.

# [Rotate image with the command line ](https://askubuntu.com/questions/591733/rotate-images-from-terminal)

If you want to overwrite in-place, `mogrify` from the ImageMagick suite seems to be the easiest way to achieve this:

```bash
# counterclockwise:
mogrify -rotate -90 *.jpg

# clockwise:
mogrify -rotate 90 *.jpg
```

# [Configure desktop icons in gnome](https://gitlab.gnome.org/GNOME/nautilus/-/issues/158#instructions)

Latest versions of gnome dont have desktop icons [read this article to fix this](https://gitlab.gnome.org/GNOME/nautilus/-/issues/158#instructions)

# [Make a file executable in a git repository ](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)

```bash
git add entrypoint.sh
git update-index --chmod=+x entrypoint.sh
```

# [Configure autologin in Debian with Gnome](https://linux.how2shout.com/enable-or-disable-automatic-login-in-debian-11-bullseye/)

Edit the `/etc/gdm3/daemon.conf` file and include:

```ini
AutomaticLoginEnable = true
AutomaticLogin = <your user>
```

# [See errors in the journalctl ](https://unix.stackexchange.com/questions/332886/how-to-see-error-message-in-journald)

To get all errors for running services using journalctl:

```bash
journalctl -p 3 -xb
```

where `-p 3` means priority err, `-x` provides extra message information, and `-b` means since last boot.

# [Fix rsyslog builtin:omfile suspended error](https://ubuntu-mate.community/t/rsyslogd-action-action-0-builtin-omfile-resumed-module-builtin-omfile/24105/21)

It may be a permissions error. I have not been able to pinpoint the reason behind it.

What did solve it though is to remove the [aledgely deprecated paramenters](https://www.rsyslog.com/doc/configuration/modules/omfile.html) from `/etc/rsyslog.conf`:

```
# $FileOwner syslog
# $FileGroup adm
# $FileCreateMode 0640
# $DirCreateMode 0755
# $Umask 0022
# $PrivDropToUser syslog
# $PrivDropToGroup syslog
```

I hope that as they are the default parameters, they don't need to be set.

# [Configure nginx to restrict methods](https://tecadmin.net/how-to-allow-get-and-post-methods-only-in-nginx/)

```
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        if ($request_method !~ ^(GET|POST)$ ) {
            return 405;
        }

        try_files $uri $uri/ =404;
    }
}
```

# [Configure nginx location regexp to accept dashes](https://superuser.com/questions/1363456/nginx-server-name-regex-allow-dash)

```
location ~* /share/[\w-]+ {
  root /home/project_root;
}
```

# [Configure nginx location to accept many paths](https://serverfault.com/questions/564127/nginx-location-regex-for-multiple-paths)

```
location ~ ^/(static|media)/ {
  root /home/project_root;
}
```

# [Remove image metadata](https://stackoverflow.com/questions/66192531/exiftool-how-to-remove-all-metadata-from-all-files-possible-inside-a-folder-an)

```bash
exiftool -all:all= /path/to/file
```

# [Get the size increment of a directory between two dates](https://stackoverflow.com/questions/60147882/calculating-the-total-size-of-all-files-from-a-particular-date-to-till-date-usin)

To see how much has a directory grown between two dates you can use:

```bash
find /path/to/directory -type f -newerat 2022-12-31 ! -newerat 2024-01-01 -printf "%s\\n" | awk '{s+=$1} END {print s}'
```

It finds all the files in that directory that were created in the 2023, it only prints their size in bytes and then it adds them all up.

# [Makefile use bash instead of sh](https://stackoverflow.com/questions/589276/how-can-i-use-bash-syntax-in-makefile-targets)

The program used as the shell is taken from the variable `SHELL`. If
this variable is not set in your makefile, the program `/bin/sh` is
used as the shell.

So put `SHELL := /bin/bash` at the top of your makefile, and you should be good to go.

# [Recover the message of a commit if the command failed](https://unix.stackexchange.com/questions/590224/is-git-commit-message-recoverable-if-committing-fails-for-some-reason)

`git commit` can fail for reasons such as `gpg.commitsign = true` && `gpg` fails, or when running a pre-commit. Retrying the command opens a blank editor and the message seems to be lost.

The message is saved though in `.git/COMMIT_EDITMSG`, so you can:

```bash
git commit -m "$(cat .git/COMMIT_EDITMSG)"
```

Or in general (suitable for an alias for example):

```bash
git commit -m "$(cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG)")"
```

# [Accept new ssh keys by default](https://stackoverflow.com/questions/21383806/how-can-i-force-ssh-to-accept-a-new-host-fingerprint-from-the-command-line)

While common wisdom is not to disable host key checking, there is a built-in option in SSH itself to do this. It is relatively unknown, since it's new (added in Openssh 6.5).

This is done with `-o StrictHostKeyChecking=accept-new`. Or if you want to use it for all hosts you can add the next lines to your `~/.ssh/config`:

```
Host *
  StrictHostKeyChecking accept-new
```

WARNING: use this only if you absolutely trust the IP\hostname you are going to SSH to:

```bash
ssh -o StrictHostKeyChecking=accept-new mynewserver.example.com
```

Note, `StrictHostKeyChecking=no` will add the public key to `~/.ssh/known_hosts` even if the key was changed. `accept-new` is only for new hosts. From the man page:

> If this flag is set to “accept-new” then ssh will automatically add new host keys to the user known hosts files, but will not permit connections to hosts with changed host keys. If this flag is set to “no” or “off”, ssh will automatically add new host keys to the user known hosts files and allow connections to hosts with changed hostkeys to proceed, subject to some restrictions. If this flag is set to ask (the default), new host keys will be added to the user known host files only after the user has confirmed that is what they really want to do, and ssh will refuse to connect to hosts whose host key has changed. The host keys of known hosts will be verified automatically in all cases.

# [Do not add trailing / to ls](https://stackoverflow.com/questions/9044465/list-of-dirs-without-trailing-slash)

Probably, your `ls` is aliased or defined as a function in your config files.

Use the full path to `ls` like:

```bash
/bin/ls /var/lib/mysql/
```

# [Convert png to svg](https://askubuntu.com/questions/470495/how-do-i-convert-a-png-to-svg)

Inkscape has got an awesome auto-tracing tool.

- Install Inkscape using `sudo apt-get install inkscape`
- Import your image
- Select your image
- From the menu bar, select Path > Trace Bitmap Item
- Adjust the tracing parameters as needed
- Save as svg

Check their [tracing tutorial](https://inkscape.org/en/doc/tutorials/tracing/tutorial-tracing.html) for more information.

Once you are comfortable with the tracing options. You can automate it by using [CLI of Inkscape](https://inkscape.org/en/doc/inkscape-man.html).

# [Redirect stdout and stderr of a cron job to a file](https://unix.stackexchange.com/questions/52330/how-to-redirect-output-to-a-file-from-within-cron)

```
*/1 * * * * /home/ranveer/vimbackup.sh >> /home/ranveer/vimbackup.log 2>&1
```

# Error when unmounting a device: Target is busy

- Check the processes that are using the mountpoint with `lsof /path/to/mountpoint`
- Kill those processes
- Try the umount again

If that fails, you can use `umount -l`.

# Wipe a disk

Overwrite it many times [with badblocks](hard_drive_health.md#check-the-health-of-a-disk-with-badblocks).

```bash
badblocks -wsv -b 4096 /dev/sde | tee disk_wipe_log.txt
```

# [Impose load on a system to stress it](https://linux.die.net/man/1/stress)

```bash
sudo apt-get install stress

stress --cpu 2
```

That will fill up the usage of 2 cpus. To run 1 vm stressor using 1GB of virtual memory for 60s, enter:

```bash
stress --vm 1 --vm-bytes 1G --vm-keep -t 60s
```

You can also stress:

- io with `--io 4`, for example to spawn 4 workers.
- hard drives with `--hdd 2 --hdd-bytes 1G` which will spawn 2 workers that will write 1G

# [Get the latest tag of a git repository](https://stackoverflow.com/questions/1404796/how-can-i-get-the-latest-tag-name-in-current-branch-in-git)

```bash
git describe --tags --abbrev=0
```

# [Configure gpg-agent cache ttl](https://superuser.com/questions/624343/keep-gnupg-credentials-cached-for-entire-user-session)

The user configuration (in `~/.gnupg/gpg-agent.conf`) can only define the default and maximum caching duration; it can't be disabled.

The `default-cache-ttl` option sets the timeout (in seconds) after the last GnuPG activity (so it resets if you use it), the `max-cache-ttl` option set the timespan (in seconds) it caches after entering your password. The default value is 600 seconds (10 minutes) for `default-cache-ttl` and 7200 seconds (2 hours) for max-cache-ttl.

```
default-cache-ttl 21600
max-cache-ttl 21600
```

For this change to take effect, you need to end the session by restarting `gpg-agent`.

```bash
gpgconf --kill gpg-agent
gpg-agent --daemon --use-standard-socket
```

# Get return code of failing find exec

When you run `find . -exec ls {} \;` even if the command run in the `exec` returns a status code different than 0 [you'll get an overall status code of 0](https://serverfault.com/questions/905031/how-can-i-make-find-return-non-0-if-exec-command-fails) which makes difficult to catch errors in bash scripts.

You can instead use `xargs`, for example:

```bash
find /tmp/ -iname '*.sh' -print0 | xargs -0 shellcheck
```

This will run `shellcheck file_name` for each of the files found by the `find` command.

# Limit the resources a docker is using

You can either use limits in the `docker` service itself, see [1](https://unix.stackexchange.com/questions/537645/how-to-limit-docker-total-resources) and [2](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html).

Or/and you can limit it for each docker, see [1](https://www.baeldung.com/ops/docker-memory-limit) and [2](https://docs.docker.com/config/containers/resource_constraints/).

# [Get the current git branch](https://stackoverflow.com/questions/6245570/how-do-i-get-the-current-branch-name-in-git)

```bash
git branch --show-current
```

# Install latest version of package from backports

Add the backports repository:

```bash
vi /etc/apt/sources.list.d/bullseye-backports.list
```

```
deb http://deb.debian.org/debian bullseye-backports main contrib
deb-src http://deb.debian.org/debian bullseye-backports main contrib
```

Configure the package to be pulled from backports

```bash
vi /etc/apt/preferences.d/90_zfs
```

```
Package: src:zfs-linux
Pin: release n=bullseye-backports
Pin-Priority: 990
```

# [Rename multiple files matching a pattern](https://stackoverflow.com/questions/6840332/rename-multiple-files-by-replacing-a-particular-pattern-in-the-filenames-using-a)

There is `rename` that looks nice, but you need to install it. Using only `find` you can do:

```bash
find . -name '*yml' -exec bash -c 'echo mv $0 ${0/yml/yaml}' {} \;
```

If it shows what you expect, remove the `echo`.

# [Force ssh to use password authentication](https://superuser.com/questions/1376201/how-do-i-force-ssh-to-use-password-instead-of-key)

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no exampleUser@example.com
```

# [Do a tail -f with grep](https://stackoverflow.com/questions/23395665/tail-f-grep)

```bash
tail -f file | grep --line-buffered my_pattern
```

# [Check if a program exists in the user's PATH](https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script)

```bash
command -v <the_command>
```

Example use:

```bash
if ! command -v <the_command> &> /dev/null
then
    echo "<the_command> could not be found"
    exit
fi
```

# [Reset failed systemd services](https://unix.stackexchange.com/questions/418792/systemctl-remove-unit-from-failed-list)

Use systemctl to remove the failed status. To reset all units with failed status:

```bash
systemctl reset-failed
```

or just your specific unit:

```bash
systemctl reset-failed openvpn-server@intranert.service
```

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

If you need to forward an external port to a local one [you can use](https://linuxize.com/post/how-to-setup-ssh-tunneling/)

```bash
ssh -L LOCAL_PORT:DESTINATION:DESTINATION_PORT [USER@]SSH_SERVER
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

- `Server`: The hostname or IP address of the NFS server where the exported directory resides.
- `/path/to/export`: The shared directory (exported folder) path.
- `/local_mountpoint`: Existing directory in the host where you want to mount the NFS share.

You can specify a number of options that you want to set on the NFS mount:

- `soft/hard`: When the mount option `hard` is set, if the NFS server crashes or becomes unresponsive, the NFS requests will be retried indefinitely. You can set the mount option `intr`, so that the process can be interrupted. When the NFS server comes back online, the process can be continued from where it was while the server became unresponsive.

  When the option `soft` is set, the process will be reported an error when the NFS server is unresponsive after waiting for a period of time (defined by the `timeo` option). In certain cases `soft` option can cause data corruption and loss of data. So, it is recommended to use `hard` and `intr` options.

- `noexec`: Prevents execution of binaries on mounted file systems. This is useful if the system is mounting a non-Linux file system via NFS containing incompatible binaries.
- `nosuid`: Disables set-user-identifier or set-group-identifier bits. This prevents remote users from gaining higher privileges by running a setuid program.
- `tcp`: Specifies the NFS mount to use the TCP protocol.
- `udp`: Specifies the NFS mount to use the UDP protocol.
- `nofail`: Prevent issues when rebooting the host. The downside is that if you have services that depend on the volume to be mounted they won't behave as expected.

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

- Change main group of user

  ```bash
  usermod -g {{ group_name }} {{ user_name }}
  ```

- Add user to group

  ```bash
  usermod -a -G {{ group_name }} {{ user_name }}
  ```

- Remove user from group.

  ```bash
  usermod -G {{ remaining_group_names }} {{ user_name }}
  ```

  You have to execute `groups {{ user }}` get the list and pass the remaining to the above command

- Change uid and gid of the user

  ```bash
  usermod -u {{ newuid }} {{ login }}
  groupmod -g {{ newgid }} {{ group }}
  find / -user {{ olduid }} -exec chown -h {{ newuid }} {} \;
  find / -group {{ oldgid }} -exec chgrp -h {{ newgid }} {} \;
  usermod -g {{ newgid }} {{ login }}
  ```

# Manage ssh keys

- Generate ed25519 key

  ```bash
  ssh-keygen -t ed25519 -f {{ path_to_keyfile }}
  ```

- Generate RSA key

  ```bash
  ssh-keygen -t rsa -b 4096 -o -a 100 -f {{ path_to_keyfile }}
  ```

- Generate different comment

  ```bash
  ssh-keygen -t ed25519 -f {{ path_to_keyfile }} -C {{ email }}
  ```

- Generate key headless, batch

  ```bash
  ssh-keygen -t ed25519 -f {{ path_to_keyfile }} -q -N ""
  ```

- Generate public key from private key

  ```bash
  ssh-keygen -y -f {{ path_to_keyfile }} > {{ path_to_public_key_file }}
  ```

- Get fingerprint of key
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

- `-i`: the interval to provide periodic bandwidth updates
- `-s`: listen as a server

On the client system:

```bash
client#: iperf3 -i 10 -w 1M -t 60 -c [server hostname or ip address]
```

Where:

- `-i`: the interval to provide periodic bandwidth updates
- `-w`: the socket buffer size (which affects the TCP Window). The buffer size is also set on the server by this client command.
- `-t`: the time to run the test in seconds
- `-c`: connect to a listening server at…

Sometimes is interesting to test both ways as they may return different outcomes

I've got the next results at home:

- From new NAS to laptop through wifi 67.5 MB/s
- From laptop to new NAS 59.25 MB/s
- From intel Nuc to new NAS 116.75 MB/s (934Mbit/s)
- From old NAS to new NAS 11 MB/s

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

- New NAS server NVME:

  ```
  read: IOPS=297k, BW=1159MiB/s (1215MB/s)(3070MiB/2649msec)
   bw (  MiB/s): min= 1096, max= 1197, per=99.80%, avg=1156.61, stdev=45.31, samples=5
   iops        : min=280708, max=306542, avg=296092.00, stdev=11598.11, samples=5
  write: IOPS=99.2k, BW=387MiB/s (406MB/s)(1026MiB/2649msec); 0 zone resets
   bw (  KiB/s): min=373600, max=408136, per=99.91%, avg=396248.00, stdev=15836.85, samples=5
   iops        : min=93400, max=102034, avg=99062.00, stdev=3959.21, samples=5
  cpu          : usr=15.67%, sys=67.18%, ctx=233314, majf=0, minf=8
  ```

- New NAS server ZFS pool with RAIDZ:

  ```
  read: IOPS=271k, BW=1059MiB/s (1111MB/s)(3070MiB/2898msec)
   bw (  MiB/s): min=  490, max= 1205, per=98.05%, avg=1038.65, stdev=306.74, samples=5
   iops        : min=125672, max=308484, avg=265893.20, stdev=78526.52, samples=5
  write: IOPS=90.6k, BW=354MiB/s (371MB/s)(1026MiB/2898msec); 0 zone resets
   bw (  KiB/s): min=167168, max=411776, per=98.26%, avg=356236.80, stdev=105826.16, samples=5
   iops        : min=41792, max=102944, avg=89059.20, stdev=26456.54, samples=5
  cpu          : usr=12.84%, sys=63.20%, ctx=234345, majf=0, minf=6
  ```

- Laptop NVME:

  ```
  read: IOPS=36.8k, BW=144MiB/s (151MB/s)(3070MiB/21357msec)
   bw (  KiB/s): min=129368, max=160304, per=100.00%, avg=147315.43, stdev=6640.40, samples=42
   iops        : min=32342, max=40076, avg=36828.86, stdev=1660.10, samples=42
  write: IOPS=12.3k, BW=48.0MiB/s (50.4MB/s)(1026MiB/21357msec); 0 zone resets
   bw (  KiB/s): min=42952, max=53376, per=100.00%, avg=49241.33, stdev=2151.40, samples=42
   iops        : min=10738, max=13344, avg=12310.33, stdev=537.85, samples=42
  cpu          : usr=14.32%, sys=32.17%, ctx=356674, majf=0, minf=7
  ```

- Laptop ZFS pool through NFS (running in parallel with other network processes):

  ```
  read: IOPS=4917, BW=19.2MiB/s (20.1MB/s)(3070MiB/159812msec)
   bw (  KiB/s): min=16304, max=22368, per=100.00%, avg=19681.46, stdev=951.52, samples=319
   iops        : min= 4076, max= 5592, avg=4920.34, stdev=237.87, samples=319
  write: IOPS=1643, BW=6574KiB/s (6732kB/s)(1026MiB/159812msec); 0 zone resets
   bw (  KiB/s): min= 5288, max= 7560, per=100.00%, avg=6577.35, stdev=363.32, samples=319
   iops        : min= 1322, max= 1890, avg=1644.32, stdev=90.82, samples=319
  cpu          : usr=5.21%, sys=10.59%, ctx=175825, majf=0, minf=8
  ```

- Intel Nuc server disk SSD:

  ```
    read: IOPS=11.0k, BW=46.9MiB/s (49.1MB/s)(3070MiB/65525msec)
   bw (  KiB/s): min=  280, max=73504, per=100.00%, avg=48332.30, stdev=25165.49, samples=130
   iops        : min=   70, max=18376, avg=12083.04, stdev=6291.41, samples=130
  write: IOPS=4008, BW=15.7MiB/s (16.4MB/s)(1026MiB/65525msec); 0 zone resets
   bw (  KiB/s): min=   55, max=24176, per=100.00%, avg=16153.84, stdev=8405.53, samples=130
   iops        : min=   13, max= 6044, avg=4038.40, stdev=2101.42, samples=130
  cpu          : usr=8.04%, sys=25.87%, ctx=268055, majf=0, minf=8
  ```

- Intel Nuc server external HD usb disk :

  ```

  ```

- Intel Nuc ZFS pool through NFS (running in parallel with other network processes):

  ```
    read: IOPS=18.7k, BW=73.2MiB/s (76.8MB/s)(3070MiB/41929msec)
   bw (  KiB/s): min=43008, max=103504, per=99.80%, avg=74822.75, stdev=16708.40, samples=83
   iops        : min=10752, max=25876, avg=18705.65, stdev=4177.11, samples=83
  write: IOPS=6264, BW=24.5MiB/s (25.7MB/s)(1026MiB/41929msec); 0 zone resets
   bw (  KiB/s): min=14312, max=35216, per=99.79%, avg=25003.55, stdev=5585.54, samples=83
   iops        : min= 3578, max= 8804, avg=6250.88, stdev=1396.40, samples=83
  cpu          : usr=6.29%, sys=13.21%, ctx=575927, majf=0, minf=10
  ```

- Old NAS with RAID5:
  ```
  read : io=785812KB, bw=405434B/s, iops=98, runt=1984714msec
  write: io=262764KB, bw=135571B/s, iops=33, runt=1984714msec
  cpu          : usr=0.16%, sys=0.59%, ctx=212447, majf=0, minf=8
  ```

Conclusions:

- New NVME are **super fast** (1215MB/s read, 406MB/s write)
- ZFS rocks, with a RAIDZ1, L2ARC and ZLOG it returned almost the same performance as the NVME ( 1111MB/s read, 371MB/s write)
- Old NAS with RAID is **super slow** (0.4KB/s read, 0.1KB/s write!)
- I should replace the laptop's NVME, the NAS one has 10x performace both on read and write.

There is a huge difference between ZFS in local and through NFS. In local you get (1111MB/s read and 371MB/s write) while through NFS I got (20.1MB/s read and 6.7MB/s write). I've measured the network performance between both machines with `iperf3` and got:

- From NAS to laptop 67.5 MB/s
- From laptop to NAS 59.25 MB/s

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

  File: `/etc/apt/preferences`

  ```
  Package: *
  Pin: release a=stable
  Pin-Priority: 700

  Package: *
  Pin: release  a=testing
  Pin-Priority: 600

  Package: *
  Pin: release a=unstable
  Pin-Priority: 100
  ```

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

If you run this command in conjunction with [watchtower](watchtower.md) and manually defined networks you may run into the issue that the docker system prune acts just when the dockers are stopped and thus removing the networks, which will prevent the dockers to start. In those cases you can either make sure that docker system prune is never run when watchtower is doing the updates or you can split the command into the next script:

```bash
#!/bin/bash

# Prune unused containers, images, and volumes, but preserve networks
date
echo "Pruning the containers"
docker container prune -f --filter "label!=prune=false"
echo "Pruning the images"
docker image prune -a -f --filter "label!=prune=false"
echo "Pruning the volumes"
docker volume prune -f
```

You can check the remaining docker images sorted by size with:

```bash
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | sort -k2 -h
```

You can also use the builtin `docker system df -v` to get a better understanding of the usage of disk space.

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
