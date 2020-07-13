---
title: Python Project template
date: 20200404
author: Lyz
---

It's hard to correctly define the directory structure to make python programs
work as expected. Even more if testing, documentation or databases are involved.

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
# Project types

Depending on the type of project you want to build there are different layouts:

* [Command-line program](python_cli_template.md).
* [A single Flask web application](python_flask_template.md).
* [Multiple interconnected Flask microservices](python_microservices_template.md).

# Additional configurations

Once the basic project structure is defined, there are several common
enhancements to be applied:

* [Continuous integration pipelines](python_ci.md)
* [Create the documentation repository](python_docs.md)
* [Configure SQLAlchemy to use the MariaDB/Mysql
    backend](python_sqlalchemy_mariadb.md)
* [Configure Docker and Docker compose to host the
    application](python_docker.md)
* [Load config from YAML](python_config_yaml.md)
* [Configure a Flask project](python_flask_template.md)

# References

* [ionel packaging a python library post](https://blog.ionelmc.ro/2014/05/25/python-packaging/)
