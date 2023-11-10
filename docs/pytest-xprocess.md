[`pytest-xprocess`](https://github.com/pytest-dev/pytest-xprocess) is a pytest plugin for managing external processes across test runs.

# [Installation](https://pytest-xprocess.readthedocs.io/en/latest/#quickstart)

```bash
pip install pytest-xprocess
```

# [Usage](https://pytest-xprocess.readthedocs.io/en/latest/#quickstart)

Define your process fixture in `conftest.py`:

```python
import pytest
from xprocess import ProcessStarter

@pytest.fixture
def myserver(xprocess):
    class Starter(ProcessStarter):
        # startup pattern
        pattern = "[Ss]erver has started!"

        # command to start process
        args = ['command', 'arg1', 'arg2']

    # ensure process is running and return its logfile
    logfile = xprocess.ensure("myserver", Starter)

    conn = # create a connection or url/port info to the server
    yield conn

    # clean up whole process tree afterwards
    xprocess.getinfo("myserver").terminate()
```

Now you can use this fixture in any test functions where `myserver` needs to be up and `xprocess` will take care of it for you.

## [Matching process output with pattern](https://pytest-xprocess.readthedocs.io/en/latest/starter.html#matching-process-output-with-pattern)

In order to detect that your process is ready to answer queries,
`pytest-xprocess` allows the user to provide a string pattern by setting the
class variable pattern in the Starter class. `pattern` will be waited for in
the process `logfile` for a maximum time defined by `timeout` before timing out in
case the provided pattern is not matched.

It’s important to note that pattern is a regular expression and will be matched using python `re.search`.

## [Controlling Startup Wait Time with timeout](https://pytest-xprocess.readthedocs.io/en/latest/starter.html#controlling-startup-wait-time-with-timeout)

Some processes naturally take longer to start than others. By default,
`pytest-xprocess` will wait for a maximum of 120 seconds for a given process to
start before raising a `TimeoutError`. Changing this value may be useful, for
example, when the user knows that a given process would never take longer than
a known amount of time to start under normal circunstancies, so if it does go
over this known upper boundary, that means something is wrong and the waiting
process must be interrupted. The maximum wait time can be controlled through the
class variable timeout.

```python
   @pytest.fixture
   def myserver(xprocess):
       class Starter(ProcessStarter):
           # will wait for 10 seconds before timing out
           timeout = 10

```

## Passing command line arguments to your process with `args`

In order to start a process, pytest-xprocess must be given a command to be passed into the subprocess.Popen constructor. Any arguments passed to the process command can also be passed using args. As an example, if I usually use the following command to start a given process:

```bash
$> myproc -name "bacon" -cores 4 <destdir>
```

That would look like:

```python
args = ['myproc', '-name', '"bacon"', '-cores', 4, '<destdir>']
```

When using `args` in `pytest-xprocess` to start the same process.

```python
@pytest.fixture
def myserver(xprocess):
    class Starter(ProcessStarter):
        # will pass "$> myproc -name "bacon" -cores 4 <destdir>"  to the
        # subprocess.Popen constructor so the process can be started with
        # the given arguments
        args = ['myproc', '-name', '"bacon"', '-cores', 4, '<destdir>']

        # ...
```

# References

- [Source](https://github.com/pytest-dev/pytest-xprocess)
- [Docs](https://pytest-xprocess.readthedocs.io/en/latest/)
