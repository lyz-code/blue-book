---
title: Configure SQLAlchemy for projects without flask
date: 20200602
author: Lyz
---

!!! warning ""
    I discourage you to use an ORM to manage the interactions with the
    database. [Check the alternative solutions](orm_builder_query_or_raw_sql.md).

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
* [Set up the testing environment for SQLAlchemy](../sqlalchemy.md#testing-sqlalchemy-code)
