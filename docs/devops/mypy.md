---
title: Mypy
date: 20201016
author: Lyz
---

[Mypy](https://mypy.readthedocs.io/en/stable/) is an optional static type
checker for Python that aims to combine the benefits of dynamic (or "duck")
typing and static typing. Mypy combines the expressive power and convenience of
Python with a powerful type system and compile-time type checking.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `mypy` already configured.

# Installation

```bash
pip install mypy
```

# Configuration

Mypy configuration is saved in the `mypy.ini` file, and they don't yet [support
`pyproject.toml`](https://github.com/python/mypy/issues/5205).

!!! note "File: mypy.ini"
    ```ini
    [mypy]
    show_error_codes = True
    follow_imports = silent
    strict_optional = True
    warn_redundant_casts = True
    warn_unused_ignores = True
    disallow_any_generics = True
    check_untyped_defs = True
    no_implicit_reexport = True
    warn_unused_configs = True
    disallow_subclassing_any = True
    disallow_incomplete_defs = True
    disallow_untyped_decorators = True
    disallow_untyped_calls = True

    # for strict mypy: (this is the tricky one :-))
    disallow_untyped_defs = True
    ```

You can use it both with:

* [Pre-commit](ci.md#configuring-pre-commit):

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://github.com/pre-commit/mirrors-mypy
          rev: v0.782
          hooks:
          - name: Run mypy static analysis tool
            id: mypy
        ```

* Github Actions:

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        name: Lint

        on: [push, pull_request]

        jobs:
          Mypy:
            runs-on: ubuntu-latest
            name: Mypy
            steps:
            - uses: actions/checkout@v1
            - name: Set up Python 3.7
              uses: actions/setup-python@v1
              with:
                python-version: 3.7
            - name: Install Dependencies
              run: pip install mypy
            - name: mypy
              run: mypy
        ```
## Ignore one line

Add `# type: ignore` to the line you want to skip.

# Troubleshooting

## Module X has no attribute Y

If you're importing objects from your own module, you need to tell mypy that
those objects are available. To do so in the `__init__.py` of your module, list
them under the [`__all__` variable](https://stackoverflow.com/a/35710527).

!!! note "File: __init__.py"
    ```python
    from .model import Entity

    __all__ = [
        "Entity",
    ]
    ```

## [W0707: Consider explicitly re-raising using the 'from'
keyword](https://blog.ram.rachum.com/post/621791438475296768/improving-python-exception-chaining-with)

The error can be raised by two cases.

* An exception was raised, we were handling it, and something went wrong in the
    process of handling it.
* An exception was raised, and we decided to replace it with a different
    exception that will make more sense to whoever called this code.

```python
try:
  self.connection, _ = self.sock.accept()
except socket.timeout as error:
  raise IPCException('The socket timed out') from error
```

The `error` bit at the end tells Python: The `IPCException` that we’re raising
is just a friendlier version of the `socket.timeout` that we just caught.

When we run that code and reach that exception, the traceback is going to look
like this:

```code
Traceback (most recent call last):
  File "foo.py", line 19, in
    self.connection, _ = self.sock.accept()
  File "foo.py", line 7, in accept
    raise socket.timeout
socket.timeout

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "foo.py", line 21, in
    raise IPCException('The socket timed out') from e
IPCException: The socket timed out
```

The `The above exception was the direct cause of the following exception:` part
tells us that we are in the second case.

If you were dealing with the first one, the message between the two tracebacks would be:

```code
During handling of the above exception, another exception occurred:
```

# Issues

* [Incompatible return value with
    TypeVar](https://github.com/python/mypy/issues/10003): search for `10003` in
    repository-pattern and fix the `type: ignore`.

# References

* [Docs](https://mypy.readthedocs.io/en/stable/)
* [Git](https://github.com/python/mypy)
* [Homepage](http://mypy-lang.org/)
