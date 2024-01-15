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

## [Mount a dataset that is encrypted](https://unix.stackexchange.com/questions/730921/zfs-on-linux-how-to-import-an-encrypted-pool-if-you-dont-know-where-key-must-b)

If your dataset is encrypted using a key file you need to:

- Mount the device that has your keys
- Import the pool without loading the key because you want to override the keylocation attribute with zfs load-key. Without the -l option, any encrypted datasets won't be mounted, which is what you want.
- Load the key(s) for the dataset(s)
- Mount the dataset(s).

```bash
zpool import rpool    # without the `-l` option!
zfs load-key -L file:///path/to/keyfile rpool
zfs mount rpool
```

## [Umount a pool](https://superuser.com/questions/1542723/zfs-unmount-entire-pool)

```bash
zpool export pool-name
```

If you get an error of `pool or dataset is busy` run the next command to see which process is still running on the pool:

```bash
lsof 2>/dev/null | grep dataset-name
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

## [Get compress ratio of a filesystem](https://www.sotechdesign.com.au/zfs-how-to-check-compression-efficiency/)

```bash
zfs get compressratio {{ filesystem }}
```

## [Rename or move a dataset](https://docs.oracle.com/cd/E19253-01/819-5461/gamnq/index.html)

NOTE: if you want to rename the topmost dataset look at [rename the topmost dataset](#rename-the-topmost-dataset) instead.
File systems can be renamed by using the `zfs rename` command. You can perform the following operations:

- Change the name of a file system.
- Relocate the file system within the ZFS hierarchy.
- Change the name of a file system and relocate it within the ZFS hierarchy.

The following example uses the `rename` subcommand to rename of a file system from `kustarz` to `kustarz_old`:

```bash
zfs rename tank/home/kustarz tank/home/kustarz_old
```

The following example shows how to use zfs `rename` to relocate a file system:

```bash
zfs rename tank/home/maybee tank/ws/maybee
```

In this example, the `maybee` file system is relocated from `tank/home` to `tank/ws`. When you relocate a file system through rename, the new location must be within the same pool and it must have enough disk space to hold this new file system. If the new location does not have enough disk space, possibly because it has reached its quota, rename operation fails.

The rename operation attempts an unmount/remount sequence for the file system and any descendent file systems. The rename command fails if the operation is unable to unmount an active file system. If this problem occurs, you must forcibly unmount the file system.

You'll loose the snapshots though, as explained below.

### [Rename the topmost dataset](https://www.solaris-cookbook.eu/solaris/solaris-zpool-rename/)

If you want to rename the topmost dataset you [need to rename the pool too](https://github.com/openzfs/zfs/issues/4681) as these two are tied. 

```bash
$: zpool status -v

  pool: tets
 state: ONLINE
 scrub: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        tets        ONLINE       0     0     0
          c0d1      ONLINE       0     0     0
          c1d0      ONLINE       0     0     0
          c1d1      ONLINE       0     0     0

errors: No known data errors
```

To fix this, first export the pool:

```bash
$ zpool export tets
```

And then imported it with the correct name:

```bash
$ zpool import tets test
```

After the import completed, the pool contains the correct name:

```bash
$ zpool status -v

  pool: test
 state: ONLINE
 scrub: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        test        ONLINE       0     0     0
          c0d1      ONLINE       0     0     0
          c1d0      ONLINE       0     0     0
          c1d1      ONLINE       0     0     0

