---
title: qBittorrent
date: 20221228
author: Lyz
---

[qBittorrent](https://www.qbittorrent.org/) is [my chosen](torrents.md) client
for [Bittorrent](https://en.wikipedia.org/wiki/BitTorrent).

# Installation

Use [binhex Docker](https://github.com/binhex/arch-qbittorrentvpn)

- [Enable the announcement to all trackers](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions#only-one-tracker-is-working-the-others-arent-contacted-yet)
- [Check the Advanced configurations](https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent#Advanced)
- I've tried the different Web UIs but none was of my licking.
- I've configured [unpackerr](https://github.com/davidnewhall/unpackerr) to
  unpack the compressed downloads.

# Migration from other client

- First [install the service](#installation)
- Make sure that the default download directory has all the downloaded data to
  import.
- Then move all the `*.torrent` files from the old client to the torrent watch
  directory.

# Python interaction

Use [this library](https://github.com/rmartin16/qbittorrent-api), you can see
some examples [here](https://github.com/StuffAnThings/qbit_manage).

# Monitorization

There's
[this nice prometheus exporter](https://github.com/caseyscarborough/qbittorrent-exporter)
with it's
[graphana dashboard](https://github.com/caseyscarborough/qbittorrent-grafana-dashboard).
With the information shown in the graphana dashboard it looks you can do alerts
on whatever you want.

When I have some time I'd like to monitor the next things:

- No `Forbidden client` string in the tracker messages. This happens when your
  client is not whitelisted in one of the trackers.
- No `Unregistered torrent` string in the tracker messages. This happens when
  the tracker has removed the torrent from their site, you can safely remove it
  then.
- No torrent is in downloading state without receiving data for more than X
  hours. This will mean that either the torrent is dead.
- If all downloading torrents are not receiving data for more than X hours could
  mean that there is an error with your torrent client so that it can't
  download.
- Configure the Hit and Run conditions per tracker to raise an alert if you
  don't comply
- If you are not seeding during X hours it would mean that there is an error in
  your application.
- Warn you when your buffer for a tracker is lower than X.
- Warn if a completed torrent is in a category for more than X hours, which will
  mean that it wasn't automatically imported.

# Automatic operation

I've found myself doing some micromanagement of the torrents that can probably
be done by a program. For example:

- Remove the torrents of a category if their ratio is above X (not all
  torrents).
- [Remove torrents if your disk is getting full](https://github.com/StuffAnThings/qbit_manage/blob/master/scripts/delete_torrents_on_low_disk_space.py)
  in an intelligent way (torrents with most seeds first, allow or disallow the
  removal of private tracker torrents, ...).
- For the trackers where you're building some ratio keep the interesting
  torrents for a while until you build the desired buffer.
- [Remove unregistered torrents](https://github.com/qbittorrent/qBittorrent/issues/11469)
- Alert or remove the directories that are not being used by any active torrent.

# Client recovery

When your download client stops working and you can't recover it soon your heart
gets a hiccup. You'll probably start browsing the private trackers webpages to
see if you have a Hit and Run and if you can solve it before you get banned. If
this happens while you're away from your infrastructure it can be even worse.

Something you can do in these cases is to have another client configured so you
can spawn it fast and import the torrents that are under the Hit and Run threat.

# References

- [Home](https://www.qbittorrent.org/)
- [Source](https://github.com/qbittorrent/qBittorrent/)
- [FAQ](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions#will-private-torrent-be-affected-by-dht-and-pex-in-qbittorrent)
