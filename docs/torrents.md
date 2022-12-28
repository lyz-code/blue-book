---
title: Torrents
date: 20221228
author: Lyz
---

[BitTorrent](https://en.wikipedia.org/wiki/BitTorrent) is a communication
protocol for peer-to-peer file sharing (P2P), which enables users to distribute
data and electronic files over the Internet in a decentralized manner.

# [Torrent client comparison](https://www.ubuntupit.com/best-torrent-client-for-linux/)

Each of us seeks something different for a torrent client, thus there is a wide
set of software, you just need to find the one that's best for you. In my case
I'm searching for a client that:

- Scales well for many torrents

- Is robust

- Is maintained

- Is popular

- Is supported by the private trackers: Some torrent clients are banned by the
  tracker because they don't report correctly to the tracker when
  canceling/finishing a torrent session. If you use them then a few MB may not
  be counted towards the stats near the end, and torrents may still be listed in
  your profile for some time after you have closed the client. Each tracker has
  their list of allowed clients. Make sure to check them.

  Also, clients in alpha or beta versions should be avoided.

- Can be easily monitored

- Has a Python library or an API to interact with

- Has clear and enough logs

- Has RSS support

- Has a pleasant UI

- Supports categories

- Can unpack content once it's downloaded

- No ads

- Easy to use behind a VPN with IP leakage protection.

- Easy to deploy

I don't need other features such as:

- Preview content
- Search in the torrent client

## [Rtorrent](https://github.com/rakshasa/rtorrent/wiki)

RTorrent is entirely different from familiar open source torrents clients like
uTorrent or Deluge. All the above-described torrent clients for Linux offer a
graphical user interface, but rTorrent is a text-based app used in Terminal.

RTorrent is written in C++ and demands an extremely low resource but provides a
large scale of various features.

You can use Rutorrent to have a graphical frontend.

I've been using rutorrent for 3 years with
[binhex docker image](https://github.com/binhex/arch-rtorrentvpn) but I've come
through some issues. Let's see how it fulfills the needs:

- Scales well for many torrents: Nope, at least not for my case, once it reached
  600 torrents it started behaving weird. Suddenly it stopped downloading and
  uploading without apparent reason. The web interface started failing, the
  docker was left unresponsive for big periods of time, with no trace in the
  logs.
- Is robust: Nope, I had big issues trying to keep the image to the latest
  version. The solution of the maintainer was to start from scratch and import
  all the data.
- Is maintained: In theory it is but the latest release is of July 2019
- Is popular: It is, 3.7k in github and widely used in the torrenting community.
- Is supported by the private trackers: Yes
- Can be easily monitored: There are some prometheus exporters, but I haven't
  tried them yet.
- Has a Python library or an API to interact with:
  [looks like there exists](https://github.com/cjlucas/rtorrent-python) but the
  latest commit is of 2014.
- Has clear and enough logs: Not at all, at least binhex image, the logs have
  not helped me debug the problems. And the rtorrent logs are very difficult to
  read.
- Has RSS support: Yes
- Has a pleasant UI: more less, there are more modern interfaces, but I ended up
  using the stock.
- Supports categories: yes
- Can unpack content once it's downloaded: yes
- No ads: yes
- Easy to use behind a VPN with IP leakage protection: Yes thanks to
  [binhex docker](https://github.com/binhex/arch-rtorrentvpn)
- Easy to deploy: Yes thanks to binhex docker.

## [Qbittorrent](https://sourceforge.net/projects/qbittorrent/files/)

- Scales well for many torrents:
  [looks like it does](https://www.reddit.com/r/qBittorrent/comments/ikj25p/whats_the_maximum_number_torrents_i_can_add/)
  but I'd have to try it myself.
- Is robust: It's what I've read, but we'd have to test it.
- Is maintained: Yes, last commit is of 5h ago, last release was last month,
  [nice insights](https://github.com/qbittorrent/qBittorrent/pulse) with 15 PR
  merged this week, 7 new, 9 closed issues and 21 new.
- Is popular: I think it's the most popular, 18.4k stars in github and
  recommended everywhere.
- Is supported by the private trackers: Yes
- Can be easily monitored: There's
  [this nice prometheus exporter](https://github.com/caseyscarborough/qbittorrent-exporter)
  with it's
  [graphana dashboard](https://github.com/caseyscarborough/qbittorrent-grafana-dashboard).
  With the information shown in the graphana dashboard it looks you can do
  alerts on whatever you want.
- Has a Python library or an API to interact with:
  [yup](https://github.com/rmartin16/qbittorrent-api)
- Has clear and enough logs: We'll have to use it to check this point.
- Has RSS support: Yup
- Has a pleasant UI: The stock one is a little bit outdated, but there are newer
  Vue based interfaces.
- Supports categories: yup
- Can unpack content once it's downloaded:
  [yup](https://superuser.com/questions/1245189/automatically-extract-qbittorrent-downloads)
- No ads: yup
- Easy to use behind a VPN with IP leakage protection:
  [yup](https://github.com/binhex/arch-qbittorrentvpn), another image done by
  binhex, it doesn't have much support, but what can you do.
- Easy to deploy: yup

Some nice features I like about qbittorrent:

- [It disables DHT and PEX for private trackers](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions#will-private-torrent-be-affected-by-dht-and-pex-in-qbittorrent):
  You can enable all 3 of those options and your private torrents will stay
  private. You can verify this by viewing the trackers tab on a private torrent
  and the status for DHT/PEX/LSD will be "Disabled" and the message column will
  say "This torrent is private".
- It works better with the \*arr family than rutorrent.

## [Deluge](https://deluge-torrent.org/)

Deluge versions 2.x is not supported by some trackers

## [Transmission](https://transmissionbt.com/)

If you search for something entirely free, open source, and comes with minimum
configuration, then the Transmission torrent client is one of them. It supports
cross-platform like Windows, Linux, Mac OS, and Unix-based systems.

This powerful torrent client for Linux is incredibly lightweight and a system
optimizer that doesn’t take many resources from your system. It’s neat, simple,
and comes in plug-and-play mode. Transmission is perfect for users who want to
download Torrents and nothing else.

Not supported by private trackers

## [Frostwire](https://www.frostwire.com/)

Frostwire is out of the analysis as
[it has ads](https://www.fossmint.com/best-bittorrent-clients-for-linux/) and
it's not supported by private trackers.

## [Vuze](https://www.vuze.com/)

Not supported by some private trackers.

## [Aria2](https://aria2.github.io/)

Not supported by private trackers.

## Tracker comparison conclusion

If you need to use private trackers, you're pretty much tied to rtorrent or to
qbittorrent. As I've used rutorrent for a while I'm going to try qbittorrent.

# Private tracker torrent client configuration

Private trackers require you to configure your torrent client in a way so that
you don't get kicked.

- *Disable DHT*: DHT can cause your stats to be recorded incorrectly and could
  be seen as cheating.
- *Disable PEX(peer exchange)*: This can also let outside people get access to
  the tracker's torrents.

# References

- [](<>)
