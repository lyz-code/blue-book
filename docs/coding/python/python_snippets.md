---
title: Python Snippets
date: 20200717
author: Lyz
---

# [Replace all characters of a string with another character](https://stackoverflow.com/questions/48995979/how-to-replace-all-characters-in-a-string-with-one-character/48996018)

```python
mystring = '_'*len(mystring)
```

# [Locate element in list](https://appdividend.com/2019/11/16/how-to-find-element-in-list-in-python/)

```python
a = ['a', 'b']

index = a.index('b')
```

# [Transpose a list of lists](https://stackoverflow.com/questions/6473679/transpose-list-of-lists)

```python
>>> l=[[1,2,3],[4,5,6],[7,8,9]]
>>> [list(i) for i in zip(*l)]
... [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
```

# [Check the type of a list of strings](https://stackoverflow.com/questions/18495098/python-check-if-an-object-is-a-list-of-strings)

```python
def _is_list_of_lists(data: Any) -> bool:
    """Check if data is a list of strings."""
    if data and isinstance(data, list):
        return all(isinstance(elem, list) for elem in data)
    else:
        return False
```

# Install default directories and files for a command line program

I've been trying for a long time to configure `setup.py` to run the required
steps to configure the required directories and files when doing `pip install`
without success.

Finally, I decided that the program itself should create the data once the
`FileNotFoundError` exception is found. That way, you don't penalize the load
time because if the file or directory exists, that code is not run.

# [Check if a dictionary is a subset of another](https://stackoverflow.com/questions/9323749/how-to-check-if-one-dictionary-is-a-subset-of-another-larger-dictionary)

If you have two dictionaries `big = {'a': 1, 'b': 2, 'c':3}` and `small = {'c':
3, 'a': 1}`, and want to check whether `small` is a subset of `big`, use the
next snippet:

```python
>>> small.items() <= big.items()
True
```

As the code is not very common or intuitive, I'd add a comment to explain what
you're doing.

# [When to use `isinstance` and when to use `type`](https://towardsdatascience.com/difference-between-type-and-isinstance-in-python-47fae6fbb068)

`isinstance` takes into account inheritance, while `type` doesn't. So if we have
the next code:

```python
class Shape:
    pass

class Rectangle(Shape):
    def __init__(self, length, width):
        self.length = length
        self.width = width
        self.area = length * width

    def get_area(self):
        return self.length * self.width

class Square(Rectangle):
    def __init__(self,length):
        Rectangle.__init__(self,length,length)
```

And we want to check if an object `a = Square(5)` is of type `Rectangle`, we could not use
`isinstance` because it'll return `True` as it's a subclass of `Rectangle`:

```python
>>> isinstance(a, Rectangle)
True
```

Instead, use a comparison with `type`:

```python
>>> type(a) == Rectangle
False
```
# [Find a static file of a python module](https://stackoverflow.com/questions/39104/finding-a-file-in-a-python-module-distribution)

Useful when you want to initialize a configuration file of a cli program when
it's not present.

Imagine you have a `setup.py` with the next contents:

```python
setup(
    name="pynbox",
    packages=find_packages("src"),
    package_dir={"": "src"},
    package_data={"pynbox": ["py.typed", "assets/config.yaml"]},
```

Then you could import the data with:

```python
import pkg_resources

file_path = pkg_resources.resource_filename("pynbox", "assets/config.yaml"),
```

# [Delete a file](https://www.w3schools.com/python/python_file_remove.asp)

```python
import os
os.remove('demofile.txt')
```

# [Measure elapsed time between lines of code](https://stackoverflow.com/questions/7370801/how-to-measure-elapsed-time-in-python)

```python
import time

start = time.time()
print("hello")
end = time.time()
print(end - start)
```

# [Create combination of elements in groups of two](https://stackoverflow.com/questions/20762574/combinations-with-two-elements)

Using the combinations function in Python's itertools module:

```python
>>> list(itertools.combinations('ABC', 2))
[('A', 'B'), ('A', 'C'), ('B', 'C')]
```

If you want the permutations use `itertools.permutations`.

