---
title: Python Project template
date: 20200404
author: Lyz
---

It's hard to correctly define the directory structure to make python programs
work as expected. Even more if testing, docs or databases are involved.

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

* Create the tests directories
    ```bash
    mkdir -p tests/unit
    touch tests/__init__.py
    touch tests/unit/__init__.py
    ```

* Create the program module structure
    ```bash
    mkdir {{ program_name }}
    ```

* Create the program `setup.py` file
    ```python
    from setuptools import find_packages
    from setuptools import setup

    __version__ = '0.1.0'

    setup(
        name='{{ program_name }}',
        version=__version__,
        description='{{ program_description }}',
        author='{{ author }}',
        author_email='{{ author_email }}',
        license='GPLv3',
        long_description=open('README.md').read(),
        packages=find_packages(exclude=('tests',)),
        package_data={'{{ program_name }}': [
            'migrations/*',
            'migrations/versions/*',
        ]},
        entry_points={'console_scripts': ['{{ program_name }} = {{ program_name }}:main']},
        install_requires=[
        ]
    )
    ```
    Remember to fill up the `install_requirements` with the dependencies that
    need to be installed at installation time.

* Create the `requirements.txt` file. It should contain the
    `install_requirements` in addition to the testing requirements such as:
    ```
    pytest
    pytest-cov
    ```

## Additional configurations

Once the basic project structure is defined, there are several common
enhancements to be applied:

* [Continuous integration pipelines](python_ci.md)
* [Create the documentation repository](python_docs.md)
* [Configure SQLAlchemy for projects without
    flask](python_sqlalchemy_without_flask.md)
* [Configure SQLAlchemy to use the MariaDB/Mysql
    backend](python_sqlalchemy_mariadb.md)
* [Configure Docker and Docker compose to host the
    application](python_docker.md)
* [Load config from YAML](python_config_yaml.md)
