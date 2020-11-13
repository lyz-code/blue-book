---
title: Markdownlint
date: 20201113
author: Lyz
---

[markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) is
a command line interface for the
[markdownlint](https://github.com/DavidAnson/markdownlint) Node.js
style checker and lint tool for Markdown/CommonMark files.

I've evaluated these other projects
([1](https://github.com/markdownlint/markdownlint),
[2](https://github.com/DavidAnson/markdownlint), but their configuration is less
user friendly and are less maintained.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `markdownlint` already configured.

# Installation

```bash
npm install -g markdownlint-cli
```

# Configuration

To [configure your
project](https://github.com/igorshubovych/markdownlint-cli#configuration), add
a `.markdownlint.json` in your project root directory, or in any parent.  I've
opened [an issue](https://github.com/igorshubovych/markdownlint-cli/issues/113)
to see if they are going to support `pyproject.toml` to save the configuration.
Check the [styles
examples](https://github.com/DavidAnson/markdownlint/tree/main/style).

Go to the
[rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
document if you ever need to check more information on a specific rule.

You can use it both with:

* The Vim through the [ALE plugin](vim_plugins.md#ale).

* [Pre-commit](ci.md#configuring-pre-commit):

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        - repo: https://github.com/igorshubovych/markdownlint-cli
          rev: v0.23.2
          hooks:
            - id: markdownlint
        ```

# Troubleshooting

Until the [#2926](https://github.com/dense-analysis/ale/pull/2926/files) PR is
merged you need to change the `let l:pattern=.*` file to make the linting work to:

!!! note "File: ~/.vim/bundle/ale/autoload/ale/handlers"
    ```vim
    let l:pattern=': \?\(\d*\):\? \(MD\d\{3}\)\(\/\)\([A-Za-z0-9-\/]\+\)\(.*\)$'
    ```

# References

* [Git](https://github.com/igorshubovych/markdownlint-cli)
