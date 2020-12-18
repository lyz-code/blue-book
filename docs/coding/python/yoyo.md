---
title: Yoyo migrations
date: 20201001
author: Lyz
---

[Yoyo](https://ollycope.com/software/yoyo/latest) is a database
schema migration tool. Migrations are written as SQL files or Python scripts
that define a list of migration steps.

# [Installation](https://ollycope.com/software/yoyo/latest/#installation)

```bash
pip install yoyo-migrations
```

# Usage

## [Command line](https://ollycope.com/software/yoyo/latest/#command-line-usage)

Start a new migration:

```bash
yoyo new ./migrations -m "Add column to foo"
```

Apply migrations from directory migrations to a PostgreSQL database:

```bash
yoyo apply --database postgresql://scott:tiger@localhost/db ./migrations
```

Rollback migrations previously applied to a MySQL database:

```bash
yoyo rollback --database mysql://scott:tiger@localhost/database ./migrations
```

Reapply (ie rollback then apply again) migrations to a SQLite database at
location /home/sheila/important.db:

```bash
yoyo reapply --database sqlite:////home/sheila/important.db ./migrations
```

List available migrations:

```bash
yoyo list --database sqlite:////home/sheila/important.db ./migrations
```

By default, yoyo-migrations starts in an interactive mode, prompting you for
each migration file before applying it, making it easy to preview which
migrations to apply and rollback.

## [Connecting to the database](https://ollycope.com/software/yoyo/latest/#connecting-to-a-database)

Database connections are specified using a URL. Examples:

```python
# SQLite: use 4 slashes for an absolute database path on unix like platforms
database = sqlite:////home/user/mydb.sqlite

# SQLite: use 3 slashes for a relative path
database = sqlite:///mydb.sqlite

# SQLite: absolute path on Windows.
database = sqlite:///c:\home\user\mydb.sqlite

# MySQL: Network database connection
database = mysql://scott:tiger@localhost/mydatabase

# MySQL: unix socket connection
database = mysql://scott:tiger@/mydatabase?unix_socket=/tmp/mysql.sock

# MySQL with the MySQLdb driver (instead of pymysql)
database = mysql+mysqldb://scott:tiger@localhost/mydatabase

# MySQL with SSL/TLS enabled
database = mysql+mysqldb://scott:tiger@localhost/mydatabase?ssl=yes&sslca=/path/to/cert

# PostgreSQL: database connection
database = postgresql://scott:tiger@localhost/mydatabase

# PostgreSQL: unix socket connection
database = postgresql://scott:tiger@/mydatabase

# PostgreSQL: changing the schema (via set search_path)
database = postgresql://scott:tiger@/mydatabase?schema=some_schema
```

You can specify your database username and password either as part of the
database connection string on the command line (exposing your database password
in the process list) or in a configuration file where other users may be able to
read it.

The `-p` or `--prompt-password` flag causes yoyo to prompt for a password,
helping prevent your credentials from being leaked.

## [Migration files](https://ollycope.com/software/yoyo/latest/#migration-files)

The migrations directory contains a series of migration scripts. Each migration
script is a Python (.py) or SQL file (.sql).

The name of each file without the extension is used as the migration’s unique identifier.

Migrations scripts are run in dependency then filename order.

Each migration file is run in a single transaction where this is supported by the database.

Yoyo creates tables in your target database to track which migrations have been applied.


### [Migrations as Python scripts](https://ollycope.com/software/yoyo/latest/#migrations-as-python-scripts)

A migration script written in Python has the following structure:

```python
#
# file: migrations/0001_create_foo.py
#
from yoyo import step

__depends__ = {"0000.initial-schema"}

steps = [
  step(
      "CREATE TABLE foo (id INT, bar VARCHAR(20), PRIMARY KEY (id))",
      "DROP TABLE foo",
  ),
  step(
      "ALTER TABLE foo ADD COLUMN baz INT NOT NULL"
  )
]
```

The step function may take up to 3 arguments:

* `apply`: an SQL query (or Python function, see below) to apply the migration
    step.
* `rollback`: (optional) an SQL query (or Python function) to rollback the
    migration step.
* `ignore_errors`: (optional, one of `apply`, `rollback` or `all`) causes yoyo
    to ignore database errors in either the apply stage, rollback stage or
    both.


Migrations may declare dependencies on other migrations via the `__depends__`
attribute:

If you use the `yoyo new` command the `__depends__` attribute will be auto
populated for you.

#### [Migration steps as Python functions](https://ollycope.com/software/yoyo/latest/#migration-steps-as-python-functions)

If SQL is not flexible enough, you may supply a Python function as either or
both of the apply or rollback arguments of step. Each function should take
a database connection as its only argument:

```python
#
# file: migrations/0001_create_foo.py
#
from yoyo import step

def apply_step(conn):
    cursor = conn.cursor()
    cursor.execute(
        # query to perform the migration
    )

def rollback_step(conn):
    cursor = conn.cursor()
    cursor.execute(
        # query to undo the above
    )

steps = [
  step(apply_step, rollback_step)
]
```

#### [Post-apply hook](https://ollycope.com/software/yoyo/latest/#post-apply-hook)

It can be useful to have a script that is run after every successful migration.
For example you could use this to update database permissions or re-create
views.

To do this, create a special migration file called `post-apply.py`.


## [Configuration file](https://ollycope.com/software/yoyo/latest/#configuration-file)

Yoyo looks for a configuration file named `yoyo.ini` in the current working
directory or any ancestor directory.

The configuration file may contain the following options:

```ini
[DEFAULT]

# List of migration source directories. "%(here)s" is expanded to the
# full path of the directory containing this ini file.
sources = %(here)s/migrations %(here)s/lib/module/migrations

# Target database
database = postgresql://scott:tiger@localhost/mydb

# Verbosity level. Goes from 0 (least verbose) to 3 (most verbose)
verbosity = 3

# Disable interactive features
batch_mode = on

# Editor to use when starting new migrations
# "{}" is expanded to the filename of the new migration
editor = /usr/local/bin/vim -f {}

# An arbitrary command to run after a migration has been created
# "{}" is expanded to the filename of the new migration
post_create_command = hg add {}

# A prefix to use for generated migration filenames
prefix = myproject_
```

## [Calling Yoyo from Python code](https://ollycope.com/software/yoyo/latest/#calling-yoyo-from-python-code)

The following example shows how to apply migrations from inside python code:

```python
from yoyo import read_migrations
from yoyo import get_backend

backend = get_backend('postgres://myuser@localhost/mydatabase')
migrations = read_migrations('path/to/migrations')

with backend.lock():

    # Apply any outstanding migrations
    backend.apply_migrations(backend.to_apply(migrations))

    # Rollback all migrations
    backend.rollback_migrations(backend.to_rollback(migrations))
```

# References

* [Docs](https://ollycope.com/software/yoyo/latest/#installation)
* [Source](https://hg.sr.ht/~olly/yoyo)
* [Issue Tracker](https://todo.sr.ht/~olly/yoyo)
* [Mailing list](https://lists.sr.ht/~olly/yoyo)
