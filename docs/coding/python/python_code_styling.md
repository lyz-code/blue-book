---
title: Code styling
date: 20200626
author: Lyz
---

# [Type hints](https://realpython.com/python-type-checking/#type-systems)

Traditionally, types have been handled by the Python interpreter in a flexible
but implicit way. Recent versions of Python allow you to specify explicit type
hints that can be used by different tools to help you develop your code more
efficiently.

!!! note "TL;DR"
    [Type hints should be used whenever unit tests are worth writing](https://www.bernat.tech/the-state-of-type-hints-in-python/)

```python
def headline(text: str, align: bool = True) -> str:
    if align:
        return f"{text.title()}\n{'-' * len(text)}"
    else:
        return f" {text.title()} ".center(50, "o")
```

Type hints are not enforced on their own by python. So you won't catch an error
if you try to execute `headline("use mypy", align="center")` unless a static
type checker like [Mypy](http://mypy-lang.org/) is run.

## Pros and Cons

Pros:

* Help **catch certain errors** if used with a static type checker.
* Help **document your code**. Docstrings can't be easily used for automatic checks.

    * Easier to reason about code: Knowing the type of the parameters makes it
        a lot easier to understand and maintain a code base. It can speed up
        significantly the time required to catch up with a code snippet. Always
        remember that code you read code a lot more often than you write it.
        Therefore you should optimize for ease of reading.
* Help you **build and maintain a cleaner architecture**. The act of writing type
    hints force you to think about the types in your program.

    * Easier refactoring: Type hints make it trivial to find where a given class is used when you're trying to refactor your code base.
* Improve IDEs and linters.

Cons:

* Type hints **take developer time and effort to add**. Even though it probably
    pays off in spending less time debugging, you will spend more time entering
    code.
* **Introduce a slight penalty in start-up time**. If you need to use the typing
    module, the import time may be significant, especially in short scripts.
* Work best in modern Pythons.

A few rules of thumb on whether to add types to your project:

* In libraries that will be used by others, they add a lot of value.
* In bigger projects, type hints help you understand how types flow through your
    code and are highly recommended.
* If you are beginning to learn Python, don't use them yet.
* If you are writing throw-away scripts, don't use them.

So, [Type hints should be used whenever unit tests are worth
writing](https://www.bernat.tech/the-state-of-type-hints-in-python/).

## Usage

### Function annotations

```python
def func(arg: arg_type, optarg: arg_type = default) -> return_type:
    ...
```
For arguments the syntax is `argument: annotation`, while the return type is
annotated using `-> annotation`. Note that the annotation must be a valid Python
expression.

When running the code, they are stored in the special `.__annotations__`
attribute on the function.

### Variable annotations

Sometimes the type checker needs help in figuring out the types of variables as
well. The syntax is similar:

```python
pi: float = 3.142

def circumference(radius: float) -> float:
    return 2 * pi * radius
```
### Composite types

If you need to hint other types than `str`, `float` and `bool`, you'll need to
import the `typing` module.

For example to define the hint types of list, dictionaries and tuples:

```python
>>> from typing import Dict, List, Tuple

>>> names: List[str] = ["Guido", "Jukka", "Ivan"]
>>> version: Tuple[int, int, int] = (3, 7, 1)
>>> options: Dict[str, bool] = {"centered": False, "capitalize": True}
```
If your function expects some king of sequence but don't care whether it's
a list or a tuple, use the `typing.Sequence` object.

### Type aliases

Type hints might become oblique when working with nested types. Annotations are
regular Python expressions, so it's easy to define type aliases and assigning
them to new variables.

```python
from typing import List, Tuple

Card = Tuple[str, str]
Deck = List[Card]

def deal_hands(deck: Deck) -> Tuple[Deck, Deck, Deck, Deck]:

    """Deal the cards in the deck into four hands"""

    return (deck[0::4], deck[1::4], deck[2::4], deck[3::4])
```

### Functions without return values

Some functions aren't meant to return anything. Use the `-> None` hint in these
cases.

```python
def play(player_name: str) -> None:

    print(f"{player_name} plays")


ret_val = play("Filip")
```

The annotation help catch the kinds of subtle bugs where you are trying to use
a meaningless return value.

If your function are never expected to return normally, use the `NoReturn`
object.

```python
from typing import NoReturn

def black_hole() -> NoReturn:
    raise Exception("There is no going back ...")
```
!!! note
    This is just the first iteration of the synoptical reading of the full [Real python article on type
    checking](https://realpython.com/python-type-checking/#type-systems). If you
    are interested in this topic, keep on reading there.

## [Using mypy with an existing codebase](https://mypy.readthedocs.io/en/latest/existing_code.html)

These steps will get you started with `mypy` on an existing codebase:

* [Start small](https://mypy.readthedocs.io/en/latest/existing_code.html#start-small):
    Pick a subset of your codebase and run mypy only in this subset, without
    any annotations.

    You’ll likely need to fix some mypy errors, either by inserting annotations
    requested by mypy or by adding `# type: ignore` comments to silence errors
    you don’t want to fix now.


    – get a clean mypy build for some files, with few annotations.
* [Write a mypy runner script](https://mypy.readthedocs.io/en/latest/existing_code.html#mypy-runner-script)
    to ensure consistent results. Here are some things you may want to do in the
    script:
    * Ensure that the correct version of mypy is installed.
    * Specify mypy config file or command-line options.
    * Provide set of files to type check. You may want to implement inclusion
        and exclusion filters for full control of the file list.
* [Run mypy in Continuous Integration to prevent type errors](https://mypy.readthedocs.io/en/latest/existing_code.html#continuous-integration):

    Once you have a clean mypy run and a runner script for a part of your
    codebase, set up your Continuous Integration (CI) system to run mypy to
    ensure that developers won’t introduce bad annotations. A simple CI script
    could look something like this:

    ```python
    python3 -m pip install mypy==0.600  # Pinned version avoids surprises
    scripts/mypy  # Runs with the correct options
    ```
* Gradually annotate commonly imported modules: Most projects have some widely
    imported modules, such as utilities or model classes. It’s a good idea to
    annotate these pretty early on, since this allows code using these modules
    to be type checked more effectively. Since mypy supports gradual typing,
    it’s okay to leave some of these modules unannotated. The more you annotate,
    the more useful mypy will be, but even a little annotation coverage is
    useful.
* Write annotations as you modify existing code and write new code: Now you are
    ready to include type annotations in your development workflows. Consider
    adding something like these in your code style conventions:

    * Developers should add annotations for any new code.
    * It’s also encouraged to write annotations when you modify existing code.

# f-strings

[f-strings](https://realpython.com/python-f-strings/), also known as *formatted
string literals*, are strings that have an `f` at the beginning and curly braces
containing expressions that will be replaced with their values.

Introduced in Python 3.6, they not only are more readable, more
concise, and less prone to error than other ways of formatting, but they are
also faster.

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

# Reference

## Type hints

* [Bernat gabor article on the state of type hints in python](https://www.bernat.tech/the-state-of-type-hints-in-python/)
* [Real python article on type checking](https://realpython.com/python-type-checking/#type-systems)
