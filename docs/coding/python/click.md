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

* Arbitrary nesting of commands.
* Automatic help page generation.
* Supports lazy loading of subcommands at runtime.
* Supports implementation of Unix/POSIX command line conventions.
* Supports loading values from environment variables out of the box.
* Support for prompting of custom values.
* Supports file handling out of the box.
* Comes with useful common helpers (getting terminal dimensions, ANSI colors,
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
    name='yourpackage',
    version='0.1.0',
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'Click',
    ],
    entry_points={
        'console_scripts': [
            'yourscript = yourpackage.scripts.yourscript:cli',
        ],
    },
)
```

# [Testing Click applications](https://click.palletsprojects.com/en/7.x/testing/)

For basic testing, Click provides the `click.testing` module which provides test
functionality that helps you invoke command line applications and check their
behavior.

The basic functionality for testing Click applications is the `CliRunner` which
can invoke commands as command line scripts. The `CliRunner.invoke()` method runs
the command line script in isolation and captures the output as both bytes and
binary data.

The return value is a Result object, which has the captured output data, exit code, and optional exception attached:

!!! note "File: hello.py"

    ```python
    import click

    @click.command()
    @click.argument('name')
    def hello(name):
       click.echo('Hello %s!' % name)
    ```

!!! note "File: test_hello.py"

    ```python
    from click.testing import CliRunner
    from hello import hello

    def test_hello_world():
      runner = CliRunner()
      result = runner.invoke(hello, ['Peter'])
      assert result.exit_code == 0
      assert result.output == 'Hello Peter!\n'
    ```

For subcommand testing, a subcommand name must be specified in the args
parameter of `CliRunner.invoke()` method:

!!! note "File: sync.py"

    ```python
    import click

    @click.group()
    @click.option('--debug/--no-debug', default=False)
    def cli(debug):
       click.echo('Debug mode is %s' % ('on' if debug else 'off'))

    @cli.command()
    def sync():
       click.echo('Syncing')
    ```

!!! note "File: test_sync.py"

    ```python
    from click.testing import CliRunner
    from sync import cli

    def test_sync():
      runner = CliRunner()
      result = runner.invoke(cli, ['--debug', 'sync'])
      assert result.exit_code == 0
      assert 'Debug mode is on' in result.output
      assert 'Syncing' in result.output
    ```

## [File system isolation](https://click.palletsprojects.com/en/7.x/testing/#file-system-isolation)

For basic command line tools with file system operations, the
`CliRunner.isolated_filesystem()` method is useful for setting the current working
directory to a new, empty folder.

!!! note "File: cat.py"

    ```python
    import click

    @click.command()
    @click.argument('f', type=click.File())
    def cat(f):
       click.echo(f.read())
    ```

!!! note "File: test_cat.py"

    ```python
    from click.testing import CliRunner
    from cat import cat

    def test_cat():
       runner = CliRunner()
       with runner.isolated_filesystem():
          with open('hello.txt', 'w') as f:
              f.write('Hello World!')

          result = runner.invoke(cat, ['hello.txt'])
          assert result.exit_code == 0
          assert result.output == 'Hello World!\n'
    ```

# [Arguments](https://click.palletsprojects.com/en/7.x/arguments/)

Arguments work similarly to options but are positional. They also only support
a subset of the features of options due to their syntactical nature. Click will
also not attempt to document arguments for you and wants you to document them
manually in order to avoid ugly help pages.

## [Basic Arguments](https://click.palletsprojects.com/en/7.x/arguments/#basic-arguments)

The most basic option is a simple string argument of one value. If no type is
provided, the type of the default value is used, and if no default value is
provided, the type is assumed to be `STRING`.

```python
@click.command()
@click.argument('filename')
def touch(filename):
    """Print FILENAME."""
    click.echo(filename)
```

And what it looks like:

```bash
$ touch foo.txt
foo.txt
```



# References

* [Homepage](https://click.palletsprojects.com/)

* [Click vs other argument parsers](https://click.palletsprojects.com/en/7.x/why/)
