---
title: Gadgetbridge
date: 20210219
author: Lyz
---

[Gadgetbridge](https://gadgetbridge.org/) is an Android (4.4+) application which
will allow you to use your Pebble, Mi Band, Amazfit Bip and HPlus device (and
more) without the vendor's closed source application and without the need to
create an account and transmit any of your data to the vendor's servers.

It wont be ever be as good as the proprietary application, but it supports
a good range of
[features](https://codeberg.org/Freeyourgadget/Gadgetbridge/src/branch/master/FEATURES.md),
and supports a [huge range of
bands](https://codeberg.org/Freeyourgadget/Gadgetbridge/src/branch/master/README.md#supported-devices-warning-some-of-them-wip-and-some-of-them-without-maintainer).

# [Data extraction](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Data-Export-Import-Merging-Processing)

You can use the Data export or Data Auto export to get copy of your data.

[Here](https://framagit.org/chabotsi/miband2_analysis) is an example of a Python
program that post processes the data.

If you start to think on how to avoid the connection with an android phone and
directly extract or interact from a linux device through python, I'd go with
[pybluez](https://github.com/pybluez/pybluez) for the bluetooth interface,
understand the band code of
[Gadgetbridge](https://codeberg.org/Freeyourgadget/Gadgetbridge) porting the
logic to the python module, and reverse engineering the call you want to
process. There isn't much in the internet following this approach, I've found an
implementation for the [Mi Band 4 though](https://github.com/satcar77/miband4),
which can be a good start.

# Heartrate measurement

Follow [the official
instructions](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Huami-Heartrate-measurement).

# Sleep

It looks that they don't yet support [smart
alarms](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1208).
# References

* [Git](https://codeberg.org/Freeyourgadget/Gadgetbridge)
* [Home](https://gadgetbridge.org/)
* [Issue tracker](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues)
* [Blog](https://blog.freeyourgadget.org/), although the
    [RSS](https://blog.freeyourgadget.org/feeds/all.atom.xml) is [not
    working](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2204).
