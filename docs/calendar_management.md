---
title: Calendar Management
date: 20221007
author: Lyz
---

# Calendar solutions
Since the break of my taskwarrior instance I've used a physical calendar to
manage the tasks that have a specific date. 

The next factors made me search for a temporal solution:

* It's taking longer than expected.
* I've started using a nextcloud calendar with some friends.
* I frequently use Google calendar at work.
* I'm sick of having to log in Nexcloud and Google to get the day's
    appointments.

To fulfill my needs the solution needs to:

* Import calendar events from different sources, basically through
    the [CalDAV](http://en.wikipedia.org/wiki/CalDAV) protocol.
* Have a usable terminal user interface
* Optionally have a command line interface or python library so it's easy to make scripts.
* Optionally it can be based in python so it's easy to contribute
* Support having a personal calendar mixed with the shared ones.
* Show all calendars in the same interface

## [Khal](khal.md)

Looking at the available programs I found [`khal`](khal.md), which looks like
it may be up to the task.

Go through the [installation](khal.md#installation) steps and configure the
instance to have a local calendar.

If you want to sync your calendar events through CalDAV, you need to set
[vdirsyncer](vdirsyncer.md).

# Calendar event notification system
Set up a system that notifies you when the next calendar event is about to start to avoid spending mental load on it and to reduce the possibilities of missing the event.

I've created a small tool that:

- Tells me the number of [pomodoros](roadmap_tools.md#pomodoro) that I have until the next event.
- Once a pomodoro finishes it makes me focus on the amount left so that I can prepare for the event
- Catches my attention when the event is starting.
