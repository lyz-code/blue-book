---
title: Pydantic factories
date: 20211128
author: Lyz
---

[Pydantic factories](https://github.com/Goldziher/pydantic-factories) is
a library offers powerful mock data generation capabilities for pydantic based
models and dataclasses. It automatically creates [FactoryBoy](factoryboy.md)
factories from a [pydantic](pydantic.md) model.

# Example

```python
from datetime import date, datetime
from typing import List, Union

from pydantic import BaseModel, UUID4

from pydantic_factories import ModelFactory


class Person(BaseModel):
    id: UUID4
    name: str
    hobbies: List[str]
    age: Union[float, int]
    birthday: Union[datetime, date]


class PersonFactory(ModelFactory[Any]):
    __model__ = Person


result = PersonFactory.build()
```

This is possible because of the typing information available on the pydantic
model and model-fields, which are used as a source of truth for data
generation.

The factory parses the information stored in the pydantic model and generates
a dictionary of kwargs that are passed to the `Person` class' init method.

# [Installation](https://github.com/Goldziher/pydantic-factories#installation)

```bash
pip install pydantic-factories
```

# [Basic Usage](https://github.com/Goldziher/pydantic-factories#usage)

## [Build Methods](https://github.com/Goldziher/pydantic-factories#build-methods)

The `ModelFactory` class exposes two build methods:

* `.build(**kwargs)`: builds a single instance of the factory's model.
* `.batch(size: int, **kwargs)`: build a list of size `n` instances.

```python
result = PersonFactory.build()  # a single Person instance

result = PersonFactory.batch(size=5)  # list[Person, Person, Person, Person, Person]
```

Any kwargs you pass to `.build`, `.batch` or any of the persistence methods,
will take precedence over whatever defaults are defined on the factory class
itself.

## [Nested Models and Complex types](https://github.com/Goldziher/pydantic-factories#nested-models-and-complex-types)

The automatic generation of mock data works for all types supported by pydantic,
as well as nested classes that derive from `BaseModel` (including for 3rd party
libraries) and complex types.

## [Defining Factory Attributes](https://github.com/Goldziher/pydantic-factories#defining-factory-attributes)

The factory api is designed to be as semantic and simple as possible, lets look
at several examples that assume we have the following models:

```python
from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel, UUID4
from typing import Any, Dict, List, Union


class Species(str, Enum):
    CAT = "Cat"
    DOG = "Dog"


class Pet(BaseModel):
    name: str
    species: Species


class Person(BaseModel):
    id: UUID4
    name: str
    hobbies: List[str]
    age: Union[float, int]
    birthday: Union[datetime, date]
    pets: List[Pet]
    assets: List[Dict[str, Dict[str, Any]]]
```

One way of defining defaults is to use hardcoded values:

```python
pet = Pet(name="Roxy", sound="woof woof", species=Species.DOG)


class PersonFactory(ModelFactory):
    __model__ = Person

    pets = [pet]
```

In this case when we call `PersonFactory.build()` the result will be randomly
generated, except the pets list, which will be the hardcoded default we
defined.

### [Use field](https://github.com/Goldziher/pydantic-factories#use-field)

This though is often not desirable. We could instead, define a factory for `Pet`
where we restrict the choices to a range we like. For example:

```python
from enum import Enum
from pydantic_factories import ModelFactory, Use
from random import choice

from .models import Pet, Person


class Species(str, Enum):
    CAT = "Cat"
    DOG = "Dog"


class PetFactory(ModelFactory):
    __model__ = Pet

    name = Use(choice, ["Ralph", "Roxy"])
    species = Use(choice, list(Species))


class PersonFactory(ModelFactory):
    __model__ = Person

    pets = Use(PetFactory.batch, size=2)
```

The signature for use is: `cb: Callable, *args, **defaults`, it can receive any
sync callable. In the above example, we used the choice function from the
standard library's random package, and the batch method of `PetFactory`.

You do not need to use the `Use` field, you can place callables (including
classes) as values for a factory's attribute directly, and these will be invoked
at build-time. Thus, you could for example re-write the above `PetFactory` like
so:

```python
class PetFactory(ModelFactory):
    __model__ = Pet

    name = lambda: choice(["Ralph", "Roxy"])
    species = lambda: choice(list(Species))
```

`Use` is merely a semantic abstraction that makes the factory cleaner and simpler to understand.

### [Ignore (field)](https://github.com/Goldziher/pydantic-factories#ignore-field)

`Ignore` is another field exported by this library, and its used - as its name
implies - to designate a given attribute as ignored:

```python
from typing import TypeVar

from odmantic import EmbeddedModel, Model
from pydantic_factories import ModelFactory, Ignore

T = TypeVar("T", Model, EmbeddedModel)


class OdmanticModelFactory(ModelFactory[T]):
    id = Ignore()
```

The above example is basically the extension included in pydantic-factories for
the library ODMantic, which is a pydantic based mongo ODM.

For ODMantic models, the id attribute should not be set by the factory, but
rather handled by the odmantic logic itself. Thus, the id field is marked as
ignored.

When you ignore an attribute using `Ignore`, it will be completely ignored by
the factory - that is, it will not be set as a kwarg passed to pydantic at all.

### [Require (field)](https://github.com/Goldziher/pydantic-factories#require-field)

The `Require` field in turn specifies that a particular attribute is a required
kwarg. That is, if a kwarg with a value for this particular attribute is not
passed when calling `factory.build()`, a `MissingBuildKwargError` will be raised.

What is the use case for this? For example, lets say we have a document called
`Article` which we store in some DB and is represented using a non-pydantic
model. We then need to store in our pydantic object a reference to an id for
this article. This value should not be some mock value, but must rather be an
actual id passed to the factory. Thus, we can define this attribute as required:

```python
from pydantic import BaseModel
from pydantic_factories import ModelFactory, Require
from uuid import UUID


class ArticleProxy(BaseModel):
    article_id: UUID
    ...


class ArticleProxyFactory(ModelFactory):
    __model__ = ArticleProxy

    article_id = Require()
```

If we call `factory.build()` without passing a value for `article_id`, an error
will be raised.

# [Creating your custom
factories](https://starlite-api.github.io/pydantic-factories/usage/7-handling-custom-types/?h=custom)

If your model has an attribute that is not supported by `pydantic-factories` and
it depends on third party libraries, you can create your custom extension
subclassing the `ModelFactory`, and overriding the `get_mock_value` method to
add your logic.


```
from pydantic_factories import ModelFactory

class CustomFactory(ModelFactory[Any]):
    """Tweak the ModelFactory to add our custom mocks."""

    @classmethod
    def get_mock_value(cls, field_type: Any) -> Any:
        """Add our custom mock value."""
        if str(field_type) == "my_super_rare_datetime_field":
            return cls._get_faker().date_time_between()

        return super().get_mock_value(field_type)
```

Where `cls._get_faker()` is a `faker` instance that you can use to build your
returned value.

# Troubleshooting

## Use pydantic-factories with pytest-freezegun

As `pytest-freezegun` overrides the `datetime.datetime` class,
`pydantic-factories` is not able to find the correct generator for the datetime
fields. It's solved by creating a [custom factory](#creating-your-custom-factories)

```python
from typing import Any
from pydantic_factories import ModelFactory


class CustomFactory(ModelFactory[Any]):
    """Tweak the ModelFactory to add our custom mocks."""

    @classmethod
    def get_mock_value(cls, field_type: Any) -> Any:
        """Add our custom mock value."""
        if str(field_type) == "<class 'datetime.datetime'>":
            return cls._get_faker().date_time_between()

        return super().get_mock_value(field_type)
```

# References

* [Git](https://github.com/Goldziher/pydantic-factories)
* [Docs](https://starlite-api.github.io/pydantic-factories/)
