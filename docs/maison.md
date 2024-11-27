---
title: Maison
date: 20220907
author: Lyz
---

[Maison](https://github.com/dbatten5/maison) is a Python library to read
configuration settings from configuration files using [`pydantic`](pydantic.md)
behind the scenes.

It's useful to parse TOML config files.

Note: "If you want to use YAML for your config files use
[`goodconf`](goodconf.md) instead."

# Installation

```bash
pip install maison
```

# [Usage](https://dbatten5.github.io/maison/)

```python
from maison import ProjectConfig

config = ProjectConfig(project_name="acme")
foo_option = config.get_option("foo")

print(foo_option)
```

## [Read from file](https://dbatten5.github.io/maison/usage/#source-files)

By default, `maison` will look for a `pyproject.toml` file. If you prefer to
look elsewhere, provide a `source_files` list to `ProjectConfig` and `maison`
will select the first source file it finds from the list.

```python
from maison import ProjectConfig

config = ProjectConfig(project_name="acme", source_files=["acme.ini", "pyproject.toml"])
```

# References

- [Git](https://github.com/dbatten5/maison)
- [Docs](https://dbatten5.github.io/maison/)
