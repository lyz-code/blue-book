---
title: Redox
date: 20221110
author: Lyz
---

[Redox](https://github.com/mattdibi/redox-keyboard)

# Installation

First flash:

Download the hex from the via website

Try to flash it many times reseting the promicros.

```bash
sudo avrdude -b 57600 -p m32u4 -P /dev/ttyACM0 -c avr109 -D -U flash:w:redox_rev1_base_via.hex
```

Once the write has finished install via:

https://github.com/the-via/releases/releases

Reboot the computer

launch it with `via-nativia`.

# References

- [Git](https://github.com/mattdibi/redox-keyboard)
