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

## [Tables](https://rich.readthedocs.io/en/latest/tables.html)

```python
from rich.console import Console
from rich.table import Table

table = Table(title="Star Wars Movies")

table.add_column("Released", justify="right", style="cyan", no_wrap=True)
table.add_column("Title", style="magenta")
table.add_column("Box Office", justify="right", style="green")

table.add_row("Dec 20, 2019", "Star Wars: The Rise of Skywalker", "$952,110,690")
table.add_row("May 25, 2018", "Solo: A Star Wars Story", "$393,151,347")
table.add_row("Dec 15, 2017", "Star Wars Ep. V111: The Last Jedi", "$1,332,539,889")
table.add_row("Dec 16, 2016", "Rogue One: A Star Wars Story", "$1,332,439,889")

console = Console()
console.print(table)
```

## [Rich text](https://rich.readthedocs.io/en/latest/text.html)

```python
from rich.console import Console
from rich.text import Text

console = Console()
text = Text.assemble(("Hello", "bold magenta"), " World!")
console.print(text)
```

## [Live display text](https://rich.readthedocs.io/en/latest/live.html)

```python
import time

from rich.live import Live

with Live("Test") as live:
    for row in range(12):
        live.update(f"Test {row}")
        time.sleep(0.4)
```

If you don't want the text to have the default colors, you can embed it all in
a `Text` object.

# References

* [Git](https://github.com/willmcgugan/rich)
* [Docs](https://rich.readthedocs.io/en/latest/)
