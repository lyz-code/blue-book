---
title: Typer
date: 20220906
author: Lyz
---

[Typer](https://typer.tiangolo.com/) is a library for building CLI applications
that users will love using and developers will love creating. Based on Python
3.6+ type hints.

The key features are:

- *Intuitive to write*: Great editor support. Completion everywhere. Less time
  debugging. Designed to be easy to use and learn. Less time reading docs.
- *Easy to use*: It's easy to use for the final users. Automatic help, and
  automatic completion for all shells.
- *Short*: Minimize code duplication. Multiple features from each parameter
  declaration. Fewer bugs.
- *Start simple*: The simplest example adds only 2 lines of code to your app: 1
  import, 1 function call.
- *Grow large*: Grow in complexity as much as you want, create arbitrarily
  complex trees of commands and groups of subcommands, with options and
  arguments.

# Installation

```bash
pip install 'typer[all]'
```

# [Minimal usage](https://typer.tiangolo.com/#the-absolute-minimum)

```python
import typer


def main(name: str):
    print(f"Hello {name}")


if __name__ == "__main__":
    typer.run(main)
```

# [Usage](https://typer.tiangolo.com/#the-absolute-minimum)

Create a `typer.Typer()` app, and create two subcommands with their parameters.

```python
import typer

app = typer.Typer()


@app.command()
def hello(name: str):
    print(f"Hello {name}")


@app.command()
def goodbye(name: str, formal: bool = False):
    if formal:
        print(f"Goodbye Ms. {name}. Have a good day.")
    else:
        print(f"Bye {name}!")


if __name__ == "__main__":
    app()
```

## [Using subcommands](https://typer.tiangolo.com/tutorial/subcommands/single-file/)

In some cases, it's possible that your application code needs to live on a
single file.

```python
import typer

app = typer.Typer()
items_app = typer.Typer()
app.add_typer(items_app, name="items")
users_app = typer.Typer()
app.add_typer(users_app, name="users")


@items_app.command("create")
def items_create(item: str):
    print(f"Creating item: {item}")


@items_app.command("delete")
def items_delete(item: str):
    print(f"Deleting item: {item}")


@items_app.command("sell")
def items_sell(item: str):
    print(f"Selling item: {item}")


@users_app.command("create")
def users_create(user_name: str):
    print(f"Creating user: {user_name}")


@users_app.command("delete")
def users_delete(user_name: str):
    print(f"Deleting user: {user_name}")


if __name__ == "__main__":
    app()
```

Then you'll be able to call each subcommand with:

```bash
python main.py items create
```

For more complex code use [nested subcommands](#nested-subcommands)

### [Nested Subcommands](https://typer.tiangolo.com/tutorial/subcommands/nested-subcommands/)

You can split the commands in different files for clarity once the code starts
to grow:

File: `reigns.py`:

```python
import typer

app = typer.Typer()


@app.command()
def conquer(name: str):
    print(f"Conquering reign: {name}")


@app.command()
def destroy(name: str):
    print(f"Destroying reign: {name}")


if __name__ == "__main__":
    app()
```

File: `towns.py`:

```python
import typer

app = typer.Typer()


@app.command()
def found(name: str):
    print(f"Founding town: {name}")


@app.command()
def burn(name: str):
    print(f"Burning town: {name}")


if __name__ == "__main__":
    app()
```

File: `lands.py`:

```python
import typer

import reigns
import towns

app = typer.Typer()
app.add_typer(reigns.app, name="reigns")
app.add_typer(towns.app, name="towns")

if __name__ == "__main__":
    app()
```

File: `users.py`:

```python
import typer

app = typer.Typer()


@app.command()
def create(user_name: str):
    print(f"Creating user: {user_name}")


@app.command()
def delete(user_name: str):
    print(f"Deleting user: {user_name}")


if __name__ == "__main__":
    app()
```

File: `items.py`:

```python
import typer

app = typer.Typer()


@app.command()
def create(item: str):
    print(f"Creating item: {item}")


@app.command()
def delete(item: str):
    print(f"Deleting item: {item}")


@app.command()
def sell(item: str):
    print(f"Selling item: {item}")


if __name__ == "__main__":
    app()
```

File: `main.py`:

```python
import typer

import items
import lands
import users

app = typer.Typer()
app.add_typer(users.app, name="users")
app.add_typer(items.app, name="items")
app.add_typer(lands.app, name="lands")

if __name__ == "__main__":
    app()
```

## [Using the context](https://typer.tiangolo.com/tutorial/commands/context/)

When you create a Typer application it uses [`Click`](click.md) underneath. And
every Click application has a special object called a "Context" that is normally
hidden.

But you can access the context by declaring a function parameter of type
`typer.Context`.

The context is also used to store objects that you may need for all the
commands, for example a [repository](repository_pattern.md).

Tiangolo (`typer`s main
developer)[suggests to use global variables or a function with `lru_cache`](https://github.com/tiangolo/typer/issues/232).

## [Using short option names](https://typer.tiangolo.com/tutorial/options/name/)

```python
import typer


def main(user_name: str = typer.Option(..., "--name", "-n")):
    print(f"Hello {user_name}")


if __name__ == "__main__":
    typer.run(main)
```

The `...` as the first argument is to make the
[option required](https://typer.tiangolo.com/tutorial/options/required/)

## [Create `-vvv`](https://typer.tiangolo.com/tutorial/parameter-types/number/#counter-cli-options)

You can make a CLI option work as a counter with the `counter` parameter:

```python
import typer


def main(verbose: int = typer.Option(0, "--verbose", "-v", count=True)):
    print(f"Verbose level is {verbose}")


if __name__ == "__main__":
    typer.run(main)
```

## [Get the command line application directory](https://typer.tiangolo.com/tutorial/app-dir/)

You can get the application directory where you can, for example, save
configuration files with `typer.get_app_dir()`:

```python
from pathlib import Path

import typer

APP_NAME = "my-super-cli-app"


def main() -> None:
    """Define the main command line interface."""
    app_dir = typer.get_app_dir(APP_NAME)
    config_path: Path = Path(app_dir) / "config.json"
    if not config_path.is_file():
        print("Config file doesn't exist yet")


if __name__ == "__main__":
    typer.run(main)
```

It will give you a directory for storing configurations appropriate for your CLI
program for the current user in each operating system.

## [Exiting with an error code](https://typer.tiangolo.com/tutorial/terminating/#exit-with-an-error)

`typer.Exit()` takes an optional code parameter. By default, code is `0`,
meaning there was no error.

You can pass a code with a number other than `0` to tell the terminal that there
was an error in the execution of the program:

```python
import typer


def main(username: str):
    if username == "root":
        print("The root user is reserved")
        raise typer.Exit(code=1)
    print(f"New user created: {username}")


if __name__ == "__main__":
    typer.run(main)
```

## [Create a `--version` command](https://typer.tiangolo.com/tutorial/options/version/)

You could use a callback to implement a `--version` CLI option.

It would show the version of your CLI program and then it would terminate it.
Even before any other CLI parameter is processed.

```python
from typing import Optional

import typer

__version__ = "0.1.0"


def version_callback(value: bool) -> None:
    """Print the version of the program."""
    if value:
        print(f"Awesome CLI Version: {__version__}")
        raise typer.Exit()


def main(
    version: Optional[bool] = typer.Option(
        None, "--version", callback=version_callback, is_eager=True
    ),
) -> None:
    ...


if __name__ == "__main__":
    typer.run(main)
```

# [Testing](https://typer.tiangolo.com/tutorial/testing/)

Testing is similar to [`click` testing](click.md#testing-click-applications),
but you import the `CliRunner` directly from `typer`:

```python
from typer.testing import CliRunner
```

# References

- [Docs](https://typer.tiangolo.com/)
- [Source](https://github.com/tiangolo/typer)
- [Issues](https://github.com/tiangolo/typer/issues)
