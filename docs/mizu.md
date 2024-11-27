---
title: Mizu
date: 20220307
author: Lyz
---

[Mizu](https://getmizu.io/) is an API Traffic Viewer for Kubernetes, think `TCPDump` and Chrome Dev
Tools combined.

# [Installation](https://getmizu.io/docs/installing-mizu/installing-mizu)

```bash
curl -Lo mizu \
https://github.com/up9inc/mizu/releases/latest/download/mizu_linux_amd64 \
&& chmod 755 mizu
```

# Usage

At the core of Mizu functionality is [the pod tap](https://getmizu.io/docs/mizu/tapping-pods)

```bash
mizu tap <podname>
```

To view traffic of several pods, identified by a regular expression:

```bash
mizu tap "(catalo*|front-end*)"
```

After tapping your pods, Mizu will tell you that "Web interface is now available
at `https://localhost:8899/`. Visit the link from Mizu to view traffic in the [Mizu
UI](https://getmizu.io/docs/mizu/mizu-ui).

# References

* [Homepage](https://getmizu.io/)
* [Docs](https://getmizu.io/docs/)
