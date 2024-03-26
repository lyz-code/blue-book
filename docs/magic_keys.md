---
Title: Docs for Magic Keys
Author: Lyz
Date: 20170417
Keywords: magic keys
          rescue
          freeze
          kernel panic
Tags: publish
---

The magic SysRq key is a key combination understood by the Linux kernel, which
allows the user to perform various low-level commands regardless of the system's
state. It is often used to recover from freezes, or to reboot a computer without
corrupting the filesystem.[1] Its effect is similar to the computer's hardware
reset button (or power switch) but with many more options and much more control.

This key combination provides access to powerful features for software
development and disaster recovery. In this sense, it can be considered a form of
escape sequence. Principal among the offered commands are means to forcibly
unmount file systems, kill processes, recover keyboard state, and write
unwritten data to disk. With respect to these tasks, this feature serves as
a tool of last resort.

The magic SysRq key cannot work under certain conditions, such as a kernel
panic[2] or a hardware failure preventing the kernel from running properly.

The key combination consists of Alt+Sys Req and another key, which controls the
command issued.

On some devices, notably laptops, the Fn key may need to be pressed to use the
magic SysRq key.

# Reboot the machine

A common use of the magic SysRq key is to perform a safe reboot of a Linux
computer which has otherwise locked up (abbr. REISUB). This can prevent a fsck
being required on reboot and gives some programs a chance to save emergency
backups of unsaved work. The QWERTY (or AZERTY) mnemonics: "Raising Elephants Is
So Utterly Boring", "Reboot Even If System Utterly Broken" or simply the word
"BUSIER" read backwards, are often used to remember the following SysRq-keys
sequence:

* unRaw      (take control of keyboard back from X),
*  tErminate (send SIGTERM to all processes, allowing them to terminate gracefully),
*  kIll      (send SIGKILL to all processes, forcing them to terminate immediately),
*   Sync     (flush data to disk),
*   Unmount  (remount all filesystems read-only),
* reBoot.

When magic SysRq keys are used to kill a frozen graphical program, the program
has no chance to restore text mode. This can make everything unreadable. The
commands textmode (part of SVGAlib) and the reset command can restore text mode
and make the console readable again.

On distributions that do not include a textmode executable, the key command
Ctrl+Alt+F1 may sometimes be able to force a return to a text console. (Use F1,
F2, F3,..., F(n), where n is the highest number of text consoles set up by the
distribution. Ctrl+Alt+F(n+1) would normally be used to reenter GUI mode on
a system on which the X server has not crashed.)

# [Interact with the sysrq through the commandline](https://unix.stackexchange.com/questions/714910/what-is-a-good-way-to-test-watchdog-script-or-command-to-deliberately-overload)
It can also be used by echoing letters to `/proc/sysrq-trigger`, for example to trigger a system crash and take a crashdump you can:

```bash 
echo c > /proc/sysrq-trigger
```
