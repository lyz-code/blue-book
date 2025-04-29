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
sudo apt install libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev \
    libpango1.0-dev libgtk-3-dev libxdg-basedir-dev libgdk-pixbuf-2.0-dev

# Build the program and install
make WAYLAND=0
sudo make WAYLAND=0 install
```

If it didn't create the systemd service you can [create it yourself](linux_snippets.md#create-a-systemd-service-for-a-non-root-user) with this service file

```ini
[Unit]
Description=Dunst notification daemon
Documentation=man:dunst(1)
PartOf=graphical-session.target

[Service]
Type=dbus
BusName=org.freedesktop.Notifications
ExecStart=/usr/local/bin/dunst
Slice=session.slice
Environment=PATH=%h/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games


[Install]
WantedBy=default.target
```

You may need to add more paths to PATH.

To see the logs of the service use `journalctl --user -u dunst.service -f --since "15 minutes ago"`

# [Configuration](https://github.com/dunst-project/dunst/blob/master/dunstrc)

Read and tweak the `~/.dunst/dunstrc` file to your liking. You have the [default one here](https://github.com/dunst-project/dunst/blob/master/dunstrc)

You'll also need to configure the actions in your window manager. In my case [i3wm](i3wm.md):

```
bindsym $mod+b exec dunstctl close-all
bindsym $mod+v exec dunstctl context
```

# Usage

## Configure each application notification

You can look at [rosoau config](https://gist.github.com/rosoau/fdfa7b3e37e3c5c67b7dad1b7257236e) for inspiration

# References

- [Git](https://github.com/dunst-project/dunst)
- [Home](https://dunst-project.org/)

* [Some dunst configs](https://github.com/dunst-project/dunst/issues/826)
* Smarttech101 tutorials ([1](https://smarttech101.com/how-to-configure-dunst-notifications-in-linux-with-images), [2](https://smarttech101.com/how-to-send-notifications-in-linux-using-dunstify-notify-send#Taking_Actions_on_notifications_using_dunstifynotify-send))

- [Archwiki page on dunst](https://wiki.archlinux.org/title/Dunst)
