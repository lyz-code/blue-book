---
title: ics
date: 20221008
author: Lyz
---

[ics](https://icspy.readthedocs.io/en/stable/index.html) is a pythonic iCalendar
library. Its goals are to read and write ics data in
a developer-friendly way.

# Installation

Install using pip:

```bash
pip install ics
```

# Usage

!!! warning "`ics` will delete all data that it doesn't understand. Maybe it's better for your case to build a parse for ics."

## Import a calendar from a file

```python
file = '/tmp/event.ics'

from ics import Calendar

with open(file, 'r') as fd:
    calendar = Calendar(fd.read())

# <Calendar with 118 events and 0 todo>
calendar.events

# {<Event 'Visite de "Fab Bike"' begin:2016-06-21T15:00:00+00:00 end:2016-06-21T17:00:00+00:00>,
# <Event 'Le lundi de l'embarqué: Adventure in Espressif Non OS SDK edition' begin:2018-02-19T17:00:00+00:00 end:2018-02-19T22:00:00+00:00>,
#  ...}
event = list(calendar.timeline)[0]
```

## Export a Calendar to a file

```python
with open('my.ics', 'w') as f:
    f.writelines(calendar.serialize_iter())
# And it's done !

# iCalendar-formatted data is also available in a string
calendar.serialize()
# 'BEGIN:VCALENDAR\nPRODID:...
```

# References

* [Docs](https://icspy.readthedocs.io/en/stable/index.html)
