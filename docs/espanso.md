[Espanso](https://github.com/espanso/espanso) is a cross-platform Text Expander written in Rust.

A text expander is a program that detects when you type a specific keyword and replaces it with something else. This is useful in many ways:

- Save a lot of typing, expanding common sentences or fixing common typos.
- Create system-wide code snippets.
- Execute custom scripts
- Use emojis like a pro.

# [Installation](https://espanso.org/docs/install/linux/)
Espanso ships with a .deb package, making the installation convenient on Debian-based systems.

Start by downloading the package by running the following command inside a terminal:

```bash
wget https://github.com/federico-terzi/espanso/releases/download/v2.2.1/espanso-debian-x11-amd64.deb
```

You can now install the package using:

```bash
sudo apt install ./espanso-debian-x11-amd64.deb
```

From now on, you should have the `espanso` command available in the terminal (you can verify by running `espanso --version`).

At this point, you are ready to use `espanso` by registering it first as a Systemd service and then starting it with:

```bash
espanso service register
```

Start espanso

```bash
espanso start
```

Espanso ships with very few built-in matches to give you the maximum flexibility, but you can expand its capabilities in two ways: creating your own custom matches or [installing packages](#using-packages).
# [Configuration](https://espanso.org/docs/get-started/#configuration)

Your configuration lives at `~/.config/espanso`. A quick way to find the path of your configuration folder is by using the following command `espanso path`.

- The files contained in the `match` directory define what Espanso should do. In other words, this is where you should specify all the custom snippets and actions (aka Matches). The `match/base.yml` file is where you might want to start adding your matches.
- The files contained in the `config` directory define how Espanso should perform its expansions. In other words, this is were you should specify all Espanso's parameters and options. The `config/default.yml` file defines the options that will be applied to all applications by default, unless an app-specific configuration is present for the current app. 

## [Using packages](https://espanso.org/docs/get-started/#understanding-packages)
Custom matches are great, but sometimes it can be tedious to define them for every common operation, especially when you want to share them with other people.

Espanso offers an easy way to share and reuse matches with other people, packages. In fact, they are so important that Espanso includes a built-in package manager and a store, the [Espanso Hub](https://hub.espanso.org/).

### [Installing a package](https://espanso.org/docs/get-started/#installing-a-package)
Get the id of the package from the [Espanso Hub](https://hub.espanso.org/) and then run `espanso install <<package_name>>`.

### Interesting packages

Of all the packages, I've found the next ones the most useful:

- [typofixer-en](https://hub.espanso.org/typofixer-en)
- [typofixer-es](https://hub.espanso.org/typofixer-es)
- [misspell-en-uk](https://hub.espanso.org/misspell-en-uk)

### Overwriting the snippets of a package

For example the `typofixer-en` replaces `si` to `is`, although `si` is a valid spanish word. To override the fix you can create your own file on `~/.config/espanso/match/typofix_overwrite.yml` with the next content:

```yaml
# This file overwrites typo fixes by https://github.com/Mte90/espanso-typofixer which conflict between languages
matches:
  # Simple text replacement
  - trigger: "si"
    replace: "si"
```
### [Creating a package](https://espanso.org/docs/packages/creating-a-package/)
## Auto-restart on config changes

Set `auto_restart: true` on `~/.config/espanso/config/default.yml`.

## [Changing the search bar shortcut](https://espanso.org/docs/configuration/options/#customizing-the-search-bar)
If the default search bar shortcut conflicts with your i3 configuration set it with:

```yaml
search_shortcut: CTRL+SHIFT+e
```

## [Hiding the notifications](https://espanso.org/docs/configuration/options/#hiding-the-notifications)
You can hide the notifications by adding the following option to your `$CONFIG/config/default.yml` config:

```yaml
show_notifications: false
```
# Usage
Just type and you'll see the text expanded. 

You can use the search bar if you don't remember your snippets.

# References
- [Code](https://github.com/espanso/espanso)
- [Docs](https://espanso.org/docs/get-started/)
