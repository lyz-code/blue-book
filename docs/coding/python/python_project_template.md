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
    mkvirtualenv --python=python3 -a {{ project_directory }} {{ project_name }}
    ```

* Create git repository
    ```bash
    cd {{ project_name }}
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
    echo "__version__ = '0.1.0'" >> {{ program_name }}/__init__.py

* Create the program `setup.py` file
    ```python
    from setuptools import find_packages
    from setuptools import setup

    from {{ program_name }} import __version__


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

## Set up the Continuous Integration

To set up the Continuous Integration on a Github workflow create the
`.github/workflows/pythonpackage.yml` file with the following contents:

```yaml
name: Python package

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      max-parallel: 3
      matrix:
        python-version: [3.6, 3.7]

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
        python -m pytest --cov-report term-missing --cov clinv tests
```

And add the Badge to your readme, something like:

~~~markdown
[![Actions
Status](https://github.com/lyz-code/pydo/workflows/Python%20package/badge.svg)](https://github.com/lyz-code/pydo/actions)
~~~

## Set up the documentation

I use [mkdocs](mkdocs.md) with Github Pages for the documentation.

Follow the steps under [Installation](mkdocs.md#installation).

## [Set up sqlalchemy for projects without flask](alembic.md)

* Install [Alembic](alembic.md):
    ```bash
    pip install alembic
    ```

* It's important that the migration scripts are saved with the rest of the source
    code. Following [Miguel Gringberg
    suggestion](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-iv-database),
    we'll store them in the `{{ program_name }}/migrations` directory.

    Execute the following command to initialize the alembic repository.

    ```bash
    alembic init {{ program_name }}/migrations
    ```

* Create the basic `models.py` file under the project code.
    ```python
    """
    Module to store the models.

    Classes:
        Class_name: Class description.
        ...
    """

    import os

    from sqlalchemy import \
        create_engine, \
        Column, \
        Integer
    from sqlalchemy.ext.declarative import declarative_base

    db_path = os.path.expanduser('{{ path_to_sqlite_file }}')
    engine = create_engine(
        os.environ.get('{{ program_name }}_DATABASE_URL') or 'sqlite:///' + db_path
    )

    Base = declarative_base(bind=engine)

    class User(Base):
        """
        Class to define the User model.
        """
        __tablename__ = 'user'
        id = Column(Integer, primary_key=True, doc='User ID')
    ```
* Create the `migrations/env.py` file as specified in the [alembic
    article](alembic.md).
* Create the first alembic revision.
    ```bash
    alembic revision --autogenerate -m "Initial schema"
    ```
