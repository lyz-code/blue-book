---
title: Email management
date: 20210525
author: Lyz
---

Email can be one of the main aggregators of interruptions as it's
supported by almost everything. I use it as the notification backend of services that
don't need to be acted upon immediately or when more powerful mechanisms are not
available.

If not used wisely, it can be a sink of productivity.

# Analyze how often you need to check it

Follow the [interruption
analysis](interruption_management.md#interruption-analysis) to discover how
often you need to check it and if you need the notifications. Once you've
decided the frequency, try to respect it!. If you want an example, check my
[work](work_interruption_analysis.md#emails) or
[personal](personal_interruption_analysis.md#emails) analysis.

# Workflow

Each time I decide to go through my emails I follow the [inbox processing
guidelines](task_tools.md#inbox). I understand the email inbox are items
that need to be taken care of. If an email doesn't fall in that category I either
archive or delete it. That way the inbox has the smallest number of items, and
if everything went well, it is empty. Having an empty inbox helps you a lot to
reduce the mental load for many reasons:

* When you look at it and don't see any mail, you get the small satisfaction
    that you have done everything.
* When there is something new, it stands out, without the distraction of other
    email subjects that can drift your attention.

## Accounts shared by many people

On email accounts managed by many people, I delete/archive emails that I know
that need no interaction by any of them. If there is nothing for me to do,
I mark them as read and wait for them to archive/delete them. If an email is
left unread for 3 or 4 days I ask by other channels what should we do with that
event.

## Use email to transport information, not to store it

Email was envisioned as a protocol for person A to send information to person B.
The fact that the "free email providers" such as Google allow users to have
almost no limit on their inbox has driven people to store all their emails and
use it as a knowledge repository. This approach has many problems:

* As most people don't use end to end encryption (GPG), the data of their emails
    is available for the email provider to read. This is a privacy violation
    that leads to scary behaviours, such as targeted adds or google suggestions
    based on the content of recent emails. You could improve the situation by
    using POP3 instead of IMAP, but that'll force you to only use one device to
    check your email, something that's becoming uncommon.
* The decent email providers that respect you, such as [RiseUp](https://riseup.net/),
    [Autistici](https://www.autistici.org/) or
    [Disroot](https://disroot.org/en), are maintained by communities and can
    only offer a limited storage, so you're forced to empty your emails
    periodically to be able to receive new ones.
* If you don't spend time and effort classifying your emails, searching between
    them is a nightmare. It is even if you classify them. There are more
    efficient knowledge repositories to store your information.

On my personal emails, I forward the information to my archive, task manager or
knowledge manager, deleting the email afterwards. At work, they use an indecent
provider, encrypts most of emails with GPG and trust the provider to hold the
rest of the data. I try to leak the least amount of personal information and
I archive every email because you don't know when you're going to need them.

## Use key bindings

Using the mouse to interact with the email client graphical interface is not
efficient, try to learn the key bindings and use them as much as possible.

# Environment setup

## Account management

It's common to have more than one account to check. For example, at work, I have
my own account and another for each team I'm part of, the last ones are managed
by all the team members. On the personal level, I've got many accounts for the
different OpSec profiles or identities.

For efficiency reasons, you need to be able to check all of them on *one* place.
You can use an email manager such as
[Thunderbird](https://www.thunderbird.net/). Once you choose one, try to master
it.

## Isolate your work and personal environments

Make sure that you set your environment so that you can't check your personal
email when you're working and the other way around. For example, you could set
two Thunderbird profiles, or you could avoid configuring the work email in your
personal phone.

## Automatic filtering and processing

[Inbox management](#workflow) is time consuming, so you want to reduce
the number of emails to process. From the [interruption
analysis](interruption_management.md#interruption-analysis) you'll know which
ones don't give you any value, our goal is to make them disappear before we open
our inbox.

You can get rid of them by:

* Preventing the sender to send them: Unsubscribe from the newsletters you no
    longer read or fix the configuration of the services that send you
    notifications that don't want.
* Tweak your spam filter: If you have no control on the source, tweak your spam
    filter so that it filters them out for you.
* Use your email client filtering and processing features: If you want to
    receive the emails for archival purposes, configure your email client to
    match them by regular expressions on the sender or subject, mark them as
    read and move them to the desired directory.
* Use email automation software: If you want to run automatic processes
    triggered by emails, use [email automation
    solutions](projects.md#automate-email-management).

## Use your preferred editor to write the emails

You'll probably be less efficient with the email client's editor in comparison
with your own. If you use [vim](vim.md) or emacs, there's a good chance that the
email client has a plugin that allows you to use it. Or you can always migrate
to a command line client. I'll probably do that once I set up the [email
automation system](projects.md#automate-email-management).
