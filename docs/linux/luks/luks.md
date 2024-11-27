---
title: LUKS
date: 20200219
author: Lyz
---

!!! quote "[LUKS definition](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup)"
    The Linux Unified Key Setup (LUKS) is a disk encryption specification
    created by Clemens Fruhwirth in 2004 and was originally intended for Linux.

    While most disk encryption software implements different, incompatible, and
    undocumented formats, LUKS implements a platform-independent standard
    on-disk format for use in various tools. This not only facilitates
    compatibility and interoperability among different programs, but also
    assures that they all implement password management in a secure and
    documented manner.

    The reference implementation for LUKS operates on Linux and is based on an
    enhanced version of cryptsetup, using dm-crypt as the disk encryption
    backend.

    LUKS is designed to conform to the TKS1 secure key setup scheme.

# LUKS Commands

We use the `cryptsetup` command to interact with LUKS partitions.

## Header management

### Get the disk header

```bash
cryptsetup luksDump /dev/sda3
```

### Backup header

```bash
cryptsetup luksHeaderBackup --header-backup-file {{ file }} {{ device }}
```

## Key management

### Add a key

```bash
cryptsetup luksAddKey --key-slot 1 {{ luks_device }}
```

### Change a key

```bash
cryptsetup luksChangeKey {{ luks_device }} -s 0
```

### Test if you remember the key

Try to add a new key and cancel the process

```bash
cryptsetup luksAddKey --key-slot 3 {{ luks_device }}
```

### Delete some keys

```bash
cryptsetup luksDump {{ device }}
cryptsetup luksKillSlot {{ device }} {{ slot_number }}
```

### Delete all keys

```bash
cryptsetup luksErase {{ device }}
```

## Encrypt hard drive

* Configure LUKS partition

  ```bash
  cryptsetup -y -v luksFormat /dev/sdg
  ```

* Open the container

  ```bash
  cryptsetup luksOpen /dev/sdg crypt
  ```

* Fill it with zeros

  ```bash
  pv -tpreb /dev/zero | dd of=/dev/mapper/crypt bs=128M
  ```

* Make filesystem
  ```bash
  mkfs.ext4 /dev/mapper/crypt
  ```

## Break a luks password

You can use [`bruteforce-luks`](https://github.com/glv2/bruteforce-luks)

# LUKS debugging

## Resource busy

* Umount the lv first

  ```bash
  lvscan
  lvchange -a n {{ partition_name }}
  ```

* Then close the luks device

  ```bash
  cryptsetup luksClose {{ device_name }}
  ```
