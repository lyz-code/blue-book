---
title: Pydantic exporting models
date: 20201009
author: Lyz
---

As well as accessing model attributes directly via their names (e.g.
`model.foobar`), models can be converted and exported in a number of ways:

# [`model.dict(...)`](https://pydantic-docs.helpmanual.io/usage/exporting_models/#modeldict)

This is the primary way of converting a model to a dictionary. Sub-models will
be recursively converted to dictionaries.

Arguments:

* `include`: Fields to include in the returned dictionary.
* `exclude`: Fields to exclude from the returned dictionary.
* `by_alias`: Whether field aliases should be used as keys in the returned
    dictionary; default `False`.
* `exclude_unset`: Whether fields which were not explicitly set when creating
    the model should be excluded from the returned dictionary; default `False`.
* `exclude_defaults`: Whether fields which are equal to their default values
    (whether set or otherwise) should be excluded from the returned dictionary;
    default `False`.
* `exclude_none`: Whether fields which are equal to `None` should be excluded
    from the returned dictionary; default `False`.

Example:

```python
from pydantic import BaseModel


class BarModel(BaseModel):
    whatever: int


class FooBarModel(BaseModel):
    banana: float
    foo: str
    bar: BarModel


m = FooBarModel(banana=3.14, foo='hello', bar={'whatever': 123})

# returns a dictionary:
print(m.dict())
"""
{
    'banana': 3.14,
    'foo': 'hello',
    'bar': {'whatever': 123},
}
"""
print(m.dict(include={'foo', 'bar'}))
#> {'foo': 'hello', 'bar': {'whatever': 123}}
print(m.dict(exclude={'foo', 'bar'}))
#> {'banana': 3.14}
```

# [`dict(model)` and iteration](https://pydantic-docs.helpmanual.io/usage/exporting_models/#dictmodel-and-iteration)

*pydantic* models can also be converted to dictionaries using `dict(model)`, and
you can also iterate over a model's field using `for field_name, value in
model:`. With this approach the raw field values are returned, so sub-models
will not be converted to dictionaries.

Example:

```python
from pydantic import BaseModel


class BarModel(BaseModel):
    whatever: int


class FooBarModel(BaseModel):
    banana: float
    foo: str
    bar: BarModel


m = FooBarModel(banana=3.14, foo='hello', bar={'whatever': 123})

print(dict(m))
"""
{
    'banana': 3.14,
    'foo': 'hello',
    'bar': BarModel(
        whatever=123,
    ),
}
"""
for name, value in m:
    print(f'{name}: {value}')
    #> banana: 3.14
    #> foo: hello
    #> bar: whatever=123
```

# [`model.copy(...)`](https://pydantic-docs.helpmanual.io/usage/exporting_models/#modelcopy)

`copy()` allows models to be duplicated, which is particularly useful for
immutable models.

Arguments:

* `include`: Fields to include in the returned dictionary.
* `exclude`: Fields to exclude from the returned dictionary.
* `update`: A dictionary of values to change when creating the copied model
* `deep`: whether to make a deep copy of the new model; default `False`

Example:

```python
from pydantic import BaseModel


class BarModel(BaseModel):
    whatever: int


class FooBarModel(BaseModel):
    banana: float
    foo: str
    bar: BarModel


m = FooBarModel(banana=3.14, foo='hello', bar={'whatever': 123})

print(m.copy(include={'foo', 'bar'}))
#> foo='hello' bar=BarModel(whatever=123)
print(m.copy(exclude={'foo', 'bar'}))
#> banana=3.14
print(m.copy(update={'banana': 0}))
#> banana=0 foo='hello' bar=BarModel(whatever=123)
print(id(m.bar), id(m.copy().bar))
#> 139868119420992 139868119420992
# normal copy gives the same object reference for `bar`
print(id(m.bar), id(m.copy(deep=True).bar))
#> 139868119420992 139868119423296
# deep copy gives a new object reference for `bar`
```

# [`model.json(...)`](https://pydantic-docs.helpmanual.io/usage/exporting_models/#modeljson)

The `.json()` method will serialise a model to JSON. Typically, `.json()` in
turn calls `.dict()` and serialises its result. (For models with a custom root
type, after calling `.dict()`, only the value for the `__root__` key is
serialised).

Arguments:

* `include`: Fields to include in the returned dictionary.
* `exclude`: Fields to exclude from the returned dictionary.
* `by_alias`: Whether field aliases should be used as keys in the returned
    dictionary; default `False`.
* `exclude_unset`: Whether fields which were not set when creating the model and
    have their default values should be excluded from the returned dictionary;
    default `False`.
* `exclude_defaults`: Whether fields which are equal to their default values
    (whether set or otherwise) should be excluded from the returned dictionary;
    default `False`.
* `exclude_none`: Whether fields which are equal to `None` should be excluded
    from the returned dictionary; default `False`.
* `encoder`: A custom encoder function passed to the `default` argument of
    `json.dumps()`; defaults to a custom encoder designed to take care of all
    common types.
* `**dumps_kwargs`: Any other keyword arguments are passed to `json.dumps()`,
    e.g. `indent`.

*pydantic* can serialise many commonly used types to JSON (e.g. `datetime`, `date` or `UUID`) which would normally
fail with a simple `json.dumps(foobar)`.

```python
from datetime import datetime
from pydantic import BaseModel


