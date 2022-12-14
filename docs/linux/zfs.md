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

## [Storage planning](https://mtlynch.io/budget-nas/#storage-planning)

There are many variables that affect the number and type of disks, you first
need to have an idea of what kind of data you want to store and what use are you
going to give to that data.

### Robustness

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

#### [Preventing concurrent disk failures](https://mtlynch.io/budget-nas/#preventing-concurrent-disk-failures)

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

### Choosing the disks to hold data

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

#### Data disk speed

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

#### Data disk load

Disk specifications tell you the amount of TB/year they support, it gives you an
idea of the fault tolerance. Some examples

| Disk       | Fault tolerance (TB/year) |
| ---------- | ------------------------- |
| WD RED 8TB | 180                       |

#### [Data disk type](https://www.howtogeek.com/345131/how-to-select-hard-drives-for-your-home-nas/)

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

#### Data disk homogeneity

It's recommended that all the disks in your pool (or is it by vdev?) have the
same RPM and size.

#### Data disk warranty

Disks are going to fail, so it's good to have a good warranty to return them.

#### [Data disk brands](https://www.nasmaster.com/best-nas-drives/)

##### [Western Digital](https://www.nasmaster.com/wd-red-vs-red-plus-vs-red-pro-nas-hdd/)

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

##### Seagate

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

#### Data disk conclusion

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

### [Choosing the disks for the cache](https://www.nasmaster.com/best-m2-nvme-ssd-nas-caching/)

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

#### Cache disk NAND technology

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

#### DWPD

DWPD stands for drive writes per day. This is often used as a measurement of a
drive’s endurance. The higher this number, the more writes the drive can perform
on a daily basis, as is rated by the manufacturer. For caching, especially which
involves writing data, you’ll want to aim for as high a DWPD rating as possible.

#### Cache disk conclusion

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

### Choosing the cold spare disks

It's good to think how much time you want to have your raids to be inconsistent
once a drive has failed.

In my case, for the data I want to restore the raid as soon as I can, therefore
I'll buy another rotational disk. For the SSDs I have more confidence that they
won't break so I don't feel like having a spare one.

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

# Resources

- [Docs](https://openzfs.github.io/openzfs-docs/)
- [Aaron Toponce articles](https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)
- [JRS articles](https://jrs-s.net/category/open-source/zfs/)
- [ZFS basic introduction video](https://yewtu.be/watch?v=MsY-BafQgj4)
