---
title: Personal Interruption Analysis
date: 20210524
author: Lyz
---

This is the [interruption
analysis](interruption_management.md#interruption-analysis) report applied to my
personal life.

I've identified the next interruption sources:

* [Physical interruptions](#physical-interruptions).
* [Emails](#emails).
* [Calls](#calls).
* [Instant message applications](#instant-messages).
* [Calendar events](#calendar-events).
* [Other desktop notifications](#desktop-notifications).

# Physical interruptions

The analysis is similar to the [work physical
interruptions](work_interruption_analysis.md#physical-interruptions).

# Emails

Email can be used as one of the main aggregators of interruptions as it's
supported by almost everything. I use it as the notification of things that
don't need to be acted upon immediately or when more powerful mechanisms are not
available. In my case emails can be categorized as:

* Bill or bank receipt emails: I receive at least one per provider per month,
    the associated action is to download the attached pdf and remove the email.
    I've got it automated using a Python program that I need to manually run. In
    the future I [expect it to be done automatically without my
    interaction](projects.md#automate-email-management). There is no urgency to
    act on them.
* General information: In the past I was subscribed to newsletters, now I prefer
    to use RSS. They don't usually require any direct action, so they can
    wait more than two days.
* Videogame deals: I was subscribed to Humblebundle, GOG and Steam notifications
    to be notified on the deals, but then I migrated to
    [IsThereAnyDeal](https://isthereanydeal.com) because it only sends the
    notifications of the deals that match a defined criteria (reducing the
    amount of emails), and monitors all sites in one place. I can act on them
    with one or two days of delay.
* Source code manager notifications: The web where I host my source code sends
    me emails when there are new pull requests or when there are comments on
    existent ones. I try to act on them daily.
* The [CI](ci.md) sends notifications when some job fails. Unless it's a new
    pipeline or I'm actively working on it, a failed work job can wait many days
    broken before I need to interact with ithe.
* Infrastructure notifications: For example LetsEncrypt renewals or cloud provider
    notification or support cases. The related actions can wait a day or more.
* Monitorization notifications: I've configured [Prometheus's
    alertmanager](prometheus.md) to send the notifications to the email as
    a fallback channel, but it's to be checked only if the main channel is down.
* Stranger emails: People whom I don't know that contacts me asking questions.
    These can be dealt with daily.

In conclusion, I can check the personal emails twice a day, one after
breakfast and another in the middle of the afternoon. So its safe to disable the
notifications.

I'm eager to start the [email automation
project](projects.md#automate-email-management) so I can spend even less time
and willpower managing the email.

# Calls

People are not used to call anymore, most of them prefer to chat. Even though it
is much less efficient. I prefer to have less frequent calls where you have full
focused interaction rather than many chat sessions.

I categorize the calls in two groups:

* Social interactions: managed similar as the [physical
    social interactions](work_interruption_analysis#social-interactions),
    with the people that I speak regularly, we arrange meetings that suit us
    both, the others I tell which are good time spans to call me. If the
    conversation allows it, I try to use headphones and simultaneously do
    mindless tasks such as folding the clothes or cleaning the kitchen. To
    prioritize and adjust the time between calls for each people I use
    [relationship management processes](relationship_management.md).
* Spam callers: Hateful events where you can't dump all the frustration that
    they produce on the person that calls you as it's not their fault and they
    surely are not enjoying either the situation. They have the lowest priority
    and can be safely ignored and blocked. You can manually do it in the phone,
    although it's not very effective as they change numbers. A better approach
    is to add your number to *do not call registries* which legally allow you to
    scare them off.

As calls are very rare and of high priority, I have my phone configured to ring
on incoming calls.

# Instant messages

It's the main communication channel for most people, so it has a great volume of
events but most have low priority. They can be categorized as:

* Asking for help through direct messages: We don't have many as we've agreed to
    [use groups as much as
    possible](instant_messages_management.md#at-work-or-collectives-use-group-rooms-over-direct-messages).
    So they have high priority and I have the notifications enabled.
* Social interaction through direct messages: I don't have many as I try to
    [arrange one on one calls
    instead](instant_messages_management#use-calls-for-non-short-conversations),
    so they have a low priority.
* Team group or support rooms: We've defined the *interruption role* so I check them
    whenever an chosen interruption event comes.
* Information rooms: They have no priority and can be checked daily.

In conclusion, I can check the personal chat applications three times per day,
for example, after each meal. As I usually need them when I'm off the computer,
I only have them configured at my mobile phone, with no sound notifications.
That way I only check them when I want to.

# Desktop notifications

I have none but I've seen people have a notification each time the music player
changes of song. It makes no sense at all.
