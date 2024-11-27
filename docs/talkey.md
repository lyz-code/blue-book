---
title: Talkey
date: 20201120
author: Lyz
---

[Talkey](https://github.com/grigi/talkey) is a Simple Text-To-Speech (TTS)
interface library with multi-language and multi-engine support.

# Installation

```bash
pip install talkey
```

You need to install the TTS engines by yourself. Talkey supports:

* Flite
* SVOX Pico
* Festival
* eSpeak
* mbrola via eSpeak

I've tried SVOX Pico, Festival and eSpeak. I've discarded Flite because it's not
in the official repositories. Of those three the one that gives the most natural
support is SVOX Pico. To install it execute:

```bash
sudo apt-get install libttspico-utils
```

It also supports the following networked TTS Engines:

* MaryTTS (needs hosting).
* Google TTS (cloud hosted)

I obviously discard Google for privacy reasons, and MaryTTS too because it needs
you to run a server, which is inconvenient for most users and pico gives us
enough quality.

# Usage

At its simplest use case:

```python
import talkey
tts = talkey.Talkey()
tts.say("I've been really busy being dead. You know, after you murdered me.")
```

It automatically detects languages without any further configuration:

```python
tts.say("La cabra siempre tira al monte")
```

# References

* [Git](https://github.com/grigi/talkey)
* [Docs](http://talkey.readthedocs.org/)
