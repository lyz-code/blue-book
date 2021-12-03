---
title: Pipenv
date: 20211130
author: Lyz
---

[Pipenv](https://github.com/pypa/pipenv) is a tool that aims to bring the best
of all packaging worlds (bundler, composer, npm, cargo, yarn, etc.) to the
Python world.

It automatically creates and manages a virtualenv for your projects, as well as
adds/removes packages from your Pipfile as you install/uninstall packages. It
also generates the ever-important Pipfile.lock, which is used to produce
deterministic builds.

# [Features](https://github.com/pypa/pipenv#-features)

* Enables truly *deterministic builds*, while easily specifying *only
    what you want*.
* Generates and checks file hashes for locked dependencies.
* Automatically install required Pythons, if `pyenv` is available.
* Automatically finds your project home, recursively, by looking for a
    `Pipfile`.
* Automatically generates a `Pipfile`, if one doesn't exist.
* Automatically creates a virtualenv in a standard location.
* Automatically adds/removes packages to a `Pipfile` when they are
    un/installed.
* Automatically loads `.env` files, if they exist.

The main commands are `install`, `uninstall`, and `lock`, which
generates a `Pipfile.lock`. These are intended to replace
`$ pip install` usage, as well as manual virtualenv management (to
activate a virtualenv, run `$ pipenv shell`).

### Basic Concepts

* A virtualenv will automatically be created, when one doesn't exist.
* When no parameters are passed to `install`, all packages
    `[packages]` specified will be installed.
* Otherwise, whatever virtualenv defaults to will be the default.

### Other Commands

-   `shell` will spawn a shell with the virtualenv activated.
-   `run` will run a given command from the virtualenv, with any
    arguments forwarded (e.g. `$ pipenv run python`).
-   `check` asserts that PEP 508 requirements are being met by the
    current environment.
-   `graph` will print a pretty graph of all your installed
    dependencies.

# [Installation](https://github.com/pypa/pipenv#installation)

In Debian: `apt-get install pipenv`

Or `pip install pipenv`.

# References

* [Git](https://github.com/pypa/pipenv)