# [Convert html to readable plaintext](https://stackoverflow.com/questions/13337528/rendered-html-to-plain-text-using-python)

```bash
pip install html2text
```

```python
import html2text
html = open("foobar.html").read()
print(html2text.html2text(html))
```

# [Parse a datetime from a string](https://stackoverflow.com/questions/466345/converting-string-into-datetime)

```python
from dateutil import parser
parser.parse("Aug 28 1999 12:00AM")  # datetime.datetime(1999, 8, 28, 0, 0)
```

# Install a python dependency from a git repository

With [pip you
can](https://stackoverflow.com/questions/16584552/how-to-state-in-requirements-txt-a-direct-github-source):

```bash
pip install git+git://github.com/path/to/repository@master
```

If you want [to hard code it in your `setup.py`](https://stackoverflow.com/questions/32688688/how-to-write-setup-py-to-include-a-git-repository-as-a-dependency/54794506#54794506), you need to:

```python
install_requires = [
  'some-pkg @ git+ssh://git@github.com/someorgname/pkg-repo-name@v1.1#egg=some-pkg',
]
```

But [Pypi won't allow you to upload the
package](https://github.com/BaderLab/saber/issues/35), as it will give you
an error:

```
HTTPError: 400 Bad Request from https://test.pypi.org/legacy/
Invalid value for requires_dist. Error: Can't have direct dependency: 'deepdiff @ git+git://github.com/lyz-code/deepdiff@master'
```

It looks like this is a conscious decision on the PyPI side. Basically, they
don't want pip to reach out to URLs outside their site when installing from PyPI.

An ugly patch is to install the dependencies in a `PostInstall` custom script in
the `setup.py` of your program:

```python
from setuptools.command.install import install
from subprocess import getoutput

# ignore: cannot subclass install, has type Any. And what would you do?
class PostInstall(install):  # type: ignore
    """Install direct dependency.

    Pypi doesn't allow uploading packages with direct dependencies, so we need to
    install them manually.
    """

    def run(self) -> None:
        """Install dependencies."""
        install.run(self)
        print(getoutput("pip install git+git://github.com/lyz-code/deepdiff@master"))

setup(
    cmdclass={'install': PostInstall}
)
```

!!! warning "It may not work!"
    Last time I used this solution, when I added the library on a `setup.py` the
    direct dependencies weren't installed :S

# Check directories and files

```python
def test_dir(directory):
    from os.path import exists
    from os import makedirs
    if not exists(directory):
        makedirs(directory)


def test_file(filepath, mode):
    ''' Check if a file exist and is accessible. '''

    def check_mode(os_mode, mode):
        if os.path.isfile(filepath) and os.access(filepath, os_mode):
            return
        else:
            raise IOError("Can't access the file with mode " + mode)

    if mode is 'r':
        check_mode(os.R_OK, mode)
    elif mode is 'w':
        check_mode(os.W_OK, mode)
    elif mode is 'a':
        check_mode(os.R_OK, mode)
        check_mode(os.W_OK, mode)
```

# [Remove the extension of a file](https://stackoverflow.com/questions/678236/how-to-get-the-filename-without-the-extension-from-a-path-in-python)

```python
os.path.splitext("/path/to/some/file.txt")[0]
```

# [Iterate over the files of a directory](https://www.newbedev.com/python/howto/how-to-iterate-over-files-in-a-given-directory/#2-using-os-scandir)

```python
import os

directory = '/path/to/directory'
for entry in os.scandir(directory):
    if (entry.path.endswith(".jpg")
            or entry.path.endswith(".png")) and entry.is_file():
        print(entry.path)
```

### Create directory

```python
if not os.path.exists(directory):
    os.makedirs(directory)
```

### [Touch a file](https://stackoverflow.com/questions/1158076/implement-touch-using-python)

```python
from pathlib import Path

Path('path/to/file.txt').touch()
```



# [Get the first day of next month](https://stackoverflow.com/questions/4130922/how-to-increment-datetime-by-custom-months-in-python-without-using-library)

```python
current = datetime.datetime(mydate.year, mydate.month, 1)
next_month = datetime.datetime(mydate.year + int(mydate.month / 12), ((mydate.month % 12) + 1), 1)
```

# [Get the week number of a datetime](https://stackoverflow.com/questions/2600775/how-to-get-week-number-in-python)

`datetime.datetime` has a `isocalendar()` method, which returns a tuple
containing the calendar week:

```python
>>> import datetime
>>> datetime.datetime(2010, 6, 16).isocalendar()[1]
24
```

`datetime.date.isocalendar()` is an instance-method returning a tuple containing
year, weeknumber and weekday in respective order for the given date instance.

# [Get the monday of a week number](https://stackoverflow.com/questions/17087314/get-date-from-week-number)

A week number is not enough to generate a date; you need a day of the week as well. Add a default:

```python
import datetime
d = "2013-W26"
r = datetime.datetime.strptime(d + '-1', "%Y-W%W-%w")
```

The `-1` and `-%w` pattern tells the parser to pick the Monday in that week.

# [Get the month name from a number](https://stackoverflow.com/questions/6557553/get-month-name-from-number)

```python
import calendar

>> calendar.month_name[3]
'March'
```

# [Get ordinal from number](https://stackoverflow.com/questions/9647202/ordinal-numbers-replacement)

```python
def int_to_ordinal(number: int) -> str:
    '''Convert an integer into its ordinal representation.

    make_ordinal(0)   => '0th'
    make_ordinal(3)   => '3rd'
    make_ordinal(122) => '122nd'
    make_ordinal(213) => '213th'

    Args:
        number: Number to convert

    Returns:
        ordinal representation of the number
    '''
    suffix = ['th', 'st', 'nd', 'rd', 'th'][min(number % 10, 4)]
    if 11 <= (number % 100) <= 13:
        suffix = 'th'
    return f"{number}{suffix}"
```

# [Group or sort a list of dictionaries or objects by a specific key](https://docs.python.org/3/howto/sorting.html)

Python lists have a built-in `list.sort()` method that modifies the list
in-place. There is also a `sorted()` built-in function that builds a new sorted
list from an iterable.

## [Sorting basics](https://docs.python.org/3/howto/sorting.html#sorting-basics)

A simple ascending sort is very easy: just call the `sorted()` function. It
returns a new sorted list:

```python
>>> sorted([5, 2, 3, 1, 4])
[1, 2, 3, 4, 5]
```

## [Key functions](https://docs.python.org/3/howto/sorting.html#key-functions)

Both `list.sort()` and `sorted()` have a `key` parameter to specify a function
(or other callable) to be called on each list element prior to making
comparisons.

For example, here’s a case-insensitive string comparison:

```python
>>> sorted("This is a test string from Andrew".split(), key=str.lower)
['a', 'Andrew', 'from', 'is', 'string', 'test', 'This']
```

The value of the `key` parameter should be a function (or other callable) that
takes a single argument and returns a key to use for sorting purposes. This
technique is fast because the key function is called exactly once for each input
record.

A common pattern is to sort complex objects using some of the object’s indices
as keys. For example:

```python
>>> from operator import itemgetter
>>> student_tuples = [
    ('john', 'A', 15),
    ('jane', 'B', 12),
    ('dave', 'B', 10),
]

>>> sorted(student_tuples, key=itemgetter(2))   # sort by age
[('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]
```


The same technique works for objects with named attributes. For example:

```python
>>> from operator import attrgetter
>>> class Student:
    def __init__(self, name, grade, age):
        self.name = name
        self.grade = grade
        self.age = age

    def __repr__(self):
        return repr((self.name, self.grade, self.age))

>>> student_objects = [
    Student('john', 'A', 15),
    Student('jane', 'B', 12),
    Student('dave', 'B', 10),
]

>>> sorted(student_objects, key=attrgetter('age'))   # sort by age
[('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]
```

The operator module functions allow multiple levels of sorting. For example, to
sort by grade then by age:

```python
>>> sorted(student_tuples, key=itemgetter(1,2))
[('john', 'A', 15), ('dave', 'B', 10), ('jane', 'B', 12)]

>>> sorted(student_objects, key=attrgetter('grade', 'age'))
[('john', 'A', 15), ('dave', 'B', 10), ('jane', 'B', 12)]
```

## [Sorts stability and complex sorts](https://docs.python.org/3/howto/sorting.html#sort-stability-and-complex-sorts)

Sorts are guaranteed to be stable. That means that when multiple records have
the same key, their original order is preserved.

```python
>>> data = [('red', 1), ('blue', 1), ('red', 2), ('blue', 2)]

>>> sorted(data, key=itemgetter(0))
[('blue', 1), ('blue', 2), ('red', 1), ('red', 2)]
```

Notice how the two records for blue retain their original order so that
`('blue', 1)` is guaranteed to precede `('blue', 2)`.

This wonderful property lets you build complex sorts in a series of sorting
steps. For example, to sort the student data by descending grade and then
ascending age, do the age sort first and then sort again using grade:

```python
>>> s = sorted(student_objects, key=attrgetter('age'))     # sort on secondary key

>>> sorted(s, key=attrgetter('grade'), reverse=True)       # now sort on primary key, descending
[('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]
```

This can be abstracted out into a wrapper function that can take a list and
tuples of field and order to sort them on multiple passes.

```python
>>> def multisort(xs, specs):
    for key, reverse in reversed(specs):
        xs.sort(key=attrgetter(key), reverse=reverse)
    return xs

>>> multisort(list(student_objects), (('grade', True), ('age', False)))
[('dave', 'B', 10), ('jane', 'B', 12), ('john', 'A', 15)]
```

# [Iterate over an instance object's data attributes in Python](https://www.saltycrane.com/blog/2008/09/how-iterate-over-instance-objects-data-attributes-python/)

```python
@dataclass(frozen=True)
class Search:
    center: str
    distance: str

se = Search('a', 'b')
for key, value in se.__dict__.items():
   print(key, value)
```

# [Generate ssh key](https://stackoverflow.com/questions/2466401/how-to-generate-ssh-key-pairs-with-python)

```bash
pip install cryptography
```

```python
from os import chmod
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend as crypto_default_backend

private_key = rsa.generate_private_key(
    backend=crypto_default_backend(),
    public_exponent=65537,
    key_size=4096
)
pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.TraditionalOpenSSL,
    encryption_algorithm=serialization.NoEncryption()
)

with open("/tmp/private.key", 'wb') as content_file:
    chmod("/tmp/private.key", 0600)
    content_file.write(pem)

public_key = (
    private_key.public_key().public_bytes(
        encoding=serialization.Encoding.OpenSSH,
        format=serialization.PublicFormat.OpenSSH,
    )
    + b' user@email.org'
)
with open("/tmp/public.key", 'wb') as content_file:
    content_file.write(public_key)
```

# Make multiline code look clean

If you need variables that contain multiline strings inside functions or methods
you need to remove the indentation

```python
def test():
    # end first line with \ to avoid the empty line!
    s = '''\
hello
  world
'''
```

Which is inconvenient as it breaks some editor source code folding and it's ugly
for the eye.

The solution is to use [`textwrap.dedent()`](https://docs.python.org/3/library/textwrap.html)

```python
import textwrap

def test():
    # end first line with \ to avoid the empty line!
    s = '''\
    hello
      world
    '''
    print(repr(s))          # prints '    hello\n      world\n    '
    print(repr(textwrap.dedent(s)))  # prints 'hello\n  world\n'

```

If you forget to add the trailing `\` character of `s = '''\` or use `s
= '''hello`, you're going to have a bad time with [black](black.md).

# [Play a sound](https://linuxhint.com/play_sound_python/)

```bash
pip install playsound
```

```python
from playsound import playsound
playsound('path/to/file.wav')
```

# [Deep copy a dictionary](https://stackoverflow.com/questions/5105517/deep-copy-of-a-dict-in-python)

```python
import copy
d = { ... }
d2 = copy.deepcopy(d)
```

# [Find the root directory of a package](https://github.com/chendaniely/pyprojroot)

`pyprojroot` finds the root working directory for your project as a `pathlib`
object. You can now use the here function to pass in a relative path from the
project root directory (no matter what working directory you are in the
project), and you will get a full path to the specified file.

## Installation

```bash
pip install pyprojroot
```

## Usage

```python
from pyprojroot import here

here()
```

# [Check if an object has an attribute](https://stackoverflow.com/questions/610883/how-to-know-if-an-object-has-an-attribute-in-python)

```python
if hasattr(a, 'property'):
    a.property
```

# [Check if a loop ends completely](https://stackoverflow.com/questions/38381850/how-to-check-whether-for-loop-ends-completely-in-python/38381893)

`for` loops can take an `else` block which is not run if the loop has ended with
a `break` statement.

```python
for i in [1,2,3]:
    print(i)
    if i==3:
        break
else:
    print("for loop was not broken")
```

## [Merge two lists](https://stackoverflow.com/questions/1720421/how-do-i-concatenate-two-lists-in-python)

```python
z = x + y
```

## [Merge two dictionaries](https://stackoverflow.com/questions/38987/how-to-merge-two-dictionaries-in-a-single-expression)

```python
z = {**x, **y}
```

## [Create user defined exceptions](https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions)

Programs may name their own exceptions by creating a new exception class.
Exceptions should typically be derived from the `Exception` class, either directly
or indirectly.

Exception classes are meant to be kept simple, only offering a number of
attributes that allow information about the error to be extracted by handlers
for the exception. When creating a module that can raise several distinct
errors, a common practice is to create a base class for exceptions defined by
that module, and subclass that to create specific exception classes for
different error conditions:

```python
class Error(Exception):
    """Base class for exceptions in this module."""


class ConceptNotFoundError(Error):
    """Transactions with unmatched concept."""

    def __init__(self, message: str, transactions: List[Transaction]) -> None:
        """Initialize the exception."""
        self.message = message
        self.transactions = transactions
        super().__init__(self.message)
```

Most exceptions are defined with names that end in “Error”, similar to the
naming of the standard exceptions.

## [Import a module or it's objects from within a python program](https://docs.python.org/3/library/importlib.html)

```python
import importlib

module = importlib.import_module('os')
module_class = module.getcwd

relative_module = importlib.import_module('.model', package='mypackage')
class_to_extract = 'MyModel'
extracted_class = geattr(relative_module, class_to_extract)
```

The first argument specifies what module to import in absolute or relative terms
(e.g. either `pkg.mod` or `..mod`). If the name is specified in relative terms, then
the package argument must be set to the name of the package which is to act as
the anchor for resolving the package name (e.g. `import_module('..mod',
'pkg.subpkg')` will `import pkg.mod`).

# [Get system's timezone and use it in datetime](https://stackoverflow.com/a/61124241)

To obtain timezone information in the form of a `datetime.tzinfo` object, use
`dateutil.tz.tzlocal()`:

```python
from dateutil import tz
myTimeZone = tz.tzlocal()
```

This object can be used in the `tz` parameter of `datetime.datetime.now()`:

```python
from datetime import datetime
from dateutil import tz
localisedDatetime = datetime.now(tz = tz.tzlocal())
```

# [Capitalize a sentence](https://stackoverflow.com/questions/53898070/capitalize-only-the-first-letter-of-sentences-in-python-using-split-function)

To change the caps of the first letter of the first word of a sentence use:

```python
>> sentence = "add funny Emojis"
>> sentence[0].upper() + sentence[1:]
Add funny Emojis
```

The `.capitalize` method transforms the rest of words to lowercase.
The `.title` transforms all sentence words to capitalize.

# [Get the last monday datetime](https://www.pythonprogramming.in/find-the-previous-and-coming-monday-s-date-based-on-current-date.html)

```python
import datetime

today = datetime.date.today()
last_monday = today - datetime.timedelta(days=today.weekday())
```

# Issues

* [Pypi won't allow you to upload packages with direct
    dependencies](https://github.com/BaderLab/saber/issues/35): update the
    section above.
