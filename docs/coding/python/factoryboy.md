---
title: FactoryBoy
date: 20200412
author: Lyz
---

[Factoryboy](https://github.com/FactoryBoy/factory_boy) is a fixtures
replacement library to generate fake data for your program. As it's designed to
work well with different ORMs (Django, [SQLAlchemy](sqlalchemy.md), Mongo) it
serves the purpose of building real objects for your tests.

!!! note "If you use pydantic, [`pydantic-factories`](pydantic_factories.md) does all this automatically for you!"

# Install

```bash
pip install factory_boy
```

Or add it to the project `requirements.txt`.

# Define a factory class

Use the following code to generate a factory class for the `User`
[SQLAlchemy](sqlalchemy.md) class.

```python
from {{ program_name }} import models

import factory

# XXX If you add new Factories remember to add the session in conftest.py


class UserFactory(factory.alchemy.SQLAlchemyModelFactory):
    """
    Class to generate a fake user element.
    """
    id = factory.Sequence(lambda n: n)
    name = factory.Faker('name')

    class Meta:
        model = models.User
        sqlalchemy_session_persistence = 'commit'
```

As stated in the comment, and if you are using the [proposed python project
template](python_project_template.md), remember to add new Factories in
`conftest.py`.

# Use the factory class

* Create an instance.

    ```python
    UserFactory.create()
    ```

* Create an instance with a defined attribute.

    ```python
    UserFactory.create(name='John')
    ```

* Create 100 instances of objects with an attribute defined.

    ```python
    UserFactory.create_batch(100, name='John')
    ```

# Define attributes

I like to use the [faker](faker.md) integration of factory boy to generate most
of the attributes.

## Generate numbers

### Sequential numbers

Ideal for IDs

```python
id = factory.Sequence(lambda n: n)
```

### Random number or integer

```python
author_id = factory.Faker('random_number')
```

If you want to [limit the number of
digits](https://faker.readthedocs.io/en/master/providers/baseprovider.html?highlight=random_number#faker.providers.BaseProvider.random_number)
use `factory.Faker('random_number', digits=3)`

### Random float

```python
score = factory.Faker('pyfloat')
```

## Generate strings

### Word

```python
default = factory.Faker('word')
```

### Word from a list

```python
user = factory.Faker('word', ext_word_list=[None, 'value_1', 'value_2'])
```

### Word from Enum choices

First [install the Enum provider](faker.md#create-a-random-choice-from-an-enum)

```python
factory.Faker.add_provider(EnumProvider)

class EntityFactory(factory.Factory):  # type: ignore
    state = factory.Faker("enum", enum_cls=EntityState)
```

### Sentences

```python
description = factory.Faker('sentence')
```

### Names

```python
name = factory.Faker('name')
```

### Urls

```python
url = factory.Faker('url')
```

### Files

```python
file_path = factory.Faker('file_path')
```

## Generate Datetime

```python
factory.Faker('date_time')
```

## Generate bool

```python
factory.Faker('pybool')
```

## Generate your own attributes

### Using custom Faker providers


### Using lazy_attributes

Use `lazy_attribute` decorator.

If you want to [use Faker inside
a lazy_attribute](https://stackoverflow.com/questions/45068596/how-to-use-lazy-attribute-with-faker-in-factory-boy)
use `.generate({})` at the end of the attribute.

!!! warning "In newer versions of Factoryboy you can't use Faker inside a lazy attribute"

    As the Faker object doesn't have the generate method.

```python
    @factory.lazy_attribute
    def due(self):
        if random.random() > 0.5:
            return factory.Faker('date_time').generate({})
```

# Define relationships

## Factory Inheritance

```python
class ContentFactory(factory.alchemy.SQLAlchemyModelFactory):
    id = factory.Sequence(lambda n: n)
    title = factory.Faker('sentence')

    class Meta:
        model = models.Content
        sqlalchemy_session_persistence = 'commit'


class ArticleFactory(ContentFactory):
    body = factory.Faker('sentence')

    class Meta:
        model = models.Article
        sqlalchemy_session_persistence = 'commit'
```

## [Dependent objects direct ForeignKey](https://stackoverflow.com/questions/50341071/simple-sqlalchemy-subfactory-example)

When one attribute is actually a complex field (e.g a ForeignKey to another
Model), use the SubFactory declaration. Assuming the following model definition:

```python
class Author(Base):
    id = Column(String, primary_key=True)
    contents = relationship('Content', back_populates='author')


class Content(Base):
    id = Column(Integer, primary_key=True, doc='Content ID')
    author_id = Column(String, ForeignKey(Author.id))
    author = relationship(Author, back_populates='contents')
```

The related factories would be:

```python
class AuthorFactory(factory.alchemy.SQLAlchemyModelFactory):
    id = factory.Faker('word')

    class Meta:
        model = models.Author
        sqlalchemy_session_persistence = 'commit'


class ContentFactory(factory.alchemy.SQLAlchemyModelFactory):
    id = factory.Sequence(lambda n: n)
    author = factory.SubFactory(AuthorFactory)

    class Meta:
        model = models.Content
        sqlalchemy_session_persistence = 'commit'
```

# Automatically generate a factory from a pydantic model

Sadly [it's not yet
supported](https://github.com/FactoryBoy/factory_boy/issues/869), [it will at
some point though](https://github.com/FactoryBoy/factory_boy/issues/836). If
you're interested in following this path, you can start with [mgaitan
snippet](https://gist.github.com/mgaitan/dcbe08bf44a5af696f2af752624ac11b) for
dataclasses.

# References

* [Docs](https://factoryboy.readthedocs.io/en/latest/)
* [Git](https://github.com/FactoryBoy/factory_boy)
* [Common recipes](https://factoryboy.readthedocs.io/en/latest/recipes.html#dependent-objects-foreignkey)
