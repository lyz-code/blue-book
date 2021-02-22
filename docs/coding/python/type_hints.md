---
title: Type hints
date: 20201001
author: Lyz
---

[Type hints](https://realpython.com/python-type-checking/#type-systems) are the
Python native way to define the type of the objects in a program.

Traditionally, the Python interpreter handles types in a flexible
but implicit way. Recent versions of Python allow you to specify explicit type
hints that different tools can use to help you develop your code more
efficiently.

!!! note "TL;DR"
    [Use Type hints whenever unit tests are worth
    writing](https://www.bernat.tech/the-state-of-type-hints-in-python/)

```python
def headline(text: str, align: bool = True) -> str:
    if align:
        return f"{text.title()}\n{'-' * len(text)}"
    else:
        return f" {text.title()} ".center(50, "o")
```

Type hints are not enforced on their own by python. So you won't catch an error
if you try to run `headline("use mypy", align="center")` unless you use a static
type checker like [Mypy](http://mypy-lang.org/).

# Advantages and disadvantages

Advantages:

* Help **catch certain errors** if used with a static type checker.
* Help **check your code**. It's not trivial to use docstrings to do
    automatic checks.
* Help to reason about code: Knowing the parameters type makes it a lot easier
    to understand and maintain a code base. It can speed up the time required to
    catch up with a code snippet. Always remember that you read code a lot more
    often than you write it, so you should optimize for ease of reading.
* Help you **build and maintain a cleaner architecture**. The act of writing type
    hints force you to think about the types in your program.

* Helps refactoring: Type hints make it trivial to find where a given class is
    used when you're trying to refactor your code base.
* Improve IDEs and linters.

Cons:

* Type hints **take developer time and effort to add**. Even though it probably
    pays off in spending less time debugging, you will spend more time entering
    code.
* **Introduce a slight penalty in start-up time**. If you need to use the typing
    module, the import time may be significant, even more in short scripts.
* Work best in modern Pythons.

Follow these guidelines when deciding if you want to add types to your project:

* In libraries that will be used by others, they add a lot of value.
* In complex projects, type hints help you understand how types flow through
   your code and are highly recommended.
* If you are beginning to learn Python, don't use them yet.
* If you are writing throw-away scripts, don't use them.

So, [Use Type hints whenever unit tests are worth
writing](https://www.bernat.tech/the-state-of-type-hints-in-python/).

# Usage

## Function annotations

```python
def func(arg: arg_type, optarg: arg_type = default) -> return_type:
    ...
```
For arguments the syntax is `argument: annotation`, while the return type is
annotated using `-> annotation`. Note that the annotation must be a valid Python
expression.

When running the code, the special `.__annotations__` attribute on the function
 stores the typing information.

## Variable annotations

Sometimes the type checker needs help in figuring out the types of variables as
well. The syntax is similar:

```python
pi: float = 3.142

def circumference(radius: float) -> float:
    return 2 * pi * radius
```
## Composite types

If you need to hint other types than `str`, `float` and `bool`, you'll need to
import the `typing` module.

For example to define the hint types of list, dictionaries and tuples:

```python
>>> from typing import Dict, List, Tuple

>>> names: List[str] = ["Guido", "Jukka", "Ivan"]
>>> version: Tuple[int, int, int] = (3, 7, 1)
>>> options: Dict[str, bool] = {"centered": False, "capitalize": True}
```

If your function expects some kind of sequence but don't care whether it's
a list or a tuple, use the `typing.Sequence` object.

### [Dictionaries with different value types per key](https://stackoverflow.com/questions/53409117/what-are-the-main-differences-of-namedtuple-and-typeddict-in-python-mypy).

[`TypedDict`](https://docs.python.org/3/library/typing.html#typing.TypedDict)
declares a dictionary type that expects all of its instances to have a certain
set of keys, where each key is associated with a value of a consistent type.
This expectation is not checked at runtime but is only enforced by type
checkers.

TypedDict started life as an experimental Mypy feature to wrangle typing onto
the heterogeneous, structure-oriented use of dictionaries. As of Python 3.8, it
was adopted into the standard library.

```python
try:
    from typing import TypedDict  # >=3.8
except ImportError:
    from mypy_extensions import TypedDict  # <=3.7

Movie = TypedDict('Movie', {'name': str, 'year': int})
```

A class-based type constructor is also available:

```python
class Movie(TypedDict):
    name: str
    year: int
```

By default, all keys must be present in a `TypedDict`. It is possible to override
this by specifying totality. Usage:

```python
class point2D(TypedDict, total=False):
    x: int
    y: int
```

This means that a `point2D` `TypedDict` can have any of the keys omitted. A type
checker is only expected to support a literal False or True as the value of the
total argument. True is the default, and makes all items defined in the class
body be required.

## Functions without return values

Some functions aren't meant to return anything. Use the `-> None` hint in these
cases.

```python
def play(player_name: str) -> None:

    print(f"{player_name} plays")


ret_val = play("Filip")
```

The annotation help catch the kinds of subtle bugs where you are trying to use
a meaningless return value.

If your function doesn't return any object, use the `NoReturn` type.

```python
from typing import NoReturn

def black_hole() -> NoReturn:
    raise Exception("There is no going back ...")
```
!!! note
    This is the first iteration of the synoptical reading of the full [Real
    python article on type
    checking](https://realpython.com/python-type-checking/#type-systems).

## Optional arguments

A common pattern is to use `None` as a default value for an argument. This is
done either to avoid problems with [mutable default
values](python_anti_patterns.md#mutable-default-arguments) or to have a sentinel
value flagging special behavior.

This creates a challenge for type hinting as the argument may be of type string
(for example) but it can also be `None`. We use the `Optional` type to address
this case.

```python
from typing import Optional

def player(name: str, start: Optional[str] = None) -> str:
    ...
```

A similar way would be to use `Union[None, str]`.

## [Allow any subclass](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#union-types)

It's not yet supported (unless inheriting from an abstract class), so the expected format

```python
class A:
    pass

class B(A):
    pass

def process_any_subclass_type_of_A(cls: A):
    pass

process_any_subclass_type_of_A(B)
```

Will fail with `error: Argument 1 to "process_any_subclass_type_of_A" has
incompatible type "Type[B]"; expected "A"`.

The solution is to use the `Union` operator:

```python
class A:
    pass

class B(A):
    pass

class C(A):
    pass

def process_any_subclass_type_of_A(cls: Union[B,C]):
    pass
```

The following works:

```python
class A(abc.ABC):
    @abc.abstractmethod
    def add(self):
        raise NotImplementedError
class B(A):
    def add(self):
        pass

class C(A):
    def add(self):
        pass

def process_any_subclass_type_of_A(cls: A):
    pass
```

## Type aliases

Type hints might become oblique when working with nested types. If it's the
case, save them into a new variable, and use that instead.

```python
from typing import List, Tuple

Card = Tuple[str, str]
Deck = List[Card]

def deal_hands(deck: Deck) -> Tuple[Deck, Deck, Deck, Deck]:

    """Deal the cards in the deck into four hands"""

    return (deck[0::4], deck[1::4], deck[2::4], deck[3::4])
```

## [Generic types](https://www.python.org/dev/peps/pep-0484/#generics)

This can be useful when you need lists of subclasses or optional list of
subclasses. The expected behavior doesn't work.

```python
Entity = TypeVar('Entity', model.Project, model.Tag, model.Task)
Entities = List[Entity]
```

If you just want to [specify any children of a parent
class](https://stackoverflow.com/questions/58986031/type-hinting-child-class-returning-self), use:

```python
from .model import Entity as EntityModel

Entity = TypeVar('Entity', bound=EntityModel)
```

Try to use `TypeVar` instead of `Union` of the different types, as it's able to
deduce better the type of the return value of a function.

```python
def do_something(entity: Entity) -> Entity:
    return Entity
```

If you use `TypeVar`, if you call the function with a type `Card`, it will know
that the result is of type `Card`, if you use `Union`, even if you call it with
`Card` the return value will be `Union[Card,Deck]`.

More generally, [Generics](https://www.python.org/dev/peps/pep-0484/#generics)
can be parameterized by using a new factory available in typing called
`TypeVar`. Example:

```python
from typing import Sequence, TypeVar

T = TypeVar('T')      # Declare type variable

def first(l: Sequence[T]) -> T:   # Generic function
    return l[0]
```

In this case the contract is that the returned value is consistent with the
elements held by the collection.


A `TypeVar()` expression must always directly be assigned to a variable (it
should not be used as part of a larger expression). The argument to `TypeVar()`
must be a string equal to the variable name to which it is assigned. Type
variables must not be redefined.

TypeVar supports constraining parametric types to a fixed set of possible types
(note: those types cannot be parameterized by type variables). For example, we
can define a type variable that ranges over just str and bytes. By default,
a type variable ranges over all possible types. Example of constraining a type
variable:

```python
from typing import TypeVar, Text

AnyStr = TypeVar('AnyStr', Text, bytes)

def concat(x: AnyStr, y: AnyStr) -> AnyStr:
    return x + y
```

## [Specify the type of the class in it's method and attributes](https://stackoverflow.com/questions/33533148/how-do-i-specify-that-the-return-type-of-a-method-is-the-same-as-the-class-itsel)

If you are using Python 3.10 or later, it just works.
Python 3.7 introduces PEP 563: postponed evaluation of annotations. A module
that uses the future statement `from __future__ import annotations` to store annotations as strings automatically:

```python
from __future__ import annotations

class Position:
    def __add__(self, other: Position) -> Position:
        ...
```

But `pyflakes` will still complain, so I've used strings.

```python
from __future__ import annotations

class Position:
    def __add__(self, other: 'Position') -> 'Position':
        ...
```

# [Using mypy with an existing codebase](https://mypy.readthedocs.io/en/latest/existing_code.html)

These steps will get you started with `mypy` on an existing codebase:

* [Start small](https://mypy.readthedocs.io/en/latest/existing_code.html#start-small):
    Pick a subset of your codebase to run mypy on, without
    any annotations.

    You’ll probably need to fix some mypy errors, either by inserting
    annotations requested by mypy or by adding `# type: ignore` comments to
    silence errors you don’t want to fix now.

    Get a clean mypy build for some files, with some annotations.
* [Write a mypy runner script](https://mypy.readthedocs.io/en/latest/existing_code.html#mypy-runner-script)
    to ensure consistent results. Here are some steps you may want to do in the
    script:
    * Ensure that you install the correct version of mypy.
    * Specify mypy config file or command-line options.
    * Provide set of files to type check. You may want to configure the inclusion
        and exclusion filters for full control of the file list.
* [Run mypy in Continuous Integration to prevent type errors](mypy.md):

    Once you have a clean mypy run and a runner script for a part of your
    codebase, set up your Continuous Integration (CI) system to run mypy to
    ensure that developers won’t introduce bad annotations. A small CI script
    could look something like this:

    ```python
    python3 -m pip install mypy==0.600  # Pinned version avoids surprises
    scripts/mypy  # Runs with the correct options
    ```
* Gradually annotate commonly imported modules: Most projects have some widely
    imported modules, such as utilities or model classes. It’s a good idea to
    annotate these soon, since this allows code using these modules
    to be type checked more effectively. Since mypy supports gradual typing,
    it’s okay to leave some of these modules unannotated. The more you annotate,
    the more useful mypy will be, but even a little annotation coverage is
    useful.
* Write annotations as you change existing code and write new code: Now you are
    ready to include type annotations in your development workflows. Consider
    adding something like these in your code style conventions:

    * Developers should add annotations for any new code.
    * It’s also encouraged to write annotations when you change existing code.

# [Reveal the type of an expression](https://mypy.readthedocs.io/en/stable/common_issues.html?highlight=get%20type%20of%20object#displaying-the-type-of-an-expression)

You can use `reveal_type(expr)` to ask mypy to display the inferred static type
of an expression. This can be useful when you don't quite understand how mypy
handles a particular piece of code. Example:

```python
reveal_type((1, 'hello'))  # Revealed type is 'Tuple[builtins.int, builtins.str]'
```

You can also use `reveal_locals()` at any line in a file to see the types of all
local variables at once. Example:

```python
a = 1
b = 'one'
reveal_locals()
# Revealed local types are:
#     a: builtins.int
#     b: builtins.str
```

`reveal_type` and `reveal_locals` are only understood by mypy and don't exist in
Python. If you try to run your program, you’ll have to remove any `reveal_type`
and `reveal_locals` calls before you can run your code. Both are always
available and you don't need to import them.

# [Solve cyclic imports due to typing](https://www.stefaanlippens.net/circular-imports-type-hints-python.html)

You can use a conditional import that is only active in "type hinting mode", but
doesn't interfere at run time. The `typing.TYPE_CHECKING` constant makes this
easily possible. For example:

```python
# thing.py
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from connection import ApiConnection

class Thing:
    def __init__(self, connection: 'ApiConnection'):
        self._conn = connection
```

The code will now execute properly as there is no circular import issue anymore.
Type hinting tools on the other hand should still be able to resolve the
`ApiConnection` type hint in `Thing.__init__`.

# [Make your library compatible with mypy](https://mypy.readthedocs.io/en/stable/installed_packages.html#making-pep-561-compatible-packages)


[PEP 561](https://www.python.org/dev/peps/pep-0561) notes three main ways to
distribute type information. The first is a package that has only inline type
annotations in the code itself. The second is a package that ships stub files
with type information alongside the runtime code. The third method, also known
as a “stub only package” is a package that ships type information for a package
separately as stub files.

If you would like to publish a library package to a package repository (e.g.
PyPI) for either internal or external use in type checking, packages that supply
type information via type comments or annotations in the code should put
a `py.typed` file in their package directory. For example, with a directory
structure as follows

```
setup.py
package_a/
    __init__.py
    lib.py
    py.typed
```

the `setup.py` might look like:

```python
from distutils.core import setup

setup(
    name="SuperPackageA",
    author="Me",
    version="0.1",
    package_data={"package_a": ["py.typed"]},
    packages=["package_a"]
)
```

!!! note ""
    If you use setuptools, you must pass the option `zip_safe=False` to
    `setup()`, or mypy will not be able to find the installed package.

# Reference

* [Bernat gabor article on the state of type hints in python](https://www.bernat.tech/the-state-of-type-hints-in-python/)
* [Real python article on type checking](https://realpython.com/python-type-checking/#type-systems)
