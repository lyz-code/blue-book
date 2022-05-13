---
title: Anki
date: 20220513
author: Lyz
---

[Anki](https://apps.ankiweb.net/) is a program which makes remembering things
easy. Because it's a lot more efficient than traditional study methods, you can
either greatly decrease your time spent studying, or greatly increase the amount
you learn.

Anyone who needs to remember things in their daily life can benefit from Anki.
Since it is content-agnostic and supports images, audio, videos and scientific
markup (via LaTeX), the possibilities are endless.

# Interacting with python

Although there are some python libraries:

* [genanki](https://github.com/kerrickstaley/genanki)
* [py-anki](https://pypi.org/project/py-anki/)

I think the best way is to use [AnkiConnect](https://foosoft.net/projects/anki-connect/)

The installation process is similar to other Anki plugins and can be accomplished in three steps:

* Open the *Install Add-on* dialog by selecting *Tools | Add-ons | Get
    Add-ons...* in Anki.
* Input `2055492159` into the text box labeled *Code* and press the *OK* button to
    proceed.
* Restart Anki when prompted to do so in order to complete the installation of
    Anki-Connect.

Anki must be kept running in the background in order for other applications to
be able to use Anki-Connect. You can verify that Anki-Connect is running at any
time by accessing `localhost:8765` in your browser. If the server is running, you
will see the message Anki-Connect displayed in your browser window.

## Get all decks

Curl:

```bash
curl localhost:8765 -X POST -d '{"action": "deckNames", "version": 6}'
```

# References

* [Homepage](https://apps.ankiweb.net/)
* [Anki-Connect reference](https://foosoft.net/projects/anki-connect/)
