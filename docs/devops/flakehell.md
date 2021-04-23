---
title: Flakehell
date: 20201016
author: Lyz
---

[Flakehell](https://github.com/flakehell/flakehell) is a [Flake8](flake8.md) wrapper
to make it cool.

Some of it's features are:

* [Lint md, rst, ipynb, and
    more](https://flakehell.readthedocs.io/parsers.html).
* [Shareable and remote
    configs](https://flakehell.readthedocs.io/config.html#base).
* [Legacy-friendly](https://flakehell.readthedocs.io/commands/baseline.html):
    ability to get report only about new errors.
* Caching for much better performance.
* [Use only specified
    plugins](https://flakehell.readthedocs.io/config.html#plugins), not
    everything installed.
* [Make output beautiful](https://flakehell.readthedocs.io/formatters.html).
* [pyproject.toml](https://www.python.org/dev/peps/pep-0518/) support.
* [Check that all required plugins are
    installed](https://flakehell.readthedocs.io/commands/missed.html).
* [Syntax highlighting in messages and code
    snippets](https://flakehell.readthedocs.io/formatters.html#colored-with-source-code).
* [PyLint](https://github.com/PyCQA/pylint) integration.
* [Remove unused noqa](https://flakehell.readthedocs.io/commands/yesqa.html).
* [Powerful GitLab support](https://flakehell.readthedocs.io/formatters.html#gitlab).
* Codes management:
    * Manage codes per plugin.
    * Enable and disable plugins and codes by wildcard.
    * [Show codes for installed plugins](https://flakehell.readthedocs.io/commands/plugins.html).
    * [Show all messages and codes for a plugin](https://flakehell.readthedocs.io/commands/codes.html).
    * Allow codes intersection for different plugins.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `flakehell` already configured.

# Installation

```bash
pip install flakehell
```

# [Configuration](https://flakehell.readthedocs.io/config.html)

FlakeHell can be configured in
[pyproject.toml](https://www.python.org/dev/peps/pep-0518/). You can specify any
Flake8 options and FlakeHell-specific parameters.

## Plugins

In `pyproject.toml` you can specify `[tool.flakehell.plugins]` table. It's
a list of flake8 [plugins](https://flakehell.readthedocs.io/plugins.html) and
associated to them rules.

Key can be exact plugin name or wildcard template. For example `"flake8-commas"`
or `"flake8-*"`. FlakeHell will choose the longest match for every plugin if
possible. In the previous example, `flake8-commas` will match to the first
pattern, `flake8-bandit` and `flake8-bugbear` to the second, and `pycodestyle`
will not match to any pattern.

Value is a list of templates for error codes for this plugin. First symbol in
every template must be `+` (include) or `-` (exclude). The latest matched
pattern wins. For example, `["+*", "-F*", "-E30?", "-E401"]` means "Include
everything except all checks that starts with `F`, check from `E301` to `E310`,
and `E401`".

!!! note "Example: pyproject.toml"

    ```ini
    [tool.flakehell]
    # optionally inherit from remote config (or local if you want)
    base = "https://raw.githubusercontent.com/life4/flakehell/master/pyproject.toml"
    # specify any flake8 options. For example, exclude "example.py":
    exclude = ["example.py"]
    # make output nice
    format = "grouped"
    # don't limit yourself
    max_line_length = 120
    # show line of source code in output
    show_source = true

    # list of plugins and rules for them
    [tool.flakehell.plugins]
    # include everything in pyflakes except F401
    pyflakes = ["+*", "-F401"]
    # enable only codes from S100 to S199
    flake8-bandit = ["-*", "+S1??"]
    # enable everything that starts from `flake8-`
    "flake8-*" = ["+*"]
    # explicitly disable plugin
    flake8-docstrings = ["-*"]

    # disable some checks for tests
    [tool.flakehell.exceptions."tests/"]
    pycodestyle = ["-F401"]     # disable a check
    pyflakes = ["-*"]           # disable a plugin

    # do not disable `pyflakes` for one file in tests
    [tool.flakehell.exceptions."tests/test_example.py"]
    pyflakes = ["+*"]           # enable a plugin
    ```

Check a [complete
list](https://github.com/DmytroLitvinov/awesome-flake8-extensions) of flake8
extensions.

* [flake8-bugbear](https://github.com/PyCQA/flake8-bugbear): Finding likely bugs
    and design problems in your program. Contains warnings that don't belong in
    pyflakes and pycodestyle.
* [flake8-fixme](https://github.com/tommilligan/flake8-fixme): Check for FIXME,
    TODO and other temporary developer notes.
* [flake8-debugger](https://github.com/JBKahn/flake8-debugger): Check for
    `pdb` or `idbp` imports and set traces.
* [flake8-mutable](https://github.com/ebeweber/flake8-mutable): Checks for
    [mutable default
    arguments](python_anti_patterns.md#mutable-default-arguments) anti-pattern.
* [flake8-pytest](https://github.com/vikingco/flake8-pytest): Check for uses of
    Django-style assert-statements in tests. So no more `self.assertEqual(a, b)`,
    but instead `assert a == b`.
* [flake8-pytest-style](https://github.com/m-burst/flake8-pytest-style): Checks
    common style issues or inconsistencies with pytest-based tests.
* [flake8-simplify](https://github.com/MartinThoma/flake8-simplify): Helps you
    to simplify code.
* [flake8-variables-names](https://github.com/best-doctor/flake8-variables-names):
    Helps to make more readable variables names.
* [pep8-naming](https://github.com/PyCQA/pep8-naming): Check your code against
    PEP 8 naming conventions.
* [flake8-expression-complexity](https://github.com/best-doctor/flake8-expression-complexity):
    Check expression complexity.
* [flake8-use-fstring](https://github.com/MichaelKim0407/flake8-use-fstring):
    Checks you're using f-strings.
* [flake8-docstrings](https://gitlab.com/pycqa/flake8-docstrings): adds an
    extension for the fantastic
    [pydocstyle](https://github.com/pycqa/pydocstyle) tool to [Flake8](flake8.md).
* [flake8-markdown](https://github.com/johnfraney/flake8-markdown): lints
    GitHub-style Python code blocks in Markdown files using flake8.
* [pylint](https://github.com/PyCQA/pylint) is a Python static code analysis
    tool which looks for programming errors, helps enforcing a coding standard,
    sniffs for code smells and offers simple refactoring suggestions.
* [dlint](https://github.com/dlint-py/dlint): Encourage best coding practices
    and helping ensure Python code is secure.
* [flake8-aaa](https://github.com/jamescooke/flake8-aaa): Checks Python tests
    follow the [Arrange-Act-Assert
    pattern](https://github.com/jamescooke/flake8-aaa#what-is-the-arrange-act-assert-pattern).
* [flake8-annotations-complexity](https://github.com/best-doctor/flake8-annotations-complexity):
    Report on too complex type annotations.
* [flake8-annotations](https://github.com/sco1/flake8-annotations): Detects the
    absence of PEP 3107-style function annotations and PEP 484-style type
    comments.
* [flake8-typing-imports](https://github.com/asottile/flake8-typing-imports):
    Checks that typing imports are properly guarded.
* [flake8-comprehensions](https://github.com/adamchainz/flake8-comprehensions):
    Help you write better list/set/dict comprehensions.
* [flake8-eradicate](https://github.com/sobolevn/flake8-eradicate):  find
    commented out (or so called "dead") code.

# Usage

When using FlakeHell, I frequently use the following commands:

`flakehell lint`
: Runs the linter, similar to the flake8 command.

`flakehell plugins`
: Lists all the plugins used, and their configuration status.

`flakehell missed`
: Shows any plugins that are in the configuration but not installed properly.

`flakehell code S322`
: (or any other code) Shows the explanation for that specific warning code.

`flakehell yesqa`
: Removes unused codes from `# noqa` and removes bare noqa that says “ignore
    everything on this line” as is a bad practice.

## Integrations

Flakehell checks can be run in:

* In [Vim](vim.md) though the [ALE plugin](vim_plugins#flakehell).

* Through a pre-commit:

    ```yaml
      - repo: https://github.com/life4/flakehell/
        rev: master
        hooks:
          - name: Run flakehell static analysis tool
            id: flakehell
    ```

* In the CI:
    ```yaml
      - name: Test linters
        run: make lint
    ```

    Assuming you're using a Makefile like the one in my
    [cookiecutter-python-project](https://github.com/lyz-code/cookiecutter-python-project/).

# Issues

* ['Namespace' object has no attribute 'extended_default_ignore'
    error](https://github.com/flakehell/flakehell/issues/10#issuecomment-823512441):
    Until it's fixed either use a version below or equal to 3.9.0, or add to
    your `pyproject.toml`:

    ```ini
    [tool.flakehell]
    extended_default_ignore=[]  # add this
    ```

    Once it's fixed, remove the patch from the maintained projects.

# References

* [Git](https://github.com/flakehell/flakehell)
* [Docs](https://flakehell.readthedocs.io/)

* [Using Flake8 and pyproject.toml with FlakeHell article by Jonathan Bowman](https://dev.to/bowmanjd/using-flake8-and-pyproject-toml-with-flakehell-1cn1)
