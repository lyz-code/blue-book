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

## [Running in background](https://amoffat.github.io/sh/sections/asynchronous_execution.html?highlight=background#background-processes)

By default, each running command blocks until completion. If you have
a long-running command, you can put it in the background with the `_bg=True`
special kwarg:

```python
# blocks
sleep(3)
print("...3 seconds later")

# doesn't block
p = sleep(3, _bg=True)
print("prints immediately!")
p.wait()
print("...and 3 seconds later")
```

You’ll notice that you need to call `RunningCommand.wait()` in order to exit
after your command exits.

Commands launched in the background ignore `SIGHUP`, meaning that when their
controlling process (the session leader, if there is a controlling terminal)
exits, they will not be signalled by the kernel. But because `sh` commands launch
their processes in their own sessions by default, meaning they are their own
session leaders, ignoring `SIGHUP` will normally have no impact. So the only time
ignoring `SIGHUP` will do anything is if you use `_new_session=False`, in which case
the controlling process will probably be the shell from which you launched
python, and exiting that shell would normally send a `SIGHUP` to all child
processes.

If you want to terminate the process use `p.kill()`.

### [Output callbacks](https://amoffat.github.io/sh/sections/asynchronous_execution.html?highlight=background#output-callbacks)

In combination with `_bg=True`, `sh` can use callbacks to process output
incrementally by passing a callable function to `_out` and/or `_err`. This callable
will be called for each line (or chunk) of data that your command outputs:

```python
from sh import tail

def process_output(line):
    print(line)

p = tail("-f", "/var/log/some_log_file.log", _out=process_output, _bg=True)
p.wait()
```

To “quit” your callback, simply `return True`. This tells the command not to call
your callback anymore. This does not kill the process though see [Interactive
callbacks](#interactive-callbacks) for how to kill a process from a callback.

The line or chunk received by the callback can either be of type str or bytes. If the output could be decoded using the provided encoding, a str will be passed to the callback, otherwise it would be raw bytes.

### [Interactive callbacks](https://amoffat.github.io/sh/sections/asynchronous_execution.html?highlight=background#interactive-callbacks)

Commands may communicate with the underlying process interactively through
a specific callback signature. Each command launched through `sh` has an internal
STDIN `queue.Queue` that can be used from callbacks:

```python
    def interact(line, stdin):
        if line == "What... is the air-speed velocity of an unladen swallow?":
            stdin.put("What do you mean? An African or European swallow?")

        elif line == "Huh? I... I don't know that....AAAAGHHHHHH":
            cross_bridge()
            return True

        else:
            stdin.put("I don't know....AAGGHHHHH")
            return True

    p = sh.bridgekeeper(_out=interact, _bg=True)
p.wait()
```

You can also kill or terminate your process (or send any signal, really) from
your callback by adding a third argument to receive the process object:

```python
def process_output(line, stdin, process):
    print(line)
    if "ERROR" in line:
        process.kill()
        return True

p = tail("-f", "/var/log/some_log_file.log", _out=process_output, _bg=True)
```

The above code will run, printing lines from `some_log_file.log` until the word
`ERROR` appears in a line, at which point the tail process will be killed and
the script will end.

## Interacting with programs that ask input from the user

!!! note
    Check [the interactive
    callbacks](https://amoffat.github.io/sh/sections/asynchronous_execution.html?highlight=background#interactive-callbacks)
    or [this issue](https://github.com/amoffat/sh/issues/543), as it
    looks like a cleaner solution.

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

# [Testing](https://amoffat.github.io/sh/sections/faq.html#how-do-i-patch-sh-in-my-tests)

`sh` can be patched in your tests the typical way, with `unittest.mock.patch()`:

```python
from unittest.mock import patch
import sh

def get_something():
    return sh.pwd()

@patch("sh.pwd", create=True)
def test_something(pwd):
    pwd.return_value = "/"
    assert get_something() == "/"
```

The important thing to note here is that `create=True` is set. This is required
because `sh` is a bit magical and patch will fail to find the `pwd` command as an
attribute on the `sh` module.

You may also patch the `Command` class:

```python
from unittest.mock import patch
import sh

def get_something():
    pwd = sh.Command("pwd")
    return pwd()

@patch("sh.Command")
def test_something(Command):
    Command().return_value = "/"
    assert get_something() == "/"
```

Notice here we do not need `create=True`, because `Command` is not an
automatically generated object on the `sh` module (it actually exists).

# Tips

## [Avoid exception logging when killing a background process](https://stackoverflow.com/questions/44936743/using-the-sh-python-module-avoid-exception-logging-when-killing-a-background-pr)

In order to catch this exception execute your process with `_bg_exec=False` and
execute `p.wait()` if you want to handle the exception. Otherwise don't use the
`p.wait()`.

```python
p = sh.sleep(100, _bg=True, _bg_exc=False)
try:
    p.kill()
    p.wait()
except sh.SignalException_SIGKILL as err:
    print("foo")

foo
```

# References

* [Docs](https://amoffat.github.io/sh/index.html)
* [Git](https://github.com/amoffat/sh)
