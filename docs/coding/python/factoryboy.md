---
title: FactoryBoy
date: 20200412
author: Lyz
---

[Factoryboy](https://github.com/FactoryBoy/factory_boy) is a fixtures
replacement library to generate fake data for your program. As it's designed to
work well with different ORMs (Django, [SQLAlchemy](sqlalchemy.md), Mongo) it
serves the purpose of building real objects for your tests.

# Install

```bash
pip install factory_boy
```

Or add it to the project `requirements.txt`.

# Define a factory class

Use the following code to generate a factory class for the `User`
[SQLAlchemy](sqlalchemy.md) class.

```python
from {{ program_name }}.models import User

import factory

# XXX If you add new Factories remember to add the session in conftest.py


class UserFactory(factory.alchemy.SQLAlchemyModelFactory):
    """
    Class to generate a fake user element.
    """
    id = factory.Sequence(lambda n: n)
    name = factory.Faker('name')

    class Meta:
        model = User
        sqlalchemy_session_persistence = 'commit'
```

As stated in the comment, and if you are using the [proposed python project
template](python_project_template.md), remember to add new Factories in
`conftest.py`.

# Define attributes

I like to use the [faker](faker.md) integration of factory boy to generate most
of the attributes.

## Generate numbers

### Sequential numbers

Ideal for IDs

```python
id = factory.Sequence(lambda n: n)
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

### Sentences

```python
description = factory.Faker('sentence')
```

### Names

```python
name = factory.Faker('name')
```

## Generate your own attribute

Use `lazy_attribute` decorator.

If you want to [use Faker inside a lazy_attribute](https://stackoverflow.com/questions/45068596/how-to-use-lazy-attribute-with-faker-in-factory-boy) use `.generate({})` at the end
of the attribute.

```python
    @factory.lazy_attribute
    def due(self):
        if random.random() > 0.5:
            return factory.Faker('date_time').generate({})
```

# References

* [Docs](https://factoryboy.readthedocs.io/en/latest/)
* [Git](https://github.com/FactoryBoy/factory_boy)
