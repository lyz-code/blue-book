---
title: Python CI
date: 20200602
author: Lyz
---

[Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)
(CI) allows to automatically run processes on the code each time a commit is
pushed.  For example it can be used to run the tests, build the documentation or
build a package.

There are three non exclusive ways to run the tests:

* Integrate them in your editor, so it's executed each time you save the file.
* Through a [pre-commit](https://github.com/pre-commit/pre-commit) hook to
    make it easy for the collaborator to submit correctly formatted code. pre-commit
    is a framework for managing and maintaining multi-language
    [pre-commit](https://pre-commit.com/) hooks.
* Through a
    ensure that all the collaborator submit correctly formatted code. pre-commit
    is a framework for managing and maintaining multi-language
* Through a CI server (like Drone or Github Actions) to ensure that the commited
    code meets the quality standards. Developers can bypass the pre-commit
    filter, so we need to set up the quality gate in an agnostic environment.

Depending on the time the test takes to run and their different implementations,
we'll choose from one to three of the choices above.

# Configuring pre-commit

To adopt `pre-commit` to our system we have to:

* Install pre-commit: `pip3 install pre-commit` and add it to the development
    `requirements.txt`.
* Define `.pre-commit-config.yaml` with the hooks you want to include.
* Execute `pre-commit install` to install git hooks in your `.git/` directory.
* Execute `pre-commit run --all-files` to tests all the files. Usually
    `pre-commit` will only run on the changed files during git hooks.

# Linting tests

## [Black](https://black.readthedocs.io/en/stable/)

Black is a style guide enforcement tool. Its configuration is stored in
`pyproject.toml`.

!!! note "File: pyproject.toml"
    ```ini
    # Example configuration for Black.

    # NOTE: you have to use single-quoted strings in TOML for regular expressions.
    # It's the equivalent of r-strings in Python.  Multiline strings are treated as
    # verbose regular expressions by Black.  Use [ ] to denote a significant space
    # character.

    [tool.black]
    line-length = 88
    target-version = ['py36', 'py37', 'py38']
    include = '\.pyi?$'
    exclude = '''
    /(
        \.eggs
      | \.git
      | \.hg
      | \.mypy_cache
      | \.tox
      | \.venv
      | _build
      | buck-out
      | build
      | dist
      # The following are specific to Black, you probably don't want those.
      | blib2to3
      | tests/data
      | profiling
    )/
    '''
    ```

Trigger hooks:

* [Vim plugin](vim_plugins.md#black).
* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://github.com/ambv/black
          rev: stable
          hooks:
            - id: black
              language_version: python3.7
        ```

* Github Actions:

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        name: Lint

        on: [push, pull_request]

        jobs:
          Black:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v2
              - uses: actions/setup-python@v2
              - name: Black
                uses: psf/black@stable
        ```

## [Flake8](https://flake8.pycqa.org/)

Flake8 is another style guide enforcement tool. Its
[configuration](https://flake8.pycqa.org/en/latest/user/configuration.html) is
stored in `setup.cfg`, `tox.ini` or `.flake8`.

!!! note "File: .flake8"
    ```ini
    [flake8]
    # ignore = E203, E266, E501, W503, F403, F401
    max-line-length = 88
    # max-complexity = 18
    # select = B,C,E,F,W,T4,B9
    ```

Trigger hooks:

* Pre-commit

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://gitlab.com/pycqa/flake8
          rev: master
          hooks:
            - id: flake8
        ```
* Github Actions

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        name: Lint

        on: [push, pull_request]

        jobs:
          Flake8:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v2
              - uses: actions/setup-python@v2
              - name: Flake8
                uses: cclauss/GitHub-Action-for-Flake8@v0.5.0
        ```

## [Mypy](http://mypy-lang.org/)

Mypy is an optional static type checker for Python that aims to combine the
benefits of dynamic (or "duck") typing and static typing. Mypy combines the
expressive power and convenience of Python with a powerful type system and
compile-time type checking.

Mypy configuration is saved in the `mypy.ini` file.

!!! note "File: mypy.ini"
    ```ini
    [mypy]
    ignore_missing_imports = False

    [mypy-alembic.*]
    ignore_missing_imports = True

    [mypy-argcomplete.*]
    ignore_missing_imports = True

    [mypy-factory.*]
    ignore_missing_imports = True

    [mypy-faker.*]
    ignore_missing_imports = True

    [mypy-pytest.*]
    ignore_missing_imports = True

    [mypy-sqlalchemy.*]
    ignore_missing_imports = True
    ```

Trigger hooks:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
        - repo: https://github.com/pre-commit/mirrors-mypy
          rev: v0.782
          hooks:
          - name: Run mypy static analysis tool
            id: mypy
        ```

* Github Actions:

    !!! note "File: .github/workflows/lint.yml"
        ```yaml
        name: Lint

        on: [push, pull_request]

        jobs:
          Mypy:
            runs-on: ubuntu-latest
            name: Mypy
            steps:
            - uses: actions/checkout@v1
            - name: Set up Python 3.7
              uses: actions/setup-python@v1
              with:
                python-version: 3.7
            - name: Install Dependencies
              run: pip install mypy
            - name: mypy
              run: mypy
        ```

## Other pre-commit tests

Pre-commit comes with several tests by default. These are the ones I've chosen.

!!! note "File: .pre-commit-config.yaml"
    ```yaml
    repos:
    - repo: https://github.com/pre-commit/pre-commit-hooks
      rev: v3.1.0
      hooks:
        - id: trailing-whitespace
        - id: check-added-large-files
        - id: check-docstring-first
        - id: check-merge-conflict
        - id: end-of-file-fixer
        - id: detect-private-key
    ```

Test yaml syntax

!!! note "File: .pre-commit-config.yaml"
    ```yaml
    - repo: https://github.com/adrienverge/yamllint
      rev: v1.21.0
      hooks:
        - id: yamllint
    ```

# Unit, integration, end-to-end, edge-to-edge tests

These tests define the behaviour of the application.

Trigger hooks:

* Github Actions: To run the tests each time a push or pull request is created in Github, create
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

# Security tests

## [Safety](https://github.com/pyupio/safety)

Safety checks your installed dependencies for known security vulnerabilities.

Trigger hooks:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
            - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
              rev: v1.1.3
              hooks:
              - id: python-safety-dependencies-check
        ```

* Github Actions: Make sure to check that the correct python version is applied.

    !!! note "File: .github/workflows/security.yml"
        ```yaml
        name: Security

        on: [push, pull_request]

        jobs:
          safety:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout
                uses: actions/checkout@v2
              - uses: actions/setup-python@v2
                with:
                  python-version: 3.7
              - name: Install dependencies
                run: pip install safety
              - name: Execute safety
                run: safety check
        ```

## [Bandit](https://bandit.readthedocs.io/en/latest/)

Safety finds common security issues in Python code. To do this, Bandit processes
each file, builds an AST from it, and runs appropriate plugins against the AST
nodes. Once Bandit has finished scanning all the files, it generates
a report.

Trigger hooks:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
            - repo: https://github.com/Lucas-C/pre-commit-hooks-bandit
              rev: v1.0.4
              hooks:
              - id: python-bandit-vulnerability-check
        ```

* Github Actions: Make sure to check that the correct python version is applied.

    !!! note "File: .github/workflows/security.yml"
        ```yaml
        name: Security

        on: [push, pull_request]

        jobs:
          bandit:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout
                uses: actions/checkout@v2
              - uses: actions/setup-python@v2
                with:
                  python-version: 3.7
              - name: Install dependencies
                run: pip install bandit
              - name: Execute bandit
                run: bandit -r project
        ```
## [Update package dependencies](https://github.com/jazzband/pip-tools)

For stability reasons it's a good idea to hardcode the dependencies versions.
Furthermore, safety needs them to work properly.

We've got three places where the dependencies are defined:

* `setup.py` should declare the loosest possible dependency versions that are
    still workable. Its job is to say what a particular package can work with.
* `requirements.txt` is a deployment manifest that defines an entire
    installation job, and shouldn't be thought of as tied to any one package.
    Its job is to declare an exhaustive list of all the necessary packages to
    make a deployment work.
* `dev-requirements.txt` Adds the dependencies required for development of the
    program.

With [pip-tools](https://github.com/jazzband/pip-tools), the dependency
management is trivial.

* Install the tool: `pip install pip-tools`.
* Set the general dependencies in the `setup.py` `install_requires`.
* Generate the `requirements.txt` file: `pip-compile`.
* Add the additional testing dependencies in the `dev-requirements.in` file.

    !!! note "File: dev-requirements.in"

       ```ini
        -c requirements.txt
        pip-tools
        factory_boy
        pytest
        pytest-cov
        ```

* Compile the development requirements `dev-requirements.txt` with `pip-compile
    dev-requirements.in`.

* If you have another `requirements.txt` for the mkdocs documentation, run
    `pip-compile docs/requirements.txt`.

Trigger hooks:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"

        ```yaml
          - repo: https://github.com/jazzband/pip-tools
            rev: 5.0.0
            hooks:
              - name: Build requirements.txt
                id: pip-compile
              - name: Build dev-requirements.txt
                id: pip-compile
                args: ['dev-requirements.in']
              - name: Build mkdocs requirements.txt
                id: pip-compile
                args: ['docs/requirements.txt']
        ```

# Coverage tests

[Coveralls](https://coveralls.io) is a service that monitors and writes
statistics on the coverage of your repositories. To use them, you'll need to log
in with your Github account and enable the repos you want to test.

Save the secret in the repository configuration and add this step to your tests
job.

```yaml
    - name: Coveralls
      uses: coverallsapp/github-action@master
      with:
        github-token: ${{ secrets.COVERALLS_TOKEN }}
```

Add the following badge to your README.md.

Variables to substitute:

* `repository_path`: Github repository path, like `lyz-code/pydo`.

~~~markdown
[![Coverage Status](https://coveralls.io/repos/github/{{ repository_path
}}/badge.svg?branch=master)](https://coveralls.io/github/{{ repository_path }}?branch=master)
~~~
