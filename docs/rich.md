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

## [Tree](https://rich.readthedocs.io/en/latest/tree.html)

Rich has a [`Tree`](https://rich.readthedocs.io/en/latest/reference/tree.html#rich.tree.Tree) class which can generate a tree view in the terminal. A tree view is a great way of presenting the contents of a filesystem or any other hierarchical data. Each branch of the tree can have a label which may be text or any other Rich renderable.

The following code creates and prints a tree with a simple text label:

```python
from rich.tree import Tree
from rich import print

tree = Tree("Rich Tree")
print(tree)
```

With only a single `Tree` instance this will output nothing more than the text “Rich Tree”. Things get more interesting when we call `add()` to add more branches to the `Tree`. The following code adds two more branches:

```python
tree.add("foo")
tree.add("bar")
print(tree)
```

The `tree` will now have two branches connected to the original tree with guide lines.

When you call `add()` a new `Tree` instance is returned. You can use this instance to add more branches to, and build up a more complex tree. Let’s add a few more levels to the tree:

```python
baz_tree = tree.add("baz")
baz_tree.add("[red]Red").add("[green]Green").add("[blue]Blue")
print(tree)
```

# References

* [Git](https://github.com/willmcgugan/rich)
* [Docs](https://rich.readthedocs.io/en/latest/)
