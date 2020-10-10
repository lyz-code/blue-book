---
title: Python pytest
date: 20200527
author: Lyz
---

[pytest](https://docs.pytest.org/en/latest) is a Python framework to makes it
easy to write small tests, yet scales to support complex functional testing for
applications and libraries.

Pytest stands out over other test frameworks in:

* Simple tests are simple to write in pytest.
* Complex tests are still simple to write.
* Tests are easy to read.
* You can get started in seconds.
* You use `assert` to fail a test, not things like `self.assertEqual()` or
    `self.assertLessThan()`. Just `assert`.
* You can use pytest to run tests written for unittest or nose.

# Install

```bash
pip install pytest
```

# Usage

Run in the project directory.

```bash
pytest
```

If you need more information run it with `-v`.

Pytest automatically finds which tests to run in a phase called *test
discovery*. It will get the tests that match one of the following conditions:

* Test files that are named `test_{{ something }}.py` or `{{ something }}_test.py`.
* Test methods and functions named `test_{{ something }}`.
* Test classes named `Test{{ Something }}`.

There are several possible outcomes of a test function:

* *PASSED (.)*: The test ran successfully.
* *FAILED (F)*: The test did not run usccessfully (or *XPASS* + strict).
* *SKIPPED (s)*: The test was skipped. You can tell pytest to skip a test by
    using enter the `@pytest.mark.skip()` or `pytest.mark.skipif()` decorators.
* *xfail (x)*: The test was not supposed to pass, ran, and failed. You can tell
    pytest that a test is expected to fail by using the `@pytest.mark.xfail()`
    decorator.
* *XPASS (X)*: The tests was not supposed to pass, ran, and passed.
* *ERROR (E)*: An exception happened outside of the test function, in either
    a fixture or a hook function.

Pytest supports several cool flags like:

* `-k EXPRESSION`: Used to select a subset of tests to run. For example `pytest
    -k "asdict or defaults"` will run both `test_asdict()` and
    `test_defaults()`.
* `--lf` or `--last-failed`: Just run the tests that have failed in the previous
    run.
* `-x`, or `--exitfirst`: Exit on first failed test.
* `-l` or `--showlocals`: Print out the local variables in a test if the test
    fails.
- `-s` Allows any output that normally would be printed to `stdout` to actually
    be printed to `stdout`. It's an alias of `--capture=no`, so the output is
    not captured when the tests are run, which is the default behavior. This is
    useful to debug with `print()` statements.
- `--durations=N`: It reports the slowest `N` number of tests/setups/teardowns
    after the test run. If you pass in `--durations=0`, it reports everything in
    order of slowest to fastest.

# Fixtures

Fixtures are functions that are run by pytest before (and sometimes after) the
actual test functions.

You can use fixtures to get a data set for the tests to work on, or use
them to get a system into a known state before running a test. They are
also used to get data ready for multiple tests.

Here's a simple fixture that returns a number:

```python
import pytest

@pytest.fixture()
def some_data()
    """ Return answer to the ultimate question """
    return 42

def test_some_data(some_data):
    """ Use fixture return value in a test"""
    assert some_data == 42
```

The `@pytest.fixture()` decorator is used to tell pytest that a function is
a fixture.When you include the fixture name in the parameter list of a test
function,pytest knows to run it before running the test. Fixtures can do work,
and can also return data to the test function.

The test test_some_data() has the name of the fixture, some_data, as
a parameter.pytest will see this and look for a fixture with this name. Naming
is significant in pytest. pytest will look in the module of the test for
a fixture of that name.

## Sharing fixtures through conftest.py

You can put fixtures into individual test files, but to share fixtures among
multiple test files, you need to use a `conftest.py` file somewhere centrally
located for all of the tests. Additionally you can have `conftest.py` files in
subdirectories of the top `tests` directory. If you do, fixtures defined in
these lower level `conftest.py` files will be available to tests in that
directory and subdirectories.

Although `conftest.py` is a Python module, it should not be imported by test
files. The file gets read by pytest, and is considered a local *plugin*.

Another option is to save the fixtures in a file by [creating a  local pytest
plugin](https://gist.github.com/peterhurford/09f7dcda0ab04b95c026c60fa49c2a68).

!!! note "File: tests/unit/conftest.py"

    ```python
    pytest_plugins = [
       "tests.unit.fixtures.some_stuff",
    ]
    ```

!!! note "File: tests/unit/fixtures/some_stuff.py"

    ```python
    import pytest

    @pytest.fixture
    def foo():
        return 'foobar'
    ```

## Specifying fixture scope

Fixtures include an optional parameter called scope, which controls how often
a fixture gets set up and torn down. The scope parameter to `@pytest.fixture()`
can have the values of function, class, module, or session.

Here’s a rundown of each scope value:

* `scope='function'`: Run once per test function. The setup portion is run before each test using the fixture. The teardown portion is run after each test using the fixture. This is the default scope used when no scope parameter is specified.
* `scope='class'`: Run once per test class, regardless of how many test methods are in the class.
* `scope='module'`: Run once per module, regardless of how many test functions or methods or other fixtures in the module use it.
* `scope='session'` Run once per session. All test methods and functions using a fixture of session scope share one setup and teardown call.

## Useful Fixtures

### [The tmpdir fixture](https://docs.pytest.org/en/stable/tmpdir.html)

You can use the `tmpdir` fixture which will provide a temporary directory unique
to the test invocation, created in the base temporary directory.

`tmpdir` is a `py.path.local` object which offers `os.path` methods and more. Here is an example test usage:

!!! note "File: test_tmpdir.py"

    ```python
    def test_create_file(tmpdir):
        p = tmpdir.mkdir("sub").join("hello.txt")
        p.write("content")
        assert p.read() == "content"
        assert len(tmpdir.listdir()) == 1
        assert 0
    ```

The `tmpdir` fixture has a scope of `function` so you can't make a session
directory. Instead use the `tmpdir_factory` fixture.


```python
@pytest.fixture(scope="session")
def image_file(tmpdir_factory):
    img = compute_expensive_image()
    fn = tmpdir_factory.mktemp("data").join("img.png")
    img.save(str(fn))
    return fn


def test_histogram(image_file):
    img = load_image(image_file)
    # compute and test histogram
```

### [The caplog fixture](https://docs.pytest.org/en/stable/logging.html#caplog-fixture)

pytest captures log messages of level WARNING or above automatically and
displays them in their own section for each failed test in the same manner as
captured stdout and stderr.

You can change the default logging level in the pytest configuration

!!! note "File: pytest.ini"
    ```ini
    [pytest]

    log_level = debug
    ```

All the logs sent to the logger during the test run are available on the
fixture in the form of both the `logging.LogRecord` instances and the final log
text. This is useful for when you want to assert on the contents of a message:

```python
def test_baz(caplog):
    func_under_test()
    for record in caplog.records:
        assert record.levelname != "CRITICAL"
    assert "wally" not in caplog.text
```

You can also resort to record_tuples if all you want to do is to ensure that
certain messages have been logged under a given logger name with a given
severity and message:

```python
def test_foo(caplog):
    logging.getLogger().info("boo %s", "arg")

    assert  ("root", logging.INFO, "boo arg") in caplog.record_tuples
```

You can call `caplog.clear()` to reset the captured log records in a test.

Inside tests it is possible to change the log level for the captured log
messages. This is supported by the caplog fixture:

```python
def test_foo(caplog):
    caplog.set_level(logging.INFO)
    pass
```

### The capsys fixture

The `capsys` builtin fixture provides two bits of functionality: it allows you
to retrieve stdout and stderr from some code, and it disables output capture
temporarily.

Suppose you have a function to print a greeting to stdout:

```python
def greeting(name):
    print(f'Hi, {name}')
```

You can test the output by using `capsys`.

```python
def test_greeting(capsys):
    greeting('Earthling')
    out, err = capsys.readouterr()
    assert out == 'Hi, Earthling\n'
    assert err == ''
```

The return value is whatever has been captured since the beginning of the
function, or from the last time it was called.

### [freezegun](https://github.com/ktosiek/pytest-freezegun)

freezegun lets you freeze time in both the test and fixtures.

#### Install

```bash
pip install pytest-freezegun
```

#### [Usage](https://github.com/ktosiek/pytest-freezegun#usage)

Freeze time by using the freezer fixture:

```python
def test_frozen_date(freezer):
    now = datetime.now()
    time.sleep(1)
    later = datetime.now()
    assert now == later
```

This can then be used to move time:

```python
def test_moving_date(freezer):
    now = datetime.now()
    freezer.move_to('2017-05-20')
    later = datetime.now()
    assert now != later
```

You can also pass arguments to freezegun by using the `freeze_time` mark:

```python
@pytest.mark.freeze_time('2017-05-21')
def test_current_date():
    assert date.today() == date(2017, 5, 21)
```

The `freezer` fixture and `freeze_time` mark can be used together, and they work with other fixtures:

```python
@pytest.fixture
def current_date():
    return date.today()

@pytest.mark.freeze_time
def test_changing_date(current_date, freezer):
    freezer.move_to('2017-05-20')
    assert current_date == date(2017, 5, 20)
    freezer.move_to('2017-05-21')
    assert current_date == date(2017, 5, 21)
```

They can also be used in class-based tests:

```python
class TestDate:

    @pytest.mark.freeze_time
    def test_changing_date(self, current_date, freezer):
        freezer.move_to('2017-05-20')
        assert current_date == date(2017, 5, 20)
        freezer.move_to('2017-05-21')
        assert current_date == date(2017, 5, 21)
```

## [Use a fixture more than once in a function](https://github.com/pytest-dev/pytest/issues/2703)

One solution is to make your fixture return a factory instead of the resource
directly:

```python
@pytest.fixture(name='make_user')
def make_user_():
    created = []
    def make_user():
        u = models.User()
        u.commit()
        created.append(u)
        return u

    yield make_user

    for u in created:
        u.delete()

def test_two_users(make_user):
    user1 = make_user()
    user2 = make_user()
    # test them


# you can even have the normal fixture when you only need a single user
@pytest.fixture
def user(make_user):
    return make_user()

def test_one_user(user):
    # test him/her
```

# Snippets

## [Mocking sys.exit](https://medium.com/python-pandemonium/testing-sys-exit-with-pytest-10c6e5f7726f)

```python
with pytest.raises(SystemExit):
    # Code to test
```

# pytest integration with Vim

Integrating pytest into your Vim workflow enhances your productivity while
writing code, thus making it easier to code using TDD.

I use [Janko-m's Vim-test plugin](https://github.com/janko-m/vim-test) (which
can be installed through [Vundle](https://github.com/VundleVim/Vundle.vim)) with the
following configuration.

```vim
nmap <silent> t :TestNearest<CR>
nmap <silent> <leader>t :TestSuite tests/unit<CR>
nmap <silent> <leader>i :TestSuite tests/integration<CR>
nmap <silent> <leader>T :TestFile<CR>

let test#python#runner = 'pytest'
let test#strategy = "neovim"
```

I often open Vim with a vertical split (`:vs`), in the left window I have the
tests and in the right the code. Whenever I want to run a single test I press
`t` when the cursor is inside that test. If you need to make changes in the
code, you can press `t` again while the cursor is at the code you are testing
and it will run the last test.

Once the unit test has passed, I run the whole unit tests with `;t` (as `;` is
my `<leader>`). And finally I use `;i` to run the integration tests.

Finally, if the test suite is huge, I use `;T` to run only the tests of a single
file.


# Reference

* Book [Python Testing with pytest by Brian Okken](https://www.oreilly.com/library/view/python-testing-with/9781680502848/).
* [Docs](https://docs.pytest.org/en/latest/)

* [Vim-test plugin](https://github.com/janko-m/vim-test)
