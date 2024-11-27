---
title: Data classes
date: 20200626
author: Lyz
---

A data class is a regular Python class that has basic data model methods like
`__init__()`, `__repr__()`, and `__eq__()` implemented for you.

Introduced in [Python 3.7](https://realpython.com/python37-new-features/),
they typically containing mainly data, although there aren’t
really any restrictions.

```python
from dataclasses import dataclass

@dataclass
class DataClassCard:
    rank: str
    suit: str
```

They behave similar to named tuples but come with many more features. At the
same time, named tuples have some other features that are not necessarily
desirable, such as:

* By design it's a regular tuple, which can lead to subtle and hard to find
    bugs.
* It's hard to add default values to some fields.
* It's by nature immutable.

That being said, if you need your data structure to behave like a tuple, then
a named tuple is a great alternative.

# Advantages over regular classes

* Simplify the class definition
    ```python
    @dataclass
    class DataClassCard:
        rank: str
        suit: str

    # Versus

    class RegularCard
        def __init__(self, rank, suit):
            self.rank = rank
            self.suit = suit
    ```
* More descriptive object representation through a better default `__repr__()`
    method.

    ```python
    >>> queen_of_hearts = DataClassCard('Q', 'Hearts')
    >>> queen_of_hearts
    DataClassCard(rank='Q', suit='Hearts')

    # Versus

    >>> queen_of_spades = RegularCard('Q', 'Spades')
    >>> queen_of_spades
    <__main__.RegularCard object at 0x7fb6eee35d30>
    ```
* Instance comparison out of the box through a better default `__eq__()` method.

    ```python
    >>> queen_of_hearts == DataClassCard('Q', 'Hearts')
    True

    # Versus

    >>> queen_of_spades == RegularCard('Q', 'Spades')
    False
    ```

# Usage

## Definition

```python
from dataclasses import dataclass

@dataclass
class Position:
    name: str
    lon: float
    lat: float
```

What makes this a data class is the `@dataclass` decorator. Beneath the `class
Position:`, simply list the fields you want in your data class.

The data class decorator support the [following
parameters](https://www.python.org/dev/peps/pep-0557/#id7):

* `init`: Add `.__init__()` method? (Default is True).
* `repr`: Add `.__repr__()` method? (Default is True).
* `eq`: Add `.__eq__()` method? (Default is True).
* `order`: Add ordering methods? (Default is False).
* `unsafe_hash`: Force the addition of a `.__hash__()` method? (Default is
    False).
* `frozen`: If `True`, assigning to fields raise an exception. (Default is
    False).

## Default values

It's easy to add default values to the fields of your data class:

```python
from dataclasses import dataclass

@dataclass
class Position:
    name: str
    lon: float = 0.0
    lat: float = 0.0
```

More complex default values can be defined through the use of functions. For
example, the next snippet builds a French deck:

```python
from dataclasses import dataclass, field
from typing import List

RANKS = '2 3 4 5 6 7 8 9 10 J Q K A'.split()
SUITS = '♣ ♢ ♡ ♠'.split()

def make_french_deck():
    return [PlayingCard(r, s) for s in SUITS for r in RANKS]


@dataclass
class PlayingCard:
    rank: str
    suit: str


@dataclass
class Deck:
    cards: List[PlayingCard] = field(default_factory=make_french_deck)
```

Using ` cards: List[PlayingCard] = make_french_deck()` introduces the
[using mutable default arguments](python_anti_patterns.md#mutable-default-arguments)
anti-pattern. Instead, data classes use the `default_factory` to handle mutable
default values. To use it, you need to use the `field()` specifier which is used
to customize each field of a data class individually. It supports the following
parameters:

* `default`: Default value of the field.
* `default_factory`: Function that returns the initial value of the field.
* `init`: Use field in `.__init__()` method? (Default is `True`).
* `repr`: Use field in `repr` of the object? (Default is `True`).
    For example to hide a parameter from the `repr`, use `lat: float
    = field(default=0.0, repr=False)`.
* `compare`: Include the field in comparisons? (Default is `True`).
* `hash`: Include the field when calculating `hash()`? (Default is to use the
    same as `compare`).
* `metadata`: A mapping with information about the field. It's not used by the
    data classes themselves but is available for you to attach information to
    fields. For example:

    ```python
    from dataclasses import dataclass, field

    @dataclass
    class Position:
        name: str
        lon: float = field(default=0.0, metadata={'unit': 'degrees'})
        lat: float = field(default=0.0, metadata={'unit': 'degrees'})
    ```

    To retrieve the information use the `fields()` function.

    ```python
    >>> from dataclasses import fields
    >>> fields(Position)
    (Field(name='name',type=<class 'str'>,...,metadata={}),
     Field(name='lon',type=<class 'float'>,...,metadata={'unit': 'degrees'}),
     Field(name='lat',type=<class 'float'>,...,metadata={'unit': 'degrees'}))
    >>> lat_unit = fields(Position)[2].metadata['unit']
    >>> lat_unit
    'degrees'
    ```

## Type hints

They support [typing](python_code_styling.md#type-hints) out of the
box. Without a type hint, the field will not be a part of the data class.

While you need to add type hints in some form when using data classes, these
types are not enforced at runtime. This is how typing in python usually works:
[Python is and will always be a dynamically typed
language](https://www.python.org/dev/peps/pep-0484/#non-goals).

## Adding methods

Same as with a normal class.

## Adding complex order comparison logic

```python
from dataclasses import dataclass

@dataclass(order=True)
class PlayingCard:
    rank: str
    suit: str

    def __str__(self):
        return f'{self.suit}{self.rank}'
```

After setting `order=True` in the decorator definition the instances of
`PlayingCard` can be compared.

```python
>>> queen_of_hearts = PlayingCard('Q', '♡')
>>> ace_of_spades = PlayingCard('A', '♠')
>>> ace_of_spades > queen_of_hearts
False
```

Data classes compare objects as if they were tuples of their fields. A Queen is
higher than an Ace because `Q` comes after `A` in the alphabet.

```python
>>> ('A', '♠') > ('Q', '♡')
False
```

To use more complex comparisons, we need to add the field `.sort_index` to
the class. However, this field should be calculated from the other fields
automatically. That's what the special method `.__post_init__()` is for. It
allows for special processing after the regular `.__init__()` method is called.

```python
from dataclasses import dataclass, field

RANKS = '2 3 4 5 6 7 8 9 10 J Q K A'.split()
SUITS = '♣ ♢ ♡ ♠'.split()

@dataclass(order=True)
class PlayingCard:
    sort_index: int = field(init=False, repr=False)
    rank: str
    suit: str

    def __post_init__(self):
        self.sort_index = (RANKS.index(self.rank) * len(SUITS)
                           + SUITS.index(self.suit))

    def __str__(self):
        return f'{self.suit}{self.rank}'
```

Note that `.sort_index` is added as the first field of the class. That way, the
comparison is first done using `.sort_index` and only if there are ties are the
other fields used. Using `field()`, you must also specify that `.sort_index`
should not be included as a parameter in the `.__init__()` method (because it is
calculated from the `.rank` and `.suit` fields). To avoid confusing the user
about this implementation detail, it is probably also a good idea to remove
.sort_index from the `repr` of the class.

## Immutable data classes

To make a data class immutable, set `frozen=True` when you create it.

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Position:
    name: str
    lon: float = 0.0
    lat: float = 0.0
```

In a frozen data class, you can not assign values to the fields after creation:

```python
>>> pos = Position('Oslo', 10.8, 59.9)
>>> pos.name
'Oslo'
>>> pos.name = 'Stockholm'
dataclasses.FrozenInstanceError: cannot assign to field 'name'
```
Be aware though that if your data class contains mutable fields, those might
still change. This is true for all nested data structures in Python:

```python
from dataclasses import dataclass
from typing import List

@dataclass(frozen=True)
class ImmutableCard:
    rank: str
    suit: str

@dataclass(frozen=True)
class ImmutableDeck:
    cards: List[PlayingCard]
```

Even though both `ImmutableCard` and `ImmutableDeck` are immutable, the list
holding cards is not. You can therefore still change the cards in the deck:

```python
>>> queen_of_hearts = ImmutableCard('Q', '♡')
>>> ace_of_spades = ImmutableCard('A', '♠')
>>> deck = ImmutableDeck([queen_of_hearts, ace_of_spades])
>>> deck
ImmutableDeck(cards=[ImmutableCard(rank='Q', suit='♡'), ImmutableCard(rank='A', suit='♠')])
>>> deck.cards[0] = ImmutableCard('7', '♢')
>>> deck
ImmutableDeck(cards=[ImmutableCard(rank='7', suit='♢'), ImmutableCard(rank='A', suit='♠')])
```

To avoid this, make sure all fields of an immutable data class use immutable
types (but remember that types are not enforced at runtime). The `ImmutableDeck`
should be implemented using a tuple instead of a list.

## Inheritance

You can subclass data classes quite freely.

```python
from dataclasses import dataclass

@dataclass
class Position:
    name: str
    lon: float
    lat: float

@dataclass
class Capital(Position):
    country: str
```

```python
>>> Capital('Oslo', 10.8, 59.9, 'Norway')
Capital(name='Oslo', lon=10.8, lat=59.9, country='Norway')
```

!!! warning
    This won't work if the base class have default values unless all the
    subclass parameters also have default values.

!!! warning
    If you redefine a base class field, you need to keep the fields order after
    the subclass new fields:

    ```python
    from dataclasses import dataclass

    @dataclass
    class Position:
        name: str
        lon: float = 0.0
        lat: float = 0.0

    @dataclass
    class Capital(Position):
        country: str = 'Unknown'
        lat: float = 40.0
    ```

# Optimizing Data Classes

[Slots](https://docs.python.org/reference/datamodel.html#slots) can be used to
make classes faster and use less memory.

```python
from dataclasses import dataclass

@dataclass
class SimplePosition:
    name: str
    lon: float
    lat: float

@dataclass
class SlotPosition:
    __slots__ = ['name', 'lon', 'lat']
    name: str
    lon: float
    lat: float
```
Essentially, slots are defined using `.__slots__` to list the variables on
a class. Variables or attributes not present in `.__slots__` may not be defined.
Furthermore, **a slots class may not have default values**.

# References

* [Real Python Data classes article](https://realpython.com/python-data-classes/)
