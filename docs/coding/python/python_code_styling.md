---
title: Code styling
date: 20200626
author: Lyz
---

# [Commit message guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)

I'm following the Angular commit convention that is backed up by
[python-semantic-release](https://python-semantic-release.readthedocs.io/en/latest/commit-log-parsing.html),
with the idea of implementing automatic [semantic
versioning](https://semver.org/) sometime in the future.

Each commit message consists of a header, a body and a footer. The header has
a defined format that includes a type, a scope and a subject:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The *header* is mandatory and the *scope* of the header is optional.

Any line of the commit message cannot be longer 100 characters.

The *footer* should contain a [closing reference to an issue](https://help.github.com/articles/closing-issues-via-commit-messages/) if any.

Samples: (even more samples)

```
docs(changelog): update changelog to beta.5

fix(release): need to depend on latest rxjs and zone.js

The version in our package.json gets copied to the one we publish, and users need the latest of these.

docs(router): fix typo 'containa' to 'contains' (#36764)

Closes #36763

PR Close #36764
```

## Revert

If the commit reverts a previous commit, it should begin with `revert:` , followed
by the header of the reverted commit. In the body it should say: `This reverts
commit <hash>.`, where the hash is the SHA of the commit to revert.

## Type

Must be one of the following:

* `build`: Changes that affect the build system or external dependencies.
* `ci`: Changes to our CI configuration files and scripts.
* `docs`: Documentation changes.
* `feat`: A new feature.
* `fix`: A bug fix.
* `perf`: A code change that improves performance.
* `refactor`: A code change that neither fixes a bug nor adds a feature.
* `style`: Changes that do not affect the meaning of the code (white-space,
    formatting, missing semi-colons, etc).
* `test`: Adding missing tests or correcting existing tests.

## Subject

The subject contains a succinct description of the change:

* Use the imperative, present tense: "change" not "changed" nor "changes".
* Don't capitalize the first letter.
* No dot (.) at the end.

## Body

Same as in the subject, use the imperative, present tense: "change" not
"changed" nor "changes". The body should include the motivation for the change
and contrast this with previous behavior.

## Footer

The footer should contain any information about Breaking Changes and is also the
place to reference issues that this commit Closes.

Breaking Changes should start with the word `BREAKING CHANGE:` with a space or
two newlines. The rest of the commit message is then used for this.

## Pre-commit

To ensure that your project follows these guidelines, add the following
to your [pre-commit configuration](python_ci.md):

!!! note "File: .pre-commit-config.yaml"
    ```yaml
    - repo: https://github.com/commitizen-tools/commitizen
      rev: master
      hooks:
        - id: commitizen
          stages: [commit-msg]
    ```

To make your life easier, change your workflow to use
[commitizen](https://commitizen-tools.github.io/commitizen/).

In Vim, if you're using Vim fugitive [change the
configuration](https://vi.stackexchange.com/questions/3670/how-to-enter-insert-mode-when-entering-neovim-terminal-pane)
to:

```vimrc
nnoremap <leader>gc :terminal cz c<CR>
nnoremap <leader>gr :terminal cz c --retry<CR>

" Open terminal mode in insert mode
if has('nvim')
    autocmd TermOpen term://* startinsert
endif
autocmd BufLeave term://* stopinsert
```

If some pre-commit hook fails, make the changes and then use `<leader>gr` to
repeat the same commit message.

To automatically generate the changelog use `cz bump --changelog --no-verify`.
The `--no-verify` part is required [if you use pre-commit
hooks](https://github.com/commitizen-tools/commitizen/issues/164).

Whenever you want to release `1.0.0`, use `cz bump --changelog --no-verify
--increment MAJOR`.

# [Black code style](https://black.readthedocs.io)

[Black](python_ci.md#black) is a style guide enforcement tool.

# [Flake8](https://flake8.pycqa.org/)

[Flake8](python_ci.md#flake8) is another style guide enforcement tool.

# [Type hints](https://realpython.com/python-type-checking/#type-systems)

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

## Advantages and disadvantages

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

## Usage

### Function annotations

```python
def func(arg: arg_type, optarg: arg_type = default) -> return_type:
    ...
```
For arguments the syntax is `argument: annotation`, while the return type is
annotated using `-> annotation`. Note that the annotation must be a valid Python
expression.

When running the code, the special `.__annotations__` attribute on the function
 stores the typing information.

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
If your function expects some kind of sequence but don't care whether it's
a list or a tuple, use the `typing.Sequence` object.

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

### Optional arguments

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

### [Allow any subclass](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#union-types)

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

### Type aliases

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

This can be useful when you need lists of subclasses or optional list of
subclasses. The expected behavior doesn't work.

```python
Entity = TypeVar('Entity', model.Project, model.Tag, model.Task)
Entities = List[Entity]
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

### [Specify the type of the class in it's method and attributes](https://stackoverflow.com/questions/33533148/how-do-i-specify-that-the-return-type-of-a-method-is-the-same-as-the-class-itsel)

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

## [Using mypy with an existing codebase](https://mypy.readthedocs.io/en/latest/existing_code.html)

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
* [Run mypy in Continuous Integration to prevent type errors](python_ci.md#mypy):

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

## [Reveal the type of an expression](https://mypy.readthedocs.io/en/stable/common_issues.html?highlight=get%20type%20of%20object#displaying-the-type-of-an-expression)

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

## [Solve cyclic imports due to typing](https://www.stefaanlippens.net/circular-imports-type-hints-python.html)

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

# Reference

## Type hints

* [Bernat gabor article on the state of type hints in python](https://www.bernat.tech/the-state-of-type-hints-in-python/)
* [Real python article on type checking](https://realpython.com/python-type-checking/#type-systems)
