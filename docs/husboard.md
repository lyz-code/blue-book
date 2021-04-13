---
title: Hushboard
date: 2021-04-10
author: m0wer
tags:
---

[Hushboard](https://kryogenix.org/code/hushboard/) is an utility that mutes your
microphone while you’re typing.

# Installation

They recommend using the [Snap Store package](https://snapcraft.io/hushboard)
but you can also install it manually as follows:

```bash
sudo apt install libgirepository1.0-dev libcairo2-dev
mkvirtualenv hushboard
git clone https://github.com/stuartlangridge/hushboard
cd hushboard
pip install pycairo PyGObject six xlib
pip install .
deactivate
```

# Running the application

You can run it manually as follows

```bash
workon hushboard
python -m hushboard
deactivate
```

Or if you use i3wm, create the following script.

```bash
#!/usr/bin/env bash

source {WORKON_PATH}/hushboard/bin/activate
python -m hushboard
deactivate
```

You should replace `{WORKON_PATH}` with your virtual environments path. Then
add this line to your `i3wm` configuration file to start it automatically.

```
exec --no-startup-id ~/scripts/hushboard.sh
```

# Reference

* [M0wer Husboard article](https://m0wer.github.io/memento/computer_science/gnu_linux/hushboard/)
