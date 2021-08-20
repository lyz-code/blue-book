---
title: mbsync
date: 20210820
author: Lyz
---

[mbsync](https://isync.sourceforge.io/mbsync.html) is a command line application
which synchronizes mailboxes; currently Maildir and IMAP4 mailboxes are
supported. New messages, message deletions and flag changes can be propagated
both ways; the operation set can be selected in a fine-grained manner.

# Installation

```bash
apt-get install isync
```

# [Configuration](https://github.com/pazz/alot/wiki/pazz's-mail-setup#fetching-mail-mbsync)

Assuming that you want to sync the mails of `example@examplehost.com` and that
you have your password stored in `pass` under `mail/example`.

!!! note "File: ~/.mbsyncrc"

    ```
    IMAPAccount example
    Host examplehost.com
    User "example@examplehost.com"
    PassCmd "/usr/bin/pass mail/example"

    IMAPStore example-remote
    Account example
    UseNamespace no

    MaildirStore example-local
    Path ~/mail/example/
    Inbox ~/mail/example/Inbox

    Channel example
    Master :example-remote:
    Slave :example-local:
    Create Both
    Patterns *
    SyncState *
    CopyArrivalDate yes
    Sync Pull
    ```

You need to manually create the directories where you store the emails.

```bash
mkdir -p ~/mail/example
```

# References

* [Homepage](https://isync.sourceforge.io/mbsync.html)
