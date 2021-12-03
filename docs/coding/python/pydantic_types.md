---
title: Pydantic types
date: 20201002
author: Lyz
---

Where possible *pydantic* uses [standard library types](#standard-library-types)
to define fields, thus smoothing the learning curve. For many useful
applications, however, no standard library type exists, so *pydantic* implements
[many commonly used types](#pydantic-types).

If no existing type suits your purpose you can also implement your [own
pydantic-compatible types](#custom-data-types) with custom properties and
validation.

# [Standard Library Types](https://pydantic-docs.helpmanual.io/usage/types/#standard-library-types)

*pydantic* supports many common types from the python standard library. If you need stricter processing see
[Strict Types](#strict-types); if you need to constrain the values allowed (e.g. to require a positive int) see
[Constrained Types](#constrained-types).

`bool`
: see [Booleans](https://pydantic-docs.helpmanual.io/usage/types/#booleans) for
    details on how bools are validated and what values are permitted.

`int`
: *pydantic* uses `int(v)` to coerce types to an `int`;
  see [this](pydantic.md#data-conversion) warning on loss of information during data
  conversion.

`float`
: similarly, `float(v)` is used to coerce values to floats.

`str`
: strings are accepted as-is, `int` `float` and `Decimal` are coerced using
    `str(v)`, `bytes` and `bytearray` are converted using `v.decode()`, enums
    inheriting from `str` are converted using `v.value`, and all other types
    cause an error.

`list`
: allows `list`, `tuple`, `set`, `frozenset`, or generators and casts to
    a list.

`tuple`
: allows `list`, `tuple`, `set`, `frozenset`, or generators and casts to a tuple.

`dict`
: `dict(v)` is used to attempt to convert a dictionary.

`set`
: allows `list`, `tuple`, `set`, `frozenset`, or generators and casts to a set.

`frozenset`
: allows `list`, `tuple`, `set`, `frozenset`, or generators and casts to a frozen set.

`datetime.date`
: see [Datetime Types](#datetime-types) below for more detail on parsing and
    validation.

`datetime.time`
: see [Datetime Types](#datetime-types) below for more detail on parsing and
    validation.

`datetime.datetime`
: see [Datetime Types](#datetime-types) below for more detail on parsing and
    validation.

`datetime.timedelta`
: see [Datetime Types](#datetime-types) below for more detail on parsing and
    validation.

`typing.Any`
: allows any value include `None`, thus an `Any` field is optional.

`typing.TypeVar`
: constrains the values allowed based on `constraints` or `bound`, see
    [TypeVar](#typevar).

`typing.Union`
: see [Unions](#unions) below for more detail on parsing and validation.

`typing.Optional`
: `Optional[x]` is simply short hand for `Union[x, None]`;
  see [Unions](#unions) below for more detail on parsing and validation.

`typing.List`
:

`typing.Tuple`
:

`typing.Dict`
:

`typing.Set`
:

`typing.FrozenSet`
:

`typing.Sequence`
:

`typing.Iterable`
: this is reserved for iterables that shouldn't be consumed. See [Infinite
    Generators](https://pydantic-docs.helpmanual.io/usage/types/#infinite-generators)
    below for more detail on parsing and validation.

`typing.Type`
: see [Type](#type) below for more detail on parsing and validation.

`typing.Callable`
: see [Callable](https://pydantic-docs.helpmanual.io/usage/types/#callable) for
    more detail on parsing and validation.

`typing.Pattern`
: will cause the input value to be passed to `re.compile(v)` to create a regex
pattern.

`ipaddress.IPv4Address`
: simply uses the type itself for validation by passing the value to
    `IPv4Address(v)`.

`ipaddress.IPv4Interface`
: simply uses the type itself for validation by passing the value to
    `IPv4Address(v)`.

`ipaddress.IPv4Network`
: simply uses the type itself for validation by passing the value to
    `IPv4Network(v)`.

`enum.Enum`
: checks that the value is a valid member of the enum;
  see [Enums and Choices](#enums-and-choices) for more details.

`enum.IntEnum`
: checks that the value is a valid member of the integer enum;
  see [Enums and Choices](#enums-and-choices) for more details.

`decimal.Decimal`
: *pydantic* attempts to convert the value to a string, then passes the string
    to `Decimal(v)`.

`pathlib.Path`
: simply uses the type itself for validation by passing the value to `Path(v)`.

## Iterables

### [Define default value for an iterable](https://stackoverflow.com/questions/63793662/how-to-give-a-pydantic-list-field-a-default-value)

If you want to define an empty list, dictionary, set or other iterable as
a model attribute, you can use the `default_factory`.

```python
from typing import Sequence
from pydantic import BaseModel, Field


class Foo(BaseModel):
    defaulted_list_field: Sequence[str] = Field(default_factory=list)
```

It might be tempting to do

```python
class Foo(BaseModel):
    defaulted_list_field: Sequence[str] = [] # Bad!
```

But you'll follow the [mutable default
argument](python_anti_patterns.md#mutable-default-arguments) anti-pattern.


## [Unions](https://pydantic-docs.helpmanual.io/usage/types/#unions)

The `Union` type allows a model attribute to accept different types, e.g.:

```python
from uuid import UUID
from typing import Union
from pydantic import BaseModel


class User(BaseModel):
    id: Union[int, str, UUID]
    name: str


user_01 = User(id=123, name='John Doe')
print(user_01)
#> id=123 name='John Doe'
print(user_01.id)
#> 123
user_02 = User(id='1234', name='John Doe')
print(user_02)
#> id=1234 name='John Doe'
print(user_02.id)
#> 1234
user_03_uuid = UUID('cf57432e-809e-4353-adbd-9d5c0d733868')
user_03 = User(id=user_03_uuid, name='John Doe')
print(user_03)
#> id=275603287559914445491632874575877060712 name='John Doe'
print(user_03.id)
#> 275603287559914445491632874575877060712
print(user_03_uuid.int)
#> 275603287559914445491632874575877060712
```

However, as can be seen above, *pydantic* will attempt to 'match' any of the
types defined under `Union` and will use the first one that matches. In the
above example the `id` of `user_03` was defined as a `uuid.UUID` class (which is
defined under the attribute's `Union` annotation) but as the `uuid.UUID` can be
marshalled into an `int` it chose to match against the `int` type and
disregarded the other types.

As such, it is recommended that, when defining `Union` annotations, the most
specific type is included first and followed by less specific types. In the
above example, the `UUID` class should precede the `int` and `str` classes to
preclude the unexpected representation as such:

```python
from uuid import UUID
from typing import Union
from pydantic import BaseModel


class User(BaseModel):
    id: Union[UUID, int, str]
    name: str


user_03_uuid = UUID('cf57432e-809e-4353-adbd-9d5c0d733868')
user_03 = User(id=user_03_uuid, name='John Doe')
print(user_03)
#> id=UUID('cf57432e-809e-4353-adbd-9d5c0d733868') name='John Doe'
print(user_03.id)
#> cf57432e-809e-4353-adbd-9d5c0d733868
print(user_03_uuid.int)
#> 275603287559914445491632874575877060712
```

## [Enums and Choices](https://pydantic-docs.helpmanual.io/usage/types/#enums-and-choices)

*pydantic* uses python's standard `enum` classes to define choices.

```python
from enum import Enum, IntEnum

from pydantic import BaseModel, ValidationError


class FruitEnum(str, Enum):
    pear = 'pear'
    banana = 'banana'


class ToolEnum(IntEnum):
    spanner = 1
    wrench = 2


class CookingModel(BaseModel):
    fruit: FruitEnum = FruitEnum.pear
    tool: ToolEnum = ToolEnum.spanner


print(CookingModel())
#> fruit=<FruitEnum.pear: 'pear'> tool=<ToolEnum.spanner: 1>
print(CookingModel(tool=2, fruit='banana'))
#> fruit=<FruitEnum.banana: 'banana'> tool=<ToolEnum.wrench: 2>
try:
    CookingModel(fruit='other')
except ValidationError as e:
    print(e)
    """
    1 validation error for CookingModel
    fruit
      value is not a valid enumeration member; permitted: 'pear', 'banana'
    (type=type_error.enum; enum_values=[<FruitEnum.pear: 'pear'>,
    <FruitEnum.banana: 'banana'>])
    """
```

## [Datetime Types](https://pydantic-docs.helpmanual.io/usage/types/#datetime-types)

*Pydantic* supports the following [datetime](https://docs.python.org/library/datetime.html#available-types)
types:

* `datetime` fields can be:

    * `datetime`, existing `datetime` object
    * `int` or `float`, assumed as Unix time, i.e. seconds (if >= `-2e10` or <= `2e10`) or milliseconds (if < `-2e10`or > `2e10`) since 1 January 1970
    * `str`, following formats work:

        * `YYYY-MM-DD[T]HH:MM[:SS[.ffffff]][Z[±]HH[:]MM]]]`
        * `int` or `float` as a string (assumed as Unix time)

* `date` fields can be:

    * `date`, existing `date` object
    * `int` or `float`, see `datetime`
    * `str`, following formats work:

        * `YYYY-MM-DD`
        * `int` or `float`, see `datetime`

* `time` fields can be:

    * `time`, existing `time` object
    * `str`, following formats work:

        * `HH:MM[:SS[.ffffff]]`

* `timedelta` fields can be:

    * `timedelta`, existing `timedelta` object
    * `int` or `float`, assumed as seconds
    * `str`, following formats work:

        * `[-][DD ][HH:MM]SS[.ffffff]`
        * `[±]P[DD]DT[HH]H[MM]M[SS]S` (ISO 8601 format for timedelta)


## [Type](https://pydantic-docs.helpmanual.io/usage/types/#type)

*pydantic* supports the use of `Type[T]` to specify that a field may only accept
classes (not instances) that are subclasses of `T`.

```python
from typing import Type

from pydantic import BaseModel
from pydantic import ValidationError


class Foo:
    pass


class Bar(Foo):
    pass


class Other:
    pass


class SimpleModel(BaseModel):
    just_subclasses: Type[Foo]


SimpleModel(just_subclasses=Foo)
SimpleModel(just_subclasses=Bar)
try:
    SimpleModel(just_subclasses=Other)
except ValidationError as e:
    print(e)
    """
    1 validation error for SimpleModel
    just_subclasses
      subclass of Foo expected (type=type_error.subclass; expected_class=Foo)
    """
```

## [TypeVar](https://pydantic-docs.helpmanual.io/usage/types/#typevar)

`TypeVar` is supported either unconstrained, constrained or with a bound.

```python
from typing import TypeVar
from pydantic import BaseModel

Foobar = TypeVar('Foobar')
BoundFloat = TypeVar('BoundFloat', bound=float)
IntStr = TypeVar('IntStr', int, str)


class Model(BaseModel):
    a: Foobar  # equivalent of ": Any"
    b: BoundFloat  # equivalent of ": float"
    c: IntStr  # equivalent of ": Union[int, str]"


print(Model(a=[1], b=4.2, c='x'))
#> a=[1] b=4.2 c='x'

# a may be None and is therefore optional
print(Model(b=1, c=1))
#> a=None b=1.0 c=1
```

# [Pydantic Types](https://pydantic-docs.helpmanual.io/usage/types/#pydantic-types)

*pydantic* also provides a variety of other useful types:

`FilePath`
: like `Path`, but the path must exist and be a file.

`DirectoryPath`
: like `Path`, but the path must exist and be a directory.

`Color`
: for parsing HTML and CSS colors; see [Color
    Type](https://pydantic-docs.helpmanual.io/usage/types/#color-type).

`Json`
: a special type wrapper which loads JSON before parsing; see [JSON
    Type](https://pydantic-docs.helpmanual.io/usage/types/#json-type).

`AnyUrl`
: any URL; see [URLs](https://pydantic-docs.helpmanual.io/usage/types/#urls).

`AnyHttpUrl`
: an HTTP URL; see
    [URLs](https://pydantic-docs.helpmanual.io/usage/types/#urls).

`HttpUrl`
: a stricter HTTP URL; see
    [URLs](https://pydantic-docs.helpmanual.io/usage/types/#urls).

`PostgresDsn`
: a postgres DSN style URL; see
    [URLs](https://pydantic-docs.helpmanual.io/usage/types/#urls).

`RedisDsn`
: a redis DSN style URL; see
    [URLs](https://pydantic-docs.helpmanual.io/usage/types/#urls).

`SecretStr`
: string where the value is kept partially secret; see
    [Secrets](https://pydantic-docs.helpmanual.io/usage/types/#secret-types).

`IPvAnyAddress`
: allows either an `IPv4Address` or an `IPv6Address`.

`IPvAnyInterface`
: allows either an `IPv4Interface` or an `IPv6Interface`.

`IPvAnyNetwork`
: allows either an `IPv4Network` or an `IPv6Network`.

`NegativeFloat`
: allows a float which is negative; uses standard `float` parsing then checks
    the value is less than 0; see [Constrained
    Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`NegativeInt`
: allows an int which is negative; uses standard `int` parsing then checks
    the value is less than 0; see [Constrained
    Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`PositiveFloat`
: allows a float which is positive; uses standard `float` parsing then checks
    the value is greater than 0; see [Constrained
    Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`PositiveInt`
: allows an int which is positive; uses standard `int` parsing then checks
    the value is greater than 0; see [Constrained
    Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`condecimal`
: type method for constraining Decimals;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`confloat`
: type method for constraining floats;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`conint`
: type method for constraining ints;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`conlist`
: type method for constraining lists;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`conset`
: type method for constraining sets;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

`constr`
: type method for constraining strs;
  see [Constrained
  Types](https://pydantic-docs.helpmanual.io/usage/types/#constrained-types).

# [Custom Data Types](https://pydantic-docs.helpmanual.io/usage/types/#custom-data-types)

You can also define your own custom data types. There are several ways to achieve it.

## [Classes with `__get_validators__`](https://pydantic-docs.helpmanual.io/usage/types/#classes-with-__get_validators__)

You use a custom class with a classmethod `__get_validators__`. It will be called
to get validators to parse and validate the input data.

!!! tip
    These validators have the same semantics as in
    [Validators](pydantic_validators.md), you can declare a parameter `config`,
    `field`, etc.

```python
import re
from pydantic import BaseModel

# https://en.wikipedia.org/wiki/Postcodes_in_the_United_Kingdom#Validation
post_code_regex = re.compile(
    r'(?:'
    r'([A-Z]{1,2}[0-9][A-Z0-9]?|ASCN|STHL|TDCU|BBND|[BFS]IQQ|PCRN|TKCA) ?'
    r'([0-9][A-Z]{2})|'
    r'(BFPO) ?([0-9]{1,4})|'
    r'(KY[0-9]|MSR|VG|AI)[ -]?[0-9]{4}|'
    r'([A-Z]{2}) ?([0-9]{2})|'
    r'(GE) ?(CX)|'
    r'(GIR) ?(0A{2})|'
    r'(SAN) ?(TA1)'
    r')'
)


class PostCode(str):
    """
    Partial UK postcode validation. Note: this is just an example, and is not
    intended for use in production; in particular this does NOT guarantee
    a postcode exists, just that it has a valid format.
    """

    @classmethod
    def __get_validators__(cls):
        # one or more validators may be yielded which will be called in the
        # order to validate the input, each validator will receive as an input
        # the value returned from the previous validator
        yield cls.validate

    @classmethod
    def __modify_schema__(cls, field_schema):
        # __modify_schema__ should mutate the dict it receives in place,
        # the returned value will be ignored
        field_schema.update(
            # simplified regex here for brevity, see the wikipedia link above
            pattern='^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
            # some example postcodes
            examples=['SP11 9DG', 'w1j7bu'],
        )

    @classmethod
    def validate(cls, v):
        if not isinstance(v, str):
            raise TypeError('string required')
        m = post_code_regex.fullmatch(v.upper())
        if not m:
            raise ValueError('invalid postcode format')
        # you could also return a string here which would mean model.post_code
        # would be a string, pydantic won't care but you could end up with some
        # confusion since the value's type won't match the type annotation
        # exactly
        return cls(f'{m.group(1)} {m.group(2)}')

    def __repr__(self):
        return f'PostCode({super().__repr__()})'


class Model(BaseModel):
    post_code: PostCode


model = Model(post_code='sw8 5el')
print(model)
#> post_code=PostCode('SW8 5EL')
print(model.post_code)
#> SW8 5EL
print(Model.schema())
"""
{
    'title': 'Model',
    'type': 'object',
    'properties': {
        'post_code': {
            'title': 'Post Code',
            'pattern': '^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
            'examples': ['SP11 9DG', 'w1j7bu'],
            'type': 'string',
        },
    },
    'required': ['post_code'],
}
"""
```

### Generic Classes as Types

!!! warning
    This is an advanced technique that you might not need in the beginning. In most of
    the cases you will probably be fine with standard *pydantic* models.

You can use
[Generic Classes](https://docs.python.org/3/library/typing.html#typing.Generic) as
field types and perform custom validation based on the "type parameters" (or sub-types)
with `__get_validators__`.

If the Generic class that you are using as a sub-type has a classmethod
`__get_validators__` you don't need to use `arbitrary_types_allowed` for it to work.

Because you can declare validators that receive the current `field`, you can extract
the `sub_fields` (from the generic class type parameters) and validate data with them.

```python
from pydantic import BaseModel, ValidationError
from pydantic.fields import ModelField
from typing import TypeVar, Generic

AgedType = TypeVar('AgedType')
QualityType = TypeVar('QualityType')


# This is not a pydantic model, it's an arbitrary generic class
class TastingModel(Generic[AgedType, QualityType]):
    def __init__(self, name: str, aged: AgedType, quality: QualityType):
        self.name = name
        self.aged = aged
        self.quality = quality

    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    # You don't need to add the "ModelField", but it will help your
    # editor give you completion and catch errors
    def validate(cls, v, field: ModelField):
        if not isinstance(v, cls):
            # The value is not even a TastingModel
            raise TypeError('Invalid value')
        if not field.sub_fields:
            # Generic parameters were not provided so we don't try to validate
            # them and just return the value as is
            return v
        aged_f = field.sub_fields[0]
        quality_f = field.sub_fields[1]
        errors = []
        # Here we don't need the validated value, but we want the errors
        valid_value, error = aged_f.validate(v.aged, {}, loc='aged')
        if error:
            errors.append(error)
        # Here we don't need the validated value, but we want the errors
        valid_value, error = quality_f.validate(v.quality, {}, loc='quality')
        if error:
            errors.append(error)
        if errors:
            raise ValidationError(errors, cls)
        # Validation passed without errors, return the same instance received
        return v


class Model(BaseModel):
    # for wine, "aged" is an int with years, "quality" is a float
    wine: TastingModel[int, float]
    # for cheese, "aged" is a bool, "quality" is a str
    cheese: TastingModel[bool, str]
    # for thing, "aged" is a Any, "quality" is Any
    thing: TastingModel


model = Model(
    # This wine was aged for 20 years and has a quality of 85.6
    wine=TastingModel(name='Cabernet Sauvignon', aged=20, quality=85.6),
    # This cheese is aged (is mature) and has "Good" quality
    cheese=TastingModel(name='Gouda', aged=True, quality='Good'),
    # This Python thing has aged "Not much" and has a quality "Awesome"
    thing=TastingModel(name='Python', aged='Not much', quality='Awesome'),
)
print(model)
"""
wine=<types_generics.TastingModel object at 0x7f3593a4eee0>
cheese=<types_generics.TastingModel object at 0x7f3593a46100>
thing=<types_generics.TastingModel object at 0x7f3593a464c0>
"""
print(model.wine.aged)
#> 20
print(model.wine.quality)
#> 85.6
print(model.cheese.aged)
#> True
print(model.cheese.quality)
#> Good
print(model.thing.aged)
#> Not much
try:
    # If the values of the sub-types are invalid, we get an error
    Model(
        # For wine, aged should be an int with the years, and quality a float
        wine=TastingModel(name='Merlot', aged=True, quality='Kinda good'),
        # For cheese, aged should be a bool, and quality a str
        cheese=TastingModel(name='Gouda', aged='yeah', quality=5),
        # For thing, no type parameters are declared, and we skipped validation
        # in those cases in the Assessment.validate() function
        thing=TastingModel(name='Python', aged='Not much', quality='Awesome'),
    )
except ValidationError as e:
    print(e)
    """
    2 validation errors for Model
    wine -> quality
      value is not a valid float (type=type_error.float)
    cheese -> aged
      value could not be parsed to a boolean (type=type_error.bool)
    """
```

# [Using constrained strings in list attributes](https://stackoverflow.com/questions/66924001/conflict-between-pydantic-constr-and-mypy-checking)

If you try to use:

```python
from pydantic import constr

Regexp = constr(regex="^i-.*")

class Data(pydantic.BaseModel):
    regex: List[Regex]
```

You'll encounter the `Variable "Regexp" is not valid as a type [valid-type]`
mypy error.

There are a few ways to achieve this:

## Using `typing.Annotated` with `pydantic.Field`

Instead of using `constr` to specify the `regex` constraint, you can specify it
as an argument to `Field` and then use it in combination with `typing.Annotated`:

!!! warning "Until this [open
issue](https://github.com/samuelcolvin/pydantic/issues/2551) is not solved, this
won't work."

!!! note "`typing.Annotated` is only available since Python 3.9. For older
Python versions `typing_extensions.Annotated` can be used."

```python
import pydantic
from pydantic import Field
from typing import Annotated

Regex = Annotated[str, Field(regex="^[0-9a-z_]*$")]

class DataNotList(pydantic.BaseModel):
    regex: Regex

data = DataNotList(**{"regex": "abc"})
print(data)
# regex='abc'
print(data.json())
# {"regex": "abc"}
```

Mypy treats `Annotated[str, Field(regex="^[0-9a-z_]*$")]` as a type alias of
`str`. But it also tells pydantic to do validation. This is described in the
[pydantic
docs](https://pydantic-docs.helpmanual.io/usage/schema/#typingannotated-fields).

Unfortunately it does not currently work with the following:

```python
class Data(pydantic.BaseModel):
    regex: List[Regex]
```

## Inheriting from pydantic.ConstrainedStr

Instead of using `constr` to specify the regex constraint (which uses
`pydantic.ConstrainedStr` internally), you can inherit from
`pydantic.ConstrainedStr` directly:

```python
import re
import pydantic
from pydantic import Field
from typing import List

class Regex(pydantic.ConstrainedStr):
    regex = re.compile("^[0-9a-z_]*$")

class Data(pydantic.BaseModel):
    regex: List[Regex]

data = Data(**{"regex": ["abc", "123", "asdf"]})
print(data)
# regex=['abc', '123', 'asdf']
print(data.json())
# {"regex": ["abc", "123", "asdf"]}
```

Mypy accepts this happily and pydantic does correct validation. The type of
`data.regex[i]` is `Regex`, but as `pydantic.ConstrainedStr` itself inherits
from `str`, it can be used as a string in most places.

# References

* [Field types](https://pydantic-docs.helpmanual.io/usage/types)
