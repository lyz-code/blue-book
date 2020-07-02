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

## Parametrized testing

Parametrized testing is a way to send multiple sets of data through the same
test and have pytest report if any of the sets failed.

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
### [Parametrize fixture arguments](https://docs.pytest.org/en/latest/example/parametrize.html#apply-indirect-on-particular-arguments)
Sometimes is interesting to parametrize the arguments of a fixture. For example,
imagine that we've got two fixtures to generate test data, then when the test is
run, it must call the correct fixture for each case.

```python
@pytest.fixture
def insert_task():
    task = factories.TaskFactory.create()

    session.execute(
        'INSERT INTO task (id, description, state, type)'
        'VALUES ('
        f'"{task.id}", "{task.description}", "{task.state}", "task"'
        ')'
    )

    return task


@pytest.fixture
def insert_project(session):
    project = factories.ProjectFactory.create()

    session.execute(
        'INSERT INTO project (id, description)'
        f'VALUES ("{project.id}", "{project.description}")'
    )

    return project
```

We can create a fixture that uses both and returns the correct one based on an
argument that is given.

```python
@pytest.fixture
def insert_object(
    request,
    insert_task,
    insert_project
):
    if request.param == 'insert_task':
        return insert_task
    elif request.param == 'insert_project':
        return insert_project

@pytest.mark.parametrize(
    'table,insert_object',
    [
        ('task', 'insert_task'),
        ('project', 'insert_project'),
    ]
    models_to_try,
    indirect=['insert_object'],
)
def test_repository_can_retrieve_an_object(
    self,
    session,
    table,
    insert_object,
):
    expected_obj = insert_object

    repo = repository.SqlAlchemyRepository(session)
    retrieved_obj = repo.get(table, expected_obj.id)

    assert retrieved_obj == expected_obj
    # Task.__eq__ only compares reference
    assert retrieved_obj.description == expected_obj.description
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
