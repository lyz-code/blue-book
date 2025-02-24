## Check the health of a disk with badblocks

The `badblocks` command will write and read the disk with different patterns, thus overwriting the whole disk, so you will loose all the data in the disk.

This test is good for rotational disks as there is no disk degradation on massive writes, do not use it on SSD though.

WARNING: be sure that you specify the correct disk!!

```bash
badblocks -wsv -b 4096 /dev/sde | tee disk_analysis_log.txt
```

If errors are shown is that all of the spare sectors of the disk are used, so you must not use this disk anymore. Again, check `dmesg` for traces of disk errors.
