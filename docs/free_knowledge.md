---
title: Free Knowledge
date: 20210524
author: Lyz
---

One of the early principles of the internet has been to make knowledge free to
everyone. [Alexandra Elbakyan](https://en.wikipedia.org/wiki/Alexandra_Elbakyan)
of [Sci-Hub](https://sci-hub.do/), bookwarrior of [Library
Genesis](https://libgen.fun/), [Aaron
Swartz](https://en.wikipedia.org/wiki/Aaron_Swartz), and countless unnamed
others have fought to free science from the grips of for-profit publishers.
Today, they do it working in hiding, alone, without acknowledgment, in fear of
imprisonment, and even now wiretapped by the FBI. They sacrifice everything for
one vision: Open Science.

Some days ago, a [post appeared on
reddit](https://www.reddit.com/r/DataHoarder/comments/nc27fv/rescue_mission_for_scihub_and_open_science_we_are/)
to rescue Sci-Hub by increasing the seeders of the [850 scihub
torrents](http://libgen.rs/scimag/repository_torrent/). The plan is to follow
the steps done last year to move [Libgen to
IPFS](https://www.reddit.com/r/DataHoarder/comments/ed9byj/library_genesis_project_update_25_million_books/)
to make it more difficult for the states to bring down this marvelous
collection.

A good way to start is to look at the [most ill
torrents](https://phillm.net/torrent-health-frontend/seeds-needed.php) and
fix their state. If you follow this path, take care of IP leaking, they're
surely monitoring who's sharing.

Another way to contribute is by following the guidelines of
[freeread.org](https://freeread.org/) and contribute to the [IPFS free
library](https://freeread.org/ipfs/). Beware though, the guidelines don't
explain how to install IPFS behind a VPN or Tor. This could be contributed to
the site.

Something that is needed is a command line tool that reads the [list of ill
torrents](https://phillm.net/torrent-health-frontend/seeds-needed.php), and
downloads the torrents that have a low number of seeders and DHT peers. The
number of torrents to download could be limited by the amount the user wants to
share. A second version could have an interaction with the torrent client so
that when a torrent is no longer ill, it's automatically replaced with one that
is.

# References

* [FreeRead.org](https://freeread.org/)
* [Libgen reddit](https://www.reddit.com/r/libgen/)
* [Sci-Hub reddit](https://www.reddit.com/r/scihub/)
* [DataHoarder reddit](https://www.reddit.com/r/DataHoarder/)
