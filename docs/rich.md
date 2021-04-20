---
title: Rich
date: 20210420
author: Lyz
---

[Rich](https://github.com/willmcgugan/rich) is a Python library for rich text
and beautiful formatting in the terminal.

# [Installation](https://rich.readthedocs.io/en/latest/introduction.html#installation)

```bash
pip install rich
```

# Usage

## [Progress display](https://rich.readthedocs.io/en/latest/progress.html)

Rich can display continuously updated information regarding the progress of long
running tasks / file copies etc. The information displayed is configurable, the
default will display a description of the ‘task’, a progress bar, percentage
complete, and estimated time remaining.

Rich progress display supports multiple tasks, each with a bar and progress
information. You can use this to track concurrent tasks where the work is
happening in threads or processes.

It's beautiful, check it out with `python -m rich.progress`.

### [Basic Usage](https://rich.readthedocs.io/en/latest/progress.html#basic-usage)

For basic usage call the track() function, which accepts a sequence (such as
a list or range object) and an optional description of the job you are working
on. The track method will yield values from the sequence and update the progress
information on each iteration. Here’s an example:

```python
from rich.progress import track

for n in track(range(n), description="Processing..."):
    do_work(n)
```

# References

* [Git](https://github.com/willmcgugan/rich)
* [Docs](https://rich.readthedocs.io/en/latest/)
