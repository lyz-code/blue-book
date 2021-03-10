---
title: Fitness tracker
date: 20210223
author: Lyz
---

[Fitness tracker](https://en.wikipedia.org/wiki/Activity_tracker) or activity
trackers are devices or applications for monitoring and tracking fitness-related
metrics such as distance walked or run, calorie consumption, and in some cases
heartbeat. It is a type of wearable computer.

As with anything that can be bought, I usually first try a cheap model to see if
I need the advanced features that the expensive ones offer. After a quick model
review, I went for the [Amazfit band 5](amazfit_band_5.md).

I've now discovered [wasp-os](https://github.com/daniel-thompson/wasp-os)
an open source firmware for smart watches that are based on the nRF52 family of
microcontrollers. Fully supported by [gadgetbridge](gadgetbridge.md), Wasp-os
features full heart rate monitoring and step counting support together with
multiple clock faces, a stopwatch, an alarm clock, a countdown timer,
a calculator and lots of other games and utilities. All of this, and still with
access to the MicroPython REPL for interactive tweaking, development and
testing.

Currently it support the following devices:

* [Colmi P8](https://wasp-os.readthedocs.io/en/latest/install.html#colmi-p8)
* [Senbono K9](https://wasp-os.readthedocs.io/en/latest/install.html#senbono-k9)
* [Pine64 PineTime](https://www.pine64.org/pinetime/)

Pinetime seems to be a work in progress, [Colmi
P8](https://www.colmi.com/products/p8-smartwatch) looks awesome, and the
[Senbono
K9](https://www.senbono.store/products/senbono-k9-men-smart-watch-ip68-waterproof-ips-full-touch-screen-heart-rate-monitor-fitness-tracker-sports-women-wristband?_pos=1&_sid=c3f22a815&_ss=r)
looks good too but wasp-os is lacking touch screen support.

So if I had to choose now, I'd try the Colmi P8, the only thing that I'd miss is
the possible voice assistant support. They say that you can take one for 18$ in
aliexpress.
