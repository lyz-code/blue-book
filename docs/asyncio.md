---
title: Asyncio
date: 20210817
author: Lyz
---

[asyncio](https://docs.python.org/3/library/asyncio.html) is a library to write
concurrent code using the async/await syntax.

asyncio is used as a foundation for multiple Python asynchronous frameworks that
provide high-performance network and web-servers, database connection libraries,
distributed task queues, etc.

asyncio is often a perfect fit for IO-bound and high-level structured network
code.

!!! note
        "[Asyncer](https://asyncer.tiangolo.com/tutorial/) looks very useful"

# Tips

## [Limit concurrency](https://m0wer.github.io/memento/computer_science/programming/python/asyncio/#limit-concurrency)

Use [`asyncio.Semaphore`](https://docs.python.org/3/library/asyncio-sync.html#semaphores).

```python
sem = asyncio.Semaphore(10)
async with sem:
    # work with shared resource
```

Note that this method is not thread-safe.

# References

* [Docs](https://docs.python.org/3/library/asyncio.html#module-asyncio)
* [Awesome Asyncio](https://github.com/timofurrer/awesome-asyncio)
* [Roguelynn tutorial](https://www.roguelynn.com/words/asyncio-we-did-it-wrong/)

## Libraries to explore

* [Asyncer](https://github.com/tiangolo/asyncer)
