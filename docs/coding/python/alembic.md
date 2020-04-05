---
title: Alembic
date: 20200405
author: Lyz
---

[Alembic](http://alembic.readthedocs.org/en/latest/) is a lightweight database
migration tool for SQLAlchemy. It is created by the author of SQLAlchemy and it
has become the de-facto standard tool to perform migrations on SQLAlchemy backed
databases.

# Database Migration in SQLAlchemy

A database migration usually changes the schema of a database, such as adding
a column or a constraint, adding a table or updating a table. It's often
performed using raw SQL wrapped in a transaction so that it can be rolled back
if something went wrong during the migration.

To migrate a SQLAlchemy database, an Alembic migration script is created for the
intended migration, perform the migration, update the model definition and then
start using the database under the migrated schema.

## Alembic repository initialization

It's important that the migration scripts are saved with the rest of the source
code. Following [Miguel Gringberg
suggestion](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-iv-database),
we'll store them in the `{{ program_name }}/migrations` directory.

Execute the following command to initialize the alembic repository.

```bash
alembic init {{ program_name }}/migrations
```

## Database Migration

When changes need to be made in the schema, instead of modifying it directly and
then recreate the database from scratch, we can leverage that actions to
alembic.

```bash
alembic revision --autogenerate -m "{{ commit_comment }}"
```

That command will write a migration script to make the changes. To perform the
migration use:

```bash
alembic upgrade head
```

To check the status, execute:

```bash
alembic current
```


# [Seed database with data](https://stackoverflow.com/questions/19334604/creating-seed-data-in-a-flask-migrate-or-alembic-migration)

!!! note
    This is an alembic script

```python
from datetime import date
from sqlalchemy.sql import table, column
from sqlalchemy import String, Integer, Date
from alembic import op

# Create an ad-hoc table to use for the insert statement.
accounts_table = table('account',
    column('id', Integer),
    column('name', String),
    column('create_date', Date)
)

op.bulk_insert(accounts_table,
    [
        {'id':1, 'name':'John Smith',
                'create_date':date(2010, 10, 5)},
        {'id':2, 'name':'Ed Williams',
                'create_date':date(2007, 5, 27)},
        {'id':3, 'name':'Wendy Jones',
                'create_date':date(2008, 8, 15)},
    ]
)
```

# Links

* [Git](https://github.com/sqlalchemy/alembic)
* [Docs](https://alembic.sqlalchemy.org/en/latest/)

## Articles

* [Migrate SQLAlchemy databases with Alembic](https://www.pythoncentral.io/migrate-sqlalchemy-databases-alembic/)
