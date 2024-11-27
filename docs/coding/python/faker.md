---
title: Faker
date: 20200412
author: Lyz
---

[Faker](https://faker.readthedocs.io/en/master/) is a Python package that
generates fake data for you. Whether you need to bootstrap your database, create
good-looking XML documents, fill-in your persistence to stress test it, or
anonymize data taken from a production service, Faker is for you.

# Install

If you use [factoryboy](factoryboy.md) you'd probably have it. If you don't use

```bash
pip install faker
```

Or add it to the project `requirements.txt`.


# Use

`Faker` includes a `faker` fixture for pytest.

```python
def test_faker(faker):
    assert isinstance(faker.name(), str)
```

By default it's populated with a [seed of
`0`](https://faker.readthedocs.io/en/master/pytest-fixtures.html#seeding-configuration),
to set a random seed add the following to your test configuration.

!!! note "File: conftest.py"

    ```python
    from random import SystemRandom


    @pytest.fixture(scope="session", autouse=True)
    def faker_seed() -> int:
        """Create a random seed for the Faker library."""
        return SystemRandom().randint(0, 999999)
    ```

## Generate fake number

```python
fake.random_number()
```

If you want to specify max and min values use:

```python
faker.pyint(min_value=0, max_value=99)
```

## Generate a fake dictionary

```python
fake.pydict(nb_elements=5, variable_nb_elements=True, *value_types)
```

Where `*value_types` can be `'str', 'list'`


## [Generate a fake date](https://faker.readthedocs.io/en/master/providers/faker.providers.date_time.html)

```python
fake.date_time()
```

## [Generate a random string](https://faker.readthedocs.io/en/master/providers/faker.providers.python.html#faker.providers.python.Provider.pystr)

```python
faker.pystr()
```

## [Create a random string with a defined format](https://faker.readthedocs.io/en/master/providers/faker.providers.python.html#faker.providers.python.Provider.pystr_format)

```python
faker.pystr_format("id-#######{{random_letter}}")
'id-6443059M'
```

## [Create an IP address](https://faker.readthedocs.io/en/master/providers/faker.providers.internet.html#faker.providers.internet.Provider.ipv4)

```python
faker.ipv4()
```

If you want a CIDR, use `network=True`.

## [Create a random choice from an Enum](https://github.com/NazarioJL/faker_enum)

[pydantic](pydantic.md) uses `Enum` objects to define [the choices of
fields](https://pydantic-docs.helpmanual.io/usage/types/#enums-and-choices), so
we need them to create the factories of those objects.

Sadly, there is no official provider for `Enums`, but NazarioJL made a custom
provider.

### Install

```bash
pip install faker-enum
```

### Usage

```python
from enum import Enum

from faker import Faker
from faker_enum import EnumProvider

fake = Faker()
fake.add_provider(EnumProvider)

class Color(Enum):
    RED = 1
    GREEN = 2
    BLUE = 3

fake.enum(Color)
# One of [Color.RED, Color.GREEN, Color.BLUE]
```

If you're using [factoryboy](factoryboy.md), check [this
instructions](factoryboy.md#word-from-enum-choices).

## [Create `Optional` data](https://lyz-code.github.io/faker-optional/)

### [Install](https://lyz-code.github.io/faker-optional/#installing)

```bash
pip install fake-optional
```

### [Usage](https://lyz-code.github.io/faker-optional/#a-simple-example)

```python
from faker import Faker
from faker_optional import OptionalProvider

fake = Faker()
fake.add_provider(OptionalProvider)

fake.optional_int()
# None

fake.optional_int()
# 1234
```

`OptionalProvider` uses existent faker providers to create the data, so you can
use the provider method arguments.

For example, `optional_int` uses the [`python provider
pyint`](https://faker.readthedocs.io/en/master/providers/faker.providers.python.html#faker.providers.python.Provider.pyint),
so you can use the `min_value`, `max_value`, and `step` arguments. Every
`optional_` method accepts the float `ratio` argument between `0` and `1`, with
a default value of `0.5` to define what percent of results should be `None`,
a greater value will mean that less results will be `None`.

Check the [supported
methods](https://lyz-code.github.io/faker-optional/reference/#faker_optional.model.OptionalProvider).


## [Generate your own custom provider](https://semaphoreci.com/community/tutorials/generating-fake-data-for-python-unit-tests-with-faker)

Providers are just classes which define the methods we call on `Faker` objects to
generate fake data.

To define a provider, you need to create a class that inherits from the
`BaseProvider`. That class can then define as many methods as you want.

Once your provider is ready, add it to your `Faker` instance.

```python
import random

from faker import Faker
from faker.providers import BaseProvider

fake = Faker()

# Our custom provider inherits from the BaseProvider
class TravelProvider(BaseProvider):
    def destination(self):
        destinations = ['NY', 'CO', 'CA', 'TX', 'RI']

        # We select a random destination from the list and return it
        return random.choice(destinations)

# Add the TravelProvider to our faker object
fake.add_provider(TravelProvider)

# We can now use the destination method:
print(fake.destination())
```

If you want to give arguments when calling the provider, add them to the
provider method.

# References

* [Git](https://github.com/joke2k/faker)
* [Docs](https://faker.readthedocs.io/en/master/)
* [Faker python
   providers](https://faker.readthedocs.io/en/master/providers/faker.providers.python.html)
