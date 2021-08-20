---
title: alot
date: 20210820
author: Lyz
---

[alot](https://github.com/pazz/alot) is a terminal-based mail user agent based
on the [notmuch mail indexer](notmuch.md). It is written in python using the
urwid toolkit and features a modular and command prompt driven interface to
provide a full MUA experience.

# [Installation](https://alot.readthedocs.io/en/latest/installation.html)

```bash
sudo apt-get install alot
```

# [Configuration](https://alot.readthedocs.io/en/latest/configuration/index.html)

Alot reads the *INI* config file `~/.config/alot/config`. That file is not
created by default, if you don't want to start from scratch, you can use [pazz's
alot
configuration](https://github.com/pazz/configs/blob/master/.config/alot/config),
in particular the `[accounts]` section.

# UI interaction

Basic movement is done with:

* Move up and down: `j`/`k`, arrows and page up and page down.
* Cancel prompts: `Escape`
* Select highlighted element: `Enter`.
* Update buffer: `@`.

The interface shows one buffer at a time, basic buffer management is done with:

* Change buffer: `Tab` and `Shift-Tab`.
* Close the current buffer: `d`
* List all buffers: `;`.

The buffer type or mode (displayed at the bottom left) determines which prompt
commands are available. Usage information on any command can be listed by typing
`help YOURCOMMAND` to the prompt. The key bindings for the current mode are listed
upon pressing `?`.

You can always run commands with `:`.

# Troubleshooting

## [Remove emails](https://github.com/pazz/alot/issues/1473)

Say you want to remove emails from the provider's server but keep them in the
notmuch database. There is no straight way to do it, you need to tag them with
a special tag like `deleted` and then remove them from the server with
a post-hook.

## Theme not found

I don't know why but `apt-get` didn't install the default themes, you need to
create the `~/.config/alot/themes` and copy the contents of the [themes
directory](https://github.com/pazz/alot/tree/master/extra/themes).

# References

* [Git](https://github.com/pazz/alot)
* [Docs](https://alot.readthedocs.io/en/latest/)
* [Wiki](https://github.com/pazz/alot/wiki)
* [FAQ](https://alot.readthedocs.io/en/latest/faq.html)
