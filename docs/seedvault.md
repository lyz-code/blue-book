[Seedvault](https://calyxinstitute.org/projects/seedvault-encrypted-backup-for-android) is an open-source encrypted backup app for inclusion in Android-based operating systems.

While every smartphone user wants to be prepared with comprehensive data backups in case their phone is lost or stolen, not every Android user wants to entrust their sensitive data to Google's cloud-based storage. By storing data outside Google's reach, and by using client-side encryption to protect all backed-up data, Seedvault offers users maximum data privacy with minimal hassle.

Seedvault allows Android users to store their phone data without relying on Google's proprietary cloud storage. Users can decide where their phone's backup will be stored, with options ranging from a USB flash drive to a remote self-hosted cloud storage alternative such as NextCloud. Seedvault also offers an Auto-Restore feature: instead of permanently losing all data for an app when it is uninstalled, Seedvault's Auto-Restore will restore all backed-up data for the app upon reinstallation.

Seedvault protects users' private data by encrypting it on the device with a key known only to the user. Each Seedvault account is protected by client-side encryption (AES/GCM/NoPadding). This encryption is unlockable only with a 12-word randomly-generated key.

With Seedvault, backups run automatically in the background of the phone's operating system, ensuring that no data will be left behind if the device is lost or stolen. The Seedvault application requires no technical knowledge to operate, and does not require a rooted device.

# Installation

After looking at their repo and docs I haven't found how to install it. Luckily [GrapheneOS](grapheneos.md) comes with it pre-installed. 

# Usage

To access the seedvault backup configuration (at least in GrapheneOS) go to `Settings/System/Backup`.

## Store the backup remotely

You can use an USB drive or Nextcloud to store the backup outside your phone. The first is no good because you need to manually manage the backup extraction, and the second assumes you have a Nextcloud instance that you trust.

If you don't like those options, you can also store the backup in the phone and use [`syncthing`](syncthing.md) to sync it with your server. If you select local storage, the [backups are saved in the `.SeedVaultAndroidBackup` directory at the root directory of the internal storage (it may be hidden).

## Restore the backup

# References

* [Home](https://calyxinstitute.org/projects/seedvault-encrypted-backup-for-android)
* [Source](https://github.com/seedvault-app/seedvault)
