---
title: rm
date: 20200219
author: Lyz
---

!!! quote "[rm definition](https://en.wikipedia.org/wiki/Rm_%28Unix%29)"
    In computing, rm (short for remove) is a basic command on Unix and Unix-like
    operating systems used to remove objects such as computer files, directories
    and symbolic links from file systems and also special files such as device
    nodes, pipes and sockets

# Debugging

## Cannot remove file: “Structure needs cleaning”

From [Victoria Stuart and Depressed Daniel answer](https://unix.stackexchange.com/questions/330742/cannot-remove-file-structure-needs-cleaning)

You first need to:

* Umount the partition.
* Do a sector level backup of your disk.
* If your filesystem is ext4 run:
  ```bash
  fsck.ext4 {{ device }}
  ```
  Accept all suggested fixes.

* Mount again the partition.
