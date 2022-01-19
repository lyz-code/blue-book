---
title: pexpect
date: 20210130
author: Lyz
---

[pexpect](https://pexpect.readthedocs.io) is a pure Python module for spawning
child applications; controlling them; and responding to expected patterns in
their output. Pexpect works like Don Libes’ Expect. Pexpect allows your script
to spawn a child application and control it as if a human were typing commands.

# [Installation](https://pexpect.readthedocs.io/en/stable/install.html)

```bash
pip install pexpect
```

# Usage

```python
import pexpect

child = pexpect.spawn('ftp ftp.openbsd.org')
child.expect('Name .*: ')
child.sendline('anonymous')
```

If you're using it to spawn a program that asks something and then ends, you
can catch the end with `.expect_exact(pexpect.EOF)`.

```python
tui = pexpect.spawn("python source.py", timeout=5)
tui.expect("Give me .*")
tui.sendline("HI")
tui.expect_exact(pexpect.EOF)
```

The `timeout=5` is useful if the `pexpect` interaction is not well
defined, so that the script is not hung forever.

## Send key presses

To simulate key presses, you can use [prompt_toolkit](prompt_toolkit.md)
[keys](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/keys.py)
with
[REVERSE_ANSI_SEQUENCES](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/input/ansi_escape_sequences.py#L335).

```python
from prompt_toolkit.input.ansi_escape_sequences import REVERSE_ANSI_SEQUENCES
from prompt_toolkit.keys import Keys

tui = pexpect.spawn("python source.py", timeout=5)
tui.send(REVERSE_ANSI_SEQUENCES[Keys.ControlC])
```

To make your code cleaner you can use [a helper
class](https://github.com/copier-org/copier/blob/66d34d1dd35a55ad2a230dd1b0ce3c820089c971/tests/helpers.py):

```python
from prompt_toolkit.input.ansi_escape_sequences import REVERSE_ANSI_SEQUENCES
from prompt_toolkit.keys import Keys

class Keyboard(str, Enum):
    ControlH = REVERSE_ANSI_SEQUENCES[Keys.ControlH]
    Enter = "\r"
    Esc = REVERSE_ANSI_SEQUENCES[Keys.Escape]

    # Equivalent keystrokes in terminals; see python-prompt-toolkit for
    # further explanations
    Alt = Esc
    Backspace = ControlH
```

## [Read output of command](https://stackoverflow.com/questions/17632010/python-how-to-read-output-from-pexpect-child)

```python
import sys
import pexpect
child = pexpect.spawn('ls')
child.logfile = sys.stdout
child.expect(pexpect.EOF)
```

For the tests, you can use the [capsys](pytest.md#the-capsys-fixture) fixture to
do assertions on the content:

```python
out, err = capsys.readouterr()
assert "WARNING! you took 1 seconds to process the last element" in out
```


# References

* [Docs](https://pexpect.readthedocs.io)
