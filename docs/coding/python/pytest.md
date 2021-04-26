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

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `pytest` already configured.

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
* `-s` Allows any output that normally would be printed to `stdout` to actually
    be printed to `stdout`. It's an alias of `--capture=no`, so the output is
    not captured when the tests are run, which is the default behavior. This is
    useful to debug with `print()` statements.
* `--durations=N`: It reports the slowest `N` number of tests/setups/teardowns
    after the test run. If you pass in `--durations=0`, it reports everything in
    order of slowest to fastest.
* `--setup-show`: Show the fixtures in use.

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

If the function is defined in the same file as where it's being used pylint will
raise an `W0621: Redefining name %r from outer scope (line %s)` error. To
[solve](https://stackoverflow.com/questions/46089480/pytest-fixtures-redefining-name-from-outer-scope-pylint)
it either move the fixture to other file or name the decorated function
`fixture_<fixturename>` and then use `@pytest.fixture(name='<fixturename>')`.

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
    from py._path.local import LocalPath

    def test_create_file(tmpdir: LocalPath):
        p = tmpdir.mkdir("sub").join("hello.txt")
        p.write("content")
        assert p.read() == "content"
        assert len(tmpdir.listdir()) == 1
        assert 0
    ```

The `tmpdir` fixture has a scope of `function` so you can't make a session
directory. Instead use the `tmpdir_factory` fixture.


```python
from _pytest.tmpdir import TempdirFactory
@pytest.fixture(scope="session")
def image_file(tmpdir_factory: TempdirFactory):
    img = compute_expensive_image()
    fn = tmpdir_factory.mktemp("data").join("img.png")
    img.save(str(fn))
    return fn


def test_histogram(image_file):
    img = load_image(image_file)
    # compute and test histogram
```

#### Make a subdirectory

```python
p = tmpdir.mkdir("sub").join("hello.txt")
```

### [The caplog fixture](https://docs.pytest.org/en/stable/logging.html#caplog-fixture)

pytest captures log messages of level WARNING or above automatically and
displays them in their own section for each failed test in the same manner as
captured stdout and stderr.

You can change the default logging level in the pytest configuration:

!!! note "File: pytest.ini"
    ```ini
    [pytest]

    log_level = debug
    ```

Although it may not be a good idea in most cases. It's better to change the log
level in the tests that need a lower level.

All the logs sent to the logger during the test run are available on the
fixture in the form of both the `logging.LogRecord` instances and the final log
text. This is useful for when you want to assert on the contents of a message:

```python
from _pytest.logging import LogCaptureFixture

def test_baz(caplog: LogCaptureFixture):
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

#### Change the log level

Inside tests it's possible to change the log level for the captured log
messages.

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
from _pytest.capture import CaptureFixture

def test_greeting(capsys: CaptureFixture[Any]):
    greeting('Earthling')
    out, err = capsys.readouterr()
    assert out == 'Hi, Earthling\n'
    assert err == ''
```

The return value is whatever has been captured since the beginning of the
function, or from the last time it was called.

### [freezegun](https://github.com/ktosiek/pytest-freezegun)

[freezegun](https://github.com/spulec/freezegun) lets you freeze time in both
the test and fixtures.

#### Install

```bash
pip install pytest-freezegun
```

#### [Usage](https://github.com/ktosiek/pytest-freezegun#usage)

Freeze time by using the freezer fixture:

```python
if TYPE_CHECKING:
    from freezegun.api import FrozenDateTimeFactory

def test_frozen_date(freezer: FrozenDateTimeFactory):
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

## [Customize nested fixtures](http://www.obeythetestinggoat.com/a-pytest-pattern-using-parametrize-to-customise-nested-fixtures.html)

Sometimes you need to tweak your fixtures so they can be used in different
tests. As usual, there are different solutions to the same problem.

!!! note "TL;DR: For simple cases [parametrize your
fixtures](#parametrize-your-fixtures) or use [parametrization to override the
default valued
fixture](#use-pytest-parametrization-to-override-the-default-valued-fixtures).
As your test suite get's more complex migrate to [pytest-case](pytest_cases.md)."

Let's say you're running along merrily with some fixtures that create database
objects for you:

```python
@pytest.fixture
def supplier(db):
    s = Supplier(
        ref=random_ref(),
        name=random_name(),
        country="US",
    )
    db.add(s)
    yield s
    db.remove(s)


@pytest.fixture()
def product(db, supplier):
    p = Product(
        ref=random_ref(),
        name=random_name(),
        supplier=supplier,
        net_price=9.99,
    )
    db.add(p)
    yield p
    db.remove(p)
```

And now you're writing a new test and you suddenly realize you need to customize
your default "supplier" fixture:

```python
def test_US_supplier_has_total_price_equal_net_price(product):
    assert product.total_price == product.net_price

def test_EU_supplier_has_total_price_including_VAT(supplier, product):
    supplier.country = "FR" # oh, this doesn't work
    assert product.total_price == product.net_price * 1.2
```

There are different ways to modify your fixtures

### Add more fixtures

We can just create more fixtures, and try to do a bit of DRY by extracting out
common logic:

```python
def _default_supplier():
    return Supplier(
        ref=random_ref(),
        name=random_name(),
    )

@pytest.fixture
def us_supplier(db):
    s = _default_supplier()
    s.country = "US"
    db.add(s)
    yield s
    db.remove(s)

@pytest.fixture
def eu_supplier(db):
    s = _default_supplier()
    s.country = "FR"
    db.add(s)
    yield s
    db.remove(s)
```

That's just one way you could do it, maybe you can figure out ways to reduce the
duplication of the `db.add()` stuff as well, but you are going to have
a different, named fixture for each customization of Supplier, and eventually
you may decide that doesn't scale.

### Use factory fixtures

Instead of a fixture returning an object directly, it can return a function that
creates an object, and that function can take arguments:

```python
@pytest.fixture
def make_supplier(db):
    s = Supplier(
        ref=random_ref(),
        name=random_name(),
    )

    def _make_supplier(country):
        s.country = country
        db.add(s)
        return s

    yield _make_supplier
    db.remove(s)
```

The problem with this is that, once you start, you tend to have to go all the
way, and make all of your fixture hierarchy into factory functions:

```python
def test_EU_supplier_has_total_price_including_VAT(make_supplier, product):
    supplier = make_supplier(country="FR")
    product.supplier = supplier # OH, now this doesn't work, because it's too late again
    assert product.total_price == product.net_price * 1.2
```

And so...

```python
@pytest.fixture
def make_product(db):
    p = Product(
        ref=random_ref(),
        name=random_name(),
    )

    def _make_product(supplier):
        p.supplier = supplier
        db.add(p)
        return p

    yield _make_product
    db.remove(p)

def test_EU_supplier_has_total_price_including_VAT(make_supplier, make_product):
    supplier = make_supplier(country="FR")
    product = make_product(supplier=supplier)
    assert product.total_price == product.net_price * 1.2
```

That works, but firstly now everything is a factory-fixture, which makes them
more convoluted, and secondly, your tests are filling up with extra calls to
`make_things`, and you're having to embed some of the domain knowledge of
what-depends-on-what into your tests as well as your fixtures. Ugly!

### Parametrize your fixtures

You can also [parametrize your
fixtures](pytest_parametrized_testing.md#parametrize-the-fixtures).

```python
@pytest.fixture(params=['US', 'FR'])
def supplier(db, request):
    s = Supplier(
        ref=random_ref(),
        name=random_name(),
        country=request.param
    )
    db.add(s)
    yield s
    db.remove(s)
```

Now any test that depends on supplier, directly or indirectly, will be run
twice, once with `supplier.country = US` and once with `FR`.

That's really cool for checking that a given piece of logic works in a variety
of different cases, but it's not really ideal in our case. We have to build
a bunch of if logic into our tests:

```python
def test_US_supplier_has_no_VAT_but_EU_supplier_has_total_price_including_VAT(product):
    # this test is magically run twice, but:
    if product.supplier.country == 'US':
        assert product.total_price == product.net_price
    if product.supplier.country == 'FR':
        assert product.total_price == product.net_price * 1.2
```

So that's ugly, and on top of that, now every single test that depends
(indirectly) on supplier gets run twice, and some of those extra test runs may
be totally irrelevant to what the country is.

### Use pytest parametrization to override the default valued fixtures

We introduce an extra fixture that holds a default value for the country field:

```python
@pytest.fixture()
def country():
    return "US"


@pytest.fixture
def supplier(db, country):
    s = Supplier(
        ref=random_ref(),
        name=random_name(),
        country=country,
    )
    db.add(s)
    yield s
    db.remove(s)
```

And then in the tests that need to change it, we can use parametrize to override
the default value of country, even though the country fixture isn't explicitly
named in that test:

```python
@pytest.mark.parametrize('country', ["US"])
def test_US_supplier_has_total_price_equal_net_price(product):
    assert product.total_price == product.net_price

@pytest.mark.parametrize('country', ["EU"])
def test_EU_supplier_has_total_price_including_VAT(product):
    assert product.total_price == product.net_price * 1.2
```

The only problem is that you're now likely to build a implicit dependencies
where the only way to find out what's actually happening is to spend ages
spelunking in conftest.py.

### Use pytest-case

[pytest-case](pytest_cases.md) gives a lot of power when it comes to tweaking the
fixtures and parameterizations.

Check that file for further information.

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

# [Marks](https://docs.pytest.org/en/stable/mark.html)

Pytest marks can be used to group tests. It can be useful to:

`slow`
: Mark the tests that are slow.

`secondary`
: Mart the tests that use functionality that is being tested in the same file.

To mark a test, use the `@pytest.mark` decorator. For example:

```python
@pytest.mark.slow
def test_really_slow_test():
    pass
```

Pytest requires you to register your marks, do so in the `pytest.ini` file

```ini
[pytest]
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    secondary: mark tests that use functionality tested in the same file (deselect with '-m "not secondary"')
```

# Snippets

## [Mocking sys.exit](https://medium.com/python-pandemonium/testing-sys-exit-with-pytest-10c6e5f7726f)

```python
with pytest.raises(SystemExit):
    # Code to test
```

## Testing exceptions with pytest

```python

def test_value_error_is_raised():
    with pytest.raises(ValueError, match="invalid literal for int() with base 10: 'a'"):
        int('a')
```

## [Excluding code from coverage](https://coverage.readthedocs.io/en/coverage-4.3.3/excluding.html)

You may have code in your project that you know won’t be executed, and you want
to tell `coverage.py` to ignore it. For example, if you have some code in
abstract classes that is going to be tested on the subclasses, you can ignore it
with `# pragma: no cover`.


# [Running tests in parallel](https://pypi.org/project/pytest-xdist/)

`pytest-xdist` makes it possible to run the tests in parallel, useful when the
test suit is large or when the tests are slow.

## Installation

```bash
pip install pytest-xdist
```

## Usage

```bash
pytest -n 4
```

It will run the tests with `4` workers. If you use `auto` it will adapt the
number of workers to the number of CPUS, or 1 if you use `--pdb`.

To configure it in the `pyproject.toml` use the `addopts`

```ini
[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-vv --tb=short -n auto"
```

# pytest integration with Vim

Integrating pytest into your Vim workflow enhances your productivity while
writing code, thus making it easier to code using TDD.

I use [Janko-m's Vim-test plugin](https://github.com/janko-m/vim-test) (which
can be installed through [Vundle](https://github.com/VundleVim/Vundle.vim)) with the
following configuration.

```vim
nmap <silent> t :TestNearest --pdb<CR>
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

As you can see only the `t` has the `--pdb` flag, so the rest of them will run
en parallel and any pdb trace will fail.


# Reference

* Book [Python Testing with pytest by Brian Okken](https://www.oreilly.com/library/view/python-testing-with/9781680502848/).
* [Docs](https://docs.pytest.org/en/latest/)

* [Vim-test plugin](https://github.com/janko-m/vim-test)
