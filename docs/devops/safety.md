---
title: Safety
date: 20201016
author: Lyz
---

[Safety](https://github.com/pyupio/safety) checks your installed dependencies
for known security vulnerabilities.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `safety` already configured.

# Installation

```bash
pip install safety
```

# Configuration

Safety can be used through:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
            - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
              rev: v1.1.3
              hooks:
              - id: python-safety-dependencies-check
        ```

* Github Actions: Make sure to check that the correct python version is applied.

    !!! note "File: .github/workflows/security.yml"
        ```yaml
        name: Security

        on: [push, pull_request]

        jobs:
          Safety:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout
                uses: actions/checkout@v2
              - uses: actions/setup-python@v2
                with:
                  python-version: 3.7
              - name: Install dependencies
                run: pip install safety
              - name: Execute safety
                run: safety check
        ```

# References

* [Git](https://github.com/pyupio/safety)
