---
title: ZFS
date: 20201029
author: Lyz
---

[ZFS](https://en.wikipedia.org/wiki/ZFS) combines a file system with a volume manager.

# Usage

## Mount a pool as readonly

```bash
zpool import -o readonly=on {{ pool_name }}
```

## Mount a ZFS snapshot in a directory as readonly

```bash
mount -t zfs {{ pool_name }}/{{ snapshot_name }} {{ mount_path }} -o ro
```

## List volumes

```bash
zpool list
```

## List snapshots

```bash
zfs list -t snapshot
```

## Get read and write stats from pool

```bash
zpool iostat {{ pool_name }} {{ refresh_time_in_seconds }}
```
