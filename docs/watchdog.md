A [watchdog timer](https://en.wikipedia.org/wiki/Watchdog_timer) (WDT, or simply a watchdog), sometimes called a computer operating properly timer (COP timer), is an electronic or software timer that is used to detect and recover from computer malfunctions. Watchdog timers are widely used in computers to facilitate automatic correction of temporary hardware faults, and to prevent errant or malevolent software from disrupting system operation.

During normal operation, the computer regularly restarts the watchdog timer to prevent it from elapsing, or "timing out". If, due to a hardware fault or program error, the computer fails to restart the watchdog, the timer will elapse and generate a timeout signal. The timeout signal is used to initiate corrective actions. The corrective actions typically include placing the computer and associated hardware in a safe state and invoking a computer reboot.

Microcontrollers often include an integrated, on-chip watchdog. In other computers the watchdog may reside in a nearby chip that connects directly to the CPU, or it may be located on an external expansion card in the computer's chassis. 

# Hardware watchdog

Before you start using the hardware watchdog you need to check if your hardware actually supports it. 

If you see [Watchdog hardware is disabled error on boot](#watchdog-hardware-is-disabled-error-on-boot) things are not looking good.

## Check if the hardware watchdog is enabled
You can see if hardware watchdog is loaded by running `wdctl`. For example for a machine that has it enabled you'll see:

```
Device:        /dev/watchdog0
Identity:      iTCO_wdt [version 0]
Timeout:       30 seconds
Pre-timeout:    0 seconds
Timeleft:      30 seconds
FLAG           DESCRIPTION               STATUS BOOT-STATUS
KEEPALIVEPING  Keep alive ping reply          1           0
MAGICCLOSE     Supports magic close char      0           0
SETTIMEOUT     Set timeout (in seconds)       0           0
```

On a machine that doesn't you'll see:

```
wdctl: No default device is available.: No such file or directory
```

Another option is to run `dmesg | grep wd` or `dmesg | grep watc -i`. For example for a machine that has enabled the hardware watchdog you'll see something like:

```
[   20.708839] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   20.708894] iTCO_wdt: Found a Intel PCH TCO device (Version=4, TCOBASE=0x0400)
[   20.709009] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
```

For one that is not you'll see:

```
[    1.934999] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver
[    1.935057] sp5100-tco sp5100-tco: Using 0xfed80b00 for watchdog MMIO address
[    1.935062] sp5100-tco sp5100-tco: Watchdog hardware is disabled
```

If you're out of luck and your hardware doesn't support it you can delegate the task to the software watchdog or get some [usb watchdog](https://github.com/zatarra/usb-watchdog)
# [Systemd watchdog](https://0pointer.de/blog/projects/watchdog.html)

Starting with version 183 systemd provides full support for hardware watchdogs (as exposed in /dev/watchdog to userspace), as well as supervisor (software) watchdog support for invidual system services. The basic idea is the following: if enabled, systemd will regularly ping the watchdog hardware. If systemd or the kernel hang this ping will not happen anymore and the hardware will automatically reset the system. This way systemd and the kernel are protected from boundless hangs -- by the hardware. To make the chain complete, systemd then exposes a software watchdog interface for individual services so that they can also be restarted (or some other action taken) if they begin to hang. This software watchdog logic can be configured individually for each service in the ping frequency and the action to take. Putting both parts together (i.e. hardware watchdogs supervising systemd and the kernel, as well as systemd supervising all other services) we have a reliable way to watchdog every single component of the system.
# [Configuring the watchdog](https://0pointer.de/blog/projects/watchdog.html)

## Configuring the hardware watchdog
To make use of the hardware watchdog it is sufficient to set the `RuntimeWatchdogSec=` option in `/etc/systemd/system.conf`. It defaults to `0` (i.e. no hardware watchdog use). Set it to a value like `20s` and the watchdog is enabled. After 20s of no keep-alive pings the hardware will reset itself. Note that `systemd` will send a ping to the hardware at half the specified interval, i.e. every 10s.

Note that the hardware watchdog device (`/dev/watchdog`) is single-user only. That means that you can either enable this functionality in systemd, or use a separate external watchdog daemon, such as the aptly named `watchdog`. Although the built-in hardware watchdog support of systemd does not conflict with other watchdog software by default. systemd does not make use of `/dev/watchdog` by default, and you are welcome to use external watchdog daemons in conjunction with systemd, if this better suits your needs.

`ShutdownWatchdogSec=`` is another option that can be configured in `/etc/systemd/system.conf`. It controls the watchdog interval to use during reboots. It defaults to 10min, and adds extra reliability to the system reboot logic: if a clean reboot is not possible and shutdown hangs, we rely on the watchdog hardware to reset the system abruptly, as extra safety net.

## Configuring the service watchdog
Now, let's have a look how to add watchdog logic to individual services.

First of all, to make software watchdog-supervisable it needs to be patched to send out "I am alive" signals in regular intervals in its event loop. Patching this is relatively easy. First, a daemon needs to read the `WATCHDOG_USEC=` environment variable. If it is set, it will contain the watchdog interval in usec formatted as ASCII text string, as it is configured for the service. The daemon should then issue `sd_notify("WATCHDOG=1")` calls every half of that interval. A daemon patched this way should transparently support watchdog functionality by checking whether the environment variable is set and honoring the value it is set to.

To enable the software watchdog logic for a service (which has been patched to support the logic pointed out above) it is sufficient to set the `WatchdogSec=` to the desired failure latency. See `systemd.service(5)` for details on this setting. This causes `WATCHDOG_USEC=` to be set for the service's processes and will cause the service to enter a failure state as soon as no keep-alive ping is received within the configured interval.

The next step is to configure whether the service shall be restarted and how often, and what to do if it then still fails. To enable automatic service restarts on failure set `Restart=on-failure` for the service. To configure how many times a service shall be attempted to be restarted use the combination of `StartLimitBurst=` and `StartLimitInterval=` which allow you to configure how often a service may restart within a time interval. If that limit is reached, a special action can be taken. This action is configured with `StartLimitAction=`. The default is a none, i.e. that no further action is taken and the service simply remains in the failure state without any further attempted restarts. The other three possible values are `reboot`, `reboot-force` and `reboot-immediate`. 

- `reboot` attempts a clean reboot, going through the usual, clean shutdown logic. 
- `reboot-force` is more abrupt: it will not actually try to cleanly shutdown any services, but immediately kills all remaining services and unmounts all file systems and then forcibly reboots (this way all file systems will be clean but reboot will still be very fast). 
- `reboot-immediate` does not attempt to kill any process or unmount any file systems. Instead it just hard reboots the machine without delay. `reboot-immediate` hence comes closest to a reboot triggered by a hardware watchdog. All these settings are documented in `systemd.service(5)`.

Putting this all together we now have pretty flexible options to watchdog-supervise a specific service and configure automatic restarts of the service if it hangs, plus take ultimate action if that doesn't help.

Here's an example unit file:

```ini
[Unit]
Description=My Little Daemon
Documentation=man:mylittled(8)

[Service]
ExecStart=/usr/bin/mylittled
WatchdogSec=30s
Restart=on-failure
StartLimitInterval=5min
StartLimitBurst=4
StartLimitAction=reboot-force
````

This service will automatically be restarted if it hasn't pinged the system manager for longer than 30s or if it fails otherwise. If it is restarted this way more often than 4 times in 5min action is taken and the system quickly rebooted, with all file systems being clean when it comes up again.

# Developing a watchdog 
To write the code of the watchdog service you can follow one of these guides:

- [Python based watchdog](#python-based-watchdog)
- [Bash based watchdog](https://www.medo64.com/2019/01/systemd-watchdog-for-any-service/)
## [Python based watchdog](https://sleeplessbeastie.eu/2022/08/15/how-to-create-watchdog-for-systemd-service/)

Check the steps under the [watchdog to monitor zfs](zfs.md#configure-a-watchdog) article.

# Testing watchdogs
## [Testing a hardware watchdog](https://serverfault.com/questions/375220/how-to-check-what-if-hardware-watchdogs-are-available-in-linux)
One simple way to test a watchdog is to trigger a kernel panic. This can be done as root with:

```bash
echo c > /proc/sysrq-trigger
```

The kernel will stop responding to the watchdog pings, so the watchdog will trigger.

SysRq is a 'magical' key combo you can hit which the kernel will respond to regardless of whatever else it is doing, unless it is completely locked up. It can also be used by echoing letters to /proc/sysrq-trigger, like we're doing here.

In this case, the letter c means perform a system crash and take a crashdump if configured.
# Monitoring a watchdog
## Monitoring a software watchdog

Check the steps under the [watchdog to monitor zfs](zfs.md#monitor-the-watchdog) article.
# Troubleshooting
## Watchdog hardware is disabled error on boot

According to the discussion at [the kernel mailing list](https://lore.kernel.org/linux-watchdog/20220509163304.86-1-mario.limonciello@amd.com/T/#u) it means that the system contains hardware watchdog but it has been disabled (probably by BIOS) and Linux cannot enable the hardware.

If your BIOS doesn't have a switch to enable it, consider the watchdog hardware broken for your system.

Some people are blacklisting the module so that it's not loaded and therefore it doesn't return the error ([1](https://www.reddit.com/r/openSUSE/comments/a3nmg5/watchdog_hardware_is_disabled_on_boot/), [2](https://bbs.archlinux.org/viewtopic.php?id=239075)
# References

- [0pointer post on systemd watchdogs](https://0pointer.de/blog/projects/watchdog.html)
- [Heckel post on how to reboot using watchdogs](https://blog.heckel.io/2020/10/08/reliably-rebooting-ubuntu-using-watchdogs/)
