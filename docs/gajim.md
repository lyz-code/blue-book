---
title: Gajim
date: 20210520
author: Lyz
---

[Gajim](https://gajim.org/) is the best Linux XMPP client in terms of end-to-end
encryption support as it's able to speak OMEMO.

# Installation

```bash
sudo apt-get install gajim gajim-omemo
```

Once you open it, you need to enable the plugin in the main program dropdown.

The only problem I've encountered so far is that [OMEMO is not enabled by
default](https://dev.gajim.org/gajim/gajim-plugins/-/issues/319), they made
a [PR](https://dev.gajim.org/gajim/gajim/-/merge_requests/366/diffs) but closed
it because it encountered [some errors that was not able to
solve](https://dev.gajim.org/gajim/gajim/-/merge_requests/366#note_193183). It's
a crucial feature, so if you have some spare time and know a bit of Python
please try to fix it!

# Developing

I've found [the Developing section in the
wiki](https://dev.gajim.org/gajim/gajim/-/wikis/development/Development) to get
started.

# Issues

* [Enable encryption by
    default](https://dev.gajim.org/gajim/gajim-plugins/-/issues/319): Nothing to
    do.

# References

* [Homepage](https://gajim.org/)
