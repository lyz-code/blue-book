---
title: Pydantic Mypy Plugin
date: 20201009
author: Lyz
---

Pydantic works well with [mypy](http://mypy-lang.org/) right out of the
box.

However, Pydantic also ships with a mypy plugin that adds a number of important
[pydantic-specific
features](https://pydantic-docs.helpmanual.io/mypy_plugin/#plugin-capabilities)
to mypy that improve its ability to type-check your code.

# [Enabling the Plugin](https://pydantic-docs.helpmanual.io/mypy_plugin/#enabling-the-plugin)

To enable the plugin, just add `pydantic.mypy` to the list of plugins in your
[mypy config file](https://mypy.readthedocs.io/en/latest/config_file.html) (this
could be `mypy.ini` or `setup.cfg`).

To get started, all you need to do is create a `mypy.ini` file with following
contents:
```ini
[mypy]
plugins = pydantic.mypy
```

See the [mypy usage](https://pydantic-docs.helpmanual.io/usage/mypy/) and [plugin
configuration](https://pydantic-docs.helpmanual.io/mypy_plugin/#configuring-the-plugin)
docs for more details.

# References

* [Pydantic mypy plugin docs](https://pydantic-docs.helpmanual.io/mypy_plugin/)
