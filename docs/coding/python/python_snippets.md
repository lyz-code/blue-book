---
title: Python Snippets
date: 20200717
author: Lyz
---

# [Print an exception](https://stackoverflow.com/questions/1483429/how-do-i-print-an-exception-in-python)

## Using the logging module

Logging an exception can be done with the module-level function
`logging.exception()` like so:

```python
import logging

try:
    1 / 0
except BaseException:
    logging.exception("An exception was thrown!")
```

```
ERROR:root:An exception was thrown!
Traceback (most recent call last):
File ".../Desktop/test.py", line 4, in <module>
    1/0
ZeroDivisionError: division by zero
```

Notes

- The function `logging.exception()` should only be called from an exception
  handler.

- The logging module should not be used inside a logging handler to avoid a
  `RecursionError`.

It's also possible to log the exception with another log level but still show
the exception details by using the keyword argument `exc_info=True`, like so:

```python
logging.critical("An exception was thrown!", exc_info=True)
logging.error("An exception was thrown!", exc_info=True)
logging.warning("An exception was thrown!", exc_info=True)
logging.info("An exception was thrown!", exc_info=True)
logging.debug("An exception was thrown!", exc_info=True)

# or the general form
logging.log(level, "An exception was thrown!", exc_info=True)
```

## With the traceback module

The `traceback` module provides methods for formatting and printing exceptions
and their tracebacks, e.g. this would print exception like the default handler
does:

```python
import traceback

try:
    1 / 0
except Exception:
    traceback.print_exc()
```

```python
Traceback (most recent call last):
  File "C:\scripts\divide_by_zero.py", line 4, in <module>
    1/0
ZeroDivisionError: division by zero
```

# [Get common elements of two lists](https://stackoverflow.com/questions/13962781/common-elements-in-two-lists-python)

```python
>>> a = ['a', 'b']
>>> b = ['c', 'd', 'b']
>>> set(a) & set(b)
{'b'}
```

# [Recursively find files](https://stackoverflow.com/questions/2186525/how-to-use-glob-to-find-files-recursively)

## Using `pathlib.Path.rglob`

```python
from pathlib import Path

for path in Path("src").rglob("*.c"):
    print(path.name)
```

