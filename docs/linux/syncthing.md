---
title: Syncthing
date: 20200404
author: Lyz
---

[Syncthing](https://syncthing.net/) is a continuous file synchronization
program. It synchronizes files between two or more computers in real time,
safely protected from prying eyes. Your data is your data alone and you deserve
to choose where it is stored, whether it is shared with some third party, and
how it's transmitted over the internet.

# [Installation](https://syncthing.net/downloads/)

## Debian or Ubuntu

```bash
# Add the release PGP keys:
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

# Add the "stable" channel to your APT sources:
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Update and install syncthing:
sudo apt-get update
sudo apt-get install syncthing
```

## Docker

Use [Linuxserver Docker](https://docs.linuxserver.io/images/docker-syncthing)

# Links

* [Home](https://syncthing.net/)
* [Getting Started](https://docs.syncthing.net/intro/getting-started.html)
