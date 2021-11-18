---
title: Python Properties
date: 20211118
author: Lyz
---

The `@property` is the pythonic way to use getters and setters in
object-oriented programming. It can be used to make methods look like attributes.

The `property` decorator returns an object that proxies any request to set or
access the attribute value through the methods we have specified.

```python
class Foo:
    @property
    def foo(self):
        return 'bar'
```

We can specify a setter function for the new property

```python
class Foo:
    @property
    def foo(self):
        return self._foo

    @foo.setter
    def foo(self, value):
        self._foo = value
```

We first decorate the `foo` method a as getter. Then we decorate a second method
with exactly the same name by applying the `setter` attribute of the originally
decorated `foo` method. The `property` function returns an object; this object
always comes with its own `setter` attribute, which can then be applied as
a decorator to other functions. Using the same name for the get and set methods
is not required, but it does help group the multiple methods that access one
property together.

We can also specify a deletion function with `@foo.deleter`. We cannot specify
a docstring using `property` decorators, so we need  to rely on the property
copying the docstring from the initial getter method

```python
class Silly:
    @property
    def silly(self):
        "This is a silly property"
        print("You are getting silly")
        return self._silly

    @silly.setter
    def silly(self, value):
        print("You are making silly {}".format(value))
        self._silly = value

    @silly.deleter
    def silly(self):
        print("Whoah, you kicked silly!")
        del self.silly
```

```python
>>> s = Silly()
>>> s.silly = "funny"
You are making silly funny
>>> s.silly
You are getting silly
'funny'
>>> del s.silly
Whoah, you kicked silly!
```

# When to use properties

The most common use of a property is when we have some data on a class that we
later want to add behavior to.

The fact that methods are just callable attributes, and properties are just
customizable attributes can help us make the decision. Methods should typically
represent actions; things that can be done to, or performed by, the object. When
you call a method, even with only one argument, it should *do* something. Method
names a generally verbs.

Once confirming that an attribute is not an action, we need to decide between
standard data attributes and properties. In general, always use a standard
attribute until you need to control access to that property in some way. In
either case, your attribute is usually a noun . The only difference between an
attribute and a property is that we can invoke custom actions automatically when
a property is retrieved, set, or deleted

## Cache expensive data

A common need for custom behavior is caching a value that is difficult to
calculate or expensive to look up.

We can do this with a custom getter on the property. The first time the value is
retrieved, we perform the lookup or calculation. Then we could locally cache the
value as a private attribute on our object, and the next time the value is
requested, we return the stored data.

```python
from urlib.request import urlopen

class Webpage:
    def __init__(self, url):
        self.url = url
        self._content = None

    @property
    def content(self):
        if not self._content:
            print("Retrieving New Page..")
            self._content = urlopen(self.url).read()
        return self._content
```

```python
>>> import time
>>> webpage = Webpage("http://ccphillips.net/")
>>> now = time.time()
>>> content1 = webpage.content
Retrieving new Page...
>>> time.time() - now
22.43316
>>> now = time.time()
>>> content2 = webpage.content
>>> time.time() -now
1.926645
>>> content1 == content2
True
```

## Attributes calculated on the fly

Custom getters are also useful for attributes that need to be calculated on the
fly, based on other object attributes.

```python
clsas AverageList(list):
    @property
    def average(self):
        return sum(self) / len(self)
```
```python
>>> a = AverageList([1,2,3,4])
>>> a.average
2.5
```

Of course we could have made this a method instead, but then we should call it
`calculate_average()`, since methods represent actions. But a property called
`average` is more suitable, both easier to type, and easier to read.

# [Abstract properties](https://stackoverflow.com/questions/5960337/how-to-create-abstract-properties-in-python-abstract-classes)

Sometimes you want to define properties in your abstract classes, to do that, use:

```python
from abc import ABC, abstractmethod

class C(ABC):
    @property
    @abstractmethod
    def my_abstract_property(self):
        ...
```

If you want to use an abstract setter, you'll encounter the mypy `Decorated
property not supported` error, you'll need to add a `# type: ignore` until [this
issue is solved](https://github.com/python/mypy/issues/1362).
