---
title: Work Interruption Analysis
date: 20210524
author: Lyz
---

This is the [interruption
analysis](interruption_management.md#interruption-analysis) report applied to my
everyday work.

I've identified the next interruption sources:

* [Physical interruptions](#physical-interruptions).
* [Emails](#emails).
* [Calls](#calls).
* [Instant message applications](#instant-messages).
* [Calendar events](#calendar-events).

# Physical interruptions

Physical interactions are when someone comes to your desk and expect you to
attend them immediately. These interruptions can be categorized as:

* [Asking for help](#asking-for-help).
* [Social interactions](#social-interactions).

The obvious solution is to remote work as much as possible. It's less easy for
people to interrupt through digital channels than physically.

It goes the other way around too. Be respectful to your colleagues and try to
use asynchronous communications as much as possible, so they can manage when
they attend you.

## Asking for help

These interruptions are the most difficult to delay, as it's hard to tell
a person to wait when it's already in front of you. If you don't take care of
them you may end up in the situation where you can receive 5 o 6 interruptions per
minute which can drive you crazy. By definition all these events require an
immediate action. The priority and delay may depend on many factors, such as
the person or moment.

The first thing I'd do is make a mental prioritization of the people that
interrupt you, to decide which ones do you accept and which ones you need to
regulate. Once you have it, work on how to assertively tell them that they need
to reduce their interruptions. You can agree with them a non interruption time
where they can aggregate and prepare all the questions so you can work through
them efficiently. Often they are able to answer most of them themselves. The
length of the period needs to be picked wisely as you want to be interrupted the
minimum number of times while you don't make them loose their time trying to
solve something you could work out quickly.

Other times it's easier to forward them to the team's *interruption manager*.

## Social interactions

Depending how popular you are, you'll have more or less of these interactions.
The way I've found to be able to be in control of them is by scheduling social
events in my calendar and introducing them in my task management workflow. For
example, we agree to go to have lunch all together at the same hour every day,
or I arrange a coffee break with someone every Monday at a defined hour.

# Emails

Email can be used as one of the main aggregators of interruptions as it's
supported by almost everything. I use it as the notification of things that
don't need to be acted upon immediately or when more powerful mechanisms are not
available. In my case emails can be categorized as:

* General information: They don't usually require any direct action, so they can
    wait more than 24 hours.
* Support to internal agents: At work, we have decided that email is not to be
    used as the internal main communication channel, so I don't receive many and
    their priority is low.
* Support to external agents: I'm lucky to not have many of these and they have
    less priority than internal people so they can wait 4 or more hours.
* Infrastructure notifications: For example LetsEncrypt renewals or cloud provider
    notification or support cases. The related actions can wait 4 hours or more.
* Calendar events: Someone creates a new meeting, changes an existing one or
    confirms/declines its assistance. We have defined a policy that we don't
    create or change events with less than 24 hours notice, and in the special
    cases that we need to, they will be addressed in the chat rooms. So these
    mails can be read once per day.
* Monitorization notifications: We've configured [Prometheus's
    alertmanager](prometheus.md) to send the notifications to the email as
    a fallback channel, but it's to be checked only if the main channel is down.
* Source code manager notifications: The web where we host our source code sends
    us emails when there are new pull requests or when there are comments on
    existent ones. I automatically mark them as read and move them to a mail
    directory as I manage these interruptions with other workflow.
* The [CI](ci.md) sends notifications when some job fails. Unless it's a new
    pipeline or I'm actively working on it, a failed job can wait four
    hours broken before I interact with it.
* The issue tracker notifications: It sends them on new or changed issues.
    At work, I filter them out as I delegate it's management to the Scrum
    Master.

In conclusion, I can check the work email only when I start working, on the
lunch break and when I'm about to leave. So its safe to disable the
notifications.

I'm eager to start the [email automation
project](projects.md#automate-email-management) so I can spend even less time
and willpower managing the email.

# Calls

We've agreed that the calls are the communication channel used only for critical
situations, similar to the [physical interruptions](#physical-interruptions),
they are synchronous so they're more difficult to manage.

As calls are very rare and of high priority, I have my phone configured to ring
on incoming calls.

!!! note "Have a work phone independent of your personal"

    Nowadays you can have phone contracts of 0$/month used only to receive
    calls.

    Remember to give it to the fewer people as possible.

# Instant messages

It's the main internal communication channel, so it has a great volume of events
with a wide range of priorities. They can be categorized as:

* Asking for help through direct messages: We don't have many as we've agreed to
    [use groups as much as
    possible](instant_messages_management.md#at-work-or-collectives-use-group-rooms-over-direct-messages).
    So they have high priority and I have the notifications enabled.
* Social interaction through direct messages: I don't have many as I try to
    [arrange one on one meetings
    instead](instant_messages_management#use-calls-for-non-short-conversations),
    so they have a low priority. As notifications are defined for all direct
    messages, I inherit the notifications from the last category.
* Team group or support rooms: We've defined the *interruption role* so I check them
    whenever an chosen interruption event comes. If I'm assuming the role
    I enable the notifications on the channel, if not I'll check them whenever
    I check the application.
* Information rooms: They have no priority and can be checked each 4 hours.

In conclusion, I can check the work chat applications each pomodoro cycle or
when I receive a direct notification until the [improve the notification management in
Linux](projects.md#improve-the-notification-management-in-linux) project is ready.

# Calendar events

Often with a wide range of priorities.

* decide if you have to go
* Define an agenda with times
