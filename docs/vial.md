[Vial](https://get.vial.today/) is an open-source cross-platform (Windows, Linux and Mac) GUI and a QMK fork for configuring your keyboard in real time.

# [Installation](https://get.vial.today/download/)

Even though you can use a [web version](https://vial.rocks/) you can install it locally through an [AppImage](https://itsfoss.com/use-appimage-linux/)

- Download [the latest version](https://get.vial.today/download/)
- Give it execution permissions
- Add the file somewhere in your `$PATH`

On linux you [need to configure an `udev` rule](https://get.vial.today/manual/linux-udev.html).

For a universal access rule for any device with Vial firmware, run this in your shell while logged in as your user (this will only work with sudo installed):

```bash
export USER_GID=`id -g`; sudo --preserve-env=USER_GID sh -c 'echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{serial}==\"*vial:f64c2b3c*\", MODE=\"0660\", GROUP=\"$USER_GID\", TAG+=\"uaccess\", TAG+=\"udev-acl\"" > /etc/udev/rules.d/99-vial.rules && udevadm control --reload && udevadm trigger'
```

This command will automatically create a `udev` rule and reload the `udev` system.
