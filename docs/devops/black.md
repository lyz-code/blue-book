---
title: black
date: 20201016
author: Lyz
---

[Black](https://black.readthedocs.io/en/stable/) is a style guide enforcement
tool.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `black` already configured.

# Installation

```bash
pip install black
```

# Configuration

Its configuration is stored in `pyproject.toml`.

!!! note "File: pyproject.toml"
    ```ini
    # Example configuration for Black.

    # NOTE: you have to use single-quoted strings in TOML for regular expressions.
    # It's the equivalent of r-strings in Python.  Multiline strings are treated as
    # verbose regular expressions by Black.  Use [ ] to denote a significant space
    # character.

    [tool.black]
    line-length = 88
    target-version = ['py36', 'py37', 'py38']
    include = '\.pyi?$'
    exclude = '''
    /(
        \.eggs
      | \.git
      | \.hg
      | \.mypy_cache
      | \.tox
      | \.venv
      | _build
      | buck-out
      | build
      | dist
      # The following are specific to Black, you probably don't want those.
      | blib2to3
      | tests/data
      | profiling
    )/
    '''
    ```

You can use it both with:

* The Vim [plugin](vim_plugins.md#black)

* [Pre-commit](ci.md#configuring-pre-commit):

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://github.com/ambv/black
          rev: stable
          hooks:
            - id: black
              language_version: python3.7
        ```

* Github Actions:

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        ---
        name: Lint

        on: [push, pull_request]

        jobs:
          Black:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v2
              - uses: actions/setup-python@v2
              - name: Black
                uses: psf/black@stable
        ```

## [Split long lines](https://github.com/psf/black/issues/1787)

If you want to split long lines, you need to use the
`--experimental-string-processing` flag. I haven't found how to set that option
in the config file.

## [Disable the formatting of some lines](https://github.com/psf/black/issues/451)

You can use the comments `# fmt: off` and `# fmt: on`

# References

* [Docs](https://black.readthedocs.io/en/stable/)
* [Git](https://github.com/psf/black)
