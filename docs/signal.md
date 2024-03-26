---
title: Signal
date: 20210312
author: Lyz
---

[Signal](https://en.wikipedia.org/wiki/Signal_%28software%29) is
a cross-platform centralized encrypted messaging service developed by the Signal
Technology Foundation and Signal Messenger LLC. It uses the Internet to send
one-to-one and group messages, which can include files, voice notes, images and
videos. It can also be used to make one-to-one and group voice and video
calls.

Signal uses standard cellular telephone numbers as identifiers and secures all
communications to other Signal users with end-to-end encryption. The apps
include mechanisms by which users can independently verify the identity of their
contacts and the integrity of the data channel.

Signal's software is free and open-source. Its clients are published under the
GPLv3 license, while the server code is published under the AGPLv3
license. The official Android app generally uses the proprietary Google Play
Services (installed on most Android devices), though it is designed to still
work without them installed. Signal also has an official client app for iOS and
desktop apps for Windows, MacOS and Linux.

## Pros and cons

Pros:

* Good security by default.
* Easy to use for non technical users.
* Good multi-device support.

Cons:

* Uses phones to identify users.
* Centralized.
* [Not available in
    F-droid](https://community.signalusers.org/t/wiki-signal-android-app-on-f-droid-store-f-droid-status/28581).

# Installation

## [Use the Molly FOSS android client](https://molly.im/)
Molly is an independent Signal fork for Android. The advantages are:

- Contains no proprietary blobs, unlike Signal.
- Protects database with passphrase encryption.
- Locks down the app automatically when you are gone for a set period of time.
- Securely shreds sensitive data from RAM.
- Automatic backups on a daily or weekly basis.
- Supports SOCKS proxy and Tor via Orbot.

### [Migrate from Signal](https://github.com/mollyim/mollyim-android/wiki/Migrating-From-Signal)

Note, the migration should be done when the available Molly version is equal to or later than the currently installed Signal app version.

- Verify your Signal backup passphrase. In the Signal app: Settings > Chats > Chat backups > Verify backup passphrase.
- Optionally, put your phone offline (enable airplane mode or disable data services) until after Signal is uninstalled in step 5. This will prevent the possibility of losing any Signal messages that are received during or after the backup is created.
- Create a Signal backup. In the Signal app, go to Settings > Chats > Chat backups > Create backup.
- Uninstall the Signal app. Now you can put your phone back online (disable airplane mode or re-enable data services).
- Install the Molly or Molly-FOSS app.
- Open the Molly app. Enable database encryption if desired. As soon as the option is given, tap Transfer or restore account. Answer any permissions questions.
- Choose to Restore from backup and tap Choose backup. Navigate to your Signal backup location (Signal/Backups/, by default) and choose the backup that was created in step 3.
- Check the backup details and then tap Restore backup to confirm. Enter the backup passphrase when requested.
- If asked, choose a new folder for backup storage. Or choose Not Now and do it later.

Consider also:

- Any previously linked devices will need to be re-linked. Go to Settings > Linked devices in the Molly app. If Signal Desktop is not detecting that it is no longer linked, try restarting it.
- Verify your Molly backup settings and passphrase at Settings > Chats > Chat backups (to change the backup folder, disable and then enable backups). Tap Create backup to create your first Molly backup.
- When you are satisfied that Molly is working, you may want to delete the old Signal backups (in Signal/Backups, by default).
## Install the Signal app
These instructions only work for 64 bit Debian-based Linux distributions such as Ubuntu, Mint etc.

* Install our official public software signing key

```bash
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
```

* Add our repository to your list of repositories

```bash
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
```

* Update your package database and install signal

```bash
sudo apt update && sudo apt install signal-desktop
```
# Backup extraction

I'd first try to use [signal-black](https://github.com/xeals/signal-back).

# References

* [Home]()
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
