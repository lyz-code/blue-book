---
title: Click
date: 20200827
author: Lyz
---

[Click](https://click.palletsprojects.com/) is a Python package for creating
beautiful command line interfaces in a composable way with as little code as
necessary. It’s the “Command Line Interface Creation Kit”. It’s highly
configurable but comes with sensible defaults out of the box.

Click has the following features:

- Arbitrary nesting of commands.
- Automatic help page generation.
- Supports lazy loading of subcommands at runtime.
- Supports implementation of Unix/POSIX command line conventions.
- Supports loading values from environment variables out of the box.
- Support for prompting of custom values.
- Supports file handling out of the box.
- Comes with useful common helpers (getting terminal dimensions, ANSI colors,
  fetching direct keyboard input, screen clearing, finding config paths,
  launching apps and editors).

# [Setuptools Integration](https://click.palletsprojects.com/en/master/setuptools/)

To bundle your script with setuptools, all you need is the script in a Python
package and a setup.py file.

Let’s assume your directory structure changed to this:

```
project/
    yourpackage/
        __init__.py
        main.py
        utils.py
        scripts/
            __init__.py
            yourscript.py
    setup.py
```

In this case instead of using py_modules in your setup.py file you can use
packages and the automatic package finding support of setuptools. In addition to
that it’s also recommended to include other package data.

These would be the modified contents of setup.py:

```python
from setuptools import setup, find_packages

setup(
    name="yourpackage",
    version="0.1.0",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "Click",
    ],
    entry_points={
        "console_scripts": [
            "yourscript = yourpackage.scripts.yourscript:cli",
        ],
    },
)
```

# [Testing Click applications](https://click.palletsprojects.com/en/7.x/testing/)

For basic testing, Click provides the `click.testing` module which provides test
functionality that helps you invoke command line applications and check their
behavior.

The basic functionality for testing Click applications is the `CliRunner` which
can invoke commands as command line scripts. The `CliRunner.invoke()` method
runs the command line script in isolation and captures the output as both bytes
and binary data.

The return value is a Result object, which has the captured output data, exit
code, and optional exception attached:

File: `hello.py`

```python
import click


@click.command()
@click.argument("name")
def hello(name):
    click.echo("Hello %s!" % name)
```

File: `test_hello.py`:

```python
from click.testing import CliRunner
from hello import hello


def test_hello_world():
    runner = CliRunner()
    result = runner.invoke(hello, ["Peter"])
    assert result.exit_code == 0
    assert result.output == "Hello Peter!\n"
```

For subcommand testing, a subcommand name must be specified in the args
parameter of `CliRunner.invoke()` method:

File: `sync.py`:

```python
import click


@click.group()
@click.option("--debug/--no-debug", default=False)
def cli(debug):
    click.echo("Debug mode is %s" % ("on" if debug else "off"))


@cli.command()
def sync():
    click.echo("Syncing")
```

File: `test_sync.py`:

```python
from click.testing import CliRunner
from sync import cli


def test_sync():
    runner = CliRunner()
    result = runner.invoke(cli, ["--debug", "sync"])
    assert result.exit_code == 0
    assert "Debug mode is on" in result.output
    assert "Syncing" in result.output
```

If you want to test user stdin interaction check the
[prompt_toolkit](prompt_toolkit.md) and [pexpect](pexpect.md) articles.

## [File system isolation](https://click.palletsprojects.com/en/7.x/testing/#file-system-isolation)

For basic command line tools with file system operations, the
`CliRunner.isolated_filesystem()` method is useful for setting the current
working directory to a new, empty folder.

File: `cat.py`:

```python
import click


@click.command()
@click.argument("f", type=click.File())
def cat(f):
    click.echo(f.read())
```

File: `test_cat.py`:

```python
from click.testing import CliRunner
from cat import cat


def test_cat():
    runner = CliRunner()
    with runner.isolated_filesystem():
        with open("hello.txt", "w") as f:
            f.write("Hello World!")

        result = runner.invoke(cat, ["hello.txt"])
        assert result.exit_code == 0
        assert result.output == "Hello World!\n"
```

## Testing the value of stdout and stderr

The `runner` has the `stdout` and `stderr` attributes to test if something was
written on those buffers.

## Injecting fake dependencies

If you're following the [domain driven design](domain_driven_design.md)
architecture pattern, you'll probably need to inject some fake objects instead
of using the original objects.

The challenge is to do it without modifying your real code too much for the sake
of testing. Harry J.W. Percival and Bob Gregory have an interesting proposal in
their
[Dependency Injection (and Bootstrapping)](https://www.cosmicpython.com/book/chapter_13_dependency_injection.html)
chapter, although I found it a little bit complex.

Imagine that we've got an adapter to interact with the
[Gitea](https://gitea.io/) web application called `Gitea`.

File: `adapters/gitea.py`:

```python
class Gitea:
    fake: bool = False
```

The Click cli definition would be:

File: `entrypoints/cli.py`:

```python
import logging
from adapters.gitea import Gitea

log = logging.getLogger(__name__)


@click.group()
@click.pass_context
def cli(ctx: click.core.Context) -> None:
    """Command line interface main click entrypoint."""
    ctx.ensure_object(dict)
    try:
        ctx.obj["gitea"]
    except KeyError:
        ctx.obj["gitea"] = load_gitea()


@cli.command()
@click.pass_context
def is_fake(ctx: Context) -> None:
    if ctx.obj["gitea"].fake:
        log.info("It's fake!")


def load_gitea() -> Gitea:
    """Configure the Gitea object."""
    return Gitea()
```

Where:

- `load_gitea`: is a simplified version of the loading of an adapter, in a real
  example, you'll probably will need to catch some exceptions when loading the
  object.
- `is_fake`: Is the subcommand we're going to use to test if the adapter has
  been replaced by the fake object.

The fake implementation of the adapter is called `FakeGitea`.

File: `tests/fake_adapters.py`:

```python
class FakeGitea:
    fake: bool = True
```

To inject `FakeGitea` in the tests we need to load it in the `'gitea'` key of
the `obj` attribute of the click `ctx` `Context` object. To do it create the
`fake_dependencies` dictionary with the required fakes and pass it to the
`invoke` call.

File: `tests/e2e/test_cli.py`:

```python
from tests.fake_adapters import FakeGitea
from _pytest.logging import LogCaptureFixture

fake_dependencies = {"gitea": FakeGitea()}


@pytest.fixture(name="runner")
def fixture_runner() -> CliRunner:
    """Configure the Click cli test runner."""
    return CliRunner()


def test_fake_injection(runner: CliRunner, caplog: LogCaptureFixture) -> None:
    result = runner.invoke(cli, ["is_fake"], obj=fake_dependencies)

    assert result.exit_code == 0
    assert (
        "entrypoints.cli",
        logging.INFO,
        "It's fake!",
    ) in caplog.record_tuples
```

In this way we don't need to ship the fake objects with the code, and the
modifications are minimal. Only the `try/except KeyError` snippet in the `cli`
definition.

## [File System Isolation](https://click.palletsprojects.com/en/8.1.x/testing/#file-system-isolation)

For basic command line tools with file system operations, the
`CliRunner.isolated_filesystem()` method is useful for setting the current
working directory to a new, empty folder.

```python
from click.testing import CliRunner
from cat import cat


def test_cat():
    runner = CliRunner()
    with runner.isolated_filesystem():
        with open("hello.txt", "w") as f:
            f.write("Hello World!")

        result = runner.invoke(cat, ["hello.txt"])
        assert result.exit_code == 0
        assert result.output == "Hello World!\n"
```

Pass `temp_dir` to control where the temporary directory is created. The
directory will not be removed by Click in this case. This is useful to integrate
with a framework like Pytest that manages temporary files.

```python
def test_keep_dir(tmp_path):
    runner = CliRunner()

    with runner.isolated_filesystem(temp_dir=tmp_path) as td:
        ...
```

# [Options](https://click.palletsprojects.com/en/7.x/options/)

## [Boolean Flags](https://click.palletsprojects.com/en/7.x/options/#boolean-flags)

Boolean flags are options that can be enabled or disabled. This can be
accomplished by defining two flags in one go separated by a slash (/) for
enabling or disabling the option. Click always wants you to provide an enable
and disable flag so that you can change the default later.

```python
import sys


@click.command()
@click.option("--shout/--no-shout", default=False)
def info(shout):
    rv = sys.platform
    if shout:
        rv = rv.upper() + "!!!!111"
    click.echo(rv)
```

If you really don’t want an off-switch, you can just define one and manually
inform Click that something is a flag:

```python
import sys


@click.command()
@click.option("--shout", is_flag=True)
def info(shout):
    rv = sys.platform
    if shout:
        rv = rv.upper() + "!!!!111"
    click.echo(rv)
```

## [Accepting values from environmental variables](https://click.palletsprojects.com/en/7.x/options/#values-from-environment-variables)

Click is the able to accept parameters from environment variables. There are two
ways to define them.

- Passing the `auto_envvar_prefix` to the script that is invoked so each command
  and parameter is then added as an uppercase underscore-separated variable.

- Manually pull values in from specific environment variables by defining the
  name of the environment variable on the option.

  ```python
  @click.command()
  @click.option("--username", envvar="USERNAME")
  def greet(username):
      click.echo(f"Hello {username}!")


  if __name__ == "__main__":
      greet()
  ```

# [Arguments](https://click.palletsprojects.com/en/7.x/arguments/)

Arguments work similarly to options but are positional. They also only support a
subset of the features of options due to their syntactical nature. Click will
also not attempt to document arguments for you and wants you to document them
manually in order to avoid ugly help pages.

## [Basic Arguments](https://click.palletsprojects.com/en/7.x/arguments/#basic-arguments)

The most basic option is a simple string argument of one value. If no type is
provided, the type of the default value is used, and if no default value is
provided, the type is assumed to be `STRING`.

```python
@click.command()
@click.argument("filename")
def touch(filename):
    """Print FILENAME."""
    click.echo(filename)
```

And what it looks like:

```bash
$ touch foo.txt
foo.txt
```

## [Variadic arguments](https://pocoo-click.readthedocs.io/en/latest/arguments/?highlight=variadic#variadic-arguments)

The second most common version is variadic arguments where a specific (or
unlimited) number of arguments is accepted. This can be controlled with the
`nargs` parameter. If it is set to `-1`, then an unlimited number of arguments
is accepted.

The value is then passed as a tuple. Note that only one argument can be set to
`nargs=-1`, as it will eat up all arguments.

```python
@click.command()
@click.argument("src", nargs=-1)
@click.argument("dst", nargs=1)
def copy(src, dst):
    """Move file SRC to DST."""
    for fn in src:
        click.echo("move %s to folder %s" % (fn, dst))
```

You can't use
[variadic arguments and then specify a command](https://github.com/pallets/click/issues/1153).

## [File Arguments](https://click.palletsprojects.com/en/7.x/arguments/#file-arguments)

Command line tools are more fun if they work with files the Unix way, which is
to accept `-` as a special file that refers to stdin/stdout.

Click supports this through the `click.File` type which intelligently handles
files for you. It also deals with Unicode and bytes correctly for all versions
of Python so your script stays very portable.

```python
@click.command()
@click.argument("input", type=click.File("rb"))
@click.argument("output", type=click.File("wb"))
def inout(input, output):
    """Copy contents of INPUT to OUTPUT."""
    while True:
        chunk = input.read(1024)
        if not chunk:
            break
        output.write(chunk)
```

And what it does:

```bash
$ inout - hello.txt
hello
^D
$ inout hello.txt -
hello
```

## [File path arguments](https://click.palletsprojects.com/en/7.x/arguments/#file-path-arguments)

In the previous example, the files were opened immediately. If we just want the
filename, you should be using the `Path` type. Not only will it return either
bytes or Unicode depending on what makes more sense, but it will also be able to
do some basic checks for you such as existence checks.

```python
@click.command()
@click.argument("filename", type=click.Path(exists=True))
def touch(filename):
    """Print FILENAME if the file exists."""
    click.echo(click.format_filename(filename))
```

And what it does:

```bash
$ touch hello.txt
hello.txt

$ touch missing.txt
Usage: touch [OPTIONS] FILENAME
Try 'touch --help' for help.

Error: Invalid value for 'FILENAME': Path 'missing.txt' does not exist.
```

## [Set allowable values for an argument](https://stackoverflow.com/questions/55065439/python-click-set-allowable-values-for-option)

```python
@cli.command()
@click.argument("source")
@click.argument("destination")
@click.option("--mode", type=click.Choice(["local", "ftp"]), required=True)
def copy(source, destination, mode):
    print(
        "copying files from "
        + source
        + " to "
        + destination
        + "using "
        + mode
        + " mode"
    )
```

# [Commands and groups](https://click.palletsprojects.com/en/7.x/commands)

## [Nested handling and contexts](https://click.palletsprojects.com/en/7.x/commands/?highlight=pass%20context#nested-handling-and-contexts)

Each time a command is invoked, a new context is created and linked with the
parent context. Contexts are passed to parameter callbacks together with the
value automatically. Commands can also ask for the context to be passed by
marking themselves with the `pass_context()` decorator. In that case, the
context is passed as first argument.

The context can also carry a program specified object that can be used for the
program’s purposes.

```python
@click.group(help="Description of the command line.")
@click.option('--debug/--no-debug', default=False)
@click.pass_context
def cli(ctx, debug):
    # ensure that ctx.obj exists and is a dict (in case `cli()` is called
    # by means other than the `if` block below)
    ctx.ensure_object(dict)

    ctx.obj['DEBUG'] = debug

@cli.command()
@click.pass_context
def sync(ctx):
    click.echo(f'Debug is {ctx.obj['DEBUG'] and 'on' or 'off'}'))

if __name__ == '__main__':
    cli(obj={})
```

If the object is provided, each context will pass the object onwards to its
children, but at any level a context’s object can be overridden. To reach to a
parent, `context.parent` can be used.

In addition to that, instead of passing an object down, nothing stops the
application from modifying global state. For instance, you could just flip a
global `DEBUG` variable and be done with it.

## [Add default command to group](https://github.com/click-contrib/click-default-group)

You need to use `DefaultGroup`, which is a sub class of `click.Group`. But it
invokes a default subcommand instead of showing a help message when a subcommand
is not passed.

```bash
pip install click-default-group
```

```python
import click
from click_default_group import DefaultGroup


@click.group(cls=DefaultGroup, default="foo", default_if_no_args=True)
def cli():
    pass


@cli.command()
def foo():
    click.echo("foo")


@cli.command()
def bar():
    click.echo("bar")
```

Then you can invoke that without explicit subcommand name:

```bash
$ cli.py --help
Usage: cli.py [OPTIONS] COMMAND [ARGS]...

Options:
--help    Show this message and exit.

Command:
foo*
bar

$ cli.py
foo
$ cli.py foo
foo
$ cli.py bar
bar
```

## [Hide a command from the help](https://stackoverflow.com/questions/34334392/python-click-make-some-options-hidden)

```python
@click.command(..., hidden=True)
```

## [Invoke other commands from a command](https://click.palletsprojects.com/en/6.x/advanced/#invoking-other-commands)

This is a pattern that is generally discouraged with Click, but possible
nonetheless. For this, you can use the `Context.invoke()` or `Context.forward()`
methods.

They work similarly, but the difference is that `Context.invoke()` merely
invokes another command with the arguments you provide as a caller, whereas
`Context.forward()` fills in the arguments from the current command. Both accept
the command as the first argument and everything else is passed onwards as you
would expect.

```python
cli = click.Group()


@cli.command()
@click.option("--count", default=1)
def test(count):
    click.echo("Count: %d" % count)


@cli.command()
@click.option("--count", default=1)
@click.pass_context
def dist(ctx, count):
    ctx.forward(test)
    ctx.invoke(test, count=42)
```

And what it looks like:

```bash
$ cli dist
Count: 1
Count: 42
```

# References

- [Homepage](https://click.palletsprojects.com/)

- [Click vs other argument parsers](https://click.palletsprojects.com/en/7.x/why/)
