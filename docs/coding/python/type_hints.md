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
a list or a tuple, use the `typing.Sequence` object. In fact, try to use
`Sequence` if you can because using `List` could lead to some unexpected errors
when combined with type inference. For example:

```python
class A: ...
class B(A): ...

lst = [A(), A()]  # Inferred type is List[A]
new_lst = [B(), B()]  # inferred type is List[B]
lst = new_lst  # mypy will complain about this, because List is invariant
```

Possible strategies in such situations are:

* Use an explicit type annotation:

    ```python
    new_lst: List[A] = [B(), B()]
    lst = new_lst  # OK
    ```

* Make a copy of the right hand side:

    ```python
    lst = list(new_lst) # Also OK
    ```

* Use immutable collections as annotations whenever possible:

    ```python
    def f_bad(x: List[A]) -> A:
        return x[0]
    f_bad(new_lst) # Fails

    def f_good(x: Sequence[A]) -> A:
        return x[0]
    f_good(new_lst) # OK
    ```

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

## [Allow any subclass](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#class-types)

Every class is also a valid type. Any instance of a subclass is also compatible
with all superclasses – it follows that every value is compatible with the
object type (and incidentally also the Any type, discussed below). Mypy analyzes
the bodies of classes to determine which methods and attributes are available in
instances. For example

```python
class A:
    def f(self) -> int:  # Type of self inferred (A)
        return 2

class B(A):
    def f(self) -> int:
         return 3
    def g(self) -> int:
        return 4

def foo(a: A) -> None:
    print(a.f())  # 3
    a.g()         # Error: "A" has no attribute "g"

foo(B())  # OK (B is a subclass of A)
```

### [Deduce returned value type from the arguments](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#the-type-of-class-objects)

The previous approach works if you don't need to use class objects that inherit
from a given class. For example:

```python
class User:
    # Defines fields like name, email

class BasicUser(User):
    def upgrade(self):
        """Upgrade to Pro"""

class ProUser(User):
    def pay(self):
        """Pay bill"""

def new_user(user_class) -> User:
    user = user_class()
    # (Here we could write the user object to a database)
    return user
```

Where:

* `ProUser` doesn't inherit from `BasicUser`.
* `new_user` creates an instance of one of these classes if you pass
    it the right class object.

The problem is that right now mypy doesn't know which subclass of `User` you're
giving it, and will only accept the methods and attributes defined in the parent
class `User`.

```python
buyer = new_user(ProUser)
buyer.pay()  # Rejected, not a method on User
```

