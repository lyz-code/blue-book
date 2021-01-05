---
title: Bandit
date: 20201016
author: Lyz
---

[Bandit](https://bandit.readthedocs.io/en/latest/) finds common security issues
in Python code. To do this, Bandit processes each file, builds an AST from it,
and runs appropriate plugins against the AST nodes. Once Bandit has finished
scanning all the files, it generates a report.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `bandit` already configured.

# Installation

```bash
pip install bandit
```

# Usage

## Ignore an error.

Add the `# nosec` comment in the line.

# Configuration

You can run bandit through:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
            - repo: https://github.com/Lucas-C/pre-commit-hooks-bandit
              rev: v1.0.4
              hooks:
              - id: python-bandit-vulnerability-check
        ```

        bandit takes a lot of time to run, so it slows down too much the
        commiting, therefore it should be run only in the CI.

* Github Actions: Make sure to check that the correct python version is applied.

    !!! note "File: .github/workflows/security.yml"
        ```yaml
        name: Security

        on: [push, pull_request]

        jobs:
          bandit:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout
                uses: actions/checkout@v2
              - uses: actions/setup-python@v2
                with:
                  python-version: 3.7
              - name: Install dependencies
                run: pip install bandit
              - name: Execute bandit
                run: bandit -r project
        ```

# References

* [Docs](https://bandit.readthedocs.io/en/latest/)
