---
title: notmuch
date: 20210820
author: Lyz
---

[notmuch](https://notmuchmail.org/) is a command-line based program for
indexing, searching, reading, and tagging large collections of email messages.

# [Installation](https://notmuchmail.org/getting-started/)

In order to use Notmuch, you will need to have your email messages stored in
your local filesystem, one message per file. You can use [`mbsync`](mbsync.md)
to do that.

```bash
sudo apt-get install notmuch
```

# Configuration

To configure Notmuch, just run

```bash
notmuch
```

This will interactively guide you through the setup process, and save the
configuration to `~/.notmuch-config`. If you'd like to change the configuration
in the future, you can either edit that file directly, or run `notmuch setup`.

If you plan to use [`afew`](afew.md) [set the tags to
`new`](https://afew.readthedocs.io/en/latest/configuration.html#notmuch-config).

To test everything works as expected, and create a database that indexes all of
your mail run:

```bash
notmuch new
```

# References

* [Docs](https://notmuchmail.org/)
