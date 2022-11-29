---
title: GoodConf
date: 20211127
author: Lyz
---

[goodconf](https://github.com/lincolnloop/goodconf/) is a thin wrapper over
Pydantic's settings management. Allows you to define configuration variables and
load them from environment or JSON/YAML file. Also generates initial
configuration files and documentation for your defined configuration.

# [Installation](https://github.com/lincolnloop/goodconf/#installation)

`pip install goodconf` or `pip install goodconf[yaml]` if parsing/generating
YAML files is required.

# [Basic Usage](https://github.com/lincolnloop/goodconf/#quick-start)

Define the configuration object in `config.py`:

```python
import base64
import os

from goodconf import GoodConf, Field
from pydantic import PostgresDsn


class AppConfig(GoodConf):  # type: ignore
    """Configure my application."""

    debug: bool
    database_url: PostgresDsn = "postgres://localhost:5432/mydb"
    secret_key: str = Field(
        initial=lambda: base64.b64encode(os.urandom(60)).decode(),
        description="Used for cryptographic signing. "
        "https://docs.djangoproject.com/en/2.0/ref/settings/#secret-key",
    )

    class Config:
        """Define the default files to check."""

        default_files = [
            os.path.expanduser("~/.local/share/your_program/config.yaml"),
            "config.yaml",
        ]


config = AppConfig()
```

To load the configuration use `config.load()`. If you don't pass any file to
`load()`, then the `default_files` will be read in order.

Remember that environment variables always take precedence over variables in the
configuration files.

For more details see Pydantic's docs for examples of loading:

- [Dotenv (.env) files](https://pydantic-docs.helpmanual.io/usage/settings/#dotenv-env-support).
- [Docker secrets](https://pydantic-docs.helpmanual.io/usage/settings/#secret-support).

# References

- [Git](https://github.com/lincolnloop/goodconf/)
