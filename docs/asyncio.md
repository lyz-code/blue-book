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

# Basic concepts

## [Concurrency](https://realpython.com/async-io-python/#async-io-explained)

Concurrency is best explained by an example stolen from [Miguel Grinberg](https://youtu.be/iG6fr81xHKA?t=4m29s).

Chess master Judit Polgár hosts a chess exhibition in which she plays multiple amateur players. She has two ways of conducting the exhibition: synchronously and asynchronously.

Assumptions:

- 24 opponents
- Judit makes each chess move in 5 seconds
- Opponents each take 55 seconds to make a move
- Games average 30 pair-moves (60 moves total)

Synchronous version: Judit plays one game at a time, never two at the same time, until the game is complete. Each game takes (55 + 5) * 30 == 1800 seconds, or 30 minutes. The entire exhibition takes 24 * 30 == 720 minutes, or 12 hours.

Asynchronous version: Judit moves from table to table, making one move at each table. She leaves the table and lets the opponent make their next move during the wait time. One move on all 24 games takes Judit 24 * 5 == 120 seconds, or 2 minutes. The entire exhibition is now cut down to 120 * 30 == 3600 seconds, or just 1 hour.

Async IO takes long waiting periods in which functions would otherwise be blocking and allows other functions to run during that downtime. (A function that blocks effectively forbids others from running from the time that it starts until the time that it returns.)

## [AsyncIO is not easy](https://realpython.com/async-io-python/#async-io-is-not-easy)

You may have heard the phrase “Use async IO when you can; use threading when you must.” The truth is that building durable multithreaded code can be hard and error-prone. Async IO avoids some of the potential speedbumps that you might otherwise encounter with a threaded design.

But that’s not to say that async IO in Python is easy. Be warned: when you venture a bit below the surface level, async programming can be difficult too! Python’s async model is built around concepts such as callbacks, events, transports, protocols, and futures—just the terminology can be intimidating. The fact that its API has been changing continually makes it no easier.

Luckily, asyncio has matured to a point where most of its features are no longer provisional, while its documentation has received a huge overhaul and some quality resources on the subject are starting to emerge as well.

## [The async/await Syntax and Native Coroutines](https://realpython.com/async-io-python/#the-asyncawait-syntax-and-native-coroutines)

At the heart of async IO are coroutines. A coroutine is a specialized version of a Python generator function. A coroutine is a function that can suspend its execution before reaching return, and it can indirectly pass control to another coroutine for some time. For example look at this Hello World async IO example:

```python
#!/usr/bin/env python3
# countasync.py

import asyncio

async def count():
    print("One")
    await asyncio.sleep(1)
    print("Two")

async def main():
    await asyncio.gather(count(), count(), count())

if __name__ == "__main__":
    import time
    s = time.perf_counter()
    asyncio.run(main())
    elapsed = time.perf_counter() - s
    print(f"{__file__} executed in {elapsed:0.2f} seconds.")
```

When you execute this file, take note of what looks different than if you were to define the functions with just `def` and `time.sleep()`:

```bash
$ python3 countasync.py
One
One
One
Two
Two
Two
countasync.py executed in 1.01 seconds.
```

The order of this output is the heart of async IO. Talking to each of the calls to `count()` is a single event loop, or coordinator. When each task reaches `await asyncio.sleep(1)`, the function talks to the event loop and gives control back to it saying, “I’m going to be sleeping for 1 second. Go ahead and let something else meaningful be done in the meantime.”

Contrast this to the synchronous version:

```python
#!/usr/bin/env python3
# countsync.py

import time

def count():
    print("One")
    time.sleep(1)
    print("Two")

def main():
    for _ in range(3):
        count()

if __name__ == "__main__":
    s = time.perf_counter()
    main()
    elapsed = time.perf_counter() - s
    print(f"{__file__} executed in {elapsed:0.2f} seconds.")
```

When executed, there is a slight but critical change in order and execution time:

```bash
$ python3 countsync.py
One
Two
One
Two
One
Two
countsync.py executed in 3.01 seconds.
```

Here `time.sleep()` can represent any time-consuming blocking function call, while `asyncio.sleep()` is used to stand in for a non-blocking time-consuming call.

Summing up the benefit of awaiting something, including `asyncio.sleep()`, is that the surrounding function can temporarily cede control to another function that’s more readily able to do something immediately. In contrast, `time.sleep()` or any other blocking call is incompatible with asynchronous Python code, because it will stop everything in its tracks for the duration of the sleep time.

## [The Rules of Async IO](https://realpython.com/async-io-python/#the-rules-of-async-io)

There are a strict set of rules around when and how you can and cannot use `async`/`await`:

- A function that you introduce with `async def` is a coroutine. It may use `await`, `return`, or `yield`, but all of these are optional.

    - Using `await` and/or `return` creates a coroutine function. To call a coroutine function, you must `await` it to get its results.
    - Using `yield` in an `async def` block creates an asynchronous generator, which you iterate over with `async for`. 
    - Anything defined with `async def` may not use `yield from`, which will raise a `SyntaxError`. (Remember that `yield from x()` is just syntactic sugar to replace for `i in x(): yield i`)

- The keyword `await` passes function control back to the event loop. (It suspends the execution of the surrounding coroutine.) If Python encounters an `await f()` expression in the scope of `g()`, this is how `await` tells the event loop, “Suspend execution of g() until whatever I’m waiting on—the result of f()—is returned. In the meantime, go let something else run.”. In pseudo code this would be:

    ```python
    async def g():
        r = await f() # Pause here and come back to g() when f() is ready
        return r
    ```

- You can't use `await` outside of an `async def` coroutine.
- When you use await `f()`, it’s required that `f()` be an object that is awaitable. An awaitable object is either another coroutine or an object defining an `.__await__()` method that returns an iterator. 

Here are some examples that summarize the above rules:

```python
async def f(x):
    y = await z(x)  # OK - `await` and `return` allowed in coroutines
    return y

async def g(x):
    yield x  # OK - this is an async generator

async def m(x):
    yield from gen(x)  # No - SyntaxError

def m(x):
    y = await z(x)  # No - SyntaxError (no `async def` here)
    return y
```

## [Async IO Design Patterns](https://realpython.com/async-io-python/#async-io-design-patterns)

Async IO comes with its own set of possible script designs.

### [Chaining Coroutines](https://realpython.com/async-io-python/#chaining-coroutines)

This allows you to break programs into smaller, manageable, recyclable coroutines:

```python
#!/usr/bin/env python3
# chained.py

import asyncio
import random
import time

async def part1(n: int) -> str:
    i = random.randint(0, 10)
    print(f"part1({n}) sleeping for {i} seconds.")
    await asyncio.sleep(i)
    result = f"result{n}-1"
    print(f"Returning part1({n}) == {result}.")
    return result

async def part2(n: int, arg: str) -> str:
    i = random.randint(0, 10)
    print(f"part2{n, arg} sleeping for {i} seconds.")
    await asyncio.sleep(i)
    result = f"result{n}-2 derived from {arg}"
    print(f"Returning part2{n, arg} == {result}.")
    return result

async def chain(n: int) -> None:
    start = time.perf_counter()
    p1 = await part1(n)
    p2 = await part2(n, p1)
    end = time.perf_counter() - start
    print(f"-->Chained result{n} => {p2} (took {end:0.2f} seconds).")

async def main(*args):
    await asyncio.gather(*(chain(n) for n in args))

if __name__ == "__main__":
    import sys
    random.seed(444)
    args = [1, 2, 3] if len(sys.argv) == 1 else map(int, sys.argv[1:])
    start = time.perf_counter()
    asyncio.run(main(*args))
    end = time.perf_counter() - start
    print(f"Program finished in {end:0.2f} seconds.")
```

Pay careful attention to the output, where `part1()` sleeps for a variable amount of time, and `part2()` begins working with the results as they become available:

```shell
$ python3 chained.py 9 6 3
part1(9) sleeping for 4 seconds.
part1(6) sleeping for 4 seconds.
part1(3) sleeping for 0 seconds.
Returning part1(3) == result3-1.
part2(3, 'result3-1') sleeping for 4 seconds.
Returning part1(9) == result9-1.
part2(9, 'result9-1') sleeping for 7 seconds.
Returning part1(6) == result6-1.
part2(6, 'result6-1') sleeping for 4 seconds.
Returning part2(3, 'result3-1') == result3-2 derived from result3-1.
-->Chained result3 => result3-2 derived from result3-1 (took 4.00 seconds).
Returning part2(6, 'result6-1') == result6-2 derived from result6-1.
-->Chained result6 => result6-2 derived from result6-1 (took 8.01 seconds).
Returning part2(9, 'result9-1') == result9-2 derived from result9-1.
-->Chained result9 => result9-2 derived from result9-1 (took 11.01 seconds).
Program finished in 11.01 seconds.
```

In this setup, the runtime of `main()` will be equal to the maximum runtime of the tasks that it gathers together and schedules.

### [Using a Queue](https://realpython.com/async-io-python/#using-a-queue)

The `asyncio` package provides [queue classes](https://docs.python.org/3/library/asyncio-queue.html) that are designed to be similar to classes of the [`queue`](https://docs.python.org/3/library/queue.html#module-queue) module.

There is an alternative structure that can also work with async IO: a number of producers, which are not associated with each other, add items to a queue. Each producer may add multiple items to the queue at staggered, random, unannounced times. A group of consumers pull items from the queue as they show up, greedily and without waiting for any other signal.

In this design, there is no chaining of any individual consumer to a producer. The consumers don’t know the number of producers, or even the cumulative number of items that will be added to the queue, in advance.

It takes an individual producer or consumer a variable amount of time to put and extract items from the queue, respectively. The queue serves as a throughput that can communicate with the producers and consumers without them talking to each other directly.

One use-case for queues is for the queue to act as a transmitter for producers and consumers that aren’t otherwise directly chained or associated with each other.

For example:

```python
#!/usr/bin/env python3
# asyncq.py

import asyncio
import itertools 
import os
import random
import time

async def makeitem(size: int = 5) -> str:
    return os.urandom(size).hex()

async def randsleep(caller=None) -> None:
    i = random.randint(0, 10)
    if caller:
        print(f"{caller} sleeping for {i} seconds.")
    await asyncio.sleep(i)

async def produce(name: int, q: asyncio.Queue) -> None:
    n = random.randint(0, 10)
    for _ in itertools.repeat(None, n):  # Synchronous loop for each single producer
        await randsleep(caller=f"Producer {name}")
        i = await makeitem()
        t = time.perf_counter()
        await q.put((i, t))
        print(f"Producer {name} added <{i}> to queue.")

async def consume(name: int, q: asyncio.Queue) -> None:
    while True:
        await randsleep(caller=f"Consumer {name}")
        i, t = await q.get()
        now = time.perf_counter()
        print(f"Consumer {name} got element <{i}>"
              f" in {now-t:0.5f} seconds.")
        q.task_done()

async def main(nprod: int, ncon: int):
    q = asyncio.Queue()
    producers = [asyncio.create_task(produce(n, q)) for n in range(nprod)]
    consumers = [asyncio.create_task(consume(n, q)) for n in range(ncon)]
    await asyncio.gather(*producers)
    await q.join()  # Implicitly awaits consumers, too
    for c in consumers:
        c.cancel()

if __name__ == "__main__":
    import argparse
    random.seed(444)
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--nprod", type=int, default=5)
    parser.add_argument("-c", "--ncon", type=int, default=10)
    ns = parser.parse_args()
    start = time.perf_counter()
    asyncio.run(main(**ns.__dict__))
    elapsed = time.perf_counter() - start
    print(f"Program completed in {elapsed:0.5f} seconds.")
```

The challenging part of this workflow is that there needs to be a signal to the consumers that production is done. Otherwise, `await q.get()` will hang indefinitely, because the queue will have been fully processed, but consumers won’t have any idea that production is complete. The key is to `await q.join()`, which blocks until all items in the queue have been received and processed, and then to cancel the consumer tasks, which would otherwise hang up and wait endlessly for additional queue items to appear.

The first few coroutines are helper functions that return a random string, a fractional-second performance counter, and a random integer. A producer puts anywhere from 1 to 10 items into the queue. Each item is a tuple of `(i, t)` where `i` is a random string and `t` is the time at which the producer attempts to put the tuple into the queue.

When a consumer pulls an item out, it simply calculates the elapsed time that the item sat in the queue using the timestamp that the item was put in with.

Here is a test run with two producers and five consumers:

```bash
$ python3 asyncq.py -p 2 -c 5
Producer 0 sleeping for 3 seconds.
Producer 1 sleeping for 3 seconds.
Consumer 0 sleeping for 4 seconds.
Consumer 1 sleeping for 3 seconds.
Consumer 2 sleeping for 3 seconds.
Consumer 3 sleeping for 5 seconds.
Consumer 4 sleeping for 4 seconds.
Producer 0 added <377b1e8f82> to queue.
Producer 0 sleeping for 5 seconds.
Producer 1 added <413b8802f8> to queue.
Consumer 1 got element <377b1e8f82> in 0.00013 seconds.
Consumer 1 sleeping for 3 seconds.
Consumer 2 got element <413b8802f8> in 0.00009 seconds.
Consumer 2 sleeping for 4 seconds.
Producer 0 added <06c055b3ab> to queue.
Producer 0 sleeping for 1 seconds.
Consumer 0 got element <06c055b3ab> in 0.00021 seconds.
Consumer 0 sleeping for 4 seconds.
Producer 0 added <17a8613276> to queue.
Consumer 4 got element <17a8613276> in 0.00022 seconds.
Consumer 4 sleeping for 5 seconds.
Program completed in 9.00954 seconds.
```

In this case, the items process in fractions of a second. A delay can be due to two reasons:

* Standard, largely unavoidable overhead
* Situations where all consumers are sleeping when an item appears in the queue

With regards to the second reason, luckily, it is perfectly normal to scale to hundreds or thousands of consumers. You should have no problem with `python3 asyncq.py -p 5 -c 100`. The point here is that, theoretically, you could have different users on different systems controlling the management of producers and consumers, with the queue serving as the central throughput.

## [`async for` and list comprehensions](https://realpython.com/async-io-python/#other-features-async-for-and-async-generators-comprehensions)

You can use `async for` to iterate over an asynchronous iterator. The purpose of an asynchronous iterator is for it to be able to call asynchronous code at each stage when it is iterated over.

A natural extension of this concept is an asynchronous generator:

```python
>>> async def mygen(u: int = 10):
...     """Yield powers of 2."""
...     i = 0
...     while i < u:
...         yield 2 ** i
...         i += 1
...         await asyncio.sleep(0.1)
```

You can also use asynchronous comprehension with `async for`:

```python
>>> async def main():
...     # This does *not* introduce concurrent execution
...     # It is meant to show syntax only
...     g = [i async for i in mygen()]
...     f = [j async for j in mygen() if not (j // 3 % 5)]
...     return g, f
...
>>> g, f = asyncio.run(main())
>>> g
[1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
>>> f
[1, 2, 16, 32, 256, 512]
```

Asynchronous iterators and asynchronous generators are not designed to concurrently map some function over a sequence or iterator. They’re merely designed to let the enclosing coroutine allow other tasks to take their turn. The `async for` and `async with` statements are only needed to the extent that using plain `for` or `with` would “break” the nature of `await` in the coroutine. 

## [The Event Loop and asyncio.run()](https://realpython.com/async-io-python/#the-event-loop-and-asynciorun)

You can think of an event loop as something like a `while True` loop that monitors coroutines, taking feedback on what’s idle, and looking around for things that can be executed in the meantime. It is able to wake up an idle coroutine when whatever that coroutine is waiting on becomes available.

Thus far, the entire management of the event loop has been implicitly handled by one function call:

```python
asyncio.run(main())
```

`asyncio.run()` is responsible for getting the event loop, running tasks until they are marked as complete, and then closing the event loop.

If you do need to interact with the event loop within a Python program, `loop` (obtained through `loop = asyncio.get_event_loop()`) is a good-old-fashioned Python object that supports introspection with `loop.is_running()` and `loop.is_closed()`. You can manipulate it if you need to get more fine-tuned control, such as in scheduling a callback by passing the loop as an argument.

Some important points regarding the event loop are:

- Coroutines don’t do much on their own until they are tied to the event loop. If you have a main coroutine that awaits others, simply calling it in isolation has little effect:

    ```python
    >>> import asyncio

    >>> async def main():
    ...     print("Hello ...")
    ...     await asyncio.sleep(1)
    ...     print("World!")

    >>> routine = main()
    >>> routine
    <coroutine object main at 0x1027a6150>
    ```

    Remember to use `asyncio.run()` to actually force execution by scheduling the `main()` coroutine (future object) for execution on the event loop:

    ```python
    >>> asyncio.run(routine)
    Hello ...
    World!
    ```

- By default, an async IO event loop runs in a single thread and on a single CPU core. It is also possible to run event loops across multiple cores. Check out [this talk by John Reese](https://youtu.be/0kXaLh8Fz3k?t=10m30s) for more, and be warned that your laptop may spontaneously combust.

## [Creating and gathering tasks](https://realpython.com/async-io-python/#other-top-level-asyncio-functions)

You can use `create_task()` to schedule the execution of a coroutine object, followed by `asyncio.run()`:

```python
>>> import asyncio

>>> async def coro(seq) -> list:
...     """'IO' wait time is proportional to the max element."""
...     await asyncio.sleep(max(seq))
...     return list(reversed(seq))
...
>>> async def main():
...     # This is a bit redundant in the case of one task
...     # We could use `await coro([3, 2, 1])` on its own
...     t = asyncio.create_task(coro([3, 2, 1])) 
...     await t
...     print(f't: type {type(t)}')
...     print(f't done: {t.done()}')
...
>>> t = asyncio.run(main())
t: type <class '_asyncio.Task'>
t done: True
```

There’s a subtlety to this pattern: if you don’t `await t` within `main()`, it may finish before `main()` itself signals that it is complete. Because `asyncio.run(main())` calls `loop.run_until_complete(main())`, the event loop is only concerned (without `await t` present) that `main()` is done, not that the tasks that get created within `main()` are done, if this happens the loop’s other tasks will be cancelled, possibly before they are completed. If you need to get a list of currently pending tasks, you can use `asyncio.Task.all_tasks()`.

Separately, there’s `asyncio.gather()` which is meant to neatly put a collection of coroutines (futures) into a single future. As a result, it returns a single future object, and, if you `await asyncio.gather()` and specify multiple tasks or coroutines, you’re waiting for all of them to be completed. (This somewhat parallels `queue.join()` from our earlier example.) The result of `gather()` will be a list of the results across the inputs:

```python
>>> import time
>>> async def main():
...     t = asyncio.create_task(coro([3, 2, 1]))
...     t2 = asyncio.create_task(coro([10, 5, 0]))  # Python 3.7+
...     print('Start:', time.strftime('%X'))
...     a = await asyncio.gather(t, t2)
...     print('End:', time.strftime('%X'))  # Should be 10 seconds
...     print(f'Both tasks done: {all((t.done(), t2.done()))}')
...     return a
...
>>> a = asyncio.run(main())
Start: 16:20:11
End: 16:20:21
Both tasks done: True
>>> a
[[1, 2, 3], [0, 5, 10]]
```

You can loop over `asyncio.as_completed()` to get tasks as they are completed, in the order of completion. The function returns an iterator that yields tasks as they finish. Below, the result of `coro([3, 2, 1])` will be available before `coro([10, 5, 0])` is complete, which is not the case with `gather()`:

```python
>>> async def main():
...     t = asyncio.create_task(coro([3, 2, 1]))
...     t2 = asyncio.create_task(coro([10, 5, 0]))
...     print('Start:', time.strftime('%X'))
...     for res in asyncio.as_completed((t, t2)):
...         compl = await res
...         print(f'res: {compl} completed at {time.strftime("%X")}')
...     print('End:', time.strftime('%X'))
...     print(f'Both tasks done: {all((t.done(), t2.done()))}')
...
>>> a = asyncio.run(main())
Start: 09:49:07
res: [1, 2, 3] completed at 09:49:10
res: [0, 5, 10] completed at 09:49:17
End: 09:49:17
Both tasks done: True
```

Lastly, you may also see `asyncio.ensure_future()`. You should rarely need it, because it’s a lower-level plumbing API and largely replaced by `create_task()`, which was introduced later.

## [When and Why Is Async IO the Right Choice?](https://realpython.com/async-io-python/#when-and-why-is-async-io-the-right-choice)

If you have multiple, fairly uniform CPU-bound tasks (a great example is a grid search in libraries such as scikit-learn or keras), multiprocessing should be an obvious choice.

Simply putting `async` before every function is a bad idea if all of the functions use blocking calls. This can actually slow down your code.

The contest between async IO and threading is a little bit more direct. Even in cases where threading seems easy to implement, it can still lead to infamous impossible-to-trace bugs due to race conditions and memory usage, among other things.

Threading also tends to scale less elegantly than async IO, because threads are a system resource with a finite availability. Creating thousands of threads will fail on many machines. Creating thousands of async IO tasks is completely feasible.

Async IO shines when you have multiple IO-bound tasks where the tasks would otherwise be dominated by blocking IO-bound wait time, such as:

- Network IO, whether your program is the server or the client side
- Serverless designs, such as a peer-to-peer, multi-user network like a group chatroom
- Read/write operations where you want to mimic a “fire-and-forget” style but worry less about holding a lock on whatever you’re reading and writing to

The biggest reason not to use it is that `await` only supports a specific set of objects that define a specific set of methods. If you want to do async read operations with a certain DBMS, you’ll need to find not just a Python wrapper for that DBMS, but one that supports the async/await syntax. Coroutines that contain synchronous calls block other coroutines and tasks from running.

## [Async IO It Is, but Which One?](https://realpython.com/async-io-python/#async-io-it-is-but-which-one)

`asyncio` certainly isn’t the only async IO library out there. The most popular are:

- [`anyio`](https://anyio.readthedocs.io/en/stable/)
- [`curio`](https://github.com/dabeaz/curio)
- [`trio`](https://github.com/python-trio/trio)

You might find that they get the same thing done in a way that’s more intuitive for you as the user. Many of the package-agnostic concepts presented here should permeate to alternative async IO packages as well. But if you’re building a moderately sized, straightforward program, just using `asyncio` is plenty sufficient and understandable, and lets you avoid adding yet another large dependency outside of Python’s standard library.

# Snippets

## Write on file

```python
import aiofiles
async with aiofiles.open(file, "a") as f:
    for p in res:
        await f.write(f"{url}\t{p}\n")
```

## Do http requests

Use the [`aiohttp`](aiohttp.md) library

# Tips

## [Limit concurrency](https://m0wer.github.io/memento/computer_science/programming/python/asyncio/#limit-concurrency)

Use [`asyncio.Semaphore`](https://docs.python.org/3/library/asyncio-sync.html#semaphores).

```python
sem = asyncio.Semaphore(10)
async with sem:
    # work with shared resource
```

Note that this method is not thread-safe.

# [Testing](https://pytest-asyncio.readthedocs.io/en/latest/)

With the [`pytest-asyncio`](https://pytest-asyncio.readthedocs.io/en/latest/) plugin you can test code that uses the asyncio library.

Install it with `pip install pytest-asyncio`

Specifically, `pytest-asyncio` provides support for coroutines as test functions. This allows users to await code inside their tests. For example, the following code is executed as a test item by pytest:

```python
@pytest.mark.asyncio
async def test_some_asyncio_code():
    res = await library.do_something()
    assert b"expected result" == res
```

`pytest-asyncio` runs each test item in its own `asyncio` event loop. The loop can be accessed via the `event_loop` fixture, which is automatically requested by all async tests.

```python
async def test_provided_loop_is_running_loop(event_loop):
    assert event_loop is asyncio.get_running_loop()
```

You can think of `event_loop` as an `autouse` fixture for async tests.

It has [two discovery modes](https://pytest-asyncio.readthedocs.io/en/latest/concepts.html#test-discovery-modes):

- Strict mode: will only run tests that have the `asyncio` marker and will only evaluate async fixtures decorated with `@pytest_asyncio.fixture`
- Auto mode: will automatically add the `asyncio` marker to all asynchronous test functions. It will also take ownership of all async fixtures, regardless of whether they are decorated with `@pytest.fixture` or `@pytest_asyncio.fixture`. 

    This mode is intended for projects that use `asyncio` as their only asynchronous programming library. Auto mode makes for the simplest test and fixture configuration and is the recommended default.

To use the Auto mode you need to pass the [`--asyncio-mode=auto`](https://pytest-asyncio.readthedocs.io/en/latest/reference/configuration.html) flag to `pytest`. If you use `pyproject.toml` you can set the next configuration:

```toml
[tool.pytest.ini_options]
addopts = "--asyncio-mode=auto"
```

# References

* [Docs](https://docs.python.org/3/library/asyncio.html#module-asyncio)
* [Awesome Asyncio](https://github.com/timofurrer/awesome-asyncio)
* [Real python tutorial](https://realpython.com/async-io-python/)
* [Roguelynn tutorial](https://www.roguelynn.com/words/asyncio-we-did-it-wrong/)

## Libraries to explore

* [Asyncer](https://github.com/tiangolo/asyncer)
