---
title: Python Snippets
date: 20200717
author: Lyz
---

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

# [Deep copy
a dictionary](https://stackoverflow.com/questions/5105517/deep-copy-of-a-dict-in-python)

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

## [Create user defined
exceptions](https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions)

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
