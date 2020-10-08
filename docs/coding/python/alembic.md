---
title: Alembic
date: 20200405
author: Lyz
---

[Alembic](http://alembic.readthedocs.org/en/latest/) is a lightweight database
migration tool for SQLAlchemy. It is created by the author of SQLAlchemy and it
has become the de-facto standard tool to perform migrations on SQLAlchemy backed
databases.

!!! warning ""
    I discourage you to use an ORM to manage the interactions with the
    database. [Check the alternative solutions](orm_builder_query_or_raw_sql.md).

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

It will create several files and directories under the selected path, the most
important are:

* `alembic.ini`: It's the file the `alembic` script will look for when invoked.
    Usually it's located at the root of the program. Although there are [several
    options](https://alembic.sqlalchemy.org/en/latest/tutorial.html#editing-the-ini-file)
    to configure here, we'll use the `env.py` file to define how to access the
    database.
* `env.py`: It is a Python script that is run whenever the alembic migration
    tool is invoked. At the very least, it contains instructions to configure
    and generate a SQLAlchemy engine, procure a connection from that engine
    along with a transaction, and then invoke the migration engine, using the
    connection as a source of database connectivity.

    The `env.py` script is part of the generated environment so that the way
    migrations run is entirely customizable. The exact specifics of how to
    connect are here, as well as the specifics of how the migration environment
    are invoked. The script can be modified so that multiple engines can be
    operated upon, custom arguments can be passed into the migration
    environment, application-specific libraries and models can be loaded in and
    made available.

    By default alembic takes the database url by the `sqlalchemy.url` key in the
    `alembic.ini` file. But it's advisable to be able to define the url from
    environmental variables. Therefore we need to modify this file with the
    following changes:

    ```python

    # from sqlalchemy import engine_from_config
    # from sqlalchemy import pool
    from sqlalchemy import create_engine

    import os

    if config.attributes.get("configure_logger", True):
        fileConfig(config.config_file_name)

    def get_url():
        basedir = '~/.local/share/{{ program_name }}'
        return os.environ.get('{{ program_name }}_DATABASE_URL') or \
            'sqlite:///' + os.path.join(os.path.expanduser(basedir), 'main.db')


    def run_migrations_offline():
        """Run migrations in 'offline' mode.

        This configures the context with just a URL
        and not an Engine, though an Engine is acceptable
        here as well.  By skipping the Engine creation
        we don't even need a DBAPI to be available.

        Calls to context.execute() here emit the given string to the
        script output.

        """

        # url = config.get_main_option("sqlalchemy.url")
        url = get_url()

        context.configure(
            url=url,
            target_metadata=target_metadata,
            literal_binds=True,
            dialect_opts={"paramstyle": "named"},
        )

        with context.begin_transaction():
            context.run_migrations()


    def run_migrations_online():
        """Run migrations in 'online' mode.

        In this scenario we need to create an Engine
        and associate a connection with the context.

        """
        # connectable = engine_from_config(
        #     config.get_section(config.config_ini_section),
        #     prefix="sqlalchemy.",
        #     poolclass=pool.NullPool,
        # )

        connectable = create_engine(get_url())


        # Leave the rest of the file as it is
    ```

    It is also necessary to import your models metadata, to do so, modify:

    ```python
    # add your model's MetaData object here
    # for 'autogenerate' support
    # from myapp import mymodel
    # target_metadata = mymodel.Base.metadata
    # target_metadata = None

    import sys

    sys.path = ['', '..'] + sys.path[1:]
    from {{ program_name }} import models
    target_metadata = models.Base.metadata
    ```

    We had to add the parent directory to the `sys.path` because when `env.py` is
    executed, `models` is not in your `PYTHONPATH`, resulting in [an import
    error](https://stackoverflow.com/questions/57468141/alembic-modulenotfounderror-in-env-py).

* `versions/`: Directory that holds the individual version scripts. The files it
    contains don’t use ascending integers, and instead use a partial GUID
    approach. In Alembic, the ordering of version scripts is relative to
    directives within the scripts themselves, and it is theoretically possible
    to “splice” version files in between others, allowing migration sequences
    from different branches to be merged, albeit carefully by hand.

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

To load the migrations from the alembic library inside a python program, the
best way to do it is through `alembic.command` instead of `alembic.config.main`
because it will [redirect all logging output to a file](https://stackoverflow.com/questions/42427487/using-alembic-config-main-redirects-log-output)

```python
from alembic.config import Config
import alembic.command

config = Config('alembic.ini')
config.attributes['configure_logger'] = False

alembic.command.upgrade(config, 'head')
```

!!! note "File: env.py"
    ```python
    if config.attributes.get('configure_logger', True):
        fileConfig(config.config_file_name)
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

# Database downgrade or rollback

If you want to correct a migration first check the `history` to see where do you
want to go (it accepts `--verbose` for more information):

```bash
alembic history
```

Then you can specify the id of the revision you want to downgrade to. To specify
the last one, use `-1`.

```bash
alembic downgrade -1
```

After the downgrade is performed, if you want to remove the last revision, you'd
need to manually remove the revision python file.

# References

* [Git](https://github.com/sqlalchemy/alembic)
* [Docs](https://alembic.sqlalchemy.org/en/latest/)

## Articles

* [Migrate SQLAlchemy databases with Alembic](https://www.pythoncentral.io/migrate-sqlalchemy-databases-alembic/)
