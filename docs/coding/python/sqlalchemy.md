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

There are different types of fields to add to a table:

* Integer: `id = Column(Integer, primary_key=True, doc='Source ID')`.
* String: `title = Column(String)`.
* Datetime: `created_date = Column(DateTime, doc='Date of creation')`.


To make sure that a field can't contain `nulls` set the `nullable=False`
attribute in the definition of the `Column`.

It's important to add the different parameters as attributes if you want to
access them later.

# Testing SQLAlchemy Code

The definition of the database can be tested, I usually use them to test that
the attributes are loaded and that the [factory objects](factoryboy.md) work as
expected.

So first create the [factory boy objects](factoryboy.md) in
`tests/factories.py`.

Then define an abstract base test class `BaseModelTest` defined as
following in the `tests/unit/test_models.py` file.

```python
from {{ program_name }}.models import User
from tests.factories import \
    UserFactory

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
        self.factory = UserFactory
        self.dummy_instance = UserFactory.create()
        self.model = User(
            id=self.dummy_instance.id,
            name=self.dummy_instance.name,
        )
        self.model_attributes = [
            'name',
            'id',
        ]
```

# References

* [Home](https://www.sqlalchemy.org/)
* [Docs](https://docs.sqlalchemy.org)
