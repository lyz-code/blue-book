---
title: ZFS
date: 20201029
author: Lyz
---

[OpenZFS](https://en.wikipedia.org/wiki/ZFS) is a file system with volume
management capabilities designed specifically for storage servers.

Some neat features of ZFS include:

- Aggregating multiple physical disks into a single filesystem.
- Automatically repairing data corruption.
- Creating point-in-time snapshots of data on disk.
- Optionally encrypting or compressing data on disk.

# Usage

## Mount a pool as readonly

```bash
zpool import -o readonly=on {{ pool_name }}
```

## Mount a ZFS snapshot in a directory as readonly

```bash
mount -t zfs {{ pool_name }}/{{ snapshot_name }} {{ mount_path }} -o ro
```

## List pools

```bash
zpool list
```

## List the filesystems

```bash
zfs list
```

## Get read and write stats from pool

```bash
zpool iostat -v {{ pool_name }} {{ refresh_time_in_seconds }}
```

## Get all properties of a pool

```bash
zpool get all {{ pool_name }}
```

## Get all properties of a filesystem

```bash
zfs get all {{ pool_name }}
```

# Installation

## Install the required programs

OpenZFS is not in the mainline kernel for license issues (fucking capitalism...) so it's not yet suggested to use it for the root of your filesystem. 

To install it in a Debian device:

* ZFS packages are included in the `contrib` repository, but the `backports` repository often provides newer releases of ZFS. You can use it as follows.
  
  Add the backports repository:

  ```bash
  vi /etc/apt/sources.list.d/bullseye-backports.list
  ```

  ```
  deb http://deb.debian.org/debian bullseye-backports main contrib
  deb-src http://deb.debian.org/debian bullseye-backports main contrib
  ```

  ```bash
  vi /etc/apt/preferences.d/90_zfs
  ```

  ```
  Package: src:zfs-linux
  Pin: release n=bullseye-backports
  Pin-Priority: 990
  ```

* Install the packages:

```bash
apt update
apt install dpkg-dev linux-headers-generic linux-image-generic
apt install zfs-dkms zfsutils-linux
```

BE CAREFUL: if root doesn't have `sbin` in the `PATH` you will get an error of loading the zfs module as it's not signed. If this happens to you reinstall or try the debugging I did (which didn't work).

## [Create your pool](https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/)

First read the [ZFS storage planning](zfs_storage_planning.md) article and then create your `main` pool with a command similar to:

```bash
zpool create \
  -o ashift=12 \ 
  -o autoexpand=on \ 
  -o compression=lz4 \
main raidz /dev/sda /dev/sdb /dev/sdc /dev/sdd \
  log mirror \
    /dev/disk/by-id/nvme-eui.e823gqkwadgp32uhtpobsodkjfl2k9d0-part4 \
    /dev/disk/by-id/nvme-eui.a0sdgohosdfjlkgjwoqkegdkjfl2k9d0-part4 \
  cache \
    /dev/disk/by-id/nvme-eui.e823gqkwadgp32uhtpobsodkjfl2k9d0-part5 \
    /dev/disk/by-id/nvme-eui.a0sdgohosdfjlkgjwoqkegdkjfl2k9d0-part5 \
```

Where:

* `-o ashift=12`: Adjusts the disk sector size to the disks in use.
* `-o canmount=off`:  Don't mount the main pool, we'll mount the filesystems.
* `-o compression=lz4`: Enable compression by default
* `/dev/sda /dev/sdb /dev/sdc /dev/sdd` are the rotational data disks configured in RAIDZ1
* We set two partitions in mirror for the ZLOG
* We set two partitions in stripe for the L2ARC

If you don't want the main pool to be mounted use `zfs set mountpoint=none main`.

## [Create your filesystems](https://pthree.org/2012/12/17/zfs-administration-part-x-creating-filesystems/)

Once we have the pool you can create the different filesystems. If you want to use encryption with a key follow the next steps:

```bash
mkdir /etc/zfs/keys
chmod 700 /etc/zfs/keys
dd if=/dev/random of=/etc/zfs/keys/home.key bs=1 count=32
```

Then create the filesystem:

```bash
zfs create \ 
  -o mountpoint=/home/lyz \
  -o encryption=on \
  -o keyformat=raw \
  -o keylocation=file:///etc/zfs/keys/home.key \
  main/lyz
```

I'm assuming that `compression` was set in the pool.

You can check the created filesystems with `zfs list`

## Enable the autoloading of datasets on boot

It is possible to automatically unlock a pool dataset on boot time by using a systemd unit. For example create the following service to unlock any specific dataset:

```
/etc/systemd/system/zfs-load-key.service
```

```
[Unit]
Description=Load encryption keys
DefaultDependencies=no
After=zfs-import.target
Before=zfs-mount.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/zfs load-key -a
StandardInput=tty-force

[Install]
WantedBy=zfs-mount.service
```

```bash
systemctl start zfs-load-key.service
systemctl enable zfs-load-key.service
reboot
```

# [Configure NFS](https://pthree.org/2012/12/31/zfs-administration-part-xv-iscsi-nfs-and-samba/)

With ZFS you can share a specific dataset via NFS. If for whatever reason the dataset does not mount, then the export will not be available to the application, and the NFS client will be blocked.

You still must install the necessary daemon software to make the share available. For example, if you wish to share a dataset via NFS, then you need to install the NFS server software, and it must be running. Then, all you need to do is flip the sharing NFS switch on the dataset, and it will be immediately available.

## Install NFS 

To share a dataset via NFS, you first need to make sure the NFS daemon is running. On Debian and Ubuntu, this is the `nfs-kernel-server` package. 

```bash
sudo apt-get install nfs-kernel-server
```

Further, with Debian and Ubuntu, the NFS daemon will not start unless there is an export in the `/etc/exports` file. So, you have two options: you can create a dummy export, only available to localhost, or you can edit the init script to start without checking for a current export. I prefer the former. Let's get that setup:

```bash
echo '/tmp localhost(ro)' >> /etc/exports
$ sudo /etc/init.d/nfs-kernel-server start
$ showmount -e hostname.example.com
Export list for hostname.example.com:
/mnt localhost
```

With our NFS daemon running, we can now start sharing ZFS datasets. The `sharenfs` property can be `on`, `off` or `opts`, where `opts` are valid NFS export options. So, if you want to share the `pool/srv` dataset, which is mounted to `/srv` to the `10.80.86.0/24` network you could run:

```bash
# zfs set sharenfs="rw=@10.80.86.0/24" pool/srv
# zfs share pool/srv
# showmount -e hostname.example.com
Export list for hostname.example.com:
/srv 10.80.86.0/24
/mnt localhost
```

If you need to share to multiple subnets, you would do something like:

```bash
sudo zfs set sharenfs="rw=@192.168.0.0/24,rw=@10.0.0.0/24" pool-name/dataset-name
```

If you need `root` to be able to write to the directory [enable the `no_root_squash` NFS option](https://serverfault.com/questions/611007/unable-to-write-to-mount-point-nfs-server-getting-permission-denied)

> root_squash — Prevents root users connected remotely from having root privileges and assigns them the user ID for the user nfsnobody. This effectively "squashes" the power of the remote root user to the lowest local user, preventing unauthorized alteration of files on the remote server. Alternatively, the no_root_squash option turns off root squashing. To squash every remote user, including root, use the all_squash option. To specify the user and group IDs to use with remote users from a particular host, use the anonuid and anongid options, respectively. In this case, a special user account can be created for remote NFS users to share and specify (anonuid=,anongid=), where is the user ID number and is the group ID number.

You should now be able to mount the NFS export from an NFS client. Install the client with:

```bash
sudo apt-get install nfs-common
```

And then mount it with:

```bash
mount -t nfs hostname.example.com:/srv /mnt
```

To permanently mount it you need to add it to your `/etc/fstab`, check [this section for more details](linux_snippets.md#configure-fstab-to-mount-nfs).

# Backup

Please remember that [RAID is not a backup](https://serverfault.com/questions/2888/why-is-raid-not-a-backup), it guards against one kind of hardware failure. There's lots of failure modes that it doesn't guard against though:

* File corruption
* Human error (deleting files by mistake)
* Catastrophic damage (someone dumps water onto the server)
* Viruses and other malware
* Software bugs that wipe out data
* Hardware problems that wipe out data or cause hardware damage (controller malfunctions, firmware bugs, voltage spikes, ...)

That's why you still need to make backups.

ZFS has the builtin feature to make snapshots of the pool. A snapshot is a first class read-only filesystem. It is a mirrored copy of the state of the filesystem at the time you took the snapshot. They are persistent across reboots, and they don't require any additional backing store; they use the same storage pool as the rest of your data. 

If you remember [ZFS's awesome nature of copy-on-write](https://pthree.org/2012/12/14/zfs-administration-part-ix-copy-on-write/) filesystems, you will remember the discussion about Merkle trees. A ZFS snapshot is a copy of the Merkle tree in that state, except we make sure that the snapshot of that Merkle tree is never modified.

Creating snapshots is near instantaneous, and they are cheap. However, once the data begins to change, the snapshot will begin storing data. If you have multiple snapshots, then multiple deltas will be tracked across all the snapshots. However, depending on your needs, snapshots can still be exceptionally cheap.

## ZFS snapshot lifecycle management

ZFS doesn't though have a clean way to manage the lifecycle of those snapshots. There are many tools to fill the gap:

* [`sanoid`](sanoid.md): Made in Perl, 2.4k stars, last commit April 2022, last release April 2021
* [zfs-auto-snapshot](https://github.com/zfsonlinux/zfs-auto-snapshot): Made in Bash, 767 stars, last commit/release on September 2019
* [pyznap](https://github.com/yboetz/pyznap): Made in Python, 176 stars, last commit/release on September 2020
* Custom scripts.

It seems that the state of the art of ZFS backups is not changing too much in the last years, possibly because the functionality is covered so there is no need for further development. So I'm going to manage the backups with [`sanoid`](sanoid.md) despite it being done in Perl because [it's the most popular, it looks simple but flexible for complex cases, and it doesn't look I'd need to tweak the code](sanoid.md).

## [Restore a backup](https://pthree.org/2012/12/19/zfs-administration-part-xii-snapshots-and-clones/)

You can list the available snapshots of a filesystem with `zfs list -t snapshot {{ pool_or_filesystem_name }}`, if you don't specify the `pool_or_filesystem_name` it will show all available snapshots.

You have two ways to restore a backup:

* [Mount the snapshot in a directory and manually copy the needed files](https://askubuntu.com/questions/103369/ubuntu-how-to-mount-zfs-snapshot):

  ```bash
  mount -t zfs main/lyz@autosnap_2023-02-17_13:15:06_hourly /mnt
  ```

  To umount the snapshot run `umount /mnt`.

* Rolling back the filesystem to the snapshot state: Rolling back to a previous snapshot will discard any data changes between that snapshot and the current time. Further, by default, you can only rollback to the most recent snapshot. In order to rollback to an earlier snapshot, you must destroy all snapshots between the current time and that snapshot you wish to rollback to. If that's not enough, the filesystem must be unmounted before the rollback can begin. This means downtime.

  To rollback the "tank/test" dataset to the "tuesday" snapshot, we would issue:

  ```bash
  $: zfs rollback tank/test@tuesday
  cannot rollback to 'tank/test@tuesday': more recent snapshots exist
  use '-r' to force deletion of the following snapshots:
  tank/test@wednesday
  tank/test@thursday
  ```

  As expected, we must remove the `@wednesday` and `@thursday` snapshots before we can rollback to the `@tuesday` snapshot.

# Learning

I've found that learning about ZFS was an interesting, intense and time
consuming task. If you want a quick overview check
[this video](https://yewtu.be/watch?v=MsY-BafQgj4). If you prefer to read, head
to the awesome
[Aaron Toponce](https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)
articles and read all of them sequentially, each is a jewel. The
[docs](https://openzfs.github.io/openzfs-docs/) on the other hand are not that
pleasant to read. For further information check
[JRS articles](https://jrs-s.net/category/open-source/zfs/).

# Resources

- [Aaron Toponce articles](https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)
- [Docs](https://openzfs.github.io/openzfs-docs/)
- [JRS articles](https://jrs-s.net/category/open-source/zfs/)
- [ZFS basic introduction video](https://yewtu.be/watch?v=MsY-BafQgj4)
