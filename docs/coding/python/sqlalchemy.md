---
title: SQLAlchemy
date: 20200412
author: Lyz
---

[SQLAlchemy](https://www.sqlalchemy.org/) is the Python SQL toolkit and Object
Relational Mapper that gives application developers the full power and
flexibility of SQL.

# Creating an SQL Schema

First of all it's important to create a diagram with the database structure, it
will help you in the design and it's a great improvement of the project's
documentation. I usually use [ondras
wwwsqldesigner](https://github.com/ondras/wwwsqldesigner) through his
[demo](https://ondras.zarovi.cz/sql/demo/), as it's easy to use and it's
possible to save the data in your repository in an xml file.

I assume you've already [set up your project to support
sqlalchemy](python_project_template.md#set-up-sqlalchemy-for-projects-without-flask)
in your project. If not, do so before moving forward.

## Creating Tables

If you simply want to create a table of association without any parameters, such
as with a many to many relationship association table, use this type of object.

```python
class User(Base):
    """
    Class to define the User model.
    """
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True, doc='User ID')
    name = Column(String, doc='User name')

    def __init__(
        self,
        id,
        name=None,
    ):
        self.id = id
        self.name = name
```

There are [different
types](https://docs.sqlalchemy.org/en/13/core/type_basics.html) of fields to add to a table:

* Boolean: `is_true = Column(Boolean)`.
* Datetime: `created_date = Column(DateTime, doc='Date of creation')`.
* Float: `score = Column(Float)`
* Integer: `id = Column(Integer, primary_key=True, doc='Source ID')`.
* String: `title = Column(String)`.


To make sure that a field can't contain `nulls` set the `nullable=False`
attribute in the definition of the `Column`.

It's important to add the different parameters as attributes if you want to
access them later.

## Creating relationships

### [Joined table inheritance](https://docs.sqlalchemy.org/en/13/orm/inheritance.html#joined-table-inheritance)

In joined table inheritance, each class along a hierarchy of classes is
represented by a distinct table. Querying for a particular subclass in the
hierarchy will render as a `SQL JOIN` along all tables in its inheritance path.
If the queried class is the base class, the default behavior is to include only
the base table in a `SELECT` statement. In all cases, the ultimate class to
instantiate for a given row is determined by a discriminator column or an
expression that works against the base table. When a subclass is loaded only
against a base table, resulting objects by default will have base attributes
populated at first; attributes that are local to the subclass will lazy load
when they are accessed.

The base class in a joined inheritance hierarchy is configured with additional
arguments that will refer to the polymorphic discriminator column as well as the
identifier for the base class.

```python
class Employee(Base):
    __tablename__ = 'employee'
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    type = Column(String(50))

    __mapper_args__ = {
        'polymorphic_identity':'employee',
        'polymorphic_on':type
    }


class Engineer(Employee):
    __tablename__ = 'engineer'
    id = Column(Integer, ForeignKey('employee.id'), primary_key=True)
    engineer_name = Column(String(30))

    __mapper_args__ = {
        'polymorphic_identity':'engineer',
    }


class Manager(Employee):
    __tablename__ = 'manager'
    id = Column(Integer, ForeignKey('employee.id'), primary_key=True)
    manager_name = Column(String(30))

    __mapper_args__ = {
        'polymorphic_identity':'manager',
    }
```

### One to many

```python
from sqlalchemy.orm import relationship


class User(db.Model):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    posts = relationship('Post', back_populates='author')


class Post(db.Model):
    id = Column(Integer, primary_key=True)
    body = Column(String(140))
    user_id = Column(Integer, ForeignKey('user.id'))
    user = relationship('User', back_populates='posts')
```

In the tests of the `Post` class, only check that the `user` attribute is
present.

[Factoryboy](factoryboy.md) supports the creation of [Dependent objects direct
ForeignKey](factoryboy.md#dependent_objects_direct foreignKey).

### [Many to many](https://docs.sqlalchemy.org/en/13/orm/basic_relationships.html#many-to-many)

```python
# Association tables

source_has_category = Table(
    'source_has_category',
    Base.metadata,
    Column('source_id', Integer, ForeignKey('source.id')),
    Column('category_id', Integer, ForeignKey('category.id'))
)

# Tables


class Category(Base):
    __tablename__ = 'category'
    id = Column(String, primary_key=True)
    contents = relationship(
        'Content',
        back_populates='categories',
        secondary=source_has_category,
    )


class Content(Base):
    __tablename__ = 'content'
    id = Column(Integer, primary_key=True, doc='Content ID')
    categories = relationship(
        'Category',
        back_populates='contents',
        secondary=source_has_category,
    )
```

#### Self referenced many to many

Using the `followers` table as an association table.

```python
followers = db.Table(
    'followers',
    Base.metadata,
    Column('follower_id', Integer, ForeignKey('user.id')),
    Column('followed_id', Integer, ForeignKey('user.id')),
)


class User(Base):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    followed = relationship(
        'User',
        secondary=followers,
        primaryjoin=(followers.c.follower_id == id),
        secondaryjoin=(followers.c.followed_id == id),
        backref=db.backref('followers', lazy='dynamic'),
        lazy='dynamic',
    )
```
Links User instances to other User instances, so as a convention let's say that
for a pair of users linked by this relationship, the left side user is following
the right side user. The relationship definition is created as seen from the
left side user with the name followed, because when this relationship is queried
from the left side it will get the list of followed users (i.e those on the
right side).

* `User`: Is the right side entity of the relationship. Since this is
  a self-referential relationship, The same class must be used on both sides.
* `secondary`: configures the association table that is used for this
  relationship.
* `primaryjoin`: Indicates the condition that links the left side entity (the
  follower user) with the association table. The join condition for the left
  side of the relationship is the user id matching the `follower_id` field of
  the association table. The `followers.c.follower_id` expression references the
  `follower_id` column of the association table.
* `secondaryjoin`: Indicates the condition that links the right side entity (the
  followed user) with the association table. This condition is similar to the
  one for `primaryjoin`.
* `backref`: Defines how this relationship will be accessed from the right side
  entity. From the left side, the relationship is named `followed`, so from the
  right side, the name `followers` represent all the left side users that are
  linked to the target user in the right side. The additional `lazy` argument
  indicates the execution mode for this query. A mode of `dynamic` sets up the
  query not to run until specifically requested.
* `lazy`: same as with `backref`, but this one applies to the left side query
  instead of the right side.

# Testing SQLAlchemy Code

The definition of the database can be tested, I usually use them to test that
the attributes are loaded and that the [factory objects](factoryboy.md) work as
expected. Several steps need to be set to make it work:


* Create the [factory boy objects](factoryboy.md) in
`tests/factories.py`.

* Configure the tests to use a temporal sqlite database in the
    `tests/conftest.py` file with the following contents (changing `{{
    program_name }}`):

    ```python
    from alembic.command import upgrade
    from alembic.config import Config
    from sqlalchemy.orm import sessionmaker

    import os
    import pytest
    import tempfile

    temp_ddbb = tempfile.mkstemp()[1]

    os.environ['{{ program_name }} _DATABASE_URL'] = 'sqlite:///{}'.format(temp_ddbb)

    # It needs to be after the environmental variable
    from {{ program_name }}.models import engine
    from tests import factories


    @pytest.fixture(scope='module')
    def connection():
        '''
        Fixture to set up the connection to the temporal database, the path is
        stablished at conftest.py
        '''

        # Create database connection
        connection = engine.connect()

        # Applies all alembic migrations.
        config = Config('{{ program_name }}/migrations/alembic.ini')
        upgrade(config, 'head')

        # End of setUp

        yield connection

        # Start of tearDown
        connection.close()


    @pytest.fixture(scope='function')
    def session(connection):
        '''
        Fixture to set up the sqlalchemy session of the database.
        '''

        # Begin a non-ORM transaction and bind session
        transaction = connection.begin()
        session = sessionmaker()(bind=connection)

        factories.UserFactory._meta.sqlalchemy_session = session

        yield session

        # Close session and rollback transaction
        session.close()
        transaction.rollback()
    ```

* Define an abstract base test class `BaseModelTest` defined as
following in the `tests/unit/test_models.py` file.

```python
from {{ program_name }} import models
from tests import factories

import pytest


class BaseModelTest:
    """
    Abstract base test class to refactor model tests.

    The Children classes must define the following attributes:
        self.model: The model object to test.
        self.dummy_instance: A factory object of the model to test.
        self.model_attributes: List of model attributes to test

    Public attributes:
        dummy_instance (Factory_boy object): Dummy instance of the model.
    """

    @pytest.fixture(autouse=True)
    def base_setup(self, session):
        self.session = session

    def test_attributes_defined(self):
        for attribute in self.model_attributes:
            assert getattr(self.model, attribute) == \
                getattr(self.dummy_instance, attribute)


@pytest.mark.usefixtures('base_setup')
class TestUser(BaseModelTest):

    @pytest.fixture(autouse=True)
    def setup(self, session):
        self.factory = factories.UserFactory
        self.dummy_instance = self.factory.create()
        self.model = models.User(
            id=self.dummy_instance.id,
            name=self.dummy_instance.name,
        )
        self.model_attributes = [
            'name',
            'id',
        ]
```

* Then [create the `models` table](#creating-tables).
* [Create an alembic revision](alembic.md#database-migration)
* Run `pytest`: `python -m pytest`.

# References

* [Home](https://www.sqlalchemy.org/)
* [Docs](https://docs.sqlalchemy.org)
