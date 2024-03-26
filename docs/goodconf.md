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

## Initialize the config with a default value if the file doesn't exist

```python
    def load(self, filename: Optional[str] = None) -> None:
        self._config_file = filename
        if not self.store_dir.is_dir():
            log.warning("The store directory doesn't exist. Creating it")
            os.makedirs(str(self.store_dir))
        if not Path(self.config_file).is_file():
            log.warning("The yaml store file doesn't exist. Creating it")
            self.save()
        super().load(filename)

```
## Config saving

So far [`goodconf` doesn't support saving the config](https://github.com/lincolnloop/goodconf/issues/12). Until it's ready you can use the next snippet:

```python
class YamlStorage(GoodConf):
    """Adapter to store and load information from a yaml file."""

    @property
    def config_file(self) -> str:
        """Return the path to the config file."""
        return str(self._config_file)

    @property
    def store_dir(self) -> Path:
        """Return the path to the store directory."""
        return Path(self.config_file).parent

    def reload(self) -> None:
        """Reload the contents of the authentication store."""
        self.load(self.config_file)

    def load(self, filename: Optional[str] = None) -> None:
        """Load a configuration file."""
        if not filename:
            filename = f"{self.store_dir}/data.yaml"
        super().load(self.config_file)

    def save(self) -> None:
        """Save the contents of the authentication store."""
        with open(self.config_file, "w+", encoding="utf-8") as file_cursor:
            yaml = YAML()
            yaml.default_flow_style = False
            yaml.dump(self.dict(), file_cursor)
```

# References

- [Source](https://github.com/lincolnloop/goodconf/)

[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
