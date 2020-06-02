---
title: Python CI
date: 20200602
author: Lyz
---

[Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)
allows to automatically run processes on the code each time a commit is pushed.
For example it can be used to run the tests, build the documentation or build
a package.

# Run code tests with Github actions

To run the tests each time a push or pull request is created in Github, create
the `.github/workflows/pythonpackage.yml` file with the following Jinja
template.

Make sure to check:

* The correct Python versions are configured.
* The steps make sense to your case scenario.

Variables to substitute:

* `program_name`: your program name

```yaml
name: Python package

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      max-parallel: 3
      matrix:
        python-version: [3.6, 3.7]

    steps:
    - uses: actions/checkout@v1
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v1
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    - name: Lint with flake8
      run: |
        pip install flake8
        # stop the build if there are Python syntax errors or undefined names
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        # exit-zero treats all errors as warnings. The GitHub editor is 127 chars wide
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    - name: Test with pytest
      run: |
        pip install pytest pytest-cov
        python -m pytest --cov-report term-missing --cov {{ program_name }} tests
```

If you want to add a badge stating the last build status in your readme, use the
following template.

Variables to substitute:

* `repository_url`: Github repository url, like
    `https://github.com/lyz-code/pydo`.
~~~markdown
[![Actions
Status]({{ repository_url }}/workflows/Python%20package/badge.svg)]({{ repository_url }}/actions)
~~~
