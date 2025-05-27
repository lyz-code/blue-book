# [Installation](https://wiki.pine64.org/wiki/ROCK64_Software_Releases#Debian)

- Go to [the rock64 wiki page](https://wiki.pine64.org/wiki/ROCK64_Software_Releases#Debian) to get the download directory for the debian version you want to install
- Download `firmware.rock64-rk3328.img.gz` and `partition.img.gz`
- Combine the 2 parts into 1 image file: `zcat firmware.rock64-rk3328.img.gz partition.img.gz > debian-installer.img`
- Write the created .img file to microSD card or eMMC Module using dd: `dd if=debian-installer.img of=/dev/sda bs=4M`. Replace `/dev/sda` with your target drive.
- Plug the microSD/eMMC card in the Rock64 (and connect a serial console, or keyboard and monitor) and boot up to start the Debian Installer

Notes:

- An Ethernet connection is required for the above installer
- Remember to leave some space before your first partition for u-boot! You can do this by creating a 32M size unused partition at the start of the device.
- Auto creating all partitions does not work. You can use the following manual partition scheme:

```
 #1 - 34MB  Unused/Free Space
 #2 - 512MB ext2 /boot           (Remember to set the bootable flag)
 #3 - xxGB  ext4 /               (This can be as large as you want. You can also create separate partitions for /home /var /tmp)
 #4 - 1GB   swap                 (May not be a good idea if using an SD card)
```
