---
title: Dunst
date: 20210612
author: Lyz
---

[Dunst](https://dunst-project.org/) is a lightweight replacement for the
notification daemons provided by most desktop environments. It’s very
customizable, isn’t dependent on any toolkits, and therefore fits into those
window manager centric setups we all love to customize to perfection.

# Installation

```bash
sudo apt-get install dunst
```

Test it's working with:

```bash
notify-send "Notification Title" "Notification Messages"
```

If your distro version is too old that doesn't have `dunstctl` or `dunstify`,
you [can install it manually](https://github.com/dunst-project/dunst#building):

```bash
git clone https://github.com/dunst-project/dunst.git
cd dunst

# Install dependencies
sudo apt-get install libgdk-pixbuf2.0-0 libnotify-dev librust-pangocairo-dev

# Build the program and install
make WAYLAND=0 SYSTEMD=1
sudo make WAYLAND=0 SYSTEMD=1 install
```

Read and tweak the `~/.dunst/dunstrc` file to your liking.

# References

* [Git](https://github.com/dunst-project/dunst)
* [Home](https://dunst-project.org/)
* [Archwiki page on dunst](https://wiki.archlinux.org/title/Dunst)
