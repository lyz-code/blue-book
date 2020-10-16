---
title: Mypy
date: 20201016
author: Lyz
---

[Mypy](https://mypy.readthedocs.io/en/stable/) is an optional static type
checker for Python that aims to combine the benefits of dynamic (or "duck")
typing and static typing. Mypy combines the expressive power and convenience of
Python with a powerful type system and compile-time type checking.

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

* Pre-commit:

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

# References

* [Docs](https://mypy.readthedocs.io/en/stable/)
* [Git](https://github.com/python/mypy)
* [Homepage](http://mypy-lang.org/)
