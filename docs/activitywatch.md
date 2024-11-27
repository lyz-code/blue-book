---
title: ActivityWatch
date: 20210312
author: Lyz
---

[ActivityWatch](https://activitywatch.net/) is a bundle of software that tracks
your computer activity. You are, by default, the sole owner of your data.

ActivityWatch is:

* A set of watchers that record relevant information about what you do and what
    happens on your computer (such as if you are AFK or not, or which window is
    currently active).
* A way of storing data collected by the watchers.
* A dataformat accomodating most logging needs due to its flexibility.
* An ecosystem of tools to help users extend the software to fit their needs.

# [Installation](https://docs.activitywatch.net/en/latest/getting-started.html#installation)

* Download the [latest
release](https://github.com/ActivityWatch/activitywatch/releases)
* Unpack it and move it for example to `~/.local/bin/activitywatch`.
* Add the `aw-qt` executable to the autostart.

It will start the web interface at http://localhost:5600 and will capture the
data.

# [Configuration](https://docs.activitywatch.net/en/latest/configuration.html)

First go to the `settings` page of the Web UI, you can define there the rules
for the categories.

More advanced settings can be changed on the files, but I had no need to go
there yet.

The used [directories](https://docs.activitywatch.net/en/latest/directories.html) are:

* Data: `~/.local/share/activitywatch`.
* Config: `~/.config/activitywatch`.
* Logs: `~/.cache/activitywatch/log`.
* Cache: `~/.cache/activitywatch`.

## [Watchers](https://docs.activitywatch.net/en/latest/watchers.html)

By default ActivityWatch comes with the next watchers:

* [aw-watcher-afk](https://github.com/ActivityWatch/aw-watcher-afk): Watches for
    mouse & keyboard activity to detect if the user is active.
* [aw-watcher-window](https://github.com/ActivityWatch/aw-watcher-window):
    Watches the active window and its title.

But you can add more, such as:

* [aw-watcher-web](https://github.com/ActivityWatch/aw-watcher-web): The
    official browser extension, supports Chrome and Firefox. Watches properties
    of the active tab like title, URL, and incognito state.

    It doesn't work if you [Configure it to Never remember
    history](https://github.com/ActivityWatch/aw-watcher-web/issues/32), or if
    you [use incognito mode](https://github.com/ActivityWatch/aw-watcher-web/pull/54)

    It's known not to be [very
    accurate](https://github.com/ActivityWatch/aw-watcher-web/issues/20). The
    overall time spent in the browser shown by the `aw-watcher-window` is
    greater than the one shown in `aw-watcher-web-firefox`.

* [aw-watcher-vim](https://github.com/ActivityWatch/aw-watcher-vim): Watches the
    actively edited file and associated metadata like path, language, and
    project name (folder name of git root).

    It's impressive, plug and play:

    ![ ](activitywatch_vim.png)

    It still doesn't [add the branch
    information](https://github.com/ActivityWatch/aw-watcher-vim/issues/19), it
    could be useful to give hints of what task you're working on inside
    a project.

They even show you how to [create your own
watcher](https://docs.activitywatch.net/en/latest/examples/writing-watchers.html).

# [Syncing](https://docs.activitywatch.net/en/latest/features/syncing.html)

There is [currently no syncing
support](https://github.com/ActivityWatch/activitywatch/issues/35). You'll need
to export the data (under `Raw Data`, `Export all buckets as JSON`), and either
tweak it so it can be imported, or analyze the data through other processes.

# Issues

* [Syncing support](https://github.com/ActivityWatch/activitywatch/issues/35):
    See how to merge the data from the different devices.
* [Firefox not logging
    data](https://github.com/ActivityWatch/aw-watcher-web/issues/32): Once it's
    solved, try it again.
* [Making it work in incognito
    mode](https://github.com/ActivityWatch/aw-watcher-web/pull/54): Try it once
    it's solved.
* [Add branch information in vim
    watcher](https://github.com/ActivityWatch/aw-watcher-vim/issues/19): try it
    once it's out.
* [Web tracking is not
    accurate](https://github.com/ActivityWatch/aw-watcher-web/issues/20): Test
    the solution once it's implemented.
* [Physical Activity Monitor Integration
    (gadgetbridge)](https://forum.activitywatch.net/t/physical-activity-monitor-integration-via-gadgetbridge-maybe/1121):
    Try it once there is a solution.

# References

* [Home](https://activitywatch.net/)
* [Docs](https://docs.activitywatch.net/en/latest/introduction.html)
* [Git](https://github.com/ActivityWatch/activitywatch)
