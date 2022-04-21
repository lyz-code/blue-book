---
title: Python Optimization
date: 20201218
author: Lyz
---

Optimization can be done through different metrics, such as, CPU performance
(execution time) or memory footprint.

Optimizing your code makes sense when you are sure that the business logic in
the code is correct and not going to change soon.

!!! quote ""
    "First make it work. Then make it right. Then make it fast." ~ Kent Beck

Unless you're developing a performance-intensive product or a code dependency
that is going to be used by other projects which might be performance-intensive,
optimizing every aspect of the code can be overkill. For most of the scenarios,
the 80-20 principle (80 percent of performance benefits may come from optimizing
20 percent of your code) will be more appropriate.

Most of the time we make intuitive guesses on what the bottlenecks are, but more
often than not, our guesses are either wrong or just approximately correct. So,
it's always advisable to use [profiling tools](python_profiling.md) to identify
how often a resource is used and who is using the resource. For instance,
a profiler designed for profiling execution time will measure how often and for
how various long parts of the code are executed. Using a profiling mechanism
becomes a necessity when the codebase grows large, and you still want to
maintain efficiency.

# [Making Python command line fast](https://files.bemusement.org/talks/OSDC2008-FastPython/)

People like using software that feels fast, and Python programs tend to be slow
to start running. What qualifies as *fast* is subjective, and varies by the type
of tool and by the user's expectations.

Roughly speaking, for a command line program, people expect results almost
instantaneously. For a tool that appears to be doing a simple task a sub-second
result is enough, but under 200ms is even better.

Obviously to achieve this, your program actually has to be fast at doing its
work. But what if you've written your code in Python, and it can take 800ms just
to import your code, let alone start running it.

## [How fast can a Python program be?](https://files.bemusement.org/talks/OSDC2008-FastPython/)

TBC with the next sources

* https://files.bemusement.org/talks/OSDC2008-FastPython/
* https://files.bemusement.org/talks/OSDC2008-FastPython/
* https://stackoverflow.com/questions/4177735/best-practice-for-lazy-loading-python-modules
* https://snarky.ca/lazy-importing-in-python-3-7/
* https://levelup.gitconnected.com/python-trick-lazy-module-loading-df9b9dc111af

## Minimize the relative import statements on command line tools

When developing a library, it's common to expose the main objects into the
package `__init__.py` under the variable `__all__`. The problem with command
line programs is that each time you run the command it will load those objects,
which can mean an increase of 0.5s or even a second for each command, which is
unacceptable.

Following this string, if you manage to minimize the relative imports, you'll
make your code faster.

[Python's
wiki](https://wiki.python.org/moin/PythonSpeed/PerformanceTips#Import_Statement_Overhead)
discusses different places to locate your import statements. If you put them on
the top, the imports that you don't need for that command in particular will
worsen your load time, if you add them inside the functions, if you run the
function more than once, the performance drops too, and it's a common etiquete
to have all your imports on the top.

One step that you can do is to mark the imports required for type checking under
a conditional:

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
   from model import Object
```

This change can be negligible, and it will force you to use `'Object'`, instead
of `Object` in the typing information, which is not nice, so it may not be worth
it.

If you are still unable to make the loading time drop below an acceptable time,
you can migrate to a server-client architecture, where all the logic is loaded
by the backend (once as it's always running), and have a "silly" client that
only does requests to the backend. Beware though, as you will add the network
latency.

## Don't dynamically install the package

If you install the package with `pip install -e .` you will see an increase on
the load time of ~0.2s. It is useful to develop the package, but when you use
it, do so from a virtualenv that installs it directly without the `-e` flag.

# References

* [Satwik Kansal article on Scout APM](https://scoutapm.com/blog/identifying-bottlenecks-and-optimizing-performance-in-a-python-codebase)
