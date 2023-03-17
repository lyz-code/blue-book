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

# [Move the focus to a container](https://i3wm.org/docs/userguide.html#_focusing_moving_containers)

Get the container identifier with `xprop` and then:

```bash
i3-msg '[title="khime"]' focus
i3-msg '[class="Firefox"]' focus
```

# Interact with Python

Install the `i3ipc` library:

```bash
pip install i3ipc
```

Create the connection object:

```python
from i3ipc import Connection, Event

# Create the Connection object that can be used to send commands and subscribe
# to events.
i3 = Connection()
```

Interact with i3:

```python

# Print the name of the focused window
focused = i3.get_tree().find_focused()
print('Focused window %s is on workspace %s' %
      (focused.name, focused.workspace().name))

# Query the ipc for outputs. The result is a list that represents the parsed
# reply of a command like `i3-msg -t get_outputs`.
outputs = i3.get_outputs()

print('Active outputs:')

for output in filter(lambda o: o.active, outputs):
    print(output.name)

# Send a command to be executed synchronously.
i3.command('focus left')

# Take all fullscreen windows out of fullscreen
for container in i3.get_tree().find_fullscreen():
    container.command('fullscreen')

# Print the names of all the containers in the tree
root = i3.get_tree()
print(root.name)
for con in root:
    print(con.name)

# Define a callback to be called when you switch workspaces.
def on_workspace_focus(self, e):
    # The first parameter is the connection to the ipc and the second is an object
    # with the data of the event sent from i3.
    if e.current:
        print('Windows on this workspace:')
        for w in e.current.leaves():
            print(w.name)

# Dynamically name your workspaces after the current window class
def on_window_focus(i3, e):
    focused = i3.get_tree().find_focused()
    ws_name = "%s:%s" % (focused.workspace().num, focused.window_class)
    i3.command('rename workspace to "%s"' % ws_name)

# Subscribe to events
i3.on(Event.WORKSPACE_FOCUS, on_workspace_focus)
i3.on(Event.WINDOW_FOCUS, on_window_focus)

# Start the main loop and wait for events to come in.
i3.main()
```

# References

* [Home](https://i3wm.org/)
* [`i3ipc` Docs](https://i3ipc-python.readthedocs.io/en/latest/)
* [`i3ipc` Source](https://github.com/altdesktop/i3ipc-python)
