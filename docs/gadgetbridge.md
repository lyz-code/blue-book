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
program that post processes the data. Also is [this
post](https://medium.com/machine-learning-world/how-i-hacked-xiaomi-miband-2-to-control-it-from-linux-a5bd2f36d3ad)
explaining how to reverse engineer the
miband2 with [this](https://github.com/vshymanskyy/miband2-python-test) or
[this](https://github.com/creotiv/MiBand2) scripts. If you start the path of
reverse engineering the Bluetooth protocol look at [gadgetbridge
guidelines](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/BT-Protocol-Reverse-Engineering).

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

# Weather

Follow [the official instructions](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Weather)

# Events

I haven't figured out yet how to let the events show in the "events" tab. Mobile
calendar events show up as notifications, but you can't see the list of the next
ones.

For the Amazfit band 5, there is a bug that [prevents events from
showing in the reminders
tab](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1866).
Notifications work well though.

# Setup

In the case of the [Amazfit band 5](https://www.amazfit.com/en/band5.html), we
need to use the [Huami server
pairing](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Huami-Server-Pairing#on-non-rooted-phones):

* Install the Zepp application
* Create an account through the application.
* Pair your band and wait for the firmware update
* Use [the python script](https://github.com/argrento/huami-token) to extract
    the credentials
    * `git clone https://github.com/argrento/huami-token.git`
    * `pip install -r requirements.txt`
    * Run script with your credentials: `python huami_token.py --method amazfit --email youemail@example.com --password your_password --bt_keys`
* Do not unpair the band/watch from MiFit/Amazfit/Zepp app
* Kill or uninstall the MiFit/Amazfit/Zepp app
* Ensure GPS/location services are enabled
* The official instructions tell you to *unpair the band/watch from your phone's
    bluetooth* but I didn't have to do it.
* Add the band in gadgetbridge.
* Under Auth key add your key.

# References

* [Git](https://codeberg.org/Freeyourgadget/Gadgetbridge)
* [Home](https://gadgetbridge.org/)
* [Issue tracker](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues)
* [Blog](https://blog.freeyourgadget.org/), although the
    [RSS](https://blog.freeyourgadget.org/feeds/all.atom.xml) is [not
    working](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2204).
