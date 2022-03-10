---
title: Code styling
date: 20200626
author: Lyz
---

# [Not using setdefault() to initialize a dictionary](https://docs.quantifiedcode.com/python-anti-patterns/correctness/not_using_setdefault_to_initialize_a_dictionary.html)

When initializing a dictionary, it is common to see a code check for the
existence of a key and then create the key if it does not exist.

Given a `dictionary = {}`, if you want to create a key if it doesn't exist,
instead of doing:

```python
try:
    dictionary['key']
except KeyError:
    dictionary['key'] = {}
```

You can use:

```python
dictionary.setdefault('key', {})
```

# [Black code style](https://black.readthedocs.io)

[Black](black.md) is a style guide enforcement tool.

# [Flake8](https://flake8.pycqa.org/)

[Flake8](flake8.md) is another style guide enforcement tool.

# f-strings

[f-strings](https://realpython.com/python-f-strings/), also known as *formatted
string literals*, are strings that have an `f` at the beginning and curly braces
containing expressions that will be replaced with their values.

Introduced in Python 3.6, they are more readable, concise, and less prone
to error than other ways of formatting, as well as faster.

```python
>>> name = "Eric"
>>> age = 74
>>> f"Hello, {name}. You are {age}."
'Hello, Eric. You are 74.'
```

## Arbitrary expressions

Because f-strings are evaluated at runtime, you can put any valid Python
expressions in them. For example, calling a function or method from within.

```python
>>> f"{name.lower()} is funny."
'eric idle is funny.'
```

## Multiline f-strings

```python
>>> name = "Eric"
>>> profession = "comedian"
>>> affiliation = "Monty Python"
>>> message = (
...     f"Hi {name}. "
...     f"You are a {profession}. "
...     f"You were in {affiliation}."
... )
>>> message
'Hi Eric. You are a comedian. You were in Monty Python.'
```

# Lint error fixes and ignores

## [Fix Pylint R0201 error](http://pylint-messages.wikidot.com/messages:r0201)

The error shows `Method could be a function`, it is used when there is no
reference to the class, suggesting that the method could be used as a static
function instead.

Attempt using either of the decorators `@classmethod` or `@staticmethod`.

If you don't need to change or use the class methods, use `staticmethod`.

Example:

```python
Class Foo(object):
    ...
    def bar(self, baz):
        ...
        return llama
```

Try instead to use:

```python
Class Foo(object):
    ...
    @classmethod
    def bar(cls, baz):
        ...
        return llama
```

Or

```python
Class Foo(object):
    ...
    @staticmethod
    def bar(baz):
        ...
        return llama
```

## [W1203 with F-strings](https://github.com/PyCQA/pylint/issues/2354)

This rule suggest you to use the `%` interpolation in the logging methods
because it might save some interpolation time when a logging statement is not
run. Nevertheless the performance improvement is negligible and the advantages
of using f-strings far outweigh them.

## [W0106 in list comprehension](https://github.com/PyCQA/pylint/issues/3397)

They just don't support it they suggest to use normal for loops.

## [W1514 set encoding on open](https://peps.python.org/pep-0597/)

```python
with open('file.txt', 'r', encoding='utf-8'):
```

## [SIM105 Use
'contextlib.suppress(Exception)'](https://docs.python.org/3/library/contextlib.html#contextlib.suppress)

To bypass exceptions, it's better to use:

```python
from contextlib import suppress

with suppress(FileNotFoundError):
    os.remove('somefile.tmp')
```

Instead of:

```python
try:
    os.remove('somefile.tmp')
except FileNotFoundError:
    pass
```
