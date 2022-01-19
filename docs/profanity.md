---
title: profanity
date: 20220113
author: Lyz
---

[profanity](https://profanity-im.github.io/) is a console based XMPP client
written in C using ncurses and libstrophe, inspired by Irssi.

# [Installation](https://profanity-im.github.io/guide/0111/install.html)

```bash
sudo apt-get install profanity
```

# [Usage](https://profanity-im.github.io/guide/0111/basic.html)

## Connect

To connect to an XMPP chat service:

```
/connect user@server.com
```

You will be prompted by the status bar to enter your password.

## Send one to one message

To open a new window and send a message use the `/msg` command:

```
/msg mycontact@server.com Hello there!
```

Profanity uses the contact's nickname by default, if one exists. For example:

```
/msg Bob Are you there bob?
```

## Window navigation

To make a window visible in the main window area, use any of the following:

* `Alt-1` to `Alt-0`
* `F1` to `F10`
* `Alt-left`, `Alt-right`

The `/win` command may also be used. Either the window number may be passed, or
the window title:

```
/win 4
/win someroom@chatserver.org
/win MyBuddy
```

To close the current window:

```
/close
```

## Adding contacts

To add someone to your roster:

```
/roster add newfriend@server.chat.com
```

To subscribe to a contacts presence (to be notified when they are online/offline etc):

```
/sub request newfriend@server.chat.com
```

To approve a contact's request to subscribe to your presence:

```
/sub allow newfriend@server.chat.com
```
## Giving contacts a nickname

```
/roster nick bob@company.org Bobster
```

## Logging out

To quit profanity:

```
/quit
```

## Configure OMEMO

```
/omemo gen
/carbons on
```

# References

* [Home](https://profanity-im.github.io/)
* [Quickstart](https://profanity-im.github.io/guide/0111/basic.html)
