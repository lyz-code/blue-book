---
title: Python
date: 20210311
author: Lyz
---

[Python](https://en.wikipedia.org/wiki/Python_%28programming_language%29) is an
interpreted, high-level and general-purpose programming language. Python's
design philosophy emphasizes code readability with its notable use of
significant indentation. Its language constructs and object-oriented approach
aim to help programmers write clear, logical code for small and large-scale
projects.

# Install

```bash
apt-get install python
```

## [Install a specific version](https://bobcares.com/blog/how-to-install-python-3-9-on-debian-10/)

* Install dependencies
    ```bash
    sudo apt install wget software-properties-common build-essential libnss3-dev zlib1g-dev libgdbm-dev libncurses5-dev libssl-dev libffi-dev libreadline-dev libsqlite3-dev libbz2-dev
    ```

* Select the version in https://www.python.org/ftp/python/ and download it
    ```bash
    wget https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tgz
    cd Python-3.9.2/
    ./configure --enable-optimizations
    sudo make altinstall
    ```

# [Generators](https://realpython.com/introduction-to-python-generators/)

Generator functions are a special kind of function that return a lazy iterator.
These are objects that you can loop over like a list. However, unlike lists,
lazy iterators do not store their contents in memory.

An example would be an infinite sequence generator

```python
def infinite_sequence():
    num = 0
    while True:
        yield num
        num += 1
```

You can use it as a list:

```python
for i in infinite_sequence():
...     print(i, end=" ")
...
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
30 31 32 33 34 35 36 37 38 39 40 41 42
[...]
```

Instead of using a `for` loop, you can also call `next()` on the generator object
directly. This is especially useful for testing a generator in the console:.

```python
>>> gen = infinite_sequence()
>>> next(gen)
0
>>> next(gen)
1
>>> next(gen)
2
>>> next(gen)
3
```

## [Understanding Generators](https://realpython.com/introduction-to-python-generators/#understanding-generators)

Generator functions look and act just like regular functions, but with one
defining characteristic. Generator functions use the Python `yield` keyword
instead of `return`.

`yield` indicates where a value is sent back to the caller, but unlike `return`,
you don’t exit the function afterward.Instead, the state of the function is
remembered. That way, when `next()` is called on a generator object (either
explicitly or implicitly within a for loop), the previously yielded variable
`num` is incremented, and then yielded again.



# Interesting libraries to explore

* [di](https://www.adriangb.com/di/0.36.0/): a modern dependency injection
    system, modeled around the simplicity of FastAPI's dependency injection.
* [humanize](https://github.com/python-humanize/humanize): This modest package
    contains various common humanization utilities, like turning a number into
    a fuzzy human-readable duration ("3 minutes ago") or into a human-readable
    size or throughput.
* [tryceratops](https://github.com/guilatrova/tryceratops): A linter of
    exceptions.
* [schedule](https://github.com/dbader/schedule): Python job scheduling for
    humans. Run Python functions (or any other callable) periodically using
    a friendly syntax.
* [huey](https://github.com/coleifer/huey): a little task queue for python.
* [textual](https://github.com/willmcgugan/textual): Textual is a TUI (Text User
    Interface) framework for Python using Rich as a renderer.
* [parso](https://github.com/davidhalter/parso): Parses Python code.
* [kivi](https://kivy.org/): Create android/Linux/iOS/Windows applications with
    python. Use it with [kivimd](https://github.com/kivymd/KivyMD) to make it beautiful,
    check [the examples](https://github.com/HeaTTheatR/Articles) and the
    [docs](https://kivymd.readthedocs.io/en/latest/).

    For beginner tutorials check the [real
    python's](https://realpython.com/mobile-app-kivy-python/) and [towards data
    science](https://towardsdatascience.com/building-android-apps-with-python-part-1-603820bebde8?gi=9a0166808127)
    (and [part
    2](https://medium.com/swlh/building-android-apps-with-python-part-2-1d8e78ef9166)).
* [apprise](https://github.com/caronc/apprise): Allows you to send
    a notification to almost all of the most popular notification services
    available to us today such as: Linux, Telegram, Discord, Slack, Amazon SNS,
    Gotify, etc. Look at [all the supported
    notifications](https://github.com/caronc/apprise#supported-notifications)
    `(¬º-°)¬`.
* [aiomultiprocess](https://github.com/omnilib/aiomultiprocess): Presents
    a simple interface, while running a full AsyncIO event loop on each child
    process, enabling levels of concurrency never before seen in a Python
    application. Each child process can execute multiple coroutines at once,
    limited only by the workload and number of cores available.
* [twint](https://github.com/twintproject/twint): An advanced Twitter scraping
    & OSINT tool written in Python that doesn't use Twitter's API, allowing you
    to scrape a user's followers, following, Tweets and more while evading most
    API limitations. Maybe use `snscrape` (is below) if `twint` doesn't work.
* [snscrape](https://github.com/JustAnotherArchivist/snscrape): A social
    networking service scraper in Python.
* [tweepy](https://github.com/tweepy/tweepy): Twitter for Python.

# Interesting sources

* [Musa 550](https://musa-550-fall-2020.github.io/) looks like a nice way to
    learn how to process geolocation data.
