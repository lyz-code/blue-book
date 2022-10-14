---
title: i3
date: 20221008
author: Lyz
---

[i3](https://i3wm.org/) is a tiling window manager.

# [Layout saving](https://i3wm.org/docs/layout-saving.html)

Layout saving/restoring allows you to load a JSON layout file so that you can
have a base layout to start working with after powering on your computer.

First of all arrange the windows in the workspace, then you can save the layout
of either a single workspace or an entire output:

```bash
i3-save-tree --workspace "1: terminal" > ~/.i3/workspace-1.json
```

You need to open the created file and remove the comments that match the desired
windows under the `swallows` keys, so transform the next snippet:

```json
    ...
    "swallows": [
        {
        //  "class": "^URxvt$",
        //  "instance": "^irssi$"
        }
    ]
    ...
```

Into:

```json
    ...
    "swallows": [
        {
            "class": "^URxvt$",
            "instance": "^irssi$"
        }
    ]
    ...
```

Once is ready close all the windows of the workspace you want to restore (moving
them away is not enough!).

Then on a terminal you can restore the layout with:

```bash
i3-msg 'workspace "1: terminal"; append_layout ~/.i3/workspace-1.json'
```

!!! warning "It's important that you don't use a relative path"

    Even if you're in `~/.i3/` you have to use `i3-msg append_layout
    ~/.i3/workspace-1.json`.

This command will create some fake windows (called placeholders) with the layout you had before, `i3`
will then wait for you to create the windows that match the selection criteria.
Once they are, it will put them in their respective placeholders.

If you wish to create the layouts at startup you can add the next snippet to
your i3 config.

```
exec --no-startup-id "i3-msg 'workspace \"1: terminal\"; append_layout ~/.i3/workspace-1.json'"
```

# References

* [Home](https://i3wm.org/)
