---
title: Pydantic
date: 20201002
author: Lyz
---

[Pydantic](https://pydantic-docs.helpmanual.io/) is a data validation and
settings management using python type annotations.

pydantic enforces type hints at runtime, and provides user friendly errors when
data is invalid.

Define how data should be in pure, canonical python; check it with pydantic.

# [Install](https://pydantic-docs.helpmanual.io/install/)

```bash
pip install pydantic
```

If you use [mypy](mypy.md) I highly recommend you to [activate the pydantic
plugin](https://pydantic-docs.helpmanual.io/mypy_plugin/#configuring-the-plugin)
by adding to your `pyproject.toml`:

```toml
[tool.mypy]
plugins = [
  "pydantic.mypy"
]

[tool.pydantic-mypy]
init_forbid_extra = true
init_typed = true
warn_required_dynamic_aliases = true
warn_untyped_fields = true
```

# Advantages and disadvantages

Advantages:

* Perform data validation in an easy and nice way.
* Seamless integration with [FastAPI](https://fastapi.tiangolo.com/) and
    [Typer](https://typer.tiangolo.com/).
* Nice way to export the data and data schema.

Disadvantages:

* You can't define [cyclic
    relationships](https://github.com/samuelcolvin/pydantic/issues/2279),
    therefore there is no way to simulate the *backref* SQLAlchemy function.

# [Models](https://pydantic-docs.helpmanual.io/usage/models/)

The primary means of defining objects in *pydantic* is via models
(models are simply classes which inherit from `BaseModel`).

You can think of models as similar to types in strictly typed languages, or as
the requirements of a single endpoint in an API.

Untrusted data can be passed to a model, and after parsing and validation
*pydantic* guarantees that the fields of the resultant model instance will
conform to the field types defined on the model.

## [Basic model usage](https://pydantic-docs.helpmanual.io/usage/models/#basic-model-usage)

```python
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name = 'Jane Doe'
```

`User` here is a model with two fields `id` which is an integer and is required,
and `name` which is a string and is not required (it has a default value). The
type of `name` is inferred from the default value, and so a type annotation is
not required.

```python
user = User(id='123')
```

`user` here is an instance of `User`. Initialisation of the object will perform
all parsing and validation, if no `ValidationError` is raised, you know the
resulting model instance is valid.

### [Model properties](https://pydantic-docs.helpmanual.io/usage/models/#model-properties)

Models possess the following methods and attributes:

`dict()`
: returns a dictionary of the model's fields and values.

`json()`
: returns a JSON string representation `dict()`.

`copy()`
: returns a deep copy of the model.

`parse_obj()`
: very similar to the `__init__` method of the model, used to import objects
    from a  dict rather than keyword arguments. If the object passed is not
    a dict a `ValidationError` will be raised.

`parse_raw()`
: takes a *str* or *bytes* and parses it as *json*, then passes the result
  to `parse_obj`.

`parse_file()`
: reads a file and passes the contents to `parse_raw`. If `content_type` is omitted,
  it is inferred from the file's extension.

`from_orm()`
: loads data into a model from an arbitrary class.

`schema()`
: returns a dictionary representing the model as JSON Schema.

`schema_json()`
: returns a JSON string representation of `schema()`.

## [Recursive Models](https://pydantic-docs.helpmanual.io/usage/models/#recursive-models)

More complex hierarchical data structures can be defined using models themselves as types in annotations.

```python
from typing import List
from pydantic import BaseModel


class Foo(BaseModel):
    count: int
    size: float = None


class Bar(BaseModel):
    apple = 'x'
    banana = 'y'


class Spam(BaseModel):
    foo: Foo
    bars: List[Bar]


m = Spam(foo={'count': 4}, bars=[{'apple': 'x1'}, {'apple': 'x2'}])
print(m)
#> foo=Foo(count=4, size=None) bars=[Bar(apple='x1', banana='y'),
#> Bar(apple='x2', banana='y')]
print(m.dict())
"""
{
    'foo': {'count': 4, 'size': None},
    'bars': [
        {'apple': 'x1', 'banana': 'y'},
        {'apple': 'x2', 'banana': 'y'},
    ],
}
"""
```

For self-referencing models, use postponed annotations.

### [Definition of two models that reference each other](https://github.com/samuelcolvin/pydantic/issues/1333)

```python
class A(BaseModel):
    b: Optional["B"] = None


class B(BaseModel):
    a: Optional[A] = None

A.update_forward_refs()
```

Although it [doesn't work as
expected!](https://github.com/samuelcolvin/pydantic/issues/2279)

## [Error Handling](https://pydantic-docs.helpmanual.io/usage/models/#error-handling)

*pydantic* will raise `ValidationError` whenever it finds an error in the data it's validating.

!!! note
    Validation code should not raise `ValidationError` itself, but rather raise `ValueError`, `TypeError` or
    `AssertionError` (or subclasses of `ValueError` or `TypeError`) which will be caught and used to populate
    `ValidationError`.

One exception will be raised regardless of the number of errors found, that `ValidationError` will
contain information about all the errors and how they happened.

You can access these errors in a several ways:

`e.errors()`
: method will return list of errors found in the input data.

`e.json()`
: method will return a JSON representation of `errors`.

`str(e)`
: method will return a human readable representation of the errors.

Each error object contains:

`loc`
: the error's location as a list. The first item in the list will be the field
  where the error occurred, and if the field is a sub-model, subsequent items will
  be present to indicate the nested location of the error.

`type`
: a computer-readable identifier of the error type.

`msg`
: a human readable explanation of the error.

`ctx`
: an optional object which contains values required to render the error message.

### Custom Errors

You can also define your own error classes, which can specify a custom error
code, message template, and context:

```python
from pydantic import BaseModel, PydanticValueError, ValidationError, validator


class NotABarError(PydanticValueError):
    code = 'not_a_bar'
    msg_template = 'value is not "bar", got "{wrong_value}"'


class Model(BaseModel):
    foo: str

    @validator('foo')
    def name_must_contain_space(cls, v):
        if v != 'bar':
            raise NotABarError(wrong_value=v)
        return v


try:
    Model(foo='ber')
except ValidationError as e:
    print(e.json())
    """
    [
      {
        "loc": [
          "foo"
        ],
        "msg": "value is not \"bar\", got \"ber\"",
        "type": "value_error.not_a_bar",
        "ctx": {
          "wrong_value": "ber"
        }
      }
    ]
    """
```

## [Dynamic model creation](https://pydantic-docs.helpmanual.io/usage/models/#dynamic-model-creation)

There are some occasions where the shape of a model is not known until runtime.
For this *pydantic* provides the `create_model` method to allow models to be
created on the fly.

```python
from pydantic import BaseModel, create_model

DynamicFoobarModel = create_model('DynamicFoobarModel', foo=(str, ...), bar=123)


class StaticFoobarModel(BaseModel):
    foo: str
    bar: int = 123
```

Here `StaticFoobarModel` and `DynamicFoobarModel` are identical.

!!! warning
    See the note in [Required Optional Fields](#required-optional-fields) for the distinct between an ellipsis as a
    field default and annotation only fields.
    See [samuelcolvin/pydantic#1047](https://github.com/samuelcolvin/pydantic/issues/1047) for more details.

Fields are defined by either a tuple of the form `(<type>, <default value>)` or just a default value. The
special key word arguments `__config__` and `__base__` can be used to customize the new model. This includes
extending a base model with extra fields.

```python
from pydantic import BaseModel, create_model


class FooModel(BaseModel):
    foo: str
    bar: int = 123


BarModel = create_model(
    'BarModel',
    apple='russet',
    banana='yellow',
    __base__=FooModel,
)
print(BarModel)
#> <class 'BarModel'>
print(BarModel.__fields__.keys())
#> dict_keys(['foo', 'bar', 'apple', 'banana'])
```

## [Abstract Base Classes](https://pydantic-docs.helpmanual.io/usage/models/#abstract-base-classes)

Pydantic models can be used alongside Python's
[Abstract Base Classes](https://docs.python.org/3/library/abc.html) (ABCs).

```python
import abc
from pydantic import BaseModel


class FooBarModel(BaseModel, abc.ABC):
    a: str
    b: int

    @abc.abstractmethod
    def my_abstract_method(self):
        pass
```

## [Field Ordering](https://pydantic-docs.helpmanual.io/usage/models/#field-ordering)

Field order is important in models for the following reasons:

* Validation is performed in the order fields are defined; [fields
    validators](pydantic_validators.md)
  can access the values of earlier fields, but not later ones
* Field order is preserved in the model [schema](https://pydantic-docs.helpmanual.io/usage/schema/)
* Field order is preserved in [validation errors](#error-handling)
* Field order is preserved by `.dict()` and `.json()` etc.

As of **v1.0** all fields with annotations (whether annotation-only or with
a default value) will precede all fields without an annotation. Within their
respective groups, fields remain in the order they were defined.

## [Field with dynamic default value](https://pydantic-docs.helpmanual.io/usage/models/#field-with-dynamic-default-value)

When declaring a field with a default value, you may want it to be dynamic (i.e. different for each model).
To do this, you may want to use a `default_factory`.

!!! info "In Beta"
    The `default_factory` argument is in **beta**, it has been added to *pydantic* in **v1.5** on a
    **provisional basis**. It may change significantly in future releases and its signature or behaviour will not
    be concrete until **v2**. Feedback from the community while it's still provisional would be extremely useful;
    either comment on [#866](https://github.com/samuelcolvin/pydantic/issues/866) or create a new issue.

Example of usage:

```python
from datetime import datetime
from uuid import UUID, uuid4
from pydantic import BaseModel, Field


class Model(BaseModel):
    uid: UUID = Field(default_factory=uuid4)
    updated: datetime = Field(default_factory=datetime.utcnow)


m1 = Model()
m2 = Model()
print(f'{m1.uid} != {m2.uid}')
#> 3b187763-a19c-4ed8-9588-387e224e04f1 != 0c58f97b-c8a7-4fe8-8550-e9b2b8026574
print(f'{m1.updated} != {m2.updated}')
#> 2020-07-15 20:01:48.451066 != 2020-07-15 20:01:48.451083
```

!!! warning
    The `default_factory` expects the field type to be set.
    Moreover if you want to validate default values with `validate_all`,
    *pydantic* will need to call the `default_factory`, which could lead to side effects!

## [Field customization](https://pydantic-docs.helpmanual.io/usage/schema/#field-customisation)

Optionally, the `Field` function can be used to provide extra information about
the field and validations. It has the following arguments:

* `default`: (a positional argument) the default value of the field. Since the
    `Field` replaces the field's default, this first argument can be used to set
    the default. Use ellipsis (`...`) to indicate the field is required.
* `default_factory`: a zero-argument callable that will be called when a default
    value is needed for this field. Among other purposes, this can be used to
    set dynamic default values. It is forbidden to set both `default` and
    `default_factory`.
* `alias`: the public name of the field.
* `title`: if omitted, `field_name.title()` is used.
* `description`: if omitted and the annotation is a sub-model, the docstring of
    the sub-model will be used.
* `const`: this argument must be the same as the field's default value if
    present.
* `gt`: for numeric values (`int`, `float`, `Decimal`), adds a validation of "greater
    than" and an annotation of `exclusiveMinimum` to the JSON Schema.
* `ge`: for numeric values, this adds a validation of "greater than or equal"
    and an annotation of minimum to the JSON Schema.
* `lt`: for numeric values, this adds a validation of "less than" and an
    annotation of `exclusiveMaximum` to the JSON Schema.
* `le`: for numeric values, this adds a validation of "less than or equal" and
    an annotation of maximum to the JSON Schema.
* `multiple_of`: for numeric values, this adds a validation of "a multiple of"
    and an annotation of `multipleOf` to the JSON Schema.
* `min_items`: for list values, this adds a corresponding validation and an
    annotation of `minItems` to the JSON Schema.
* `max_items`: for list values, this adds a corresponding validation and an
    annotation of `maxItems` to the JSON Schema.
* `min_length`: for string values, this adds a corresponding validation and an
    annotation of `minLength` to the JSON Schema.
* `max_length`: for string values, this adds a corresponding validation and an
    annotation of `maxLength` to the JSON Schema.
* `allow_mutation`: a boolean which defaults to `True`. When `False`, the field
    raises a `TypeError` if the field is assigned on an instance. The model config
    must set `validate_assignment` to `True` for this check to be performed.
* `regex`: for string values, this adds a Regular Expression validation
    generated from the passed string and an annotation of pattern to the JSON
    Schema.
* `**`: any other keyword arguments (e.g. `examples`) will be added verbatim to
    the field's schema.

!!! note pydantic validates strings using `re.match`, which treats regular
expressions as implicitly anchored at the beginning. On the contrary, JSON
Schema validators treat the pattern keyword as implicitly unanchored, more like
what `re.search` does.

Instead of using `Field`, the `fields` property of the `Config` class can be
used to set all of the arguments above except default.

## [Parsing data into a specified type](https://pydantic-docs.helpmanual.io/usage/models/#parsing-data-into-a-specified-type)

Pydantic includes a standalone utility function `parse_obj_as` that can be used
to apply the parsing logic used to populate pydantic models in a more ad-hoc
way. This function behaves similarly to `BaseModel.parse_obj`, but works with
arbitrary pydantic-compatible types.

This is especially useful when you want to parse results into a type that is not
a direct subclass of `BaseModel`.  For example:

```python
from typing import List

from pydantic import BaseModel, parse_obj_as


class Item(BaseModel):
    id: int
    name: str


# `item_data` could come from an API call, eg., via something like:
# item_data = requests.get('https://my-api.com/items').json()
item_data = [{'id': 1, 'name': 'My Item'}]

items = parse_obj_as(List[Item], item_data)
print(items)
#> [Item(id=1, name='My Item')]
```

This function is capable of parsing data into any of the types pydantic can
handle as fields of a `BaseModel`.

Pydantic also includes a similar standalone function called `parse_file_as`,
which is analogous to `BaseModel.parse_file`.

## [Data Conversion](https://pydantic-docs.helpmanual.io/usage/models/#data-conversion)

*pydantic* may cast input data to force it to conform to model field types, and
in some cases this may result in a loss of information.  For example:

```python
from pydantic import BaseModel


class Model(BaseModel):
    a: int
    b: float
    c: str


print(Model(a=3.1415, b=' 2.72 ', c=123).dict())
#> {'a': 3, 'b': 2.72, 'c': '123'}
```

This is a deliberate decision of *pydantic*, and in general it's the most useful
approach. See [here](https://github.com/samuelcolvin/pydantic/issues/578) for
a longer discussion on the subject.

## [Initialize attributes at object creation](https://stackoverflow.com/questions/60695759/creating-objects-with-id-and-populating-other-fields)

If you want to initialize attributes of the object automatically at object
creation, similar of what you'd do with the `__init__` method of the class, you
need to use
[`root_validators`](https://pydantic-docs.helpmanual.io/usage/validators/#root-validators).

```python
from pydantic import root_validator

class PypikaRepository(BaseModel):
    """Implement the repository pattern using the Pypika query builder."""

    connection: sqlite3.Connection
    cursor: sqlite3.Cursor

    class Config:
        """Configure the pydantic model."""

        arbitrary_types_allowed = True

    @root_validator(pre=True)
    @classmethod
    def set_connection(cls, values: Dict[str, Any]) -> Dict[str, Any]:
        """Set the connection to the database.

        Raises:
            ConnectionError: If there is no database file.
        """
        database_file = values["database_url"].replace("sqlite:///", "")
        if not os.path.isfile(database_file):
            raise ConnectionError(f"There is no database file: {database_file}")
        connection = sqlite3.connect(database_file)
        values["connection"] = connection
        values["cursor"] = connection.cursor()

        return values
```

I had to set the `arbitrary_types_allowed` because the sqlite3 objects are not
between the pydantic object types.


## [Set private attributes](https://pydantic-docs.helpmanual.io/usage/models/#private-model-attributes)

If you want to define some attributes that are not part of the model use
`PrivateAttr`:

```python
from datetime import datetime
from random import randint

from pydantic import BaseModel, PrivateAttr


class TimeAwareModel(BaseModel):
    _processed_at: datetime = PrivateAttr(default_factory=datetime.now)
    _secret_value: str = PrivateAttr()

    def __init__(self, **data: Any) -> None:
        super().__init__(**data)
        # this could also be done with default_factory
        self._secret_value = randint(1, 5)


m = TimeAwareModel()
print(m._processed_at)
#> 2021-03-03 17:30:04.030758
print(m._secret_value)
#> 5
```

### Define fields to exclude from exporting at config level

This won't be necessary once they release the version 1.9 because you can [define
the fields to exclude in the `Config` of the
model](https://github.com/samuelcolvin/pydantic/issues/660) using something
like:

```python
class User(BaseModel):
    id: int
    username: str
    password: str

class Transaction(BaseModel):
    id: str
    user: User
    value: int

    class Config:
        fields = {
            'value': {
                'alias': 'Amount',
                'exclude': ...,
            },
            'user': {
                'exclude': {'username', 'password'}
            },
            'id': {
                'dump_alias': 'external_id'
            }
        }
```

The release it's taking its time because [the developer's gremlin and salaried
work are sucking his time off](https://github.com/samuelcolvin/pydantic/discussions/3228).

## [Update entity attributes with a dictionary](https://pydantic-docs.helpmanual.io/usage/exporting_models/#modelcopy)

To update a model with the data of a dictionary you can create a new object with
the new data using the `update` argument of the `copy` method.

```python
class FooBarModel(BaseModel):
    banana: float
    foo: str

m = FooBarModel(banana=3.14, foo='hello')

m.copy(update={'banana': 0})
```

## Lazy loading attributes

[Currently](https://github.com/samuelcolvin/pydantic/issues/935) there is no
official support for [lazy loading](lazy_loading.md) model attributes.

You can define your own properties but when you export the schema they won't
appear there. [dgasmith has
a workaround](https://github.com/samuelcolvin/pydantic/issues/1035) though.

# Troubleshooting

## [Ignore a field when representing an object](https://stackoverflow.com/questions/68768017/how-to-ignore-field-repr-in-pydantic)

Use `repr=False`. This is useful for properties that don't return a value
quickly, for example if you save an `sh` background process.

```python
class Temp(BaseModel):
    foo: typing.Any
    boo: typing.Any = Field(..., repr=False)
```

## [Copy produces copy that modifies the original](https://github.com/samuelcolvin/pydantic/issues/1383)

When copying a model, changing the value of an attribute on the copy updates the
value of the attribute on the original. This only happens if `deep != True`. To
fix it use: `model.copy(deep=True)`.

## [E0611: No name 'BaseModel' in module 'pydantic'](https://github.com/samuelcolvin/pydantic/issues/1961)

Add to your pyproject.toml the following lines:

```toml
# --------- Pylint -------------
[tool.pylint.'MESSAGES CONTROL']
extension-pkg-whitelist = "pydantic"
```

Or if it fails, add to the line `# pylint: extension-pkg-whitelist`.

# References

* [Docs](https://pydantic-docs.helpmanual.io/)
* [Git](https://github.com/samuelcolvin/pydantic/)
