---
title: SH
date: 20200714
author: Lyz
---

[sh](https://amoffat.github.io/sh/index.html) is a full-fledged subprocess
replacement so beautiful that makes you want to cry. It allows you to call any
program as if it were a function:

```python
from sh import ifconfig
print(ifconfig("wlan0"))
```

Output:

```python
wlan0   Link encap:Ethernet  HWaddr 00:00:00:00:00:00
        inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.0
        inet6 addr: ffff::ffff:ffff:ffff:fff/64 Scope:Link
        UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
        RX packets:0 errors:0 dropped:0 overruns:0 frame:0
        TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:1000
        RX bytes:0 (0 GB)  TX bytes:0 (0 GB)
```

Note that these aren't Python functions, these are running the binary commands
on your system by dynamically resolving your $PATH, much like Bash does, and
then wrapping the binary in a function. In this way, all the programs on your
system are available to you from within Python.

# Installation

```bash
pip install sh
```

# Usage

## Passing arguments

```python
sh.ls("-l", "/tmp", color="never")
```

If the command gives you a syntax error (like `pass`), you can use bash.

```python
sh.bash("-c", "pass")
```

## [Handling exceptions](https://amoffat.github.io/sh/sections/exit_codes.html)

Normal processes exit with exit code 0. You can access the program return code
with `RunningCommand.exit_code`:

```python
output = ls("/")
print(output.exit_code) # should be 0
```

If a process terminates, and the exit code is not 0, sh generates an exception
dynamically. This lets you catch a specific return code, or catch all error
return codes through the base class `ErrorReturnCode`:

```python
try:
    print(ls("/some/non-existant/folder"))
except sh.ErrorReturnCode_2:
    print("folder doesn't exist!")
    create_the_folder()
except sh.ErrorReturnCode:
    print("unknown error")
```

The exception object is an sh command object, which has, between other
, the `stderr` and `stdout` bytes attributes with the errors. To show them use:

```python
except sh.ErrorReturnCode as error:
    print(str(error.stderr, 'utf8'))
```

## [Redirecting output](https://amoffat.github.io/sh/sections/redirection.html)

```python
sh.ifconfig(_out="/tmp/interfaces")
```

## Interacting with programs that ask input from the user

`sh` allows you to interact with programs that asks for user input. The
documentation is not clear on how to do it, but between the [function
callbacks](https://amoffat.github.io/sh/sections/redirection.html#function-callback)
documentation, and the example on [how to enter an SSH
password](https://amoffat.github.io/sh/tutorials/interacting_with_processes.html#entering-an-ssh-password)
we can deduce how to do it.

Imagine we've got a python script that asks the user to enter a username so it
can save it in a file.

!!! note "File: /tmp/script.py"
    ```python
    answer = input("Enter username: ")

    with open("/tmp/user.txt", "w+") as f:
        f.write(answer)
    ```

When we run it in the terminal we get prompted and answer with `lyz`:

```bash
$: /tmp/script.py
Enter username: lyz

$: cat /tmp/user.txt
lyz
```

To achieve the same goal automatically with `sh` we'll need to use the function
callbacks. They are functions we pass to the sh command through the `_out`
argument.

```python
import sys
import re

aggregated = ""

def interact(char, stdin):
    global aggregated
    sys.stdout.write(char.encode())
    sys.stdout.flush()
    aggregated += char
    if re.search(r"Enter username: ", aggregated, re.MULTILINE):
        stdin.put("lyz\n")

sh.bash(
    "-c",
    "/tmp/script.py",
    _out=interact,
    _out_bufsize=0
)
```

In the example above we've created an `interact` function that will get called
on each character of the stdout of the command. It will be called on each
character because we passed the argument `_out_bufsize=0`. Check the [ssh
password
example](https://amoffat.github.io/sh/tutorials/interacting_with_processes.html#entering-an-ssh-password)
to see why we need that.

As it's run on each character, and we need to input the username once the
program is expecting us to enter the input and not before, we need to keep track
of all the printed characters through the global `aggregated` variable. Once the
regular expression matches what we want, sh will inject the desired value.

!!! warning ""
    Remember to add the `\n` at the end of the string you want to inject.

If the output never matches the regular expression, you'll enter an endless
loop, so you need to know before hand all the possible user input prompts.

# References

* [Docs](https://amoffat.github.io/sh/index.html)
* [Git](https://github.com/amoffat/sh)
