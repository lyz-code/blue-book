---
title: LibreElec
date: 20200331
author: Lyz
---

LibreElec is the lightweight distribution to run Kodi

The root filesystem is mounted as readonly.

# Mount directories with sshfs

* Install the network-tool LibreElec addon.
* Configure the ssh credentials
* Add the following service file:
    `/storage/.config/system.d/storage-media.mount`

```
[Unit]
Description=remote external drive share
Requires=multi-user.target network-online.service
After=multi-user.target network-online.service
Before=kodi.service

[Mount]
What=/storage/.kodi/addons/virtual.network-tools/bin/sshfs#{{ user }}@{{ host }}:{{ source_path }}
Where=/storage/media

[Install]
WantedBy=multi-user.target
```
