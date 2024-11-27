---
title: GitPython
date: 20210210
author: Lyz
---

[GitPython](https://gitpython.readthedocs.io) is a python library used to
interact with git repositories, high-level like git-porcelain, or low-level like
git-plumbing.

It provides abstractions of git objects for easy access of repository data, and
additionally allows you to access the git repository more directly using either
a pure python implementation, or the faster, but more resource intensive git
command implementation.

The object database implementation is optimized for handling large quantities of
objects and large datasets, which is achieved by using low-level structures and
data streaming.

# [Installation](https://gitpython.readthedocs.io/en/stable/intro.html#installing-gitpython)

```bash
pip install GitPython
```

# Usage

## Initialize a repository

```python
from git import Repo

repo = Repo.init("path/to/initialize")
```

If you want to get the working directory of the `Repo` object use the
`working_dir` attribute.

## Load a repository

```python
from git import Repo

repo = Repo("existing/git/repo/path")
```

## [Clone a repository](https://stackoverflow.com/questions/2472552/python-way-to-clone-a-git-repository)

```python
from git import Repo

Repo.clone_from(git_url, repo_dir)
```

## [Make a commit](https://gitpython.readthedocs.io/en/stable/tutorial.html#the-index-object)

Given a `repo` object:

```python
index = repo.index

# add the changes
index.add(["README.md"])

from git import Actor

author = Actor("An author", "author@example.com")
committer = Actor("A committer", "committer@example.com")
# commit by commit message and author and committer
index.commit("my commit message", author=author, committer=committer)
```

### Change commit date

When [building fake data](#build-fake-data), creating commits in other points in
time is useful.

```python
import datetime
from dateutil import tz

commit_date = (datetime.datetime(2020, 2, 2, tzinfo=tz.tzlocal()),)

index.commit(
    "my commit message",
    author=author,
    committer=committer,
    author_date=commit_date,
    commit_date=commit_date,
)
```

## [Inspect the history](https://gitpython.readthedocs.io/en/stable/tutorial.html#examining-references)

You first need to select the branch you want to inspect. To use the default
repository branch use `head.reference`.

```python
repo.head.reference
```

Then you can either get all the `Commit` objects of that reference, or inspect
the log.

### [Get all commits of a branch](https://stackoverflow.com/questions/18502729/finding-the-first-commit-on-a-branch-with-gitpython)

```python
[commit for commit in repo.iter_commits(rev=repo.head.reference)]
```

It gives you a List of commits where the first element is the last commit in
time.

### Inspect the log

Inspect it with the `repo.head.reference.log()`, which contains a list of
`RefLogEntry` objects that have the interesting attributes:

- `actor`: Actor object of the author of the commit
- `time`: The commit timestamp, to load it as a datetime object use the
  `datetime.datetime.fromtimestamp` method
- `message`: Message as a string.

## [Create a branch](https://gitpython.readthedocs.io/en/stable/tutorial.html#advanced-repo-usage)

```python
new_branch = repo.create_head("new_branch")
assert repo.active_branch != new_branch  # It's not checked out yet
repo.head.reference = new_branch
assert not repo.head.is_detached
```

## Get the latest commit of a repository

```python
repo.head.object.hexsha
```

# Testing

There is no testing functionality, you need to either Mock, build fake data or
fake adapters.

## Build fake data

Create a `test_data` directory in your testing directory with the contents of
the git repository you want to test. Don't initialize it, we'll create a `repo`
fixture that does it. Assuming that the data is in `tests/assets/test_data`:

File `tests/conftest.py`:

```python
import shutil

import pytest
from git import Repo


@pytest.fixture(name="repo")
def repo_(tmp_path: Path) -> Repo:
    """Create a git repository with fake data and history.

    Args:
        tmp_path: Pytest fixture that creates a temporal Path
    """
    # Copy the content from `tests/assets/test_data`.
    repo_path = tmp_path / "test_data"
    shutil.copytree("tests/assets/test_data", repo_path)

    # Initializes the git repository.
    return Repo.init(repo_path)
```

On each test you can add the commits that you need for your use case.

```python
author = Actor("An author", "author@example.com")
committer = Actor("A committer", "committer@example.com")


@pytest.mark.freeze_time("2021-02-01T12:00:00")
def test_repo_is_not_empty(repo: Repo) -> None:
    commit_date = datetime.datetime(2021, 2, 1, tzinfo=tz.tzlocal())
    repo.index.add(["mkdocs.yml"])
    repo.index.commit(
        "Initial skeleton",
        author=author,
        committer=committer,
        author_date=commit_date,
        commit_date=commit_date,
    )

    assert not repo.bare
```

If you feel that the tests are too verbose, you can create a fixture with all
the commits done, and select each case with the
[freezegun pytest fixture](pytest.md#freezegun). In my opinion, it will make the
tests less clear though. The fixture can look like:

File: `tests/conftest.py`:

```python
import datetime
from dateutil import tz
import shutil
import textwrap

import pytest
from git import Actor, Repo


@pytest.fixture(name="full_repo")
def full_repo_(repo: Repo) -> Repo:
    """Create a git repository with fake data and history.

    Args:
        repo: an initialized Repo
    """
    index = repo.index
    author = Actor("An author", "author@example.com")
    committer = Actor("A committer", "committer@example.com")

    # Add a commit in time
    commit_date = datetime.datetime(2021, 2, 1, tzinfo=tz.tzlocal())
    index.add(["mkdocs.yml"])
    index.commit(
        "Initial skeleton",
        author=author,
        committer=committer,
        author_date=commit_date,
        commit_date=commit_date,
    )
```

Then you can use that fixture in any test:

```python
@pytest.mark.freeze_time("2021-02-01T12:00:00")
def test_assert_true(full_repo: Repo) -> None:
    assert not repo.bare
```

# References

- [Docs](https://gitpython.readthedocs.io)
- [Git](https://github.com/gitpython-developers/GitPython)
- [Tutorial](https://gitpython.readthedocs.io/en/stable/tutorial.html#tutorial-label)