class BarModel(BaseModel):
    whatever: int


class FooBarModel(BaseModel):
    foo: datetime
    bar: BarModel


m = FooBarModel(foo=datetime(2032, 6, 1, 12, 13, 14), bar={'whatever': 123})
print(m.json())
#> {"foo": "2032-06-01T12:13:14", "bar": {"whatever": 123}}
```

# [Advanced include and exclude](https://pydantic-docs.helpmanual.io/usage/exporting_models/#advanced-include-and-exclude)

The `dict`, `json`, and `copy` methods support `include` and `exclude` arguments
which can either be sets or dictionaries. This allows nested selection of which
fields to export:

```python
from pydantic import BaseModel, SecretStr


class User(BaseModel):
    id: int
    username: str
    password: SecretStr


class Transaction(BaseModel):
    id: str
    user: User
    value: int


t = Transaction(
    id='1234567890',
    user=User(
        id=42,
        username='JohnDoe',
        password='hashedpassword'
    ),
    value=9876543210,
)

# using a set:
print(t.dict(exclude={'user', 'value'}))
#> {'id': '1234567890'}

# using a dict:
print(t.dict(exclude={'user': {'username', 'password'}, 'value': ...}))
#> {'id': '1234567890', 'user': {'id': 42}}

print(t.dict(include={'id': ..., 'user': {'id'}}))
#> {'id': '1234567890', 'user': {'id': 42}}
```

The ellipsis (``...``) indicates that we want to exclude or include an entire
key, just as if we included it in a set.  Of course, the same can be done at any
depth level.

Special care must be taken when including or excluding fields from a list or
tuple of submodels or dictionaries.  In this scenario, `dict` and related
methods expect integer keys for element-wise inclusion or exclusion. To exclude
a field from **every** member of a list or tuple, the dictionary key `'__all__'`
can be used as follows:

```python
import datetime
from typing import List

from pydantic import BaseModel, SecretStr


class Country(BaseModel):
    name: str
    phone_code: int


class Address(BaseModel):
    post_code: int
    country: Country


class CardDetails(BaseModel):
    number: SecretStr
    expires: datetime.date


class Hobby(BaseModel):
    name: str
    info: str


class User(BaseModel):
    first_name: str
    second_name: str
    address: Address
    card_details: CardDetails
    hobbies: List[Hobby]


user = User(
    first_name='John',
    second_name='Doe',
    address=Address(
        post_code=123456,
        country=Country(
            name='USA',
            phone_code=1
        )
    ),
    card_details=CardDetails(
        number=4212934504460000,
        expires=datetime.date(2020, 5, 1)
    ),
    hobbies=[
        Hobby(name='Programming', info='Writing code and stuff'),
        Hobby(name='Gaming', info='Hell Yeah!!!'),
    ],
)

exclude_keys = {
    'second_name': ...,
    'address': {'post_code': ..., 'country': {'phone_code'}},
    'card_details': ...,
    # You can exclude fields from specific members of a tuple/list by index:
    'hobbies': {-1: {'info'}},
}

include_keys = {
    'first_name': ...,
    'address': {'country': {'name'}},
    'hobbies': {0: ..., -1: {'name'}},
}

# would be the same as user.dict(exclude=exclude_keys) in this case:
print(user.dict(include=include_keys))
"""
{
    'first_name': 'John',
    'address': {'country': {'name': 'USA'}},
    'hobbies': [
        {
            'name': 'Programming',
            'info': 'Writing code and stuff',
        },
        {'name': 'Gaming'},
    ],
}
"""

# To exclude a field from all members of a nested list or tuple, use "__all__":
print(user.dict(exclude={'hobbies': {'__all__': {'info'}}}))
"""
{
    'first_name': 'John',
    'second_name': 'Doe',
    'address': {
        'post_code': 123456,
        'country': {'name': 'USA', 'phone_code': 1},
    },
    'card_details': {
        'number': SecretStr('**********'),
        'expires': datetime.date(2020, 5, 1),
    },
    'hobbies': [{'name': 'Programming'}, {'name': 'Gaming'}],
}
"""
```

The same holds for the `json` and `copy` methods.

# References

* [Pydantic exporting models](https://pydantic-docs.helpmanual.io/usage/exporting_models)
