---
title: Task Management
date: 20200131
author: Lyz
---

[Task management](https://en.wikipedia.org/wiki/Task_management) is the process
of managing a task through its life cycle. It involves planning, testing,
tracking, and reporting. Task management can help either individual achieve
goals, or groups of individuals collaborate and share knowledge for the
accomplishment of collective goals.

You can address task management at different levels. High level management
ensures that you choose your tasks in order to accomplish a goal, low level
management helps you get things done.

# Tools

I currently use two tools to manage the tasks: the [inbox](#inbox) and the
[task manager](#task-manager).

## [Inbox](https://facilethings.com/blog/en/basics-empty-inbox)

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

I've got a [seed project](projects.md#inbox-management) to automate the emptying
of the inbox. Help out if you like it!

## Task manager

If you've never used a task manager, start with the [simplest
one](#the-simplest-task-manager) and see what do you feel its lacking. Choose
then a better task manager based on your needs.

In the past I've used [taskwarrior](https://taskwarrior.org/), but [its
limitations](https://lyz-code.github.io/pydo/#why-another-cli-task-manager) led
me to start creating [pydo](https://lyz-code.github.io/pydo). I'll update this
section once I have a stable workflow with the new program.

### The simplest task manager

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

#### Add task state sections

You'll soon encounter tasks that become blocked but need your monitoring. You
can add a `# Blocked` section and move those tasks under it. You can optionally
add the reasons why it's blocked indented below the element.

~~~markdown
* Unblocked task

# Blocked

* Blocked task
  * Waiting for Y to happen
~~~

#### Divide a task in small steps

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

# Workflows

# Unconnected thoughts

* Stop monitoring tasks when it's already an habit and the process of tracking
  the task is greater than the benefits it gives in terms of emptying your mind.
* Only have actionable tasks in task manager, add the rest to the [projects
  page](projects.md).

# References

* [GTD](https://en.wikipedia.org/wiki/Getting_Things_Done) time management
    framework.
