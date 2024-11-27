---
title: Wireshark
date: 20220228
author: Lyz
---

[Wireshark](https://www.wireshark.org/) is the world’s foremost and widely-used
network protocol analyzer. It lets you see what’s happening on your network at
a microscopic level and is the de facto (and often de jure) standard across many
commercial and non-profit enterprises, government agencies, and educational
institutions.

# Installation

```bash
apt-get install wireshark
```

If the version delivered by your distribution is not high enough, use Jezz's
Docker

```bash
docker run -d \
    -v /etc/localtime:/etc/localtime:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/wireshark:/data \
    jess/wireshark
```

# Usage

## [Filter](https://www.ictshore.com/wireshark/wireshark-filter-tutorial/)

You can filter by traffic type with `tcp and tcp.port == 80`, `http or ftp` or
`not ftp`.

It's also possible to nest many operators with `(http or ftp) and ip.addr ==
192.168.1.14`

The most common filters are:

| Item              | Description                                          |
| ---               | ---                                                  |
| ip.addr           | IP address (check both source and destination)       |
| tcp.port          | TCP Layer 4 port (check both source and destination) |
| udp.port          | UDP Layer 4 port (check both source and destination) |
| ip.src            | IP source address                                    |
| ip.dst            | IP destination address                               |
| tcp.srcport       | TCP source port                                      |
| tcp.dstport       | TCP destination port                                 |
| udp.srcport       | UDP source port                                      |
| udp.dstport       | UDP destination port                                 |
| icmp.type         | ICMP numeric type                                    |
| ip.tos.precedence | IP precedence                                        |
| eth.addr          | MAC address                                          |
| ip.ttl            | IP Time to Live (TTL)                                |

# References

* [Home](https://www.wireshark.org/)
