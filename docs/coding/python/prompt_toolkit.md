---
title: Python Prompt Toolkit
date: 20200827
author: Lyz
---

[Python Prompt Toolkit](https://python-prompt-toolkit.readthedocs.io/en/master/)
is a library for building powerful interactive command line and terminal
applications in Python.

# [Installation](https://python-prompt-toolkit.readthedocs.io/en/master/pages/getting_started.html#installation)

```bash
pip install prompt_toolkit
```

# Usage

## [A simple prompt](https://python-prompt-toolkit.readthedocs.io/en/master/pages/getting_started.html#a-simple-prompt)

The following snippet is the most simple example, it uses the `prompt()` function
to asks the user for input and returns the text. Just like `(raw_)input`.

```python
from prompt_toolkit import prompt

text = prompt('Give me some input: ')
print('You said: %s' % text)
```

It can be used to build [REPL applications](prompt_toolkit_repl) or [full screen
ones](prompt_toolkit_fullscreen_applications.md).
