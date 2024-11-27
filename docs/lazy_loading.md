---
title: Lazy evaluation
date: 20210121
author: Lyz
---

[Lazy loading](https://en.wikipedia.org/wiki/Lazy_evaluation) is an programming
implementation paradigm which delays the evaluation of an expression until its
value is needed and which also avoids repeated evaluations.

Lazy evaluation is the preferred implementation when the operation is expensive,
requiring either extensive processing time or memory. For example, in Python,
one of the best-known techniques involving lazy evaluation is generators.
Instead of creating whole sequences for the iteration, which can consume lots of
memory, generators lazily evaluate the current need and yield one element at
a time when requested.

Other example are attributes that take long to compute:

```python
class Person:
    def __init__(self, name, occupation):
        self.name = name
        self.occupation = occupation
        self.relatives = self._get_all_relatives()

    def _get_all_relatives():
        ...
        # This is an expensive operation
```

This approach may cause initialization to take unnecessarily long, especially
when you don't always need to access `Person.relatives`.

A better strategy would be to get relatives when it's needed.

```python
class Person:
    def __init__(self, name, occupation):
        self.name = name
        self.occupation = occupation
        self._relatives = None

    @property
    def relatives(self):
        if self._relatives is None:
            self._relatives = ... # Get all relatives
        return self._relatives
```

In this case, the list of relatives is computed the first time
`Person.relatives` is accessed. After that, it's stored in `Person._relatives`
to prevent repeated evaluations.

A perhaps more Pythonic approach would be to use a decorator that makes
a property lazy-evaluated.

```python
def lazy_property(fn):
    '''Decorator that makes a property lazy-evaluated.
    '''
    attr_name = '_lazy_' + fn.__name__

    @property
    def _lazy_property(self):
        if not hasattr(self, attr_name):
            setattr(self, attr_name, fn(self))
        return getattr(self, attr_name)
    return _lazy_property

class Person:
    def __init__(self, name, occupation):
        self.name = name
        self.occupation = occupation

    @lazy_property
    def relatives(self):
        # Get all relatives
        relatives = ...
        return relatives
```

This removes a lot of boilerplate, especially when an object has many
lazily-evaluated properties.

Another approach is to [use the __getattr__ special
method](https://medium.com/better-programming/how-to-create-lazy-attributes-to-improve-performance-in-python-b369fd72e1b6).

# References

* [Steven Loria article on Lazy Properties](https://stevenloria.com/lazy-properties/)
* [Yong Cui article on Lazy attributes](https://medium.com/better-programming/how-to-create-lazy-attributes-to-improve-performance-in-python-b369fd72e1b6)
