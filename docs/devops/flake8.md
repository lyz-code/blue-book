---
title: Flake8
date: 20201016
author: Lyz
---

!!! warning "DEPRECATION: Use [Flakehell](flakeheaven.md) instead"
    Flake8 [doesn't support
    `pyproject.toml`](https://gitlab.com/pycqa/flake8/-/issues/428), which is
    becoming the standard, so I suggest using [Flakehell](flakeheaven.md) instead.

[Flake8](https://flake8.pycqa.org/en/latest/) is a style guide enforcement tool.
Its [configuration](https://flake8.pycqa.org/en/latest/user/configuration.html)
is stored in `setup.cfg`, `tox.ini` or `.flake8`.

!!! note "File: .flake8"
    ```ini
    [flake8]
    # ignore = E203, E266, E501, W503, F403, F401
    max-line-length = 88
    # max-complexity = 18
    # select = B,C,E,F,W,T4,B9
    ```

You can use it both with:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://gitlab.com/pycqa/flake8
          rev: master
          hooks:
            - id: flake8
        ```
* Github Actions:

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        name: Lint

        on: [push, pull_request]

        jobs:
          Flake8:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v2
              - uses: actions/setup-python@v2
              - name: Flake8
                uses: cclauss/GitHub-Action-for-Flake8@v0.5.0
        ```

# References

* [Docs](https://flake8.pycqa.org/en/latest/)
