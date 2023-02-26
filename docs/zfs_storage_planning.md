When you build a ZFS storage system you need to invest some time doing the [storage planning](https://mtlynch.io/budget-nas/#storage-planning).

There are many variables that affect the number and type of disks, you first
need to have an idea of what kind of data you want to store and what use are you
going to give to that data.

# Robustness

ZFS is designed to survive disk failures, so it stores each block of data
redundantly. This feature complicates capacity planning because your total
usable storage is not just the sum of each disk’s capacity.

ZFS creates filesystems out of “pools” of disks. The more disks in the pool, the
more efficiently ZFS can use their storage capacity. For example, if you give
ZFS two 10 TB drives, you can only use half of your total disk capacity. If you
instead use five 4 TB drives, ZFS gives you 14 TB of usable storage. Even though
your total disk space is the same in either scenario, the five smaller drives
give you 40% more usable space.

When you’re building a NAS server, you need to decide whether to use a smaller
quantity of large disks or a larger quantity of small disks. Smaller drives are
usually cheaper in terms of $/TB, but they’re more expensive to operate. Two 4
TB drives require twice the electricity of a single 8 TB drive.

Also keep in mind that so far ZFS doesn't let you add a new drive to an existing
vdev, but that
[feature is under active development](https://github.com/openzfs/zfs/pull/12225).
If you want to be safe, plan your vdev definition so that they don't need to
change the disk numbers.

## [Preventing concurrent disk failures](https://mtlynch.io/budget-nas/#preventing-concurrent-disk-failures)

Naively, the probability of two disks failing at once seems vanishingly small.
Based on
[Backblaze’s stats](https://www.backblaze.com/blog/backblaze-hard-drive-stats-for-2020/),
high-quality disk drives fail at 0.5-4% per year. A 4% risk per year is a 0.08%
chance in any given week. Two simultaneous failures would happen once every
30,000 years, so you should be fine, right?

The problem is that disks aren’t statistically independent. If one disk fails,
its neighbor has a substantially higher risk of dying. This is especially true
if the disks are the same model, from the same manufacturing batch, and
processed the same workloads.

Further, rebuilding a ZFS pool puts an unusual amount of strain on all of the
surviving disks. A disk that would have lasted a few more months under normal
usage might die under the additional load of a pool rebuild.

Given these risks, you can reduce the risk of concurrent disk failures by
choosing two different models of disk from two different manufacturers. To
reduce the chances of getting disks from the same manufacturing batch, you can
buy them from different vendors.

# Choosing the disks 

There are many things to take into account when choosing the different disks for your pool.

## Choosing the disks to hold data

Check [diskprices.com](https://www.diskprices.com) to get an idea of the cost of
disks in the market. If you can, try to avoid buying to Amazon as it's the
devil. Try to buy them from a local store instead, that way you interact with a
human and promote a local commerce.

Note: If you want a TL;DR you can jump to the
[conclusion](#data-disk-conclusion).

To choose your disks take into account:

- [Disk speed](#data-disk-speed)
- [Disk load](#data-disk-load)
- [Disk type](#data-disk-type)
- [Disk homogeneity](#data-disk-homogeneity)
- [Disk Warranty](#data-disk-warranty)
- [Disk Brands](#data-disk-brand)

### Data disk speed

When comes to disk speed there are three kinds, the slow (5400 RPM), normal
(7200 RPM) and fast (10k RPM).

The higher the RPM, the louder the disk is, the more heat it creates and the
more power it will consume. In exchange they will have higher writing and
reading speeds. Slower disks expand the lifecycle of the device, but in the case
of a failed disk in a RAID scenario, the rebuild time will be higher than on
faster ones therefore increasing the risk on concurrent failing disks.

Before choosing a high number of RPM make sure that it's your bottleneck, which
usually is the network if you're using a 1Gbps network. In this case a 10k RPM
disk won't offer better performance than a 7200 RPM, even a 7200 one won't be
better than a 5400.

The need of higher speeds can be fixed by using an SSD as a cache for reading
and writing.

### Data disk load

Disk specifications tell you the amount of TB/year they support, it gives you an
idea of the fault tolerance. Some examples

| Disk       | Fault tolerance (TB/year) |
| ---------- | ------------------------- |
| WD RED 8TB | 180                       |

### [Data disk type](https://www.howtogeek.com/345131/how-to-select-hard-drives-for-your-home-nas/)

It’s easy to think that all hard drives are equal, save for the form factor and
connection type. However, there’s a difference between the work your hard drive
does in your computer versus the workload of a [NAS](nas.md) hard drive. A drive
in your computer may only read and write data for a couple hours at a time,
while a NAS drive may read and write data for weeks on end, or even longer.

The environment inside of a NAS box is much different than a typical desktop or
laptop computer. When you pack in a handful of hard drives close together,
several things happen: there’s more vibration, more heat, and a lot more action
going on in general.

To cope with this, NAS hard drives usually have better vibration tolerance and
produce less heat than regular hard drives, thanks to slightly-slower spindle
speeds and reduced seek noise.

Most popular brands are Western Digital Red and Seagate IronWolf which use 5400
RPM, if you want to go on the 7200 RPM speeds you can buy the Pro version of
each. I initially tried checking
[Backblaze’s hard drive stats](https://www.backblaze.com/blog/backblaze-drive-stats-for-q2-2022/)
to avoid failure-prone disks, but they use drives on the pricier side.

The last pitfall to avoid is shingled magnetic recording (SMR) technology. ZFS
[performs poorly on SMR drives](https://www.servethehome.com/wd-red-smr-vs-cmr-tested-avoid-red-smr/),
so if you’re building a NAS, avoid
[known SMR drives](https://www.truenas.com/community/resources/list-of-known-smr-drives.141/).
If the drive is labeled as CMR, that’s conventional magnetic recording, which is
fine for ZFS.

SMR is well suited for high-capacity, low-cost use where writes are few and
reads are many. It has worse sustained write performance than CMR, which can
cause severe issues during resilvering or other write-intensive operations.

There are three types of SMR:

- Drive Managed, DM-SMR: It's opaque to the OS. This means ZFS cannot "target"
  writes, and is the worst type for ZFS use. As a rule of thumb, avoid DM-SMR
  drives, unless you have a specific use case where the increased resilver time
  (a week or longer) is acceptable, and you know the drive will function for ZFS
  during resilver.
- Host Aware, HA-SMR: It's designed to give ZFS insight into the SMR process.
  Note that ZFS code to use HA-SMR does not appear to exist. Without that code,
  a HA-SMR drive behaves like a DM-SMR drive where ZFS is concerned.
- Host Managed, HM-SMR: It's not backwards compatible and requires ZFS to manage
  the SMR process.

### Data disk homogeneity

It's recommended that all the disks in your pool (or is it by vdev?) have the
same RPM and size.

### Data disk warranty

Disks are going to fail, so it's good to have a good warranty to return them.

### [Data disk brands](https://www.nasmaster.com/best-nas-drives/)

#### [Western Digital](https://www.nasmaster.com/wd-red-vs-red-plus-vs-red-pro-nas-hdd/)

The Western Digital Red series of NAS drives are very similar to Seagate’s
offering and you should consider these if you can find them at more affordable
prices. WD splits its NAS drives into three sub-categories, normal, Plus, and
Pro.

| Specs                  | WD Red    | WD Red Plus        | WD Red Pro      |
| ---------------------- | --------- | ------------------ | --------------- |
| Technology             | SMR       | CMR                | CMR             |
| Bays                   | 1-8       | 1-8                | 1-24            |
| Capacity               | 2-6TB     | 1-14TB             | 2-18TB          |
| Speed                  | 5,400 RPM | 5,400 RPM (1-4TB)  | 7200 RPM        |
| Speed                  | 5,400 RPM | 5,640 RPM (6-8TB)  | 7200 RPM        |
| Speed                  | 5,400 RPM | 7,200 RPM (8-14TB) | 7200 RPM        |
| Speed                  | ?         | 210MB/s            | 235MB/s         |
| Cache                  | 256MB     | 16MB (1TB)         |                 |
| Cache                  | 256MB     | 64MB (1TB)         | 64MB (2TB)      |
| Cache                  | 256MB     | 128MB (2-8TB)      | 256MB (4-12TB)  |
| Cache                  | 256MB     | 256MB (8-12TB)     | 512MB (14-18TB) |
| Cache                  | 256MB     | 512MB (14TB)       |                 |
| Workload               | 180TB/yr  | 180TB/yr           | 300TB/yr        |
| MTBF                   | 1 million | 1 million          | 1 million       |
| Warranty               | 3 years   | 3 years            | 5 years         |
| Power Consumption      | ?         | ?                  | 8.8 W           |
| Power Consumption Rest | ?         | ?                  | 4.6 W           |
| Price                  | From $50  | From $45           | From $78        |

#### Seagate

Seagate's "cheap" NAS disks are the IronWolf gama, there are
[two variations IronWolf and IronWolf Pro](https://www.nasmaster.com/seagate-ironwolf-vs-seagate-ironwolf-pro/).
Seagate Exos is a premium series of drives from the company. They’re even more
advanced than IronWolf Pro and are best suited for server environments. They
sport incredible levels of performance and reliability, including a workload
rate of 550TB per year.

| Specs                        | IronWolf           | IronWolf Pro         | Exos 7E8 8TB | Exos 7E10 8TB |
| ---------------------------- | ------------------ | -------------------- | ------------ | ------------- |
| Technology                   | CMR                | CMR                  | CMR          | SMR           |
| Bays                         | 1-8                | 1-24                 | ?            | ?             |
| Capacity                     | 1-12TB             | 2-20TB               | 8TB          | 8TB           |
| RPM                          | 5,400 RPM (3-6TB)  | 7200 RPM             | 7200 RPM     | 7200 RPM      |
| RPM                          | 5,900 RPM (1-3TB)  | 7200 RPM             | 7200 RPM     | 7200 RPM      |
| RPM                          | 7,200 RPM (8-12TB) | 7200 RPM             | 7200 RPM     | 7200 RPM      |
| Speed                        | 180MB/s (1-12TB)   | 214-260MB/s (4-18TB) | 249 MB/s     | 255 MB/s      |
| Cache                        | 64MB (1-4TB)       | 256 MB               | 256 MB       | 256 MB        |
| Cache                        | 256MB (3-12TB)     | 256 MB               | 256 MB       | 256 MB        |
| Power Consumption (8TB)      | 10.1 W             | 10.1 W               | 12.81 W      | 11.03 W       |
| Power Consumption Rest (8TB) | 7.8 W              | 7.8 W                | 7.64 W       | 7.06 W        |
| Workload                     | 180TB/yr           | 300TB/yr             | 550TB/yr     | 550TB/yr      |
| MTBF                         | 1 million          | 1 million            | 2 millions   | 2 millions    |
| Warranty                     | 3 years            | 5 years              | 5 years      | 5 years       |
| Price                        | From $60           | From $83             | 249$         | 249$          |

Exos 7E10 is SMR so it's ruled out.

Where MTBF stands for Medium Time Between Failures in hours

### Data disk conclusion

I'm more interested on the 5400 RPM drives, but of all the NAS disks available
to purchase only the WD RED of 8TB use it, and they use the SMR technology, so
they aren't a choice.

The disk prices offered by my cheapest provider are:

| Disk                 | Size | Price |
| -------------------- | ---- | ----- |
| Seagate IronWolf     | 8TB  | 225$  |
| Seagate IronWolf Pro | 8TB  | 254$  |
| WD Red Plus          | 8TB  | 265$  |
| Seagate Exos 7E8     | 8TB  | 277$  |
| WD Red Pro           | 8TB  | 278$  |

WD Red Plus has 5,640 RPM which is different than the rest, so it's ruled out.
Between the IronWolf and IronWolf Pro, they offer 180MB/s and 214MB/s
respectively. The Seagate Exos 7E8 provides much better performance than the WD
Red Pro so I'm afraid that WD is out of the question.

There are three possibilities in order to have two different brands. Imagining
we want 4 disks:

| Combination             | Total Price        |
| ----------------------- | ------------------ |
| IronWolf + IronWolf Pro | 958$               |
| IronWolf + Exos 7E8     | 1004$ (+46$ +4.5%) |
| IronWolf Pro + Exos 7E8 | 1062$ (+54$ +5.4%) |

In terms of:

- Consumption: both IronWolfs are equal, the Exos uses 2.7W more on normal use
  and uses 0.2W less on rest.
- Warranty: IronWolf has only 3 years, the others 5.
- Speed: Ironwolf has 210MB/s, much less than the Pro (255MB/s) and Exos
  (249MB/s), which are more similar.
- Sostenibility: The Exos disks are much more robust (more workload, MTBF and
  Warranty).

I'd say that for 104$ it makes sense to go with the IronWolf Pro + Exos 7E8
combination.

## [Choosing the disks for the cache](https://www.nasmaster.com/best-m2-nvme-ssd-nas-caching/)

Using a ZLOG greatly improves the
[writing speed](https://www.servethehome.com/exploring-best-zfs-zil-slog-ssd-intel-optane-nand/),
equally using an SSD disk for the L2ARC cache improves the read speeds and
improves the health of the rotational disks.

The best M.2 NVMe SSD for NAS caching are the ones that have enough capacity to
actually make a difference to overall system performance. It also requires a
good endurance rating for better reliability and longer lifespan, and you should
look for a drive with a specific NAND technology if possible.

Note: If you want a TL;DR you can jump to the
[conclusion](#cache-disk-conclusion).

To choose your disks take into account:

- [Cache disk NAND technology](#cache-disk-nand-technology)
- [DWPD](#dwpd)

### Cache disk NAND technology

Not all flash-based storage drives are the same. NAND flash cells are usually
categorised based on the number of bits that can be stored per cell. Watch out
for the following terms when shopping around for an SSD:

- Single-Level Cell (SLC): one bit per cell.
- Multi-Level Cell (MLC): two bits per cell.
- Triple-Level Cell (TLC): three bits per cell.
- Quad-Level Cell (QLC): four bits per cell.

When looking for the best M.2 NVMe SSD for NAS data caching, it’s important to
bear the NAND technology in mind.

SLC is the best technology for SSDs that will be used for NAS caching. This does
mean you’re paying out more per GB and won’t be able to select high-capacity
drives, but reliability and the protection of stored data is the most important
factor here.

Another benefit of SLC is the lower impact of write amplification, which can
quickly creep up and chomp through a drive’s DWPD endurance rating. It’s
important to configure an SSD for caching correctly too regardless of which
technology you pick.

Doing so will lessen the likelihood of losing data through a drive hanging and
causing the system to crash. Anything stored on the cache drive that has yet to
be written to the main drive array would be lost. This is mostly a reported
issue for NVMe drives, as opposed to SATA.

### DWPD

DWPD stands for drive writes per day. This is often used as a measurement of a
drive’s endurance. The higher this number, the more writes the drive can perform
on a daily basis, as is rated by the manufacturer. For caching, especially which
involves writing data, you’ll want to aim for as high a DWPD rating as possible.

### Cache disk conclusion

Overall, I’d recommend the Western Digital Red SN700, which has a good 1 DWPD
endurance rating, is available in sizes up to 4TB, and is using SLC NAND
technology, which is great for enhancing reliability through heavy caching
workloads. A close second place goes to the Seagate IronWolf 525, which has
similar specifications to the SN700 but utilizes TLC.

| Disk            | Size   | Speed    | Endurance | Warranty | Tech | Price |
| --------------- | ------ | -------- | --------- | -------- | ---- | ----- |
| WD Red SN700    | 500 GB | 3430MB/s | 1 DWPD    | 5 years  | SLC  | 73$   |
| SG IronWolf 525 | 500 GB | 5000MB/s | 0.8 DWPD  | 5 years  | TLC  | ?     |
| WD Red SN700    | 1 TB   | 3430MB/s | 1 DWPD    | 5 years  | SLC  | 127$  |
| SG IronWolf 525 | 1 TB   | 5000MB/s | 0.8 DWPD  | 5 years  | TLC  | ?     |

## Choosing the cold spare disks

It's good to think how much time you want to have your raids to be inconsistent
once a drive has failed.

In my case, for the data I want to restore the raid as soon as I can, therefore
I'll buy another rotational disk. For the SSDs I have more confidence that they
won't break so I don't feel like having a spare one.

# Design your pools

## Pool configuration

* [Use `ashift=12` or `ashift=13`](https://wiki.debian.org/ZFS) when creating the pool if applicable (though ZFS can detect correctly for most cases). Value of `ashift` is exponent of 2, which should be aligned to the physical sector size of disks, for example `2^9=512`, `2^12=4096`, `2^13=8192`. Some disks are reporting a logical sector size of 512 bytes while having 4KiB physical sector size , and some SSDs have 8KiB physical sector size. 

  Consider using `ashift=12` or `ashift=13` even if currently using only disks with 512 bytes sectors. Adding devices with bigger sectors to the same VDEV can severely impact performance due to wrong alignment, while a device with 512 sectors will work also with a higher `ashift`. 

* Set "autoexpand" to on, so you can expand the storage pool automatically after all disks in the pool have been replaced with larger ones. Default is off.

## [ZIL or SLOG](https://pthree.org/2012/12/06/zfs-administration-part-iii-the-zfs-intent-log/)

Before we can begin, we need to get a few terms out of the way that seem to be confusing:

* ZFS Intent Log, or ZIL is a logging mechanism where all of the data to be the written is stored, then later flushed as a transactional write. Similar in function to a journal for journaled filesystems, like `ext3` or `ext4`. Typically stored on platter disk. Consists of a ZIL header, which points to a list of records, ZIL blocks and a ZIL trailer. The ZIL behaves differently for different writes. For writes smaller than 64KB (by default), the ZIL stores the write data. For writes larger, the write is not stored in the ZIL, and the ZIL maintains pointers to the synched data that is stored in the log record.
* Separate Intent Log, or SLOG, is a separate logging device that caches the synchronous parts of the ZIL before flushing them to slower disk. This would either be a battery-backed DRAM drive or a fast SSD. The SLOG only caches synchronous data, and does not cache asynchronous data. Asynchronous data will flush directly to spinning disk. Further, blocks are written a block-at-a-time, rather than as simultaneous transactions to the SLOG. If the SLOG exists, the ZIL will be moved to it rather than residing on platter disk. Everything in the SLOG will always be in system memory.

When you read online about people referring to "adding an SSD ZIL to the pool", they are meaning adding an SSD SLOG, of where the ZIL will reside. The ZIL is a subset of the SLOG in this case. The SLOG is the device, the ZIL is data on the device. Further, not all applications take advantage of the ZIL. Applications such as databases (MySQL, PostgreSQL, Oracle), NFS and iSCSI targets do use the ZIL. Typical copying of data around the filesystem will not use it. Lastly, the ZIL is generally never read, except at boot to see if there is a missing transaction. The ZIL is basically "write-only", and is very write-intensive.

It's important to use devices that can maintain data persistence during a power outage. The SLOG and the ZIL are critical in getting your data to spinning platter. If a power outage occurs, and you have a volatile SLOG, the worst thing that will happen is the new data is not flushed, and you are left with old data. However, it's important to note, that in the case of a power outage, you won't have corrupted data, just lost data. Your data will still be consistent on disk.

If you use a SLOG you will see improved disk latencies, disk utilization and system load. What you won't see is improved throughput. Remember that the SLOG device is still flushing data to platter every 5 seconds. As a result, benchmarking disk after adding a SLOG device doesn't make much sense, unless the goal of the benchmark is to test synchronous disk write latencies. Check [this article if you want to know more](http://pthree.org/2012/12/03/how-a-zil-improves-disk-latencies/).

### Adding a SLOG

WARNING: Some motherboards will not present disks in a consistent manner to the Linux kernel across reboots. As such, a disk identified as `/dev/sda` on one boot might be `/dev/sdb` on the next. For the main pool where your data is stored, this is not a problem as ZFS can reconstruct the VDEVs based on the metadata geometry. For your L2ARC and SLOG devices, however, no such metadata exists. So, rather than adding them to the pool by their `/dev/sd?` names, you should use the `/dev/disk/by-id/*` names, as these are symbolic pointers to the ever-changing `/dev/sd?` files. If you don't heed this warning, your SLOG device may not be added to your hybrid pool at all, and you will need to re-add it later. This could drastically affect the performance of the applications depending on the existence of a fast SLOG.

Adding a SLOG to your existing zpool is not difficult. However, it is considered best practice to mirror the SLOG. Suppose that there are 4 platter disks in the pool, and two NVME. 

First you need to create a partition of 5 GB on each the nvme drive:

```bash
fdisk -l
fdisk /dev/nvme0n1
fdisk /dev/nvme1n1
```

Then mirror the partitions as SLOG

```bash
zpool add tank log mirror \
/dev/disk/by-id/nvme0n1-part1 \
/dev/disk/by-id/nvme1n1-part1 
```

Check that it worked with
```bash
# zpool status
  pool: tank
 state: ONLINE
 scan: scrub repaired 0 in 1h8m with 0 errors on Sun Dec  2 01:08:26 2012
config:

        NAME               STATE     READ WRITE CKSUM
        pool               ONLINE       0     0     0
          raidz1-0         ONLINE       0     0     0
            sdd            ONLINE       0     0     0
            sde            ONLINE       0     0     0
            sdf            ONLINE       0     0     0
            sdg            ONLINE       0     0     0
        logs
          mirror-1         ONLINE       0     0     0
            nvme0n1-part1  ONLINE       0     0     0
            nvme0n1-part2  ONLINE       0     0     0
```

You will likely not need a large ZIL, take into account that zfs dumps it's contents quite often.

## [Adjustable Replacement Cache](https://pthree.org/2012/12/07/zfs-administration-part-iv-the-adjustable-replacement-cache/)

The ZFS adjustable replacement cache (ARC) is one such caching mechanism that caches both recent block requests as well as frequent block requests. 
It will occupy 1/2 of available RAM. However, this isn't static. If you have 32 GB of RAM in your server, this doesn't mean the cache will always be 16 GB. Rather, the total cache will adjust its size based on kernel decisions. If the kernel needs more RAM for a scheduled process, the ZFS ARC will be adjusted to make room for whatever the kernel needs. However, if there is space that the ZFS ARC can occupy, it will take it up.

The ARC can be extended using the level 2 ARC or L2ARC. This means that as the MRU (the most recently requested blocks from the filesystem) or MFU (the most frequently requested blocks from the filesystem) grow, they don't both simultaneously share the ARC in RAM and the L2ARC on your SSD. Instead, when a page is about to be evicted, a walking algorithm will evict the MRU and MFU pages into an 8 MB buffer, which is later set as an atomic write transaction to the L2ARC. The advantage is that the latency of evicting pages from the cache is not impacted. Further, if a large read of data blocks is sent to the cache, the blocks are evicted before the L2ARC walk, rather than sent to the L2ARC. This minimizes polluting the L2ARC with massive sequential reads. Filling the L2ARC can also be very slow, or very fast, depending on the access to your data.

Persistence in the L2ARC is not needed, as the cache will be wiped on boot. To learn more about the ZFS ARC read [1](https://pthree.org/2012/12/07/zfs-administration-part-iv-the-adjustable-replacement-cache/).

### Adding an L2ARC

First you need to create the partitions on each the nvme drive:

```bash
fdisk -l
fdisk /dev/nvme0n1
fdisk /dev/nvme1n1
```

It is recommended that you stripe the L2ARC to maximize both size and speed.

```bash
zpool add tank cache \
/dev/disk/by-id/nvme0n1-part2 \
/dev/disk/by-id/nvme1n1-part2 
```

Check that it worked with
```bash
# zpool status
  pool: tank
 state: ONLINE
 scan: scrub repaired 0 in 1h8m with 0 errors on Sun Dec  2 01:08:26 2012
config:

        NAME               STATE     READ WRITE CKSUM
        pool               ONLINE       0     0     0
          raidz1-0         ONLINE       0     0     0
            sdd            ONLINE       0     0     0
            sde            ONLINE       0     0     0
            sdf            ONLINE       0     0     0
            sdg            ONLINE       0     0     0
        cache
          nvme0n1-part1    ONLINE       0     0     0
          nvme0n1-part2    ONLINE       0     0     0
```

To check hte size of the L2ARC use `zpool iostat -v`.

## [Follow the best practices](https://pthree.org/2012/12/13/zfs-administration-part-viii-zpool-best-practices-and-caveats/)

As with all recommendations, some of these guidelines carry a great amount of weight, while others might not. You may not even be able to follow them as rigidly as you would like. Regardless, you should be aware of them. The idea of "best practices" is to optimize space efficiency, performance and ensure maximum data integrity.

* Keep pool capacity under 80% for best performance. Due to the copy-on-write nature of ZFS, the filesystem gets heavily fragmented.
* Only run ZFS on 64-bit kernels. It has 64-bit specific code that 32-bit kernels cannot do anything with.
* Install ZFS only on a system with lots of RAM. 1 GB is a bare minimum, 2 GB is better, 4 GB would be preferred to start. Remember, ZFS will use 1/2 of the available RAM for the ARC.
* Use ECC RAM when possible for scrubbing data in registers and maintaining data consistency. The ARC is an actual read-only data cache of valuable data in RAM.
* Use whole disks rather than partitions. ZFS can make better use of the on-disk cache as a result. If you must use partitions, backup the partition table, and take care when reinstalling data into the other partitions, so you don't corrupt the data in your pool.
* Keep each VDEV in a storage pool the same size. If VDEVs vary in size, ZFS will favor the larger VDEV, which could lead to performance bottlenecks.
* Use redundancy when possible, as ZFS can and will want to correct data errors that exist in the pool. You cannot fix these errors if you do not have a redundant good copy elsewhere in the pool. Mirrors and RAID-Z levels accomplish this.
* Do not use raidz1 for disks 1TB or greater in size.
* For raidz1, do not use less than 3 disks, nor more than 7 disks in each vdev 
* For raidz2, do not use less than 6 disks, nor more than 10 disks in each vdev (8 is a typical average).
* For raidz3, do not use less than 7 disks, nor more than 15 disks in each vdev (13 & 15 are typical average).
* Consider using RAIDZ-2 or RAIDZ-3 over RAIDZ-1. You've heard the phrase "when it rains, it pours". This is true for disk failures. If a disk fails in a RAIDZ-1, and the hot spare is getting resilvered, until the data is fully copied, you cannot afford another disk failure during the resilver, or you will suffer data loss. With RAIDZ-2, you can suffer two disk failures, instead of one, increasing the probability you have fully resilvered the necessary data before the second, and even third disk fails.
* Perform regular (at least weekly) backups of the full storage pool. It's not a backup, unless you have multiple copies. Just because you have redundant disk, does not ensure live running data in the event of a power failure, hardware failure or disconnected cables.
* Use hot spares to quickly recover from a damaged device. Set the "autoreplace" property to on for the pool.
* Consider using a hybrid storage pool with fast SSDs or NVRAM drives. Using a fast SLOG and L2ARC can greatly improve performance.
* If using a hybrid storage pool with multiple devices, mirror the SLOG and stripe the L2ARC.
* If using a hybrid storage pool, and partitioning the fast SSD or NVRAM drive, unless you know you will need it, 1 GB is likely sufficient for your SLOG. Use the rest of the SSD or NVRAM drive for the L2ARC. The more storage for the L2ARC, the better.
* If possible, scrub consumer-grade SATA and SCSI disks weekly and enterprise-grade SAS and FC disks monthly. Depending on a lot factors, this might not be possible, so your mileage may vary. But, you should scrub as frequently as possible, basically.
* Email reports of the storage pool health weekly for redundant arrays, and bi-weekly for non-redundant arrays.
* When using advanced format disks that read and write data in 4 KB sectors, set the "ashift" value to 12 on pool creation for maximum performance. Default is 9 for 512-byte sectors.
* Set "autoexpand" to on, so you can expand the storage pool automatically after all disks in the pool have been replaced with larger ones. Default is off.
* Always export your storage pool when moving the disks from one physical system to another.
* When considering performance, know that for sequential writes, mirrors will always outperform RAID-Z levels. For sequential reads, RAID-Z levels will perform more slowly than mirrors on smaller data blocks and faster on larger data blocks. For random reads and writes, mirrors and RAID-Z seem to perform in similar manners. Striped mirrors will outperform mirrors and RAID-Z in both sequential, and random reads and writes.
* Compression is disabled by default. This doesn't make much sense with today's hardware. ZFS compression is extremely cheap, extremely fast, and barely adds any latency to the reads and writes. In fact, in some scenarios, your disks will respond faster with compression enabled than disabled. A further benefit is the massive space benefits.
* Unless you have the RAM, avoid using deduplication. Unlike compression, deduplication is very costly on the system. The deduplication table consumes massive amounts of RAM.
* Avoid running a ZFS root filesystem on GNU/Linux for the time being. It's a bit too experimental for /boot and GRUB. However, do create datasets for /home/, /var/log/ and /var/cache/.
* Snapshot frequently and regularly. Snapshots are cheap, and can keep a plethora of file versions over time.
* Snapshots are not a backup. Use "zfs send" and "zfs receive" to send your ZFS snapshots to an external storage.
* If using NFS, use ZFS NFS rather than your native exports. This can ensure that the dataset is mounted and online before NFS clients begin sending data to the mountpoint.
* Don't mix NFS kernel exports and ZFS NFS exports. This is difficult to administer and maintain.
* For /home/ ZFS installations, setting up nested datasets for each user. For example, pool/home/atoponce and pool/home/dobbs. Consider using quotas on the datasets.
*  When using "zfs send" and "zfs receive", send incremental streams with the "zfs send -i" switch. This can be an exceptional time saver.
* Consider using "zfs send" over "rsync", as the "zfs send" command can preserve dataset properties.

There are some caveats though. The point of the caveat list is by no means to discourage you from using ZFS. Instead, as a storage administrator planning out your ZFS storage server, these are things that you should be aware of. If you don't head these warnings, you could end up with corrupted data. The line may be blurred with the "best practices" list above.

* Your VDEVs determine the IOPS of the storage, and the slowest disk in that VDEV will determine the IOPS for the entire VDEV.
* ZFS uses 1/64 of the available raw storage for metadata. So, if you purchased a 1 TB drive, the actual raw size is 976 GiB. After ZFS uses it, you will have 961 GiB of available space. The "zfs list" command will show an accurate representation of your available storage. Plan your storage keeping this in mind.
* ZFS wants to control the whole block stack. It checksums, resilvers live data instead of full disks, self-heals corrupted blocks, and a number of other unique features. If using a RAID card, make sure to configure it as a true JBOD (or "passthrough mode"), so ZFS can control the disks. If you can't do this with your RAID card, don't use it. Best to use a real HBA.
* Do not use other volume management software beneath ZFS. ZFS will perform better, and ensure greater data integrity, if it has control of the whole block device stack. As such, avoid using dm-crypt, mdadm or LVM beneath ZFS.
* Do not share a SLOG or L2ARC DEVICE across pools. Each pool should have its own physical DEVICE, not logical drive, as is the case with some PCI-Express SSD cards. Use the full card for one pool, and a different physical card for another pool. If you share a physical device, you will create race conditions, and could end up with corrupted data.
* Do not share a single storage pool across different servers. ZFS is not a clustered filesystem. Use GlusterFS, Ceph, Lustre or some other clustered filesystem on top of the pool if you wish to have a shared storage backend.
* Other than a spare, SLOG and L2ARC in your hybrid pool, do not mix VDEVs in a single pool. If one VDEV is a mirror, all VDEVs should be mirrors. If one VDEV is a RAIDZ-1, all VDEVs should be RAIDZ-1. Unless of course, you know what you are doing, and are willing to accept the consequences. ZFS attempts to balance the data across VDEVs. Having a VDEV of a different redundancy can lead to performance issues and space efficiency concerns, and make it very difficult to recover in the event of a failure.
* Do not mix disk sizes or speeds in a single VDEV. Do mix fabrication dates, however, to prevent mass drive failure.
* In fact, do not mix disk sizes or speeds in your storage pool at all.
* Do not mix disk counts across VDEVs. If one VDEV uses 4 drives, all VDEVs should use 4 drives.
* Do not put all the drives from a single controller in one VDEV. Plan your storage, such that if a controller fails, it affects only the number of disks necessary to keep the data online.
* When using advanced format disks, you must set the ashift value to 12 at pool creation. It cannot be changed after the fact. Use "zpool create -o ashift=12 tank mirror sda sdb" as an example.
* Hot spare disks will not be added to the VDEV to replace a failed drive by default. You MUST enable this feature. Set the autoreplace feature to on. Use "zpool set autoreplace=on tank" as an example.
 * The storage pool will not auto resize itself when all smaller drives in the pool have been replaced by larger ones. You MUST enable this feature, and you MUST enable it before replacing the first disk. Use "zpool set autoexpand=on tank" as an example.
* ZFS does not restripe data in a VDEV nor across multiple VDEVs. Typically, when adding a new device to a RAID array, the RAID controller will rebuild the data, by creating a new stripe width. This will free up some space on the drives in the pool, as it copies data to the new disk. ZFS has no such mechanism. Eventually, over time, the disks will balance out due to the writes, but even a scrub will not rebuild the stripe width.
* You cannot shrink a zpool, only grow it. This means you cannot remove VDEVs from a storage pool.
* You can only remove drives from mirrored VDEV using the "zpool detach" command. You can replace drives with another drive in RAIDZ and mirror VDEVs however.
* Do not create a storage pool of files or ZVOLs from an existing zpool. Race conditions will be present, and you will end up with corrupted data. Always keep multiple pools separate.
* The Linux kernel may not assign a drive the same drive letter at every boot. Thus, you should use the /dev/disk/by-id/ convention for your SLOG and L2ARC. If you don't, your zpool devices could end up as a SLOG device, which would in turn clobber your ZFS data.
* Don't create massive storage pools "just because you can". Even though ZFS can create 78-bit storage pool sizes, that doesn't mean you need to create one.
* Don't put production directly into the zpool. Use ZFS datasets instead.
* Don't commit production data to file VDEVs. Only use file VDEVs for testing scripts or learning the ins and outs of ZFS.
* A "zfs destroy" can cause downtime for other datasets. A "zfs destroy" will touch every file in the dataset that resides in the storage pool. The larger the dataset, the longer this will take, and it will use all the possible IOPS out of your drives to make it happen. Thus, if it take 2 hours to destroy the dataset, that's 2 hours of potential downtime for the other datasets in the pool.
* Debian and Ubuntu will not start the NFS daemon without a valid export in the /etc/exports file. You must either modify the /etc/init.d/nfs init script to start without an export, or create a local dummy export.
* When creating ZVOLs, make sure to set the block size as the same, or a multiple, of the block size that you will be formatting the ZVOL with. If the block sizes do not align, performance issues could arise.
* When loading the "zfs" kernel module, make sure to set a maximum number for the ARC. Doing a lot of "zfs send" or snapshot operations will cache the data. If not set, RAM will slowly fill until the kernel invokes OOM killer, and the system becomes responsive. For example set in the `/etc/modprobe.d/zfs.conf` file "options zfs zfs_arc_max=2147483648", which is a 2 GB limit for the ARC.
