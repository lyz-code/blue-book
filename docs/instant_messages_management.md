---
title: Instant messages management
date: 20210525
author: Lyz
---

Instant messaging in all it's forms is becoming the main communication channel.

As any other input system, if not used wisely, it can be a sink of productivity.

# Analyze how often you need to check it

Follow the [interruption
analysis](interruption_management.md#interruption-analysis) to discover how
often you need to check it and if you need the notifications or fine grain them
to the sources that have higher priority. Once you've decided the frequency, try
to respect it!. If you want an example, check my
[work](work_interruption_analysis.md#instant-messages) or
[personal](personal_interruption_analysis.md#instant-messages) analysis.

# Workflow

I interact with messaging applications in two ways:

* To read the new items and answer questions.
* To start a conversation.

The passively reading for new items works perfectly with the [interruption
management](interruption_management.md) processes. Each time you decide to check
for new messages, follow the [inbox processing guidelines](task_tools.md#inbox)
to extract the information to the appropriate system (task manager, calendar or
knowledge manager). If you answer someone or if you start a new conversation,
assume that any work done in the next 5 to 10 minutes will probably be
interrupted, so choose small or mindless tasks. If the person doesn't answer in
that time, start a new
[pomodoro](time_management.md#minimize-the-context-switches) and go back when
the next interruption event comes.

## Use calls for non short conversations

Chats are good for short conversations that don't require long or quick
responses. Even though people may have forgotten it, they are an asynchronous
communication channel.

They're not suited for long conversations though as:

* Typing on a keyboard (or a mobile `ᕙ(⇀‸↼‶)ᕗ`) is slower than talking directly.
* It's difficult to transmit the conversation tone by message, and each reader
    can interpret it differently, leading to misunderstandings.
* If the conversation topic is complex, graphical aids such as screen sharing or
    doodling can make the conversation more efficient.
* Unless everyone involved is fully focused on the conversation, the delays
    between messages can be high, and all that time, the attendees need to
    manage the interruptions.
* If you fully focus on the conversation, you're loosing your time while you
    wait for the other to answer.

For all these reasons, whenever a conversation looks not to be short or trivial,
arrange a quick call or video call.

## At work or collectives, use group rooms over direct messages

Asking for help through direct messages should be avoided whenever possible,
instead of interrupting one person, it's better to ask in the group rooms
because:

* More people are reading, so you'll probably get answered sooner.
* Knowledge is spread throughout the group instead of isolated on specific
    people. Even if I don't answer a question, I read what others have
    said thus learning in the process.
* The responsibility of answering is shared between the group members, making
    it easier to define the *interruptions role*.

## Use threads or replies if the client allows it

Threads are a feature that allows people to have parallel conversations in the
same room in a way that the messages aren't mixed. This makes it easier to
maintain the focus and follow past messages. It also allows users that are not
interested, to silence the thread, so they won't get application or/and desktop
notifications on that particular topic.

Replies can be used when the conversation is not lengthy enough to open
a thread. They give the benefit of giving context to the user you're replying
to.

## Use chats to transport information, not to store it

Chat applications were envisioned as a protocol for person A to send information
to person B. The fact that the message providers allow users to have almost no
limit on their message history has driven people to use them as a knowledge
repository. This approach has many problems:

* As most people don't use end to end encryption (OMEMO/OTR/Signal), the data of
    their messages is available for the service provider to read. This is
    a privacy violation that should be avoided. Most providers don't allow you
    to set a message limit, so you'd have to delete them manually.
* Searching information in the chats is a nightmare. There are more
    efficient knowledge repositories to store your information.

## Use key bindings

Using the mouse to interact with the chat client graphical interfaces is not
efficient, try to learn the key bindings and use them as much as possible.

# Environment setup

## Account management

It's common to have more than one account or application to check. There are
many instant messaging solutions, such as XMPP, Signal, IRC, Telegram,
Slack, Whatssap or Facebook. It would be ideal to have a client that could act
as a bridge to all the solutions, but at least I don't know it, so you're forced
to install the different applications to interact with them.

The obvious suggestion would be to reduce the number of platforms in use, but we
all know that it's asking too much as it will probably isolate you from specific
people.

Once you have the minimum clients chosen, put them all on the same workspace,
for example an i3 window manager workspace, and only check them following the
[workflow](#workflow) rules.

## Isolate your work and personal environments

Make sure that you set your environment so that you can't check your personal
chats when you're working and the other way around. For example, you could
configure different instances of the chat clients and only open the ones that
you need to. Or you could avoid configuring the work clients in your personal
phone.

For example, at work, I have
my own account and another for each team I'm part of, the last ones are managed
by all the team members. On the personal level, I've got many accounts for the
different OpSec profiles or identities.

For efficiency reasons, you need to be able to check all of them on *one* place.
You can use an email manager such as
[Thunderbird](https://www.thunderbird.net/). Once you choose one, try to master
it.

## Fine grain configure the notifications

Modern client applications allow you to define the notifications at room or
people level. I usually:

* Use notifications on all messages on high priority channels. For example the
    [infrastructure monitorization](prometheus.md) one. Agree with your team to
    write as less as possible.
* Use notifications when mentioned on group rooms: Don't get notified on any
    message unless they add your name on it.
* Use notifications on direct messages: Decide which people are important enough
    to activate the notifications.

Sometimes the client applications don't give enough granularity, or you would
like to show notifications based on more complex conditions, that's why
I created the seed project to [improve the notification management in
Linux](projects.md#improve-the-notification-management-in-linux).
