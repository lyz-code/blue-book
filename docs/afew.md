---
title: afew
date: 20210820
author: Lyz
---

[afew](https://github.com/afewmail/afew) is an [initial tagging
script](http://notmuchmail.org/initial_tagging/) for [notmuch
mail](notmuch.md).

Its basic task is to provide automatic tagging each time new mail is registered
with `notmuch`. In a classic setup, you might call it after `notmuch new` in an
offlineimap post sync hook.

It can do basic thing such as adding tags based on email headers or maildir
folders, handling killed threads and spam.

In move mode, afew will move mails between maildir folders according to
configurable rules that can contain arbitrary notmuch queries to match against
any searchable attributes.

# [Installation](https://afew.readthedocs.io/en/latest/installation.html)

First install the requirements:

```bash
sudo apt-get install notmuch python-notmuch python-dev python-setuptools
```

Then configure [`notmuch`](notmuch.md#installation).

Finally install the program:

```bash
pip3 install afew
```

# Usage

To tag new emails use:

```bash
afew -v --tag --new
```

# References

* [Git](https://github.com/afewmail/afew)
* [Docs](https://afew.readthedocs.io/en/latest/)
