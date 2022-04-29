---
title: Hard Drive Health
date: 20200317
author: Lyz
---

Hard drives die, so we must be ready for that to happen. There are several
solutions, such as using [RAID](https://en.wikipedia.org/wiki/RAID) to minimize
the impact of a disk loss, but even then, we should monitor the [bad
sectors](https://en.wikipedia.org/wiki/Bad_sector) to see when are our disks
dying.

[S.M.A.R.T](https://en.wikipedia.org/wiki/S.M.A.R.T.) (Self-Monitoring, Analysis
and Reporting Technology; often written as SMART) is a monitoring system
included in computer hard disk drives (HDDs), solid-state drives (SSDs), and
eMMC drives. Its primary function is to detect and report various indicators of
drive reliability with the intent of anticipating imminent hardware failures.

Between all the SMART attributes, some that define define the health status of the
hard drive, such as:

* *Reallocated Sectors Count*:  Count of reallocated sectors. The raw value
  represents a count of the bad sectors that have been found and remapped.
  Thus, the higher the attribute value, the more sectors the drive has had to
  reallocate. This value is primarily used as a metric of the life expectancy of
  the drive; a drive which has had any reallocations at all is significantly
  more likely to fail in the immediate months.
* *Spin Retry Count*: Count of retry of spin start attempts. This attribute
  stores a total count of the spin start attempts to reach the fully operational
  speed (under the condition that the first attempt was unsuccessful). An
  increase of this attribute value is a sign of problems in the hard disk
  mechanical subsystem.
* *Reallocate Event Count*: Count of remap operations. The raw value of this
  attribute shows the total count of attempts to transfer data from reallocated
  sectors to a spare area. Both successful and unsuccessful attempts are
  counted.
* *Current Pending Sector Count*: Count of "unstable" sectors (waiting to be
    remapped, because of unrecoverable read errors). If an unstable sector is
    subsequently read successfully, the sector is remapped and this value is
    decreased. Read errors on a sector will not remap the sector immediately
    (since the correct value cannot be read and so the value to remap is not
    known, and also it might become readable later); instead, the drive
    firmware remembers that the sector needs to be remapped, and will remap it
    the next time it's written.

    However, some drives will not immediately remap such sectors when written;
    instead the drive will first attempt to write to the problem sector and if
    the write operation is successful then the sector will be marked good (in
    this case, the "Reallocation Event Count" (0xC4) will not be increased).
    This is a serious shortcoming, for if such a drive contains marginal sectors
    that consistently fail only after some time has passed following
    a successful write operation, then the drive will never remap these problem
    sectors.
* *Offline Uncorrectable Sector Count*: The total count of uncorrectable errors
  when reading/writing a sector. A rise in the value of this attribute indicates
  defects of the disk surface and/or problems in the mechanical subsystem.

# Check the warranty status

If your drive is still under warranty from the manufacturer you
may consider RMA’ing the drive (initiating a warranty return process).

* [Seagate Warranty Check](http://support.seagate.com/customer/en-US/warranty_validation.jsp)
* [Western Digital (WD) Warranty Check](https://support.wdc.com/warranty/warrantystatus.aspx?lang=en)
* [HGST Warranty Check](http://www1.hgst.com/warranty/index_gtech_serial.do)
* [Toshiba Warranty Check](https://support.toshiba.com/warranty)

# Wipe all the disk

Sometimes the `CurrentPendingSector` doesn't get reallocated, if you don't mind
about the data in the disk, you can wipe it all with:

```bash
dd if=/dev/zero of=/dev/{{ disk_id }} bs=4096 status=progress
```

# Troubleshooting

## SMART error (CurrentPendingSector) detected on host

As stated above, this means that at some point, the drive was unable to
successfully read the data from X different sectors, and hence have flagged them
for possible reallocation. The sector will be marked as reallocated if
a subsequent write fails. If the write succeeds, it is removed from current
pending sectors and assumed to be OK.

Start with a long self test with `smartctl`. Assuming the disk to test is
`/dev/sdd`:

```bash
smartctl -t long /dev/sdd
```

The command will respond with an estimate of how long it thinks the test will
take to complete.  (But this assumes that no errors will be found!)

To check progress use:

```bash
smartctl -A /dev/sdd | grep remaining
# or
smartctl -c /dev/sdd | grep remaining
```

Don't check too often because it can abort the test with some drives. If you
receive an empty output, examine the reported status with:

```bash
smartctl -l selftest /dev/sdd
```

You will see something like this:

```bash
=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Extended offline    Completed: read failure       20%      1596         44724966
```

So take that 'LBA' of 44724966 and multiply by (512/4096) which is the
equivalent of 'divide by 8'

```bash
44724966 / 8 = 5590620.75
```

The sector to test then is `5590620`. If it is in the middle of a file,
overwritting it will corrupt the file. If you are not cool with that, check the
following posts to check if that sector belongs to a file:

* [Smartmontools and fixing Unreadable Disk
    Sectors](https://nwsmith.blogspot.com/2007/08/smartmontools-and-fixing-unreadable.html).
* [Smartmontools Bad Block how to](https://www.smartmontools.org/wiki/BadBlockHowto)
* [Archlinux Identify damaged files page](https://wiki.archlinux.org/index.php/Identify_damaged_files)
* [Archlinux badblocks page](https://wiki.archlinux.org/index.php/Badblocks)

If you don't care to corrupt the file, use the following command to 'zero-out'
the sector:

```bash
dd if=/dev/zero of=/dev/sda conv=sync bs=4096 count=1 seek=5590620
1+0 records in
1+0 records out

sync
```

Now retry the `smartctl -t short` (or `smartctl -t long` if `short` fails) and
see if the test is able to finish the test without errors:

```
=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%     11699         -
# 2  Extended offline    Completed: read failure       90%     11680         65344288
# 3  Extended offline    Completed: read failure       90%     11675         65344288
```

If reading errors remain, repeat the steps above until they don't or skip to the
[bad block analysis step](#bad-block-analysis).

`Current_Pending_Sector` should be `0` now and the drive will probably be fine.
As long as `Reallocated_Sector_Ct` is zero, you should be fine. Even a few
reallocated sectors seems OK, but if that count starts to increment frequently,
then that is a danger sign. To regularly keep a close eye on the counters use
`smartd` to schedule daily tests.

If `Current_Pending_Sector` is still not `0`, we need to do a deeper [analysis on
the bad blocks](#bad-block-analysis).

## Bad block analysis

The SMART `long` test [gives no guarantee to find every
error](https://www.linuxquestions.org/questions/linux-hardware-18/smartd-currently-unreadable-pending-sectors-errors-4175659756/).
To find them, we're going to use the `badblocks` tool instead.

There is read-only mode (default) which is the least accurate. There is the
destructive write-mode (-w option) which is the most accurate but takes longer
and will (obviously) destroy all data on the drive, thus making it quite useless
for matching sectors up to files. There is finally the non-destructive
read-write mode which is probably as accurate as the destructive mode, with the
only real downside that it is probably the slowest. However, if a drive is known
to be failing then read-only mode is probably still the safest.

# Links

* [S.M.A.R.T Wikipedia article](https://en.wikipedia.org/wiki/S.M.A.R.T.).
* [linux-hardware SMART disk probes](https://github.com/linuxhw/SMART).

## Bad blocks

* [Smartmontools and fixing Unreadable Disk
    Sectors](https://nwsmith.blogspot.com/2007/08/smartmontools-and-fixing-unreadable.html).
* [Smartmontools Bad Block how to](https://www.smartmontools.org/wiki/BadBlockHowto)
* [Archlinux Identify damaged files page](https://wiki.archlinux.org/index.php/Identify_damaged_files)
* [Archlinux badblocks page](https://wiki.archlinux.org/index.php/Badblocks)
* [Hard drive geek guide on reducing the current pending sector
    count](https://harddrivegeek.com/current-pending-sector-count/).
* [Hiddencode guide on how to check bad sectors](https://hiddenc0de.wordpress.com/2015/06/12/how-to-check-bad-sectors-or-bad-blocks-on-hard-disk-in-linux/)
* [Hiddencode guide on how to fix bad sectors](https://hiddenc0de.wordpress.com/2015/06/12/how-to-fix-bad-sectors-or-bad-blocks-on-hard-disk/)