If you don't want to use `pathlib`, use can use `glob.glob('**/*.c')`, but don't
forget to pass in the recursive keyword parameter and it will use inordinate
amount of time on large directories.

## os.walk

For older Python versions, use `os.walk` to recursively walk a directory and
`fnmatch.filter` to match against a simple expression:

```python
import fnmatch
import os

matches = []
for root, dirnames, filenames in os.walk("src"):
    for filename in fnmatch.filter(filenames, "*.c"):
        matches.append(os.path.join(root, filename))
```

# [Pad a string with spaces](https://stackoverflow.com/questions/20309255/how-to-pad-a-string-to-a-fixed-length-with-spaces-in-python)

```python
>>> name = 'John'
>>> name.ljust(15)
'John           '
```

# [Get hostname of the machine](https://stackoverflow.com/questions/4271740/how-can-i-use-python-to-get-the-system-hostname)

Any of the next three options:

```python
import os

os.uname()[1]

import platform

platform.node()

import socket

socket.gethostname()
```

# [Pathlib make parent directories if they don't exist](https://stackoverflow.com/questions/50110800/python-pathlib-make-directories-if-they-don-t-exist)

```python
pathlib.Path("/tmp/sub1/sub2").mkdir(parents=True, exist_ok=True)
```

From the
[docs](https://docs.python.org/3/library/pathlib.html#pathlib.Path.mkdir):

- If `parents` is `true`, any missing parents of this path are created as
  needed; they are created with the default permissions without taking mode into
  account (mimicking the POSIX `mkdir -p` command).

- If `parents` is `false` (the default), a missing parent raises
  `FileNotFoundError`.

- If `exist_ok` is `false` (the default), `FileExistsError` is raised if the
  target directory already exists.

- If `exist_ok` is `true`, `FileExistsError` exceptions will be ignored (same
  behavior as the POSIX `mkdir -p` command), but only if the last path component
  is not an existing non-directory file.

# [Pathlib touch a file](https://docs.python.org/3/library/pathlib.html#pathlib.Path.touch)

Create a file at this given path.

```python
pathlib.Path("/tmp/file.txt").touch(exist_ok=True)
```

If the file already exists, the function succeeds if `exist_ok` is `true` (and
its modification time is updated to the current time), otherwise
`FileExistsError` is raised.

If the parent directory doesn't exist you need to create it first.

```python
global_conf_path = xdg_home / "autoimport" / "config.toml"
global_conf_path.parent.mkdir(parents=True)
global_conf_path.touch(exist_ok=True)
```

# [Pad integer with zeros](https://stackoverflow.com/questions/39402795/how-to-pad-a-string-with-leading-zeros-in-python-3)

```python
>>> length = 1
>>> print(f'length = {length:03}')
length = 001
```

# [Print datetime with a defined format](https://stackoverflow.com/questions/311627/how-to-print-a-date-in-a-regular-format)

```python
now = datetime.now()
today.strftime("We are the %d, %b %Y")
```

Where the datetime format is a string built from
[these directives](#parse-a-datetime-from-a-string).

# [Print string with asciiart](https://www.askpython.com/python-modules/ascii-art)

```bash
pip install pyfiglet
```

```python
from pyfiglet import figlet_format

print(figlet_format("09 : 30"))
```

If you want to change the default width of 80 caracteres use:

```python
from pyfiglet import Figlet

f = Figlet(font="standard", width=100)
print(f.renderText("aaaaaaaaaaaaaaaaa"))
```

# Print specific time format

```python
datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
```

| Code | Meaning Example                                                                                                                                                                      |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| %a   | Weekday as locale’s abbreviated name. Mon                                                                                                                                            |
| %A   | Weekday as locale’s full name.  Monday                                                                                                                                               |
| %w   | Weekday as a decimal number, where 0 is Sunday and 6 is Saturday. 1                                                                                                                  |
| %d   | Day of the month as a zero-padded decimal number. 30                                                                                                                                 |
| %-d  | Day of the month as a decimal number. (Platform specific) 30                                                                                                                         |
| %b   | Month as locale’s abbreviated name. Sep                                                                                                                                              |
| %B   | Month as locale’s full name.  September                                                                                                                                              |
| %m   | Month as a zero-padded decimal number.  09                                                                                                                                           |
| %-m  | Month as a decimal number. (Platform specific)  9                                                                                                                                    |
| %y   | Year without century as a zero-padded decimal number. 13                                                                                                                             |
| %Y   | Year with century as a decimal number.  2013                                                                                                                                         |
| %H   | Hour (24-hour clock) as a zero-padded decimal number. 07                                                                                                                             |
| %-H  | Hour (24-hour clock) as a decimal number. (Platform specific) 7                                                                                                                      |
| %I   | Hour (12-hour clock) as a zero-padded decimal number. 07                                                                                                                             |
| %-I  | Hour (12-hour clock) as a decimal number. (Platform specific) 7                                                                                                                      |
| %p   | Locale’s equivalent of either AM or PM. AM                                                                                                                                           |
| %M   | Minute as a zero-padded decimal number. 06                                                                                                                                           |
| %-M  | Minute as a decimal number. (Platform specific) 6                                                                                                                                    |
| %S   | Second as a zero-padded decimal number. 05                                                                                                                                           |
| %-S  | Second as a decimal number. (Platform specific) 5                                                                                                                                    |
| %f   | Microsecond as a decimal number, zero-padded on the left. 000000                                                                                                                     |
| %z   | UTC offset in the form +HHMM or -HHMM (empty string if the the object is naive).                                                                                                     |
| %Z   | Time zone name (empty string if the object is naive).                                                                                                                                |
| %j   | Day of the year as a zero-padded decimal number.  273                                                                                                                                |
| %-j  | Day of the year as a decimal number. (Platform specific)  273                                                                                                                        |
| %U   | Week number of the year (Sunday as the first day of the week) as a zero padded decimal number. All days in a new year preceding the first Sunday are considered to be in week 0.  39 |
| %W   | Week number of the year (Monday as the first day of the week) as a decimal number. All days in a new year preceding the first Monday are considered to be in week 0.                 |
| %c   | Locale’s appropriate date and time representation.  Mon Sep 30 07:06:05 2013                                                                                                         |
| %x   | Locale’s appropriate date representation. 09/30/13                                                                                                                                   |
| %X   | Locale’s appropriate time representation. 07:06:05                                                                                                                                   |
| %%   | A literal '%' character.  %                                                                                                                                                          |

# [Get an instance of an Enum by value](https://stackoverflow.com/questions/29503339/how-to-get-all-values-from-python-enum-class)

If you want to initialize a pydantic model with an `Enum` but all you have is
the value of the `Enum` then you need to create a method to get the correct
Enum. Otherwise `mypy` will complain that the type of the assignation is `str`
and not `Enum`.

So if the model is the next one:

```python
class ServiceStatus(BaseModel):
    """Model the docker status of a service."""

    name: str
    environment: Environment
```

You can't do `ServiceStatus(name='test', environment='production')`. you need to
add the `get_by_value` method to the `Enum` class:

```python
class Environment(str, Enum):
    """Set the possible environments."""

    STAGING = "staging"
    PRODUCTION = "production"

    @classmethod
    def get_by_value(cls, value: str) -> Enum:
        """Return the Enum element that meets a value"""
        return [member for member in cls if member.value == value][0]
```

Now you can do:

```python
ServiceStatus(name="test", environment=Environment.get_by_value("production"))
```

# [Fix R1728: Consider using a generator](https://pylint.pycqa.org/en/latest/user_guide/messages/refactor/consider-using-generator.html)

Removing `[]` inside calls that can use containers or generators should be
considered for performance reasons since a generator will have an upfront cost
to pay. The performance will be better if you are working with long lists or
sets.

Problematic code:

```python
list([0 for y in list(range(10))])  # [consider-using-generator]
tuple([0 for y in list(range(10))])  # [consider-using-generator]
sum([y**2 for y in list(range(10))])  # [consider-using-generator]
max([y**2 for y in list(range(10))])  # [consider-using-generator]
min([y**2 for y in list(range(10))])  # [consider-using-generator]
```

Correct code:

```python
list(0 for y in list(range(10)))
tuple(0 for y in list(range(10)))
sum(y**2 for y in list(range(10)))
max(y**2 for y in list(range(10)))
min(y**2 for y in list(range(10)))
```

# [Fix W1510: Using subprocess.run without explicitly set check is not recommended](https://pycodequ.al/docs/pylint-messages/w1510-subprocess-run-check.html)

The `run` call in the example will succeed whether the command is successful or
not. This is a problem because we silently ignore errors.

```python
import subprocess


def example():
    proc = subprocess.run("ls")
    return proc.stdout
```

When we pass `check=True`, the behavior changes towards raising an exception
when the return code of the command is non-zero.

# [Convert bytes to string](https://pythonexamples.org/python-bytes-to-string/)

```python
byte_var.decode("utf-8")
```

# [Use pipes with subprocess](https://stackoverflow.com/questions/13332268/how-to-use-subprocess-command-with-pipes)

To use pipes with subprocess you need to use the flag `shell=True` which is
[a bad idea](https://github.com/duo-labs/dlint/blob/master/docs/linters/DUO116.md).
Instead you should use two processes and link them together in python:

```python
ps = subprocess.Popen(("ps", "-A"), stdout=subprocess.PIPE)
output = subprocess.check_output(("grep", "process_name"), stdin=ps.stdout)
ps.wait()
```

# [Pass input to the stdin of a subprocess](https://stackoverflow.com/questions/8475290/how-do-i-write-to-a-python-subprocess-stdin)

```python
import subprocess

p = subprocess.run(["myapp"], input="data_to_write", text=True)
```

# [Copy and paste from clipboard](https://stackoverflow.com/questions/11063458/python-script-to-copy-text-to-clipboard)

You can use
[many libraries](https://www.delftstack.com/howto/python/python-copy-to-clipboard/)
to do it, but if you don't want to add any other dependencies you can use
`subprocess run`.

To copy from the `selection` clipboard, assuming you've got `xclip` installed,
you could do:

```python
subprocess.run(
    ["xclip", "-selection", "clipboard", "-i"],
    input="text to be copied",
    text=True,
    check=True,
)
```

To paste it:

```python
subprocess.check_output(["xclip", "-o", "-selection", "clipboard"]).decode("utf-8")
```

# [Create random number](https://www.pythoncentral.io/how-to-generate-a-random-number-in-python/)

```python
import random

a = random.randint(1, 10)
```

# [Check if local port is available or in use](https://stackoverflow.com/questions/43270868/verify-if-a-local-port-is-available-in-python)

Create a temporary socket and then try to bind to the port to see if it's
available. Close the socket after validating that the port is available.

```python
def port_in_use(port):
    """Test if a local port is used."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    with suppress(OSError):
        sock.bind(("0.0.0.0", port))
        return True
    sock.close()
    return False
```

# [Initialize a dataclass with kwargs](https://stackoverflow.com/questions/55099243/python3-dataclass-with-kwargsasterisk)

If you care about accessing attributes by name, or if you can't distinguish
between known and unknown arguments during initialisation, then your last resort
without rewriting `__init__` (which pretty much defeats the purpose of using
dataclasses in the first place) is writing a `@classmethod`:

```python
from dataclasses import dataclass
from inspect import signature


@dataclass
class Container:
    user_id: int
    body: str

    @classmethod
    def from_kwargs(cls, **kwargs):
        # fetch the constructor's signature
        cls_fields = {field for field in signature(cls).parameters}

        # split the kwargs into native ones and new ones
        native_args, new_args = {}, {}
        for key, value in kwargs.items():
            if key in cls_fields:
                native_args[key] = value
            else:
                new_args[key] = value

        # use the native ones to create the class ...
        ret = cls(**native_args)

        # ... and add the new ones by hand
        for new_key, new_value in new_args.items():
            setattr(ret, new_key, new_value)
        return ret
```

Usage:

```python
params = {"user_id": 1, "body": "foo", "bar": "baz", "amount": 10}
Container(**params)  # still doesn't work, raises a TypeError
c = Container.from_kwargs(**params)
print(c.bar)  # prints: 'baz'
```

# [Replace a substring of a string](https://www.w3schools.com/python/ref_string_replace.asp)

```python
txt = "I like bananas"

x = txt.replace("bananas", "apples")
```

# [Parse an RFC2822 date](https://stackoverflow.com/questions/1568856/how-do-i-convert-rfc822-to-a-python-datetime-object)

Interesting to test the accepted format of
[RSS dates](https://www.rssboard.org/rss-validator/docs/error/InvalidRFC2822Date.html).

```python
>>> from email.utils import parsedate_to_datetime
>>> datestr = 'Sun, 09 Mar 1997 13:45:00 -0500'
>>> parsedate_to_datetime(datestr)
datetime.datetime(1997, 3, 9, 13, 45, tzinfo=datetime.timezone(datetime.timedelta(-1, 68400)))
```

# [Convert a datetime to RFC2822](https://stackoverflow.com/questions/3453177/convert-python-datetime-to-rfc-2822)

Interesting as it's the accepted format of
[RSS dates](https://www.rssboard.org/rss-validator/docs/error/InvalidRFC2822Date.html).

```python
>>> import datetime
>>> from email import utils
>>> nowdt = datetime.datetime.now()
>>> utils.format_datetime(nowdt)
'Tue, 10 Feb 2020 10:06:53 -0000'
```

# [Encode url](https://www.urlencoder.io/python/)

```python
import urllib.parse
from pydantic import AnyHttpUrl


def _normalize_url(url: str) -> AnyHttpUrl:
    """Encode url to make it compatible with AnyHttpUrl."""
    return typing.cast(
        AnyHttpUrl,
        urllib.parse.quote(url, ":/"),
    )
```

The `:/` is needed when you try to parse urls that have the protocol, otherwise
`https://www.` gets transformed into `https%3A//www.`.

# [Fix SIM113 Use enumerate](https://github.com/MartinThoma/flake8-simplify/issues/18)

Use `enumerate` to get a running number over an iterable.

```python
# Bad
idx = 0
for el in iterable:
    ...
    idx += 1

# Good
for idx, el in enumerate(iterable):
    ...
```

# [Define a property of a class](https://stackoverflow.com/questions/128573/using-property-on-classmethods/64738850#64738850)

If you're using Python 3.9 or above you can directly use the decorators:

```python
class G:
    @classmethod
    @property
    def __doc__(cls):
        return f"A doc for {cls.__name__!r}"
```

If you're not, you can define the decorator `classproperty`:

```python
# N801: class name 'classproperty' should use CapWords convention, but it's a decorator.
# C0103: Class name "classproperty" doesn't conform to PascalCase naming style but it's
# a decorator.
class classproperty:  # noqa: N801, C0103
    """Define a class property.

    From Python 3.9 you can directly use the decorators directly.

    class G:
        @classmethod
        @property
        def __doc__(cls):
            return f'A doc for {cls.__name__!r}'
    """

    def __init__(self, function: Callable[..., Any]) -> None:
        """Initialize the decorator."""
        self.function = function

    # ANN401: Any not allowed in typings, but I don't know how to narrow the hints in
    # this case.
    def __get__(self, owner_self: Any, owner_cls: Any) -> Any:  # noqa: ANN401
        """Return the desired value."""
        return self.function(owner_self)
```

But you'll run into the
`W0143: Comparing against a callable, did you omit the parenthesis? (comparison-with-callable)`
mypy error when using it to compare the result of the property with anything, as
it doesn't detect it's a property instead of a method.

# [How to close a subprocess process](https://stackoverflow.com/questions/62172227/how-to-close-subprocess-in-python)

```python
subprocess.terminate()
```

# [How to extend a dictionary](https://stackoverflow.com/questions/577234/python-extend-for-a-dictionary)

```python
a.update(b)
```

# [How to Find Duplicates in a List in Python](https://datagy.io/python-list-duplicates/)

```python
numbers = [1, 2, 3, 2, 5, 3, 3, 5, 6, 3, 4, 5, 7]

duplicates = [number for number in numbers if numbers.count(number) > 1]
unique_duplicates = list(set(duplicates))

# Returns: [2, 3, 5]
```

If you want to count the number of occurrences of each duplicate, you can use:

```python
from collections import Counter

numbers = [1, 2, 3, 2, 5, 3, 3, 5, 6, 3, 4, 5, 7]

counts = dict(Counter(numbers))
duplicates = {key: value for key, value in counts.items() if value > 1}

# Returns: {2: 2, 3: 4, 5: 3}
```

To remove the duplicates use a combination of `list` and `set`:

```python
unique = list(set(numbers))

# Returns: [1, 2, 3, 4, 5, 6, 7]
```

# [How to decompress a gz file](https://stackoverflow.com/questions/31028815/how-to-unzip-gz-file-using-python)

```python
import gzip
import shutil

with gzip.open("file.txt.gz", "rb") as f_in:
    with open("file.txt", "wb") as f_out:
        shutil.copyfileobj(f_in, f_out)
```

# [How to compress/decompress a tar file](https://www.thepythoncode.com/article/compress-decompress-files-tarfile-python)

```python
def compress(tar_file, members):
    """
    Adds files (`members`) to a tar_file and compress it
    """
    tar = tarfile.open(tar_file, mode="w:gz")

    for member in members:
        tar.add(member)

    tar.close()


def decompress(tar_file, path, members=None):
    """
    Extracts `tar_file` and puts the `members` to `path`.
    If members is None, all members on `tar_file` will be extracted.
    """
    tar = tarfile.open(tar_file, mode="r:gz")
    if members is None:
        members = tar.getmembers()
    for member in members:
        tar.extract(member, path=path)
    tar.close()
```

# [Parse XML file with beautifulsoup](https://linuxhint.com/parse_xml_python_beautifulsoup/)

You need both `beautifulsoup4` and `lxml`:

```python
bs = BeautifulSoup(requests.get(url), "lxml")
```

# [Get a traceback from an exception](https://stackoverflow.com/questions/11414894/extract-traceback-info-from-an-exception-object)

```python
import traceback

# `e` is an exception object that you get from somewhere
traceback_str = "".join(traceback.format_tb(e.__traceback__))
```

# Change the logging level of a library

For example to change the logging level of the library `sh` use:

```python
sh_logger = logging.getLogger("sh")
sh_logger.setLevel(logging.WARN)
```

# [Get all subdirectories of a directory](https://stackoverflow.com/questions/973473/getting-a-list-of-all-subdirectories-in-the-current-directory)

```python
[x[0] for x in os.walk(directory)]
```

# [Move a file](https://stackoverflow.com/questions/8858008/how-to-move-a-file-in-python)

```python
import os

os.rename("path/to/current/file.foo", "path/to/new/destination/for/file.foo")
```

# [IPv4 regular expression](https://stackoverflow.com/questions/55928637/regex-for-matching-ipv4-addresses)

```python
regex = re.compile(
    r"(?<![-\.\d])(?:0{0,2}?[0-9]\.|1\d?\d?\.|2[0-5]?[0-5]?\.){3}"
    r'(?:0{0,2}?[0-9]|1\d?\d?|2[0-5]?[0-5]?)(?![\.\d])"^[0-9]{1,3}*$'
)
```

# [Remove the elements of a list from another](https://stackoverflow.com/questions/4211209/remove-all-the-elements-that-occur-in-one-list-from-another)

```python
>>> set([1,2,6,8]) - set([2,3,5,8])
set([1, 6])
```

Note, however, that sets do not preserve the order of elements, and cause any
duplicated elements to be removed. The elements also need to be hashable. If
these restrictions are tolerable, this may often be the simplest and highest
performance option.

# [Copy a directory](https://stackoverflow.com/questions/1868714/how-do-i-copy-an-entire-directory-of-files-into-an-existing-directory-using-pyth/22331852)

```python
import shutil

shutil.copytree("bar", "foo")
```

# [Copy a file](https://stackabuse.com/how-to-copy-a-file-in-python/)

```python
import shutil

shutil.copyfile(src_file, dest_file)
```

# [Capture the stdout of a function](https://stackoverflow.com/questions/16571150/how-to-capture-stdout-output-from-a-python-function-call)

```python
import io
from contextlib import redirect_stdout

f = io.StringIO()
with redirect_stdout(f):
    do_something(my_object)
out = f.getvalue()
```

# [Make temporal directory](https://stackoverflow.com/questions/3223604/how-to-create-a-temporary-directory-and-get-its-path-file-name)

```python
import tempfile

dirpath = tempfile.mkdtemp()
```

# [Change the working directory of a test](https://stackoverflow.com/questions/62044541/change-pytest-working-directory-to-test-case-directory)

The following function-level fixture will change to the test case directory, run
the test (`yield`), then change back to the calling directory to avoid
side-effects.

```python
@pytest.fixture(name="change_test_dir")
def change_test_dir_(request: SubRequest) -> Any:
    os.chdir(request.fspath.dirname)
    yield
    os.chdir(request.config.invocation_dir)
```

- `request` is a built-in pytest fixture
- `fspath` is the `LocalPath` to the test module being executed
- `dirname` is the directory of the test module
- `request.config.invocationdir` is the folder from which pytest was executed
- `request.config.rootdir` is the pytest root, doesn't change based on where you
  run pytest. Not used here, but could be useful.

Any processes that are kicked off by the test will use the test case folder as
their working directory and copy their logs, outputs, etc. there, regardless of
where the test suite was executed.

# [Remove a substring from the end of a string](https://stackoverflow.com/questions/1038824/how-do-i-remove-a-substring-from-the-end-of-a-string)

On Python 3.9 and newer you can use the `removeprefix` and `removesuffix`
methods to remove an entire substring from either side of the string:

```python
url = "abcdc.com"
url.removesuffix(".com")  # Returns 'abcdc'
url.removeprefix("abcdc.")  # Returns 'com'
```

On Python 3.8 and older you can use `endswith` and slicing:

```python
url = "abcdc.com"
if url.endswith(".com"):
    url = url[:-4]
```

Or a regular expression:

```python
import re

url = "abcdc.com"
url = re.sub("\.com$", "", url)
```

# [Make a flat list of lists with a list comprehension](https://stackoverflow.com/questions/952914/how-to-make-a-flat-list-out-of-a-list-of-lists)

There is no nice way to do it :(. The best I've found is:

```python
t = [[1, 2, 3], [4, 5, 6], [7], [8, 9]]
flat_list = [item for sublist in t for item in sublist]
```

# [Replace all characters of a string with another character](https://stackoverflow.com/questions/48995979/how-to-replace-all-characters-in-a-string-with-one-character/48996018)

```python
mystring = "_" * len(mystring)
```

# [Locate element in list](https://appdividend.com/2019/11/16/how-to-find-element-in-list-in-python/)

```python
a = ["a", "b"]

index = a.index("b")
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

If you have two dictionaries `big = {'a': 1, 'b': 2, 'c':3}` and
`small = {'c': 3, 'a': 1}`, and want to check whether `small` is a subset of
`big`, use the next snippet:

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
    def __init__(self, length):
        Rectangle.__init__(self, length, length)
```

And we want to check if an object `a = Square(5)` is of type `Rectangle`, we
could not use `isinstance` because it'll return `True` as it's a subclass of
`Rectangle`:

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

file_path = (pkg_resources.resource_filename("pynbox", "assets/config.yaml"),)
```

# [Delete a file](https://www.w3schools.com/python/python_file_remove.asp)

```python
import os

os.remove("demofile.txt")
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

If you don't want to use `dateutil` use `datetime`

```python
datetime.datetime.strptime("2013-W26", "%Y-W%W-%w")
```

Where the datetime format is a string built from the next directives:

| Directive | Meaning                                                        | Example                  |
| --------- | -------------------------------------------------------------- | ------------------------ |
| %a        | Abbreviated weekday name.                                      | Sun, Mon, ...            |
| %A        | Full weekday name.                                             | Sunday, Monday, ...      |
| %w        | Weekday as a decimal number.                                   | 0, 1, ..., 6             |
| %d        | Day of the month as a zero-padded decimal.                     | 01, 02, ..., 31          |
| %-d       | Day of the month as a decimal number.                          | 1, 2, ..., 30            |
| %b        | Abbreviated month name.                                        | Jan, Feb, ..., Dec       |
| %B        | Full month name.                                               | January, February, ...   |
| %m        | Month as a zero-padded decimal number.                         | 01, 02, ..., 12          |
| %-m       | Month as a decimal number.                                     | 1, 2, ..., 12            |
| %y        | Year without century as a zero-padded decimal number.          | 00, 01, ..., 99          |
| %-y       | Year without century as a decimal number.                      | 0, 1, ..., 99            |
| %Y        | Year with century as a decimal number.                         | 2013, 2019 etc.          |
| %H        | Hour (24-hour clock) as a zero-padded decimal number.          | 00, 01, ..., 23          |
| %-H       | Hour (24-hour clock) as a decimal number.                      | 0, 1, ..., 23            |
| %I        | Hour (12-hour clock) as a zero-padded decimal number.          | 01, 02, ..., 12          |
| %-I       | Hour (12-hour clock) as a decimal number.                      | 1, 2, ... 12             |
| %p        | Locale’s AM or PM.                                             | AM, PM                   |
| %M        | Minute as a zero-padded decimal number.                        | 00, 01, ..., 59          |
| %-M       | Minute as a decimal number.                                    | 0, 1, ..., 59            |
| %S        | Second as a zero-padded decimal number.                        | 00, 01, ..., 59          |
| %-S       | Second as a decimal number.                                    | 0, 1, ..., 59            |
| %f        | Microsecond as a decimal number, zero-padded on the left.      | 000000 - 999999          |
| %z        | UTC offset in the form +HHMM or -HHMM.                         |                          |
| %Z        | Time zone name.                                                |                          |
| %j        | Day of the year as a zero-padded decimal number.               | 001, 002, ..., 366       |
| %-j       | Day of the year as a decimal number.                           | 1, 2, ..., 366           |
| %U        | Week number of the year (Sunday as the first day of the week). | 00, 01, ..., 53          |
| %W        | Week number of the year (Monday as the first day of the week). | 00, 01, ..., 53          |
| %c        | Locale’s appropriate date and time representation.             | Mon Sep 30 07:06:05 2013 |
| %x        | Locale’s appropriate date representation.                      | 09/30/13                 |
| %X        | Locale’s appropriate time representation.                      | 07:06:05                 |
| %%        | A literal '%' character.                                       | %                        |

# Install a python dependency from a git repository

With
[pip you can](https://stackoverflow.com/questions/16584552/how-to-state-in-requirements-txt-a-direct-github-source):

```bash
pip install git+git://github.com/path/to/repository@master
```

If you want
[to hard code it in your `setup.py`](https://stackoverflow.com/questions/32688688/how-to-write-setup-py-to-include-a-git-repository-as-a-dependency/54794506#54794506),
you need to:

```python
install_requires = [
    "some-pkg @ git+ssh://git@github.com/someorgname/pkg-repo-name@v1.1#egg=some-pkg",
]
```

But
[Pypi won't allow you to upload the package](https://github.com/BaderLab/saber/issues/35),
as it will give you an error:

```
HTTPError: 400 Bad Request from https://test.pypi.org/legacy/
Invalid value for requires_dist. Error: Can't have direct dependency: 'deepdiff @ git+git://github.com/lyz-code/deepdiff@master'
```

It looks like this is a conscious decision on the PyPI side. Basically, they
don't want pip to reach out to URLs outside their site when installing from
PyPI.

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


setup(cmdclass={"install": PostInstall})
```

Warning: It may not work! Last time I used this solution, when I added the
library on a `setup.py` the direct dependencies weren't installed :S

# Check or test directories and files

```python
def test_dir(directory):
    from os.path import exists
    from os import makedirs

    if not exists(directory):
        makedirs(directory)


def test_file(filepath, mode):
    """Check if a file exist and is accessible."""

    def check_mode(os_mode, mode):
        if os.path.isfile(filepath) and os.access(filepath, os_mode):
            return
        else:
            raise IOError("Can't access the file with mode " + mode)

    if mode is "r":
        check_mode(os.R_OK, mode)
    elif mode is "w":
        check_mode(os.W_OK, mode)
    elif mode is "a":
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

directory = "/path/to/directory"
for entry in os.scandir(directory):
    if (entry.path.endswith(".jpg") or entry.path.endswith(".png")) and entry.is_file():
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

Path("path/to/file.txt").touch()
```

# [Get the first day of next month](https://stackoverflow.com/questions/4130922/how-to-increment-datetime-by-custom-months-in-python-without-using-library)

```python
current = datetime.datetime(mydate.year, mydate.month, 1)
next_month = datetime.datetime(
    mydate.year + int(mydate.month / 12), ((mydate.month % 12) + 1), 1
)
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

A week number is not enough to generate a date; you need a day of the week as
well. Add a default:

```python
import datetime

d = "2013-W26"
r = datetime.datetime.strptime(d + "-1", "%Y-W%W-%w")
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
    """Convert an integer into its ordinal representation.

    make_ordinal(0)   => '0th'
    make_ordinal(3)   => '3rd'
    make_ordinal(122) => '122nd'
    make_ordinal(213) => '213th'

    Args:
        number: Number to convert

    Returns:
        ordinal representation of the number
    """
    suffix = ["th", "st", "nd", "rd", "th"][min(number % 10, 4)]
    if 11 <= (number % 100) <= 13:
        suffix = "th"
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

## [Get the attribute of an attribute](https://stackoverflow.com/questions/403421/how-to-sort-a-list-of-objects-based-on-an-attribute-of-the-objects)

To sort the list in place:

```python
ut.sort(key=lambda x: x.count, reverse=True)
```

To return a new list, use the `sorted()` built-in function:

```python
newlist = sorted(ut, key=lambda x: x.body.id_, reverse=True)
```

# [Iterate over an instance object's data attributes in Python](https://www.saltycrane.com/blog/2008/09/how-iterate-over-instance-objects-data-attributes-python/)

```python
@dataclass(frozen=True)
class Search:
    center: str
    distance: str


se = Search("a", "b")
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
    backend=crypto_default_backend(), public_exponent=65537, key_size=4096
)
pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.TraditionalOpenSSL,
    encryption_algorithm=serialization.NoEncryption(),
)

with open("/tmp/private.key", "wb") as content_file:
    chmod("/tmp/private.key", 0600)
    content_file.write(pem)

public_key = (
    private_key.public_key().public_bytes(
        encoding=serialization.Encoding.OpenSSH,
        format=serialization.PublicFormat.OpenSSH,
    )
    + b" user@email.org"
)
with open("/tmp/public.key", "wb") as content_file:
    content_file.write(public_key)
```

# Make multiline code look clean

If you need variables that contain multiline strings inside functions or methods
you need to remove the indentation

```python
def test():
    # end first line with \ to avoid the empty line!
    s = """\
hello
  world
"""
```

Which is inconvenient as it breaks some editor source code folding and it's ugly
for the eye.

The solution is to use
[`textwrap.dedent()`](https://docs.python.org/3/library/textwrap.html)

```python
import textwrap


def test():
    # end first line with \ to avoid the empty line!
    s = """\
    hello
      world
    """
    print(repr(s))  # prints '    hello\n      world\n    '
    print(repr(textwrap.dedent(s)))  # prints 'hello\n  world\n'
```

If you forget to add the trailing `\` character of `s = '''\` or use
`s = '''hello`, you're going to have a bad time with [black](black.md).

# [Play a sound](https://linuxhint.com/play_sound_python/)

```bash
pip install playsound
```

```python
from playsound import playsound

playsound("path/to/file.wav")
```

# [Deep copy a dictionary](https://stackoverflow.com/questions/5105517/deep-copy-of-a-dict-in-python)

```python
import copy

d = {...}
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
if hasattr(a, "property"):
    a.property
```

# [Check if a loop ends completely](https://stackoverflow.com/questions/38381850/how-to-check-whether-for-loop-ends-completely-in-python/38381893)

`for` loops can take an `else` block which is not run if the loop has ended with
a `break` statement.

```python
for i in [1, 2, 3]:
    print(i)
    if i == 3:
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
Exceptions should typically be derived from the `Exception` class, either
directly or indirectly.

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

module = importlib.import_module("os")
module_class = module.getcwd

relative_module = importlib.import_module(".model", package="mypackage")
class_to_extract = "MyModel"
extracted_class = geattr(relative_module, class_to_extract)
```

The first argument specifies what module to import in absolute or relative terms
(e.g. either `pkg.mod` or `..mod`). If the name is specified in relative terms,
then the package argument must be set to the name of the package which is to act
as the anchor for resolving the package name (e.g.
`import_module('..mod', 'pkg.subpkg')` will `import pkg.mod`).

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

localisedDatetime = datetime.now(tz=tz.tzlocal())
```

# [Capitalize a sentence](https://stackoverflow.com/questions/53898070/capitalize-only-the-first-letter-of-sentences-in-python-using-split-function)

To change the caps of the first letter of the first word of a sentence use:

```python
>> sentence = "add funny Emojis"
>> sentence[0].upper() + sentence[1:]
Add funny Emojis
```

The `.capitalize` method transforms the rest of words to lowercase. The `.title`
transforms all sentence words to capitalize.

# [Get the last monday datetime](https://www.pythonprogramming.in/find-the-previous-and-coming-monday-s-date-based-on-current-date.html)

```python
import datetime

today = datetime.date.today()
last_monday = today - datetime.timedelta(days=today.weekday())
```

# Issues

- [Pypi won't allow you to upload packages with direct dependencies](https://github.com/BaderLab/saber/issues/35):
  update the section above.
