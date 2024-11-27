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
    Inbox ~/mail/example/INBOX

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

# Troubleshooting

## [My emails are not being deleted on the source IMAP server](https://isync-devel.narkive.com/lC9HJC40/how-do-i-get-mbsync-to-remove-mail-on-the-imap-server)

That's the default behavior of `mbsync`, if you want it to actually delete the emails on the source you need to add:

```
Expunge Both
```
Under your channel (close to `Sync All`, `Create Both`)
```
```
## [mbsync error: UID is beyond highest assigned UID](https://stackoverflow.com/questions/39513469/mbsync-error-uid-is-beyond-highest-assigned-uid)

If during the sync you receive the following errors:

```
mbsync error: UID is 3 beyond highest assigned UID 1
```

Go to the place where `mbsync` is storing the emails and find the file that is giving the error, you need to find the files that contain `U=3`, imagine that it's something like `1568901502.26338_1.hostname,U=3:2,S`. You can strip off everything from the `,U=` from that filename and resync and it should be fine, e.g.

```bash
mv '1568901502.26338_1.hostname,U=3:2,S' '1568901502.26338_1.hostname'
```

# References

* [Homepage](https://isync.sourceforge.io/mbsync.html)
