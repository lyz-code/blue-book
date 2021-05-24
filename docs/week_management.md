---
title: Week Management
date: 20200219
author: Lyz
---

I've been polishing a week reviewing and planning method that suits my needs.
I usually follow it on Wednesdays, as I'm too busy on Mondays and Tuesdays and
it gives enough time to plan the weekend.

Until I've got [pydo](https://github.com/lyz-code/pydo) ready to natively
incorporate all this processes, I heavily use taskwarrior to manage my tasks and
logs. To make the process faster and reproducible, I've written small python
scripts using tasklib.

# Week review

Life logging is the only purpose of my weekly review.

I've made `diw` a small python script that for each overdue task allows me to:

* Review: Opens vim to write a diary entry related with the task. The text is
  saved as an annotation of the task and another form is filled to record whom
  I've shared it with. The last information is used to help me take care of
  people around me.
* Skip: Don't interact with this task.
* Done: Complete the task.
* Delete: Remove the task.
* Reschedule: Opens a form to specify the new due date.

# Week planning

The purpose of the planning is to make sure that I know what I need to do and
arrange all tasks in a way that allows me not to explode.

First I empty the *INBOX* file, refactoring all the information in the other knowledge
sinks. It's the place to go to quickly gather information, such as movie/book/serie
recommendations, human arrangements, miscellaneous thoughts or tasks. This file
lives in my mobile. I edit it with
[Markor](https://f-droid.org/packages/net.gsantner.markor/) and transfer it to
my computer with [Share via HTTP](https://f-droid.org/en/packages/com.MarcosDiez.shareviahttp/).

Taking different actions to each *INBOX* element type:

* Tasks or human arrangements: Do it if it can be completed in less than
  3 minutes. Otherwise, create a taskwarrior task.
* Behavior: Add it to taskwarrior.
* Movie/Serie recommendation: Introduce it into my media monitorization system.
* Book recommendation: Introduce into my library management system.
* Miscellaneous thoughts: Refactor into the blue-book, project documentation or
  Anki.

Then I split my workspace in two terminals, in the first I run `task due.before:7d
diary` where diary is a taskwarrior report that shows pending tasks that are not
in the backlog sorted by due date. On the other I:

* Execute `gcal .` to show the calendar of the previous, current and next month.
* Check the weather for the whole week to decide which plans are suitable.
* Analyze the tasks that need to be done answering the following questions:
  * Do I need to do this task this week? If not, reschedule or delete it.
  * Does it need a due date? If not, remove the `due` attribute.
    Having the minimum number of tasks with a fixed date reduces wasted
    rescheduling time and allows better prioritizing.
  * Can I do the task on the selected date? As most humans, I tend to
    underestimate both the required time to complete a task and to switch
    contexts. To avoid it, If the day is full it's better to reschedule.
* Check that every day has at least one task. Particularly tasks that will
  help with life logging.
* If there aren't enough things to fill up all days, check the *things that
  I want to do* list and try to do one.
