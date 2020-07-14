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

Normal processes exit with exit code 0. Access the program return code with
`RunningCommand.exit_code`:

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

The exception object has the `stderr` and `stdout` bytes attributes with the
errors, to show them use:

```python
except sh.ErrorReturnCode as e:
    print(str(e.stderr, 'utf8'))
```

## [Redirecting output](https://amoffat.github.io/sh/sections/redirection.html)

```python
sh.ifconfig(_out="/tmp/interfaces")
```

# References

* [Docs](https://amoffat.github.io/sh/index.html)
* [Git](https://github.com/amoffat/sh)
