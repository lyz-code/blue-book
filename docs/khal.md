---
title: Khal
date: 20221007
author: Lyz
---

[`khal`](https://khal.readthedocs.io/en/latest/index.html) is a standards based
Python CLI (console) calendar program, able to synchronize with
[CalDAV](http://en.wikipedia.org/wiki/CalDAV) servers through
[`vdirsyncer`](vdirsyncer.md).

Features:

- Can read and write events/icalendars to vdir, so [`vdirsyncer`](vdirsyncer.md)
  can be used to synchronize calendars with a variety of other programs, for
  example CalDAV servers.
- Fast and easy way to add new events
- `ikhal` (interactive `khal`) lets you browse and edit calendars and events.

Limitations:

- It's not easy to get an idea of what you need to do in the week. At least not
  as comfortable as a graphical interface.
- Editing events with `ikhal` is a little bit cumbersome.

* Only rudimentary support for creating and editing recursion rules.
* You cannot edit the timezones of events.

# [Installation](https://khal.readthedocs.io/en/latest/install.html)

Although it's available in the major package managers, you can get a more
bleeding edge version with `pip`.

```bash
pipx install khal
```

If you don't have [`pipx`](pipx.md) you can use `pip`.

## [Configuration](https://khal.readthedocs.io/en/latest/configure.html)

`khal` reads configuration files in the ini syntax. If you do not have a
configuration file yet, running `khal configure` will launch a small,
interactive tool that should help you with initial configuration of khal.

`khal` is looking for configuration files in the following places and order:

- `$XDG_CONFIG_HOME/khal/config`: (on most systems this is
  `~/.config/khal/config`),
- `~/.khal/khal.conf` (deprecated)
- A `khal.conf` file in the current directory (deprecated).

Alternatively you can specify which configuration file to use with
`-c path/to/config` at runtime.

### [The calendars section](https://khal.readthedocs.io/en/latest/configure.html#the-calendars-section)

The `[calendars]` section is mandatory and must contain at least one subsection.
Every subsection must have a unique name (enclosed by two square brackets). Each
subsection needs exactly one path setting, everything else is optional. Here is
a small example:

```ini
[calendars]

  [[home]]
    path = ~/.calendars/home/
    color = dark green
    priority = 20

  [[work]]
    path = ~/.calendars/work/
    readonly = True
```

Some properties are:

- `path`: The path to an existing directory where this calendar is saved as a
  vdir.
- `color`: `khal` will use this color for coloring this calendar’s event. The
  following color names are supported: `black`, `white`, `brown`, `yellow`,
  `dark gray`, `dark green`, `dark blue`, `light gray`, `light green`,
  `light   blue`, `dark magenta`, `dark cyan`, `dark red`, `light magenta`,
  `light   cyan`, `light red`.
- `priority`: When coloring days, the color will be determined based on the
  calendar with the highest priority. If the priorities are equal, then the
  “multiple” color will be used.
- `readonly`: Setting this to True, will keep `khal` from making any changes to
  this calendar.

### [The default section](https://khal.readthedocs.io/en/latest/configure.html#the-calendars-section)

Some of this configurations do not affect `ikhal`.

- `default_calendar`: The calendar to use if none is specified for some
  operation (e.g. if adding a new event). If this is not set, such operations
  require an explicit value.
- `default_dayevent_duration`: Define the default duration for an event
  (`khal   new` only). `1h` by default.
- `default_event_duration`: Define the default duration for a day-long event
  (`khal  new` only). `1d` by default.
- `highlight_event_days`: If true, `khal` will highlight days with events.
  Options for highlighting are in
  [highlight_days](https://khal.readthedocs.io/en/latest/configure.html#the-highlight-days-section)
  section.

### [The key bindings section](https://khal.readthedocs.io/en/latest/configure.html#the-keybindings-section)

Key bindings for `ikhal` are set here. You can bind more than one key
(combination) to a command by supplying a comma-separated list of keys. For
binding key combinations concatenate them keys (with a space in between), for
example `ctrl n`.

| Action        | Default            | Description                                                                       |
| ------------- | ------------------ | --------------------------------------------------------------------------------- |
| down          | down, j            | Move the cursor down (in the calendar browser).                                   |
| up            | up, k              | Move the cursor up (in the calendar browser).                                     |
| left          | left, h, backspace | Move the cursor left (in the calendar browser).                                   |
| right         | right, l, space    | Move the cursor right (in the calendar browser).                                  |
| view          | enter              | Show details or edit (if details are already shown) the currently selected event. |
| save          | meta enter         | Save the currently edited event and leave the event editor.                       |
| quit          | q, Q               | Quit.                                                                             |
| new           | n                  | Create a new event on the selected date.                                          |
| delete        | d                  | Delete the currently selected event.                                              |
| search        | /                  | Open a text field to start a search for events.                                   |
| mark          | v                  | Go into highlight (visual) mode to choose a date range.                           |
| other         | o                  | In highlight mode go to the other end of the highlighted date range.              |
| today         | t                  | Focus the calendar browser on today.                                              |
| duplicate     | p                  | Duplicate the currently selected event.                                           |
| export        | e                  | Export event as a .ics file.                                                      |
| log           | L                  | Show logged messages.                                                             |
| external_edit | meta E             | Edit the currently selected events’ raw .ics file with $EDITOR                    |

Use the `external_edit` with caution, the icalendar library we use doesn't do a
lot of validation, it silently disregards most invalid data.

### [Syncing](https://khal.readthedocs.io/en/latest/configure.html#syncing)

To get `khal` working with CalDAV you will first need to setup
[`vdirsyncer`](vdirsyncer.md). After each start `khal` will automatically check
if anything has changed and automatically update its caching db (this may take
some time after the initial sync, especially for large calendar collections).
Therefore, you might want to execute `khal` automatically after syncing with
`vdirsyncer` (for example via `cron`).

# [Usage](https://khal.readthedocs.io/en/latest/usage.html)

`khal` offers a set of commands, most importantly:

- `list`: Shows all events scheduled for a given date (or datetime) range, with
  custom formatting.
- `calendar`: Shows a calendar (similar to cal(1)) and list.
- [`new`](#new): Allows for adding new events.
- `search`: Search for events matching a search string and print them.
- `at`: shows all events scheduled for a given datetime.
- [`edit`](https://khal.readthedocs.io/en/latest/usage.html#edit): An
  interactive command for editing and deleting events using a search string.
- `interactive`: Invokes the interactive version of `khal`, can also be invoked
  by calling `ikhal`.
- `printcalendars`:
- `printformats`

## [new](https://khal.readthedocs.io/en/latest/usage.html#new)

```
khal new [-a CALENDAR] [OPTIONS] [START [END | DELTA] [TIMEZONE] SUMMARY
[:: DESCRIPTION]]
```

Where `start` and `end` are either datetimes, times, or keywords and times in
the formats defined in the config file.

If no calendar is given via `-a`, the default calendar is used.

For example:

```bash
khal new 18:00 Awesome Event
```

Adds a new event starting today at 18:00 with summary `Awesome event` (lasting
for the default time of one hour) to the default calendar.

```bash
khal new tomorrow 16:30 Coffee Break
```

Adds a new event tomorrow at 16:30.

```bash
khal new 25.10. 18:00 24:00 Another Event :: with Alice and Bob
```

Adds a new event on 25th of October lasting from 18:00 to 24:00 with an
additional description.

```bash
khal new -a work 26.07. Great Event -g meeting -r weekly
```

Adds a new all day event on 26th of July to the calendar work in the meeting
category, which recurs every week.

## [Interactive](https://khal.readthedocs.io/en/latest/usage.html#interactive)

When the calendar on the left is in focus, you can:

- Move through the calendar (default keybindings are the arrow keys, space and
  backspace, those keybindings are configurable in the config file).

- Focus on the right column by pressing `tab` or `enter`.

- Focus on the current date, default keybinding `t` as in today.

- Marking a date range, default keybinding `v`, as in visual, think visual mode
  in Vim, pressing `esc` escapes this visual mode.

  If in visual mode, you can select the other end of the currently marked range,
  default keybinding `o` as in other (again as in Vim).

- Create a new event on the currently focused day (or date range if a range is
  selected), default keybinding `n`.

- Search for events, default keybinding `/`, a pop-up will ask for your search
  term.

When an event list is in focus, you can:

- View an event’s details with pressing enter (or tab) and edit it with pressing
  enter (or tab) again (if \[view\] `event_view_always_visible` is set to
  `True`, the event in focus will always be shown in detail).
- Toggle an event’s deletion status, default keybinding `d`, events marked for
  deletion will appear with a `D` in front and will be deleted when `khal`
  exits.
- Duplicate the selected event, default keybinding `p`
- Export the selected event, default keybinding `e`.

In the event editor, you can:

- Jump to the next (previous) selectable element with pressing `tab` (shift+tab)
- Quick save, default keybinding `meta+enter` (meta will probably be alt).
- Use some common editing short cuts in most text fields (ctrl+w deletes word
  before cursor, ctrl+u (ctrl+k) deletes till the beginning (end) of the line,
  ctrl+a (ctrl+e) will jump to the beginning (end) of the line.
- In the date and time fields you can increment and decrement the number under
  the cursor with `ctrl+a` and `ctrl+x` (time in 15 minute steps)
- In the date fields you can access a miniature calendar by pressing enter.
- Activate actions by pressing enter on text enclosed by angled brackets, e.g.
  \< Save > (sometimes this might open a pop up).

Pressing `esc` will cancel the current action and/or take you back to the
previously shown pane (i.e. what you see when you open ikhal), if you are at the
start pane, ikhal will quit on pressing esc again.

# Tricks

## Edit the events in a more pleasant way

The `ikhal` event editor is not comfortable for me. I usually only change the
title or the start date and in the default interface you need to press many
keystrokes to make it happen.

A patch solution is to pass a custom script on the `EDITOR` environmental
variable. Assuming you have [`questionary`](questionary.md) and [`ics`](ics.md)
installed you can save the next snippet into an `edit_event` file in your
`PATH`:

```python
#!/usr/bin/python3

"""Edit an ics calendar event."""

import sys

import questionary
from ics import Calendar

# Load the event
file = sys.argv[1]
with open(file, "r") as fd:
    calendar = Calendar(fd.read())
event = list(calendar.timeline)[0]

# Modify the event
event.name = questionary.text("Title: ", default=event.name).ask()
start = questionary.text(
    "Start: ",
    default=f"{str(event.begin.hour).zfill(2)}:{str(event.begin.minute).zfill(2)}",
).ask()
event.begin = event.begin.replace(
    hour=int(start.split(":")[0]), minute=int(start.split(":")[1])
)

# Save the event
with open(file, "w") as fd:
    fd.writelines(calendar.serialize_iter())
```

Now if you open `ikhal` as `EDITOR=edit_event ikhal`, whenever you edit one
event you'll get a better interface. Add to your `.zshrc` or `.bashrc`:

```bash
alias ikhal='EDITOR=edit_event ikhal'
```

The default keybinding for the edition is not very comfortable either, add the
next snippet on your config:

```ini
[keybindings]
external_edit = e
export = meta e
```

# References

- [Docs](https://khal.readthedocs.io/en/latest/index.html)
- [Git](https://github.com/pimutils/khal)
