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

* Create the `requirements.tx` file. It should contain the
    `install_requirements` in addition to the testing requirements such as:
    ```
    pytest
    pytest-cov
    ```

## Set up the Continuous Integration

To set up the Continuous Integration on a Github workflow create the
`.github/workflows/pythonpackage.yml` file with the following contents:

```yaml
name: Python package

on: [push, pull_request]

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
    alembic \
        -c {{ program_name }}/migrations/alembic.ini \
        revision \
        --autogenerate \
        -m "Initial schema"
    ```

* [Set up the testing environment for SQLAlchemy](sqlalchemy.md#testing-sqlalchemy-code)


## Using Mariadb/Mysql with SQLAlchemy

To use mysql you'll need to first install (or add to your requirements) `pymysql`:

```bash
pip install pymysql
```

The url to connect to the database will be:
```python
'mysql+pymysql://{}:{}@{}:{}/{}'.format(
    DB_USER,
    DB_PASS,
    DB_HOST,
    DB_PORT,
    DATABASE
)
```

It's probable that you'll need to [use UTF8 with
multi byte](https://github.com/sqlalchemy/sqlalchemy/issues/4216), otherwise the
addition of some strings into the database will fail. I've tried adding it to
the database url without success. So I've modified the MariaDB endpoint to use
that character and collation set with:

```yaml
services:
  db:
    image: mariadb:latest
    restart: always
    environment:
      - MYSQL_USER=xxxx
      - MYSQL_PASSWORD=xxxx
      - MYSQL_DATABASE=xxxx
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
    ports:
      - 3306:3306
    command:
      - '--character-set-server=utf8mb4'
      - '--collation-server=utf8mb4_unicode_ci'
```

## Using Docker and Docker compose to host the application

Docker is a popular way to distribute applications. Assuming that all required
dependencies are set in the `setup.py`,we're going to create an image with these
properties:

* *Run by an unprivileged user*: Create an unprivileged user with permissions to
    execute our program.
* Robust to vulnerabilities: Don't use Alpine as it's known to react slow to
    new vulnerabilities. Use a base of Debian instead.
* Smallest possible: Use Docker multi build step. Create a `builder` Docker that
    will execute `pip install`, but only copy the required executables to the
    final image.

```Dockerfile
FROM python:3.8-slim-buster as base

FROM base as builder

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY . /app
WORKDIR /app
RUN pip install .

FROM base

COPY --from=builder /opt/venv /opt/venv

RUN useradd -m myapp
WORKDIR /home/myapp

# Copy the required directories for your program to work.
COPY --from=builder /root/.local/share/myapp /home/myapp/.local/share/myapp
COPY --from=builder /app/myapp /home/myapp/myapp
RUN chown -R myapp:myapp /home/myapp/.local

USER myapp
ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["/opt/venv/bin/myapp"]
```

Once the application Docker is built, if we need to use it with MariaDB or with
Redis. The easiest way is to use `docker-compose`.

```yaml
version: '3.8'

services:
  myapp:
    image: myapp:latest
    restart: always
    links:
      - db
    depends_on:
      - db
    environment:
      - AIRSS_DATABASE_URL=mysql+pymysql://myapp:supersecurepassword@db/myapp
  db:
    image: mariadb:latest
    restart: always
    environment:
      - MYSQL_USER=myapp
      - MYSQL_PASSWORD=supersecurepassword
      - MYSQL_DATABASE=myapp
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
    ports:
      - 3306:3306
    command:
      - '--character-set-server=utf8mb4'
      - '--collation-server=utf8mb4_unicode_ci'
    volumes:
      - /data/myapp/mariadb:/var/lib/mysql
```

The `depends_on` flag is [not
enough](https://docs.docker.com/compose/startup-order/) to ensure that the
database is up when our application tries to connect. Therefore we need to use
external programs like [wait-for-it](https://github.com/vishnubob/wait-for-it).
To use it, modify earlier Dockerfile to match these lines:

```Dockerfile
...

FROM base

RUN apt-get update && apt-get install -y \
    wait-for-it \
 && rm -rf /var/lib/apt/lists/*

...

ENTRYPOINT ["/home/myapp/entrypoint.sh"]
```

Where `entrypoint.sh` is something like:

```bash
#!/bin/bash

# Wait for the database to be up
if [[ -n $DATABASE_URL ]];then
    wait-for-it db:3306
fi

# Execute database migrations
/opt/venv/bin/myapp install

# Enter in daemon mode
/opt/venv/bin/myapp daemon
```

Remember to add the execution permissions `chmod +x entrypoint.sh`.
