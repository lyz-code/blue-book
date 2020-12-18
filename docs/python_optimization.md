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

# References

* [Satwik Kansal article on Scout APM](https://scoutapm.com/blog/identifying-bottlenecks-and-optimizing-performance-in-a-python-codebase)
