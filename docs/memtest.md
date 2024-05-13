[memtest86](https://www.memtest86.com/) is a testing software for RAM.

# Installation
```bash
apt-get install memtest86+
```

After the installation you'll get Memtest entries in grub which you can spawn. 

For some unknown reason the memtest of the boot menu didn't work for me. So I [downloaded the latest free version of memtest](https://www.memtest86.com/download.htm) (It's at the bottom of the screen), burnt it in a usb and booted from there.

# Usage
It will run by itself. For 64GB of ECC RAM it took aproximately 100 minutes to run all the tests.

## [Check ECC errors](https://www.memtest86.com/ecc.htm)
MemTest86 directly polls ECC errors logged in the chipset/memory controller registers and displays it to the user on-screen. In addition, ECC errors are written to the log and report file.
\n\n[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
