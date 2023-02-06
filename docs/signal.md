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
