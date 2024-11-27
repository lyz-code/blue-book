---
title: Pytest cases
date: 20201010
author: Lyz
---

[pytest-cases](https://smarie.github.io/python-pytest-cases/) is a pytest plugin
that allows you to *separate your test cases from your test functions*.

In addition, `pytest-cases` provides [several useful
goodies](https://smarie.github.io/python-pytest-cases/pytest_goodies/) to
empower `pytest`. In particular it improves the fixture mechanism to support
"fixture unions". This is a major change in the internal `pytest` engine,
unlocking many possibilities such as using fixture references as parameter
values in a test function.

# [Installing](https://smarie.github.io/python-pytest-cases/#installing)

```bash
pip install pytest_cases
```

!!! note ""
    Installing pytest-cases has effects on the order of `pytest` tests execution,
    even if you do not use its features. One positive side effect is that it fixed
    [pytest#5054](https://github.com/pytest-dev/pytest/issues/5054). But if you see
    less desirable ordering please [report
    it](https://github.com/smarie/python-pytest-cases/issues).

# [Why `pytest-cases`?](https://smarie.github.io/python-pytest-cases/#why-pytest-cases)

Let's consider the following `foo` function under test, located in `example.py`:

```python
def foo(a, b):
    return a + 1, b + 1
```

If we were using plain `pytest` to test it with various inputs, we would create
a `test_foo.py` file and use `@pytest.mark.parametrize`:

```python
import pytest
from example import foo

@pytest.mark.parametrize("a,b", [(1, 2), (-1, -2)])
def test_foo(a, b):
    # check that foo runs correctly and that the result is a tuple.
    assert isinstance(foo(a, b), tuple)
```

This is the fastest and most compact thing to do when you have a few number of
test cases, that do not require code to generate each test case.

Now imagine that instead of `(1, 2)` and `(-1, -2)` each of our test cases:

* Requires a few lines of code to be generated.
* Requires documentation to explain the other developers the intent of that
    precise test case.
* Requires external resources (data files on the filesystem, databases...),
    with a variable number of cases depending on what is available on the
    resource.
* Requires a readable `id`, such as
    `'uniformly_sampled_nonsorted_with_holes'` for the above example. Of course
    we *could* use
    [`pytest.param`](https://docs.pytest.org/en/stable/example/parametrize.html#set-marks-or-test-id-for-individual-parametrized-test)
    or
    [`ids=<list>`](https://docs.pytest.org/en/stable/example/parametrize.html#different-options-for-test-ids)
    but that is "a pain to maintain" according to `pytest` doc. Such a design
    does not feel right as the id is detached from the case.

With standard `pytest` there is no particular pattern to simplify your life
here. Investigating a little bit, people usually end up trying to mix parameters
and fixtures and asking this kind of question:
[so1](https://stackoverflow.com/questions/50231627/python-pytest-unpack-fixture),
[so2](https://stackoverflow.com/questions/50482416/use-pytest-lazy-fixture-list-values-as-parameters-in-another-fixture).
But by design it is not possible to solve this problem using fixtures, because
`pytest` [does not handle "unions" of
fixtures](https://smarie.github.io/python-pytest-cases/unions_theory/).

There is also an example in `pytest` doc [with a `metafunc`
hook](https://docs.pytest.org/en/stable/example/parametrize.html#a-quick-port-of-testscenarios).

The issue with such workarounds is that you can do *anything*. And *anything* is
a bit too much: this does not provide any convention / "good practice" on how to
organize test cases, which is an open door to developing ad-hoc unreadable or
unmaintainable solutions.

`pytest_cases` was created to provide an answer to this precise situation. It
proposes a simple framework to separate test cases from test functions. The test
cases are typically located in a separate "companion" file:

* `test_foo.py` is your usual test file containing the test *functions* (named
    `test_<id>`).
* `test_foo_cases.py` contains the test *cases*, that are also functions. Note: an
    alternate file naming style `cases_foo.py` is also available if you prefer
    it.

# [Basic usage](https://smarie.github.io/python-pytest-cases/#basic-usage)

## [Case functions](https://smarie.github.io/python-pytest-cases/#a-case-functions)

Let's create a `test_foo_cases.py` file. This file will contain *test cases
generator functions*, that we will call *case functions* for brevity. In these
functions, you will typically either parse some test data files, generate some
simulated test data, expected results, etc.

!!! note "File: test_foo_cases.py"

    ```python
    def case_two_positive_ints():
        """ Inputs are two positive integers """
        return 1, 2

    def case_two_negative_ints():
        """ Inputs are two negative integers """
        return -1, -2
    ```

Case functions can return anything that is considered useful to run the
associated test. You can use all classic pytest mechanism on case functions (id
customization, skip/fail marks, parametrization or fixtures injection).

## [Test functions](https://smarie.github.io/python-pytest-cases/#b-test-functions)

As usual we write our `pytest` test functions starting with `test_`, in
a `test_foo.py` file. The only difference is that we now decorate it with
`@parametrize_with_cases` instead of `@pytest.mark.parametrize` as we were doing
previously:

!!! note "File: test_foo.py"

    ```python
    from example import foo
    from pytest_cases import parametrize_with_cases

    @parametrize_with_cases("a,b")
    def test_foo(a, b):
        # check that foo runs correctly and that the result is a tuple.
        assert isinstance(foo(a, b), tuple)
    ```

Executing `pytest` will now run our test function once for every case function:

```bash
>>> pytest -s -v
============================= test session starts =============================
(...)
<your_project>/tests/test_foo.py::test_foo[two_positive_ints] PASSED [ 50%]
<your_project>/tests/test_foo.py::test_foo[two_negative_ints] PASSED [ 100%]

========================== 2 passed in 0.24 seconds ==========================
```

# Usage

## [Cases collection](https://smarie.github.io/python-pytest-cases/#a-cases-collection)

### [Alternate source(s)](https://smarie.github.io/python-pytest-cases/#alternate-sources)

It is not mandatory that case functions should be in a different file than the
test functions: both can be in the same file. For this you can use `cases='.'`
or `cases=THIS_MODULE` to refer to the module in which the test function is
located:

```python
from pytest_cases import parametrize_with_cases

def case_one_positive_int():
    return 1

def case_one_negative_int():
    return -1

@parametrize_with_cases("i", cases='.')
def test_with_this_module(i):
    assert i == int(i)
```

!!! warning ""

    Only the case functions defined BEFORE the test function in the module file
    will be taken into account.

`@parametrize_with_cases(cases=...)` also accepts explicit list of case
functions, classes containing case functions, and modules. See [API
Reference](https://smarie.github.io/python-pytest-cases/api_reference/#parametrize_with_cases)
for details. A typical way to organize cases is to use classes for example:

```python
from pytest_cases import parametrize_with_cases

class Foo:
    def case_a_positive_int(self):
        return 1

    def case_another_positive_int(self):
        return 2

@parametrize_with_cases("a", cases=Foo)
def test_foo(a):
    assert a > 0
```

Note that as for `pytest`, `self` is recreated for every test and therefore
should not be used to store any useful information.

### [Alternate prefix](https://smarie.github.io/python-pytest-cases/#alternate-prefix)

`case_` might not be your preferred prefix, especially if you wish to store in
the same module or class various kind of case data.  `@parametrize_with_cases`
offers a `prefix=...` argument to select an alternate prefix for your case
functions. That way, you can store in the same module or class case
functions as diverse as datasets (e.g. `data_`), user descriptions (e.g.
`user_`), algorithms or machine learning models (e.g. `model_` or `algo_`), etc.

```python
from pytest_cases import parametrize_with_cases, parametrize

def data_a():
    return 'a'

@parametrize("hello", [True, False])
def data_b(hello):
    return "hello" if hello else "world"

def case_c():
    return dict(name="hi i'm not used")

def user_bob():
    return "bob"

@parametrize_with_cases("data", cases='.', prefix="data_")
@parametrize_with_cases("user", cases='.', prefix="user_")
def test_with_data(data, user):
    assert data in ('a', "hello", "world")
    assert user == 'bob'
```

Yields

```
test_doc_filters_n_tags.py::test_with_data[bob-a]       PASSED [ 33%]
test_doc_filters_n_tags.py::test_with_data[bob-b-True]   PASSED [ 66%]
test_doc_filters_n_tags.py::test_with_data[bob-b-False]   PASSED [ 100%]
```

### [Filters and tags](https://smarie.github.io/python-pytest-cases/#filters-and-tags)

The easiest way to select only a subset of case functions in a module or
a class, is to specify a custom `prefix` instead of the default one (`'case_'`).

However sometimes more advanced filtering is required. In that case, you can
also rely on three additional mechanisms provided in `@parametrize_with_cases`:

* The `glob` argument can contain a glob-like pattern for case ids. This can
    become handy to separate for example good or bad cases, the latter returning
    an expected error type and/or message for use with `pytest.raises` or with
    our alternative
    [`assert_exception`](https://smarie.github.io/python-pytest-cases/pytest_goodies/#assert_exception).

    ```python
    from math import sqrt
    import pytest
    from pytest_cases import parametrize_with_cases


    def case_int_success():
        return 1

    def case_negative_int_failure():
        # note that we decide to return the expected type of failure to check it
        return -1, ValueError, "math domain error"


    @parametrize_with_cases("data", cases='.', glob="*success")
    def test_good_datasets(data):
        assert sqrt(data) > 0

    @parametrize_with_cases("data, err_type, err_msg", cases='.', glob="*failure")
    def test_bad_datasets(data, err_type, err_msg):
        with pytest.raises(err_type, match=err_msg):
            sqrt(data)
    ```


* The `has_tag` argument allows you to filter cases based on tags set on case
    functions using the `@case` decorator. See API reference of
    [`@case`](https://smarie.github.io/python-pytest-cases/api_reference/#case) and
    [`@parametrize_with_cases`](https://smarie.github.io/python-pytest-cases/api_reference/#parametrize_with_cases).


    ```python
    from pytest_cases import parametrize_with_cases, case

    class FooCases:
        def case_two_positive_ints(self):
            return 1, 2

        @case(tags='foo')
        def case_one_positive_int(self):
            return 1

    @parametrize_with_cases("a", cases=FooCases, has_tag='foo')
    def test_foo(a):
        assert a > 0
    ```

* Finally if none of the above matches your expectations, you can provide
    a callable to `filter`. This callable will receive each collected case
    function and should return `True` in case of success. Note that your
    function can leverage the `_pytestcase` attribute available on the case
    function to read the tags, marks and id found on it.

    ```python
    @parametrize_with_cases("data", cases='.',
                            filter=lambda cf: "success" in cf._pytestcase.id)
    def test_good_datasets2(data):
        assert sqrt(data) > 0
    ```
## [Pytest marks (`skip`, `xfail`...) on cases](https://smarie.github.io/python-pytest-cases/#pytest-marks-skip-xfail)

pytest marks such as `@pytest.mark.skipif` can be applied on case functions the
same way [as with test
functions](https://docs.pytest.org/en/stable/skipping.html).

```python
import sys
import pytest

@pytest.mark.skipif(sys.version_info < (3, 0), reason="Not useful on python 2")
def case_two_positive_ints():
    return 1, 2
```

## [Case generators](https://smarie.github.io/python-pytest-cases/#case-generators)

In many real-world usage we want to generate one test case *per* `<something>`.
The most intuitive way would be to use a `for` loop to create the case
functions, and to use the `@case` decorator to set their names ; however this
would not be very readable.

Instead, case functions can be parametrized the same way [as with test
functions](https://docs.pytest.org/en/stable/parametrize.html): simply add the
parameter names as arguments in their signature and decorate with
`@pytest.mark.parametrize`. Even better, you can use the enhanced
[`@parametrize`](https://smarie.github.io/python-pytest-cases/api_reference/#parametrize)
from `pytest-cases` so as to benefit from its additional usability features:

```python
from pytest_cases import parametrize, parametrize_with_cases

class CasesFoo:
    def case_hello(self):
        return "hello world"

    @parametrize(who=('you', 'there'))
    def case_simple_generator(self, who):
        return "hello %s" % who


@parametrize_with_cases("msg", cases=CasesFoo)
def test_foo(msg):
    assert isinstance(msg, str) and msg.startswith("hello")
```

Yields

```
test_generators.py::test_foo[hello] PASSED               [ 33%]
test_generators.py::test_foo[simple_generator-who=you] PASSED [ 66%]
test_generators.py::test_foo[simple_generator-who=there] PASSED [100%]
```

## [Cases requiring fixtures](https://smarie.github.io/python-pytest-cases/#cases-requiring-fixtures)

Cases can use fixtures the same way as [test functions
do](https://docs.pytest.org/en/stable/fixture.html#fixtures-as-function-arguments):
simply add the fixture names as arguments in their signature and make sure the
fixture exists either in the same module, or in
a [`conftest.py`](https://docs.pytest.org/en/stable/fixture.html?highlight=conftest.py#conftest-py-sharing-fixture-functions)
file in one of the parent packages. See [`pytest` documentation on sharing
fixtures](https://docs.pytest.org/en/stable/fixture.html?highlight=conftest.py#conftest-py-sharing-fixture-functions).

!!! warning "Use `@fixture` instead of `@pytest.fixture`"
    If a fixture is used by *some* of your cases only, then you *should* use the
    `@fixture` decorator from pytest-cases instead of the standard
    `@pytest.fixture`. Otherwise you fixture will be setup/teardown for all
    cases even those not requiring it. See [`@fixture`
    doc](https://smarie.github.io/python-pytest-cases/api_reference/#fixture).

```python
from pytest_cases import parametrize_with_cases, fixture, parametrize

@fixture(scope='session')
def db():
    return {0: 'louise', 1: 'bob'}

def user_bob(db):
    return db[1]

@parametrize(id=range(2))
def user_from_db(db, id):
    return db[id]

@parametrize_with_cases("a", cases='.', prefix='user_')
def test_users(a, db, request):
    print("this is test %r" % request.node.nodeid)
    assert a in db.values()
```

Yields

```
test_fixtures.py::test_users[a_is_bob]
test_fixtures.py::test_users[a_is_from_db-id=0]
test_fixtures.py::test_users[a_is_from_db-id=1]
```

## [Parametrize fixtures with cases](https://smarie.github.io/python-pytest-cases/#a-test-fixtures)

In some scenarios you might wish to parametrize a fixture with the cases, rather
than the test function. For example:

* To inject the same test cases in several test functions without
    duplicating the `@parametrize_with_cases` decorator on each of them.
* To generate the test cases once for the whole session, using
    a `scope='session'` fixture or [another
    scope](https://docs.pytest.org/en/stable/fixture.html#scope-sharing-a-fixture-instance-across-tests-in-a-class-module-or-session).
* To modify the test cases, log some message, or perform some other action
    before injecting them into the test functions, and/or after executing the
    test function (thanks to [yield
    fixtures](https://docs.pytest.org/en/stable/fixture.html#fixture-finalization-executing-teardown-code)).

For this, simply use `@fixture` from `pytest_cases` instead of `@pytest.fixture`
to define your fixture. That allows your fixtures to be easily parametrized with
`@parametrize_with_cases`, `@parametrize`, and even `@pytest.mark.parametrize`.

```python
from pytest_cases import fixture, parametrize_with_cases

@fixture
@parametrize_with_cases("a,b")
def c(a, b):
    return a + b

def test_foo(c):
    assert isinstance(c, int)
```

# [Pytest-cases internals](https://smarie.github.io/python-pytest-cases/pytest_goodies/)

## [`@fixture`](https://smarie.github.io/python-pytest-cases/pytest_goodies/#fixture)

`@fixture` is similar to `pytest.fixture` but without its `param` and `ids`
arguments. Instead, it is able to pick the parametrization from
`@pytest.mark.parametrize` marks applied on fixtures. This makes it very
intuitive for users to parametrize both their tests and fixtures.

Finally it now supports unpacking, see [unpacking feature](#unpack_fixture-unpack_into).

!!! note "`@fixture` deprecation if/when `@pytest.fixture` supports `@pytest.mark.parametrize`"
    The ability for pytest fixtures to support the `@pytest.mark.parametrize`
    annotation is a feature that clearly belongs to `pytest` scope, and has been
    [requested already](https://github.com/pytest-dev/pytest/issues/3960). It is
    therefore expected that `@fixture` will be deprecated in favor of
    `@pytest_fixture` if/when the `pytest` team decides to add the proposed
    feature. As always, deprecation will happen slowly across versions (at least
    two minor, or one major version update) so as for users to have the time to
    update their code bases.

### [`unpack_fixture` / `unpack_into`](https://smarie.github.io/python-pytest-cases/pytest_goodies/#unpack_fixture-unpack_into)

In some cases fixtures return a tuple or a list of items. It is not easy to
refer to a single of these items in a test or another fixture. With
`unpack_fixture` you can easily do it:

```python
import pytest
from pytest_cases import unpack_fixture, fixture

@fixture
@pytest.mark.parametrize("o", ['hello', 'world'])
def c(o):
    return o, o[0]

a, b = unpack_fixture("a,b", c)

def test_function(a, b):
    assert a[0] == b
```

Note that you can also use the `unpack_into=` argument of `@fixture` to do the
same thing:

```python
import pytest
from pytest_cases import fixture

@fixture(unpack_into="a,b")
@pytest.mark.parametrize("o", ['hello', 'world'])
def c(o):
    return o, o[0]

def test_function(a, b):
    assert a[0] == b
```

And it is also available in `fixture_union`:

```python
import pytest
from pytest_cases import fixture, fixture_union

@fixture
@pytest.mark.parametrize("o", ['hello', 'world'])
def c(o):
    return o, o[0]

@fixture
@pytest.mark.parametrize("o", ['yeepee', 'yay'])
def d(o):
    return o, o[0]

fixture_union("c_or_d", [c, d], unpack_into="a, b")

def test_function(a, b):
    assert a[0] == b
```

### `param_fixture[s]`

If you wish to share some parameters across several fixtures and tests, it might
be convenient to have a fixture representing this parameter. This is relatively
easy for single parameters, but a bit harder for parameter tuples.

The two utilities functions `param_fixture` (for a single parameter name) and
`param_fixtures` (for a tuple of parameter names) handle the difficulty for
you:

```python
import pytest
from pytest_cases import param_fixtures, param_fixture

# create a single parameter fixture
my_parameter = param_fixture("my_parameter", [1, 2, 3, 4])

@pytest.fixture
def fixture_uses_param(my_parameter):
    ...

def test_uses_param(my_parameter, fixture_uses_param):
    ...

# -----
# create a 2-tuple parameter fixture
arg1, arg2 = param_fixtures("arg1, arg2", [(1, 2), (3, 4)])

@pytest.fixture
def fixture_uses_param2(arg2):
    ...

def test_uses_param2(arg1, arg2, fixture_uses_param2):
    ...
```

### `fixture_union`

As of `pytest` 5, it is not possible to create a "union" fixture, i.e.
a parametrized fixture that would first take all the possible values of fixture
A, then all possible values of fixture B, etc. Indeed all fixture dependencies
of each test node are grouped together, and if they have parameters a big
"cross-product" of the parameters is done by `pytest`.

```python
from pytest_cases import fixture, fixture_union

@fixture
def first():
    return 'hello'

@fixture(params=['a', 'b'])
def second(request):
    return request.param

# c will first take all the values of 'first', then all of 'second'
c = fixture_union('c', [first, second])

def test_basic_union(c):
    print(c)
```

yields

```
<...>::test_basic_union[c_is_first] hello   PASSED
<...>::test_basic_union[c_is_second-a] a    PASSED
<...>::test_basic_union[c_is_second-b] b    PASSED
```

# References

* [Docs](https://smarie.github.io/python-pytest-cases/)
* [Git](https://github.com/smarie/python-pytest-cases/)
