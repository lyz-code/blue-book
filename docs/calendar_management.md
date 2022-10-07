---
title: Calendar Management
date: 20221007
author: Lyz
---

Since the break of my taskwarrior instance I've used a physical calendar to
manage the tasks that have a specific date. Can't wait for
the first version of [`pydo`](https://github.com/lyz-code/pydo) to be finished.

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

# [Khal](khal.md)

Looking at the available programs I found [`khal`](khal.md), which looks like
it may be up to the task.

Go through the [installation](khal.md#installation) steps and configure the
instance to have a local calendar.

If you want to sync your calendar events through CalDAV, you need to set
[vdirsyncer](vdirsyncer.md).