This can be solved using [Type variables with upper
bounds](https://mypy.readthedocs.io/en/stable/generics.html#type-variable-upper-bound).

```python
UserT = TypeVar('UserT', bound=User)

def new_user(user_class: Type[UserT]) -> UserT:
    # Same  implementation as before
```

We're creating a new type `UserT` that is linked to the class or subclasses
of `User`. That way, mypy knows that the return value is an object created from
the class given in the argument `user_class`.

```python
beginner = new_user(BasicUser)  # Inferred type is BasicUser
beginner.upgrade()  # OK
```

!!! note
        "Using `UserType` is [not supported by
        pylint](https://github.com/PyCQA/pylint/issues/6003), use `UserT`
        instead."

Keep in mind that the `TypeVar` is a [Generic
type](https://mypy.readthedocs.io/en/stable/generics.html), as such, they take
one or more type parameters, similar to built-in types such as `List[X]`.

That means that when you create type aliases, you'll need to give the type
parameter. So:

```python
UserT = TypeVar("UserT", bound=User)
UserTs = List[Type[UserT]]


def new_users(user_class: UserTs) -> UserT: # Type error!
    pass
```

Will give a `Missing type parameters for generic type "UserTs"` error. To
solve it use:

```python
def new_users(user_class: UserTs[UserT]) -> UserT: # OK!
    pass
```

## [Define a TypeVar with restrictions](https://mypy.readthedocs.io/en/stable/generics.html#type-variables-with-value-restriction)

By default, a type variable can be replaced with any type. However, sometimes
it’s useful to have a type variable that can only have some specific types as
its value. A typical example is a type variable that can only have values `str`
and `bytes`:

```python
from typing import TypeVar

AnyStr = TypeVar('AnyStr', str, bytes)
```

This is actually such a common type variable that `AnyStr` is defined in typing
and we don’t need to define it ourselves.


We can use `AnyStr` to define a function that can concatenate two strings or
bytes objects, but it can’t be called with other argument types:

```python
from typing import AnyStr

def concat(x: AnyStr, y: AnyStr) -> AnyStr:
    return x + y

concat('a', 'b')    # Okay
concat(b'a', b'b')  # Okay
concat(1, 2)        # Error!
```

Note that this is different from a union type, since combinations of `str` and
`bytes` are not accepted:

```python
concat('string', b'bytes')   # Error!
```

In this case, this is exactly what we want, since it’s not possible to
concatenate a string and a bytes object! The type checker will reject this
function:

```python
def union_concat(x: Union[str, bytes], y: Union[str, bytes]) -> Union[str, bytes]:
    return x + y  # Error: can't concatenate str and bytes
```

### [Overloading the methods](https://adamj.eu/tech/2021/05/29/python-type-hints-how-to-use-overload/)

Sometimes the types of several variables are related, such as “if x is type A,
y is type B, else y is type C”. Basic type hints cannot describe such
relationships, making type checking cumbersome or inaccurate. We can instead use
`@typing.overload` to represent type relationships properly.

```python
from __future__ import annotations

from collections.abc import Sequence
from typing import overload


@overload
def double(input_: int) -> int:
    ...


@overload
def double(input_: Sequence[int]) -> list[int]:
    ...


def double(input_: int | Sequence[int]) -> int | list[int]:
    if isinstance(input_, Sequence):
        return [i * 2 for i in input_]
    return input_ * 2
```

This looks a bit weird at first glance—we are defining double three times! Let’s
take it apart.

The first two `@overload` definitions exist only for their type hints. Each
definition represents an allowed combination of types. These definitions never
run, so their bodies could contain anything, but it’s idiomatic to use Python’s
`...` (ellipsis) literal.

The third definition is the actual implementation. In this case, we need to
provide type hints that union all the possible types for each variable. Without
such hints, Mypy will skip type checking the function body.

When Mypy checks the file, it collects the `@overload` definitions as type
hints. It then uses the first non-`@overload` definition as the implementation.
All `@overload` definitions must come before the implementation, and multiple
implementations are not allowed.

When Python imports the file, the `@overload` definitions create temporary
double functions, but each is overridden by the next definition. After
importing, only the implementation exists. As a protection against accidentally
missing implementations, attempting to call an `@overload` definition will raise
a `NotImplementedError`.

`@overload` can represent arbitrarily complex scenarios. For a couple more
examples, see the function overloading section of the [Mypy
docs](https://mypy.readthedocs.io/en/stable/more_types.html#function-overloading).

### Use a constrained TypeVar in the definition of a class attributes.

If you try to use a `TypeVar` in the definition of a class attribute:

```python
class File:
    """Model a computer file."""

    path: str
    content: Optional[AnyStr] = None # mypy error!
```

[mypy](mypy.md) will complain with `Type variable AnyStr is unbound
[valid-type]`, to solve it, you need to make the class inherit from the
`Generic[AnyStr]`.

```python
class File(Generic[AnyStr]):
    """Model a computer file."""

    path: str
    content: Optional[AnyStr] = None
```

Why you ask? I have absolutely no clue. I've asked that question in the
[gitter python typing channel](https://gitter.im/python/typing#) but the kind
answer that @ktbarrett gave me sounded like Chinese.

> You can't just use a type variable for attributes or variables, you have to
> create some generic context, whether that be a function or a class, so that
> you can instantiate the generic context (or the analyzer can infer it) (i.e.
> context[var]). That's not possible if you don't specify that the class is
> a generic context. It also ensure than all uses of that variable in the
> context resolve to the same type.

If you don't mind helping me understand it, please [contact me](contact.md).

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
## [Type hints of Generators](https://stackoverflow.com/questions/42531143/type-hinting-generator-in-python-3-6)

```python
from typing import Generator

def generate() -> Generator[int, None, None]:
```

Where the first argument of `Generator` is the type of the yielded value.

## [Usage of ellipsis on `Tuple` type hints](https://stackoverflow.com/questions/772124/what-does-the-ellipsis-object-do)

The ellipsis is used to specify an arbitrary-length homogeneous tuples, for
example `Tuple[int, ...]`.

## [Using `typing.cast`](https://adamj.eu/tech/2021/07/06/python-type-hints-how-to-use-typing-cast/)

Sometimes the type hints of your program don't work as you expect, if you've
given up on fixing the issue you can `# type: ignore` it, but if you know what
type you want to enforce, you can use
[`typing.cast()`](https://docs.python.org/3/library/typing.html#typing.cast)
explicitly or implicitly from `Any` with type hints. With casting we can force
the type checker to treat a variable as a given type.

!!! warning "This is an ugly patch, always try to fix your types"

### The simplest `cast()`

When we call `cast()`, we pass it two arguments: a type, and a value. `cast()`
returns `value` unchanged, but type checkers will treat the return value as the
given type instead of the input type. For example, we can make Mypy treat an
integer as a string:

```python
from typing import cast

x = 1
reveal_type(x)
y = cast(str, x)
reveal_type(y)
y.upper()
```

Checking this program with Mypy, it doesn't report any errors, but it does debug
the types of `x` and `y` for us:

```bash
$ mypy example.py

example.py:6: note: Revealed type is "builtins.int"
example.py:8: note: Revealed type is "builtins.str"
```

But, if we remove the `reveal_type()` calls and run the code, it crashes:

```bash
$ python example.py
Traceback (most recent call last):
  File "/.../example.py", line 7, in <module>
    y.upper()
AttributeError: 'int' object has no attribute 'upper'
```

Usually Mypy would detect this bug, as it knows `int` objects do not have an
`upper()` method. But our `cast()` forced Mypy to treat `y` as a `str`, so it
assumed the call would succeed.

### Use cases

The main case to reach for `cast()` are when the type hints for a module are
either missing, incomplete, or incorrect. This may be the case for third party
packages, or occasionally for things in the standard library.

Take this example:

```python
import datetime as dt
from typing import cast

from third_party import get_data

data = get_data()
last_import_time = cast(dt.datetime, data["last_import_time"])
```

Imagine `get_data()` has a return type of `dict[str, Any]`, rather than using
stricter per-key types with a `TypedDict`. From reading the documentation or
source we might find that the `last_import_time` key always contains
a `datetime` object. Therefore, when we access it, we can wrap it in a `cast()`,
to tell our type checker the real type rather than continuing with `Any`.

When we encounter missing, incomplete, or incorrect type hints, we can
contribute back a fix. This may be in the package itself, its related stubs
package, or separate stubs in Python’s typeshed. But until such a fix is
released, we will need to use `cast()` to make our code pass type checking.

### Implicit Casting From Any

It’s worth noting that `Any` has special treatment: when we store a variable
with type `Any` in a variable with a specific type, type checkers treat this as
an implicit cast. We can thus write our previous example without `cast()`:

```python
import datetime as dt

from third_party import get_data

data = get_data()
last_import_time: dt.datetime = data["last_import_time"]
```

This kind of implicit casting is the first tool we should reach for when
interacting with libraries that return `Any`. It also applies when we pass
a variable typed `Any` as a specifically typed function argument or return
value.

Calling `cast()` directly is often more useful when dealing with incorrect types
other than `Any`.

### Mypy’s `warn_redundant_casts` option

When we use `cast()` to override a third party function’s type, that type be
corrected in a later version (perhaps from our own PR!). After such an update,
the `cast()` is unnecessary clutter that may confuse readers.

We can detect such unnecessary casts by activating Mypy’s `warn_redundant_casts`
option. With this flag turned on, Mypy will log an error for each use of
`cast()` that casts a variable to the type it already has.

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

If you need to [ignore a linter error and a type
error](https://stackoverflow.com/questions/51179109/set-pyflake-and-mypy-ignore-same-line)
use first the type and then the linter. For example, `# type: ignore # noqa:
W0212`.

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
