---
title: Yamllint
date: 20201016
author: Lyz
---

[Yamllint](https://github.com/adrienverge/yamllint) is a linter for YAML files.

`yamllint` does not only check for syntax validity, but for weirdnesses like key
repetition and cosmetic problems such as lines length, trailing spaces or
indentation.

You can use it both with:

* The Vim through the [ALE plugin](vim_plugins.md#ale).

* [Pre-commit](ci.md#configuring-pre-commit):

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        - repo: https://github.com/adrienverge/yamllint
          rev: v1.21.0
          hooks:
            - id: yamllint
        ```

# References

* [Git](https://github.com/adrienverge/yamllint)
* [Docs](https://yamllint.readthedocs.io/)
