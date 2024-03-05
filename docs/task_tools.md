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
do, ideas you have thought of, notes, bills, etc…

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

I developed [`pynbox`](https://lyz-code.github.io/pynbox) to automate the
management of the inbox.

# Task manager

If you've never used a task manager, start with the [simplest
one](#the-simplest-task-manager) and see what do you feel its lacking. Choose
then a better task manager based on your needs.

In the past I've used [taskwarrior](https://taskwarrior.org/), but [its
limitations](https://lyz-code.github.io/pydo/#why-another-cli-task-manager) led
me to start creating [pydo](https://lyz-code.github.io/pydo) although I didn't finish it. Then I moved on to [the simplest task manager](#the-simplest-task-manager) but it eventually fell short in my needs, so I started working with [Openproject](#openproject) but working on a web interface is not for me, so now I'm migrating to [orgmode](orgmode.md).

## The simplest task manager

The simplest task manager is a markdown file in your computer with a list of
tasks to do. Annotate only the actionable tasks that you need to do today,
otherwise it can quickly grow to be unmanageable.

When you add a new item, choose it's location relative to the existent one based
on its priority. Being the top tasks are the ones that need to be done first.

~~~markdown
- Task with a high priority
- Task with low priority
~~~

The advantages of using a plaintext file over a physical notebook is that you
can use your editor skills to manage the elements more efficiently. For example
by reordering them or changing the description.

### Add task state sections

As the number of tasks starts to grow it will start to become unmanageable. One way of managing it is to use sections. For example:

- Doing: Track only the things you are actively doing
- Waiting: Track blocked tasks that need your monitoring
- To do: 

You can also start adding task information such as the reasons why a task is blocked.

~~~markdown
# Doing
- Unblocked task

# Waiting

- Blocked task
  - Waiting for Y to happen

# To do 

- Thing to do next week
~~~


### Divide a task in small steps

One of the main benefits of a task manager is that you free your mind of what
you need to do next, so you can focus on the task at hand. When a task is big
split it in smaller doable steps that drive to its completion. If the steps are
also big split them further with more indentation levels.

~~~markdown
- Complex task
  - Do X
  - Do Y
    - Do Z
    - Do W
~~~
### Simplest task manager limits

After using it for a while I found that:

* I lost a lot of time in the reviews.
* I lost a lot of time when doing the different plannings (year, trimester,
    month, week, day).
* I find it hard to organize and refine the backlog.
## Command line interface task managers
My love for the command line favours these solutions. I started my task management tool journey with Taskwarrior but some of it's limits made me start the development of `pydo` which ended in a dead end. Right now I'm using [orgmode](orgmode.md), and I'm loving it.
## Web based task managers

Life happened and when I gave up on the development of [pydo](https://lyz-code.github.io/pydo), and reached a point where [simplest
one](#the-simplest-task-manager) was [no longer suitable for my workflow](#simplest-task-manager-limits), I needed a solution that worked *on that day* better than
the simplest task manager. I did an analysis of the state of the art of
[self-hosted
applications](https://github.com/awesome-selfhosted/awesome-selfhosted#software-development---project-management) and 
of all of them the two that were more promising were [Taiga](#taiga) and
[OpenProject](#openproject).

I ended using OpenProject for a while but finally switched to [orgmode](orgmode.md).

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

# Pomodoro

Pomodoro is a technique used to ensure that for short periods of time, you
invest all your mental resources in doing the work needed to finish a task. It's
your main unit of work and a good starting point if you have concentration
issues.

When done well, you'll start moving faster on your tasks, because
[uninterrupted work](interruption_management.md) is the most efficient. You'll
also begin to know if you're drifting from your [day's plan](life_planning.md#day-plan), and
will have space to adapt it or the [task plan](life_planning.md#task-plan) to time constrains or
unexpected events.

!!! note "" If you don't yet have a [task plan](life_planning.md#task-plan) or
[day plan](life_planning.md#day-plan), don't worry! Ignore the steps that involve them until you
do.

The next steps define a Pomodoro cycle:

- Select the cycle time span. Either 20 minutes or until the next interruption,
  whichever is shortest.
- Decide what are you going to do.
- Analyze yourself to see if you're state of mind is ready to only do that for
  the chosen time span. If it's not, maybe you need to take a "Pomodoro break",
  take 20 minutes off doing something that replenish your willpower or the
  personal attribute that is preventing you to be able to work.
- Start the timer.
- Work uninterruptedly on what you've decided until the timer goes off.
- Take 20s to look away from the screen (this is good for your ejes).
- Update your [task](life_planning.md#task-plan) and [day](life_planning.md#day-plan) plans:
  - Tick off the done task steps.
  - Refine the task steps that can be addressed in the next cycle.
  - Check if you can still meet the day's plan.
- Check the
  [interruption channels that need to be checked each 20 minutes](interruption_management.md#define-your-interruption-events).

At the fourth Pomodoro cycle, you'll have finished a Pomodoro iteration. At the
end of the iteration:

- Check if you're going to meet the [day plan](life_planning.md#day), if you're not, change
  change it or the [task plan](life_planning.md#task) to make the time constrain.
- Get a small rest, you've earned it! Get off the chair, stretch or give a small
  walk. What's important is that you take your mind off the task at hand and let
  your body rest. Remember, this is a marathon, you need to take care of
  yourself.
- Start a new Pomodoro iteration.

If you're super focused at the end of a Pomodoro cycle, you can skip the task
plan update until the end of the iteration.

To make it easy to follow the pomodoro plan I use a script that:

- Uses [timer](https://github.com/pando85/timer) to show the countdown.
- Uses [safeeyes](https://github.com/slgobinath/SafeEyes) to track the eye
  rests.
- Asks me to follow the list of steps I've previously defined.

# References

* [GTD](https://en.wikipedia.org/wiki/Getting_Things_Done) time management
    framework.
