---
title: Amazfit Band 5
date: 20210225
author: Lyz
---

[Amazfit Band 5](https://www.amazfit.com/en/band5.html) it's the affordable
[fitness tracker](fitness_band.md) I chose to buy because:

* It's supported by [gadgetbridge](gadgetbridge.md).
* It has a SpO2 sensor which enhances the quality of the sleep metrics
* It has sleep metrics, not only time but also type of sleep (light, deep, REM).
* It has support with Alexa, not that I'd use that, but it would be cool if once
    I've got my personal [voice assistant](virtual_assistant.md), I can use it
    through the band.

# Sleep detection quality

The sleep tracking using Gadgetbridge is not [good at
all](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Huami-Deep-Sleep-Detection).
After two nights, the band has not been able to detect when I woke in the middle
of the night, or when I really woke up, as I usually stay in the bed for a time
before standing up. I'll try with the proprietary application soon and compare results.

If it doesn't work either, I might think of getting a specific device like
[withings sleep analyzer](https://www.withings.com/nl/en/sleep-analyzer) which
seems to have much more accuracy and useful insights. I've sent them an email to
see if it's possible to extract the data before it reach their servers, and they
confirmed that there is no way. Maybe you can route the requests to their
servers to one of your own, bring up an http server and reverse engineer the
communication.

Karlicoss, the author of the awesome [HPI](https://beepb00p.xyz/hpi.html) uses
the [Emfit
QS](https://github.com/karlicoss/HPI/blob/master/my/emfit/__init__.py), so that
could be another option.

# Firmware updates

Gadgetbridge people have a [guide on how to upgrade the
firmware](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Amazfit-Band-5-Firmware-Update),
you need to get the firmware from the [geek doing
forum](https://geekdoing.com/threads/amazfit-band-5-original-firmwares-resources-fonts.2331/)
though, so it is interesting to create an account and watch the post.
