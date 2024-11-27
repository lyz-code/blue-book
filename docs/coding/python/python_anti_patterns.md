---
title: Python Anti-patterns
date: 20200626
author: Lyz
---

# [Mutable default arguments](http://docs.python-guide.org/en/latest/writing/gotchas/#mutable-default-arguments)

## What You Wrote

```python
def append_to(element, to=[]):
    to.append(element)
    return to
```

## What You Might Have Expected to Happen

```python
my_list = append_to(12)
print(my_list)

my_other_list = append_to(42)
print(my_other_list)
```

A new list is created each time the function is called if a second argument
isn’t provided, so that the output is:

```python
[12]
[42]
```

What Does Happen

```python
[12]
[12, 42]
```

A new list is created once when the function is defined, and the same list is
used in each successive call.

Python’s default arguments are evaluated once when the function is defined, not
each time the function is called. This means that if you use a mutable default
argument and mutate it, you will and have mutated that object for all future
calls to the function as well.


## What You Should Do Instead

Create a new object each time the function is called, by using a default arg to
signal that no argument was provided (None is often a good choice).

```python
def append_to(element, to=None):
    if to is None:
        to = []
    to.append(element)
    return to
```

Do not forget, you are passing a list object as the second argument.

## When the Gotcha Isn’t a Gotcha

Sometimes you can specifically “exploit” this behavior to maintain state between
calls of a function. This is often done when writing a caching function.
