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
