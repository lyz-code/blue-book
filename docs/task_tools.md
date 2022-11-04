---
title: Task Management tools
date: 20210526
author: Lyz
---

I currently use two tools to manage my tasks: the [inbox](#inbox) and the
[task manager](#task-manager).

# [Inbox](https://facilethings.com/blog/en/basics-empty-inbox)

The inbox does not refer only to your e-mail inbox. It is a broader concept that
includes all the elements you have collected in different ways: tasks you have to
do, ideas you have thought of, notes, bills, business cards, etc…

To achieve a stress-free productivity, emptying the inbox should be a daily
activity. Note that this does not mean doing things, it just means identifying
things and deciding what to do with them, when you get it done, your situation
is as follows:

* You have eliminated every thing you do not need.
* You have completed small actions that require no more than two minutes.
* You have delegated some actions that you do not have to do.
* You have sorted in your [task manager](#task-manager) the actions you will do
    when appropriate, because they require more than 2 minutes.
* You have sorted in your [task manager](#task-manager) or calendar the tasks
    that have a due date.
* There have been only a few minutes, but you feel pretty good. Everything is
    where it should be.

I've developed [`pynbox`](https://lyz-code.github.io/pynbox) to automate the
management of the inbox. Help out if you like it!

# Task manager

If you've never used a task manager, start with the [simplest
one](#the-simplest-task-manager) and see what do you feel its lacking. Choose
then a better task manager based on your needs.

In the past I've used [taskwarrior](https://taskwarrior.org/), but [its
limitations](https://lyz-code.github.io/pydo/#why-another-cli-task-manager) led
me to start creating [pydo](https://lyz-code.github.io/pydo) although it's still
not a usable project :(.

## The simplest task manager

The simplest task manager is a markdown file in your computer with a list of
tasks to do. Annotate only the actionable tasks that you need to do today,
otherwise it can quickly grow to be unmanageable.

When you add a new item, choose it's location relative to the existent one based
on its priority. Being the top tasks are the ones that need to be done first.

~~~markdown
* Task with a high priority
* Task with low priority
~~~

The advantages of using a plaintext file over a physical notebook is that you
can use your editor skills to manage the elements more efficiently. For example
by reordering them or changing the description.

### Add task state sections

You'll soon encounter tasks that become blocked but need your monitoring. You
can add a `# Blocked` section and move those tasks under it. You can optionally
add the reasons why it's blocked indented below the element.

~~~markdown
* Unblocked task

# Blocked

* Blocked task
  * Waiting for Y to happen
~~~

### Divide a task in small steps

One of the main benefits of a task manager is that you free your mind of what
you need to do next, so you can focus on the task at hand. When a task is big
split it in smaller doable steps that drive to its completion. If the steps are
also big split them further with more indentation levels.

~~~markdown
* Complex task
  * Do X
  * Do Y
    * Do Z
    * Do W
~~~

## Web based task manager

Life happened and the development of [pydo](https://lyz-code.github.io/pydo) has
fallen behind in my priority list. I've also reached a point where [simplest
one](#the-simplest-task-manager) is no longer suitable for my workflow because:

* I loose a lot of time in the reviews.
* I loose a lot of time when doing the different plannings (year, trimester,
    month, week, day).
* I find it hard to organize and refine the backlog.

As `pydo` is not ready yet and I need a solution that works *today* better than
the simplest task manager, I've done an analysis of the state of the art of
[self-hosted
applications](https://github.com/awesome-selfhosted/awesome-selfhosted#software-development---project-management)
of all of them the two that were more promising were [Taiga](#taiga) and
[OpenProject](#openproject).

### [Taiga](https://www.taiga.io/)

An Open source project with a lot of functionality. If you want to try it, you
can create an account at [Disroot](https://disroot.org) (an awesome collective
by the way). They have [set up an instance](https://board.disroot.org/) where
you can check if you like it.

Some facts made me finally not choose it, for example:

* Subtasks can't have subtasks. Something I've found myself having quite often.
    Specially if you refine your tasks in great detail.
* When browsing the backlog or the boards, you can't edit a task in that window,
    you need to open it in another tab.
* I don't understand very well the different components, the difference between
    tasks and issues for example.

### [OpenProject](openproject.md)

Check the [OpenProject](openproject.md) page to see the analysis of the tool.

In the end I went with this option.

# References

* [GTD](https://en.wikipedia.org/wiki/Getting_Things_Done) time management
    framework.