errors: No known data errors
```

Now you may need to fix the ZFS mountpoints for each dataset

```bash
zfs set mountpoint="/opt/zones/[Newmountpoint]" [ZFSPOOL/[ROOTor other filesystem]
```

## [Rename or move snapshots](https://docs.oracle.com/cd/E19253-01/819-5461/gbion/index.html)

If the dataset has snapshots you need to rename them too. They must be renamed within the same pool and dataset from which they were created though. For example:

```bash
zfs rename tank/home/cindys@083006 tank/home/cindys@today
```

In addition, the following shortcut syntax is equivalent to the preceding syntax:

```bash
zfs rename tank/home/cindys@083006 today
```

The following snapshot rename operation is not supported because the target pool and file system name are different from the pool and file system where the snapshot was created:

```bash
$: zfs rename tank/home/cindys@today pool/home/cindys@saturday
cannot rename to 'pool/home/cindys@today': snapshots must be part of same 
dataset
```

You can recursively rename snapshots by using the `zfs rename -r` command. For example:

```bash
$: zfs list
NAME                         USED  AVAIL  REFER  MOUNTPOINT
users                        270K  16.5G    22K  /users
users/home                    76K  16.5G    22K  /users/home
users/home@yesterday            0      -    22K  -
users/home/markm              18K  16.5G    18K  /users/home/markm
users/home/markm@yesterday      0      -    18K  -
users/home/marks              18K  16.5G    18K  /users/home/marks
users/home/marks@yesterday      0      -    18K  -
users/home/neil               18K  16.5G    18K  /users/home/neil
users/home/neil@yesterday       0      -    18K  -
$: zfs rename -r users/home@yesterday @2daysago
$: zfs list -r users/home
NAME                        USED  AVAIL  REFER  MOUNTPOINT
users/home                   76K  16.5G    22K  /users/home
users/home@2daysago            0      -    22K  -
users/home/markm             18K  16.5G    18K  /users/home/markm
users/home/markm@2daysago      0      -    18K  -
users/home/marks             18K  16.5G    18K  /users/home/marks
users/home/marks@2daysago      0      -    18K  -
users/home/neil              18K  16.5G    18K  /users/home/neil
users/home/neil@2daysago       0      -    18K  -
```

## [Repair a DEGRADED pool](https://blog.cavelab.dev/2021/01/zfs-replace-disk-expand-pool/)

First you need to make sure that it is in fact a problem of the disk. Check the `dmesg` to see if there are any traces of reading errors, or SATA cable errors. 

A friend suggested to mark the disk as healthy and do a resilver on the same disk. If the error is reproduced in the next days, then replace the disk. A safer approach is to resilver on a new disk, analyze the disk when it's not connected to the pool, and if you feel it's safe then save it as a cold spare.

### Replacing a disk in the pool

If you are going to replace the disk, you need to bring offline the device to be replaced:

```bash
zpool offline tank0 ata-WDC_WD2003FZEX-00SRLA0_WD-xxxxxxxxxxxx
```

Now let us have a look at the pool status.

```bash
zpool status

NAME                                            STATE     READ WRITE CKSUM
tank0                                           DEGRADED     0     0     0
  raidz2-1                                      DEGRADED     0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx            ONLINE       0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx            ONLINE       0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx            ONLINE       0     0     0
    ata-WDC_WD80EFZX-68UW8N0_xxxxxxxx           ONLINE       0     0     0
    ata-TOSHIBA_HDWG180_xxxxxxxxxxxx            ONLINE       0     0     0
    ata-TOSHIBA_HDWG180_xxxxxxxxxxxx            ONLINE       0     0     0
    ata-WDC_WD2003FZEX-00SRLA0_WD-xxxxxxxxxxxx  OFFLINE      0     0     0
    ata-ST4000VX007-2DT166_xxxxxxxx             ONLINE       0     0     0
```

Sweet, the device is offline (last time it didn't show as offline for me, but the offline command returned a status code of 0). 

Time to shut the server down and physically replace the disk.

```bash
shutdown -h now
```

When you start again the server, it’s time to instruct ZFS to replace the removed device with the disk we just installed.

```bash
zpool replace tank0 \
    ata-WDC_WD2003FZEX-00SRLA0_WD-xxxxxxxxxxxx \
    /dev/disk/by-id/ata-TOSHIBA_HDWG180_xxxxxxxxxxxx
```

```bash
zpool status tank0

pool: main
state: DEGRADED
status: One or more devices is currently being resilvered.  The pool will
        continue to function, possibly in a degraded state.
action: Wait for the resilver to complete.
  scan: resilver in progress since Fri Sep 22 12:40:28 2023
        4.00T scanned at 6.85G/s, 222G issued at 380M/s, 24.3T total
        54.7G resilvered, 0.89% done, 18:28:03 to go
NAME                                              STATE     READ WRITE CKSUM
tank0                                             DEGRADED     0     0     0
  raidz2-1                                        DEGRADED     0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx              ONLINE       0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx              ONLINE       0     0     0
    ata-TOSHIBA_HDWN180_xxxxxxxxxxxx              ONLINE       0     0     0
    ata-WDC_WD80EFZX-68UW8N0_xxxxxxxx             ONLINE       0     0     0
    ata-TOSHIBA_HDWG180_xxxxxxxxxxxx              ONLINE       0     0     0
    ata-TOSHIBA_HDWG180_xxxxxxxxxxxx              ONLINE       0     0     0
    replacing-6                                   DEGRADED     0     0     0
      ata-WDC_WD2003FZEX-00SRLA0_WD-xxxxxxxxxxxx  OFFLINE      0     0     0
      ata-TOSHIBA_HDWG180_xxxxxxxxxxxx            ONLINE       0     0     0  (resilvering)
    ata-ST4000VX007-2DT166_xxxxxxxx               ONLINE       0     0     0
```

The disk is replaced and getting resilvered (which may take a long time to run (18 hours in a 8TB disk in my case).

Once the resilvering is done; this is what the pool looks like.

```bash
zpool list

NAME      SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
tank0    43.5T  33.0T  10.5T     14.5T     7%    75%  1.00x  ONLINE  -
```

If you want to read other blogs that have covered the same topic check out [1](https://madaboutbrighton.net/articles/replace-disk-in-zfs-pool).

### Check the health of the degraded disk

Follow [these instructions](hard_drive_health.md#check-the-disk-health).

### RMA the degraded disk

Follow [these instructions](hard_drive_health.md#check-the-warranty-status).

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
* `/dev/sda /dev/sdb /dev/sdc /dev/sdd` are the rotational data disks configured in RAIDZ1
* We set two partitions in mirror for the ZLOG
* We set two partitions in stripe for the L2ARC

If you don't want the main pool to be mounted use `zfs set mountpoint=none main`.

If you don't want replication use `zpool create main sde sdf sdg`

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

If you want to use a passphrase instead [you can use the `zfs create -o encryption=on -o keylocation=prompt -o keyformat=passphrase` command.

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

### [Remove all snapshots of a dataset](https://serverfault.com/questions/340837/how-to-delete-all-but-last-n-zfs-snapshots)

```bash
zfs list -t snapshot -o name path/to/dataset | tail -n+2 | tac | xargs -n 1 zfs destroy -r
```

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

## [See how much space do your snapshots consume](https://www.thegeekdiary.com/how-to-find-the-space-consumed-by-zfs-snapshots/)

When a snapshot is created, its space is initially shared between the snapshot and the file system, and possibly with previous snapshots. As the file system changes, space that was previously shared becomes unique to the snapshot, and thus is counted in the snapshot’s `used` property.

Additionally, deleting snapshots can increase the amount of space that is unique for use by other snapshots.

Note: The value for a snapshot’s space referenced property is the same as that for the file system when the snapshot was created.

You can display the amount of space or size that is consumed by snapshots and descendant file systems by using the `zfs list -o space` command.

```bash
# zfs list -o space -r rpool
NAME                             AVAIL   USED  USEDSNAP  USEDDS  USEDREFRESERV  USEDCHILD
rpool                            10.2G  5.16G         0   4.52M              0      5.15G
rpool/ROOT                       10.2G  3.06G         0     31K              0      3.06G
rpool/ROOT/solaris               10.2G  3.06G     55.0M   2.78G              0       224M
rpool/ROOT/solaris@install           -  55.0M         -       -              -          -
rpool/ROOT/solaris/var           10.2G   224M     2.51M    221M              0          0
rpool/ROOT/solaris/var@install       -  2.51M         -       -              -          -
```

From this output, you can see the amount of space that is:

* AVAIL: The amount of space available to the dataset and all its children, assuming that there is no other activity in the pool. 
* USED: The amount of space consumed by this dataset and all its descendants. This is the value that is checked against this dataset's quota and reservation. The space used does not include this dataset's reservation, but does take into account the reservations of any descendants datasets.
    
    The used space of a snapshot is the space referenced exclusively by this snapshot. If this snapshot is destroyed, the amount of `used` space will be freed. Space that is shared by multiple snapshots isn't accounted for in this metric. 
* USEDSNAP: Space being consumed by snapshots of each data set
* USEDDS: Space being used by the dataset itself
* USEDREFRESERV: Space being used by a refreservation set on the dataset that would be freed if it was removed.
* USEDCHILD: Space being used by the children of this dataset.

Other space properties are:

* LUSED: The amount of space that is "logically" consumed by this dataset and all its descendents. It ignores the effect of `compression` and `copies` properties, giving a quantity closer to the amount of data that aplication ssee. However it does include space consumed by metadata.
* REFER: The amount of data that is accessible by this dataset, which may or may not be shared with other dataserts in the pool. When a snapshot or clone is created, it initially references the same amount of space as the filesystem or snapshot it was created from, since its contents are identical.

## [See the differences between two backups](https://docs.oracle.com/cd/E36784_01/html/E36835/gkkqz.html)

To identify the differences between two snapshots, use syntax similar to the following:

```bash
$ zfs diff tank/home/tim@snap1 tank/home/tim@snap2
M       /tank/home/tim/
+       /tank/home/tim/fileB
```

The following table summarizes the file or directory changes that are identified by the `zfs diff` command.

| File or Directory Change | Identifier | 
| --- | --- |
| File or directory has been modified or file or directory link has changed | M |
| File or directory is present in the older snapshot but not in the more recent snapshot | — |
| File or directory is present in the more recent snapshot but not in the older snapshot | + |
| File or directory has been renamed | R |

## Create a cold backup of a series of datasets

If you've used the `-o keyformat=raw -o keylocation=file:///etc/zfs/keys/home.key` arguments to encrypt your datasets you can't use a `keyformat=passphase` encryption on the cold storage device. You need to copy those keys on the disk. One way of doing it is to:

- Create a 100M LUKS partition protected with a passphrase where you store the keys.
  
- The rest of the space is left for a partition for the zpool.

WARNING: substitute `/dev/sde` for the partition you need to work on in the next snippets

To do it:
- Create the partitions: 

  ```bash
  fdisk /dev/sde
  n
  +100M
  n
  w
  ```

- Create the zpool

  ```bash
  zpool create cold-backup-01 /dev/sde2
  ```

# Troubleshooting

## [Clear a permanent ZFS error in a healthy pool](https://serverfault.com/questions/576898/clear-a-permanent-zfs-error-in-a-healthy-pool)

Sometimes when you do a `zpool status` you may see that the pool is healthy but that there are "Permanent errors" that may point to files themselves or directly to memory locations.

You can read [this long discussion](https://github.com/openzfs/zfs/discussions/9705) on what does these permanent errors mean, but what solved the issue for me was to run a new scrub

`zpool scrub my_pool`

It takes a long time to run, so be patient.

If you want [to stop a scrub](https://sotechdesign.com.au/zfs-stopping-a-scrub/) run:

```bash
zpool scrub -s my_pool
```

## ZFS pool is in suspended mode

Probably because you've unplugged a device without unmounting it.

If you want to remount the device [you can follow these steps](https://github.com/openzfsonosx/zfs/issues/104#issuecomment-30344347) to symlink the new devfs entries to where zfs thinks the vdev is. That way you can regain access to the pool without a reboot.

So if zpool status says the vdev is /dev/disk2s1, but the reattached drive is at disk4, then do the following:

```bash
cd /dev
sudo rm -f disk2s1
sudo ln -s disk4s1 disk2s1
sudo zpool clear -F WD_1TB
sudo zpool export WD_1TB
sudo rm disk2s1
sudo zpool import WD_1TB
```

If you don't care about the zpool anymore, sadly your only solution is to [reboot the server](https://github.com/openzfs/zfs/issues/5242). Real ugly, so be careful when you umount zpools.

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
