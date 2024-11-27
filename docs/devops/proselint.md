---
title: Proselint
date: 20201113
author: Lyz
---

[Proselint](https://github.com/amperser/proselint/) is another linter for prose.

# Installation

```bash
pip install proselint
```

# Configuration

It can [be configured](https://github.com/amperser/proselint/#checks) through
the `~/.config/proselint/config` file, such as:

```json
{
  "checks": {
    "typography.diacritical_marks": false
  }
}
```

* The Vim through the [ALE plugin](vim_plugins.md#ale).

* [Pre-commit](ci.md#configuring-pre-commit):

    ```yaml
    - repo: https://github.com/amperser/proselint/
      rev: 0.10.2
      hooks:
        - id: proselint
          exclude: LICENSE|requirements
          files: \.(md|mdown|markdown)$
    ```

# References

* [Git](https://github.com/amperser/proselint/)
