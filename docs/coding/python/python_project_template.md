---
title: Python Project template
date: 20200404
author: Lyz
---

It's hard to correctly define the directory structure to make python programs
work as expected. Even more if testing, documentation or databases are involved.

!!! warning ""
    I've automated the creation of the python project skeleton following most of
    these section guidelines with [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project).

    ```bash
    cruft https://github.com/lyz-code/cookiecutter-python-project
    ```

    If you don't know cruft, take a look [here](cruft.md).

# Basic Python project

* Create virtualenv
    ```bash
    mkdir {{ project_directory }}
    mkvirtualenv --python=python3 -a {{ project_directory }} {{ project_name }}
    ```

* Create git repository
    ```bash
    workon {{ project_name }}
    git init .
    git ignore-io python > .gitignore
    git add .
    git commit -m "Added gitignore"
    git checkout -b 'feat/initial_iteration'
    ```

## Project structure

After using different project structures, I've ended up using the following:

```
.
├─── docs
│   ├── ...
│   └── index.md
├── LICENSE
├── Makefile
├── mkdocs.yml
├── mypy.ini
├── pyproject.toml
├── README.md
├── requirements-dev.in
├── setup.py
├── src
│   └── package_name
│       ├── adapters
│       │   └── __init__.py
│       ├── config.py
│       ├── entrypoints
│       │   └── __init__.py
│       ├── __init__.py
│       ├── model
│       │   └── __init__.py
│       ├── py.typed
│       ├── services.py
│       └── version.py
└── tests
    ├── conftest.py
    ├── e2e
    │   └── __init__.py
    ├── __init__.py
    ├── integration
    │   └── __init__.py
    └── unit
        ├── __init__.py
        └── test_services.py
```

Heavily inspired by [ionel packaging python
library](https://blog.ionelmc.ro/2014/05/25/python-packaging/) post and
[the Architecture Patterns with
Python](https://www.cosmicpython.com/book/preface.html) book by Harry J.W.
Percival and Bob Gregory.

# Project types

Depending on the type of project you want to build there are different layouts:

* [Command-line program](python_cli_template.md).
* [A single Flask web application](python_flask_template.md).
* [Multiple interconnected Flask microservices](python_microservices_template.md).

# Additional configurations

Once the basic project structure is defined, there are several common
enhancements to be applied:

* [Manage dependencies with pip-tools](pip_tools.md)
* [Create the documentation repository](python_docs.md)
* [Continuous integration pipelines](ci.md)
* [Configure SQLAlchemy to use the MariaDB/Mysql
    backend](python_sqlalchemy_mariadb.md)
* [Configure Docker and Docker compose to host the
    application](python_docker.md)
* [Load config from YAML](python_config_yaml.md)
* [Configure a Flask project](python_flask_template.md)

## Code tests

Unit, integration, end-to-end, edge-to-edge tests define the behaviour of the
application.

Trigger hooks:

* Github Actions: To run the tests each time a push or pull request is created in Github, create
    the `.github/workflows/test.yml` file with the following Jinja
    template.

    Make sure to check:

    * The correct Python versions are configured.
    * The steps make sense to your case scenario.

    Variables to substitute:

    * `program_name`: your program name

    ```yaml
    ---
    name: Python package

    on: [push, pull_request]

    jobs:
      build:
        runs-on: ubuntu-latest
        strategy:
          max-parallel: 3
          matrix:
            python-version: [3.6, 3.7, 3.8]

        steps:
        - uses: actions/checkout@v1
        - name: Set up Python ${{ matrix.python-version }}
          uses: actions/setup-python@v1
          with:
            python-version: ${{ matrix.python-version }}
        - name: Install dependencies
          run: |
            python -m pip install --upgrade pip
            pip install -r requirements.txt
        - name: Lint with flake8
          run: |
            pip install flake8
            # stop the build if there are Python syntax errors or undefined names
            flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
            # exit-zero treats all errors as warnings. The GitHub editor is 127 chars wide
            flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
        - name: Test with pytest
          run: |
            pip install pytest pytest-cov
            python -m pytest --cov-report term-missing --cov {{ program_name }} tests
    ```

    If you want to add a badge stating the last build status in your readme, use the
    following template.

    Variables to substitute:

    * `repository_url`: Github repository url, like
        `https://github.com/lyz-code/pydo`.

    ~~~markdown
    [![Actions
    Status]({{ repository_url }}/workflows/Python%20package/badge.svg)]({{ repository_url }}/actions)
    ~~~

# References

* [ionel packaging a python library
    post](https://blog.ionelmc.ro/2014/05/25/python-packaging/) and he's
    [cookiecutter template](https://github.com/ionelmc/cookiecutter-pylibrary)
