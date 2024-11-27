---
title: Python parametrized testing
date: 20201010
author: Lyz
---

Parametrization is a process of running the same test with varying sets of data.
Each combination of a test and data is counted as a new test case.

There are multiple ways to parametrize your tests, each differs in complexity
and flexibility.

## Parametrize the test

The most simple form of parametrization is at test level:

```python
@pytest.mark.parametrize("number", [1, 2, 3, 0, 42])
def test_foo(number):
    assert number > 0
```

In this case we are getting five tests: for number 1, 2, 3, 0 and 42. Each of
those tests can fail independently of one another (if in this example the test
with 0 will fail, and four others will pass).

## Parametrize the fixtures

Fixtures may have parameters. Those parameters are passed as a list to the
argument `params` of `@pytest.fixture()` decorator.

Those parameters must be iterables, such as lists. Each parameter to a fixture
is applied to each function using this fixture. If a few fixtures are used in
one test function, pytest generates a Cartesian product of parameters of those
fixtures.

To use those parameters, a fixture must consume a special fixture named
`request`. It provides the special (built-in) fixture with some information on
the function it deals with. `request` also contains `request.param` which
contains one element from `params`. The fixture called as many times as the
number of elements in the iterable of `params` argument, and the test function
is called with values of fixtures the same number of times. (basically, the
fixture is called `len(iterable)` times with each next element of iterable in
the `request.param`).

```python
@pytest.fixture(params=["one", "uno"])
def fixture1(request):
    return request.param

@pytest.fixture(params=["two", "duo"])
def fixture2(request):
    return request.paramdef test_foobar(fixture1, fixture2):
    assert type(fixture1) == type(fixture2)
```

The output is:

```
#OUTPUT 3
collected 4 itemstest_3.py::test_foobar[one-two] PASSED  [ 25%]
test_3.py::test_foobar[one-duo] PASSED  [ 50%]
test_3.py::test_foobar[uno-two] PASSED  [ 75%]
test_3.py::test_foobar[uno-duo] PASSED  [100%]
```

## Parametrization with `pytest_generate_tests`

There is an another way to generate arbitrary parametrization at collection
time. It’s a bit more direct and verbose, but it provides introspection of test
functions, including the ability to see all other fixture names.

At collection time Pytest looks up for and calls (if found) a special function
in each module, named `pytest_generate_tests`. This function is not a fixture,
but just a regular function. It receives the argument `metafunc`, which itself
is not a fixture, but a special object.

`pytest_generate_tests` is called for each test function in the module to give
a chance to parametrize it. Parametrization may happen only through fixtures
that test function requests. There is no way to parametrize a test function like
this:

def test_simple():
   assert 2+2 == 4

You need some variables to be used as parameters, and those variables should be
arguments to the test function. Pytest will replace those arguments with values
from fixtures, and if there are a few values for a fixture, then this is
parametrization at work.

`metafunc` argument to `pytest_generate_tests` provides some useful information
on a test function:

* Ability to see all fixture names that function requests.
* Ability to see the name of the function.
* Ability to see code of the function.

Finally, `metafunc` has a parametrize function, which is the way to provide
multiple variants of values for fixtures.

The same case as before written with the `pytest_generate_tests` function is:

```python
def pytest_generate_tests(metafunc):
    if "fixture1" in metafunc.fixturenames:
        metafunc.parametrize("fixture1", ["one", "uno"])
    if "fixture2" in metafunc.fixturenames:
        metafunc.parametrize("fixture2", ["two", "duo"])

def test_foobar(fixture1, fixture2):
    assert type(fixture1) == type(fixture2)
```

This solution is a little bit magical, so I'd avoid it in favor of pytest-cases.

## Use pytest-cases

[pytest-case](pytest_cases.md) gives a lot of power when it comes to tweaking the
fixtures and parameterizations.

Check that file for further information.

# Customizations

## Change the tests name

Sometimes you want to change how the tests are shown so you can understand
better what the test is doing. You can use the `ids` argument to
`pytest.mark.parametrize`.

!!! note "File tests/unit/test_func.py"
    ```python
    tasks_to_try = (
        Task('sleep', done=True),
        Task('wake', 'brian'),
        Task('wake', 'brian'),
        Task('breathe', 'BRIAN', True),
        Task('exercise', 'BrIaN', False),
    )

    task_ids = [
        f'Task({task.summary}, {task.owner}, {task.done})'
        for task in tasks_to_try
    ]

    @pytest.mark.parametrize('task', tasks_to_try, ids=task_ids)
    def test_add_4(task):
        task_id = tasks.add(task)
        t_from_db = tasks.get(task_id)
        assert equivalent(t_from_db, task)

    ```

```bash
$ pytest -v test_func.py::test_add_4
===================== test session starts ======================
collected 5 items

test_add_variety.py::test_add_4[Task(sleep,None,True)] PASSED
test_add_variety.py::test_add_4[Task(wake,brian,False)0] PASSED
test_add_variety.py::test_add_4[Task(wake,brian,False)1] PASSED
test_add_variety.py::test_add_4[Task(breathe,BRIAN,True)] PASSED
test_add_variety.py::test_add_4[Task(exercise,BrIaN,False)] PASSED

=================== 5 passed in 0.04 seconds ===================
```

Those identifiers can be used to run that specific test. For example `pytest -v
"test_func.py::test_add_4[Task(breathe,BRIAN,True)]"`.

`parametrize()` can be applied to classes as well.

If the test id can't be derived from the parameter value, use the `id` argument
for the `pytest.param`:

```python
@pytest.mark.parametrize('task', [
    pytest.param(Task('create'), id='just summary'),
    pytest.param(Task('inspire', 'Michelle'), id='summary/owner'),
])
def test_add_6(task):
    ...
```

Will yield:

```bash
$ pytest-v test_add_variety.py::test_add_6

=================== test session starts ====================
collected 2 items

test_add_variety.py::test_add_6[justsummary]PASSED
test_add_variety.py::test_add_6[summary/owner]PASSED

================= 2 passed in 0.05 seconds =================
```

# References

* [A deep dive into Pytest parametrization by George Shulkin](https://medium.com/opsops/deepdive-into-pytest-parametrization-cb21665c05b9)
* Book [Python Testing with pytest by Brian Okken](https://www.oreilly.com/library/view/python-testing-with/9781680502848/).
