---
title: CI
date: 20200602
author: Lyz
---

[Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration)
(CI) allows to automatically run processes on the code each time a commit is
pushed.  For example it can be used to run the tests, build the documentation,
build a package or maintain dependencies updated.

!!! note ""
    I've automated the configuration of CI/CD pipelines for python projects in
    [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project).

There are three non exclusive ways to run the tests:

* Integrate them in your editor, so it's executed each time you save the file.
* Through a [pre-commit](https://github.com/pre-commit/pre-commit) hook to
    make it easy for the collaborator to submit correctly formatted code. pre-commit
    is a framework for managing and maintaining multi-language
    [pre-commit](https://pre-commit.com/) hooks.
* Through a CI server (like Drone or Github Actions) to ensure that the commited
    code meets the quality standards. Developers can bypass the pre-commit
    filter, so we need to set up the quality gate in an agnostic environment.

Depending on the time the test takes to run and their different implementations,
we'll choose from one to three of the choices above.

# Configuring pre-commit

To adopt [`pre-commit`](https://github.com/pre-commit/pre-commit) to our system
we have to:

* Install pre-commit: `pip3 install pre-commit` and add it to the development
    `requirements.txt`.
* Define `.pre-commit-config.yaml` with the hooks you want to include (they
    [don't plan to support pyproject.toml](https://github.com/pre-commit/pre-commit/issues/1165)).
* Execute `pre-commit install` to install git hooks in your `.git/` directory.
* Execute `pre-commit run --all-files` to tests all the files. Usually
    `pre-commit` will only run on the changed files during git hooks.

# Static analysis checkers

[Static analysis](https://en.wikipedia.org/wiki/Static_program_analysis) is the
analysis of computer software that is performed without actually executing
programs.

## Formatters

Formatters are tools that change your files to meet a linter requirements.

* [Black](black.md): A python style guide formatter tool.

## Linters

[Lint, or a linter](https://en.wikipedia.org/wiki/Lint_(software)), is a static
code analysis tool used to flag programming errors, bugs, stylistic errors, and
suspicious constructs. The term originates from a Unix utility that examined
C language source code.

* [alex](alex.md) to find gender favoring, polarizing, race related, religion
    inconsiderate, or other unequal phrasing in text.
* [Flake8](flakeheaven.md): A python style guide checker tool.
* [markdownlint](markdownlint.md): A linter for Markdown files.
* [proselint](proselint.md): Is another linter for prose.
* [Yamllint](yamllint.md): A linter for YAML files.
* [write-good](write_good.md) is a naive linter for English
    prose.

## Type checkers

Type checkers are programs that the code is compliant with a defined [type
system](https://en.wikipedia.org/wiki/Type_system) which is a logical system
comprising a set of rules that assigns a property called a *type* to the various
constructs of a computer program, such as variables, expressions, functions or
modules. The main purpose of a type system is to reduce possibilities for bugs
by defining interfaces between different parts of the program, and then checking
that the parts have been connected in a consistent way.

* [Mypy](mypy.md): A static type checker for Python.

## Security vulnerability checkers

Tools that check potential vulnerabilities in the code.

* [Bandit](bandit.md): Finds common security issues in Python code.
* [Safety](safety.md): Checks your installed dependencies
    for known security vulnerabilities.

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

# Update package dependencies

Tools to automatically keep your dependencies updated.

* [pip-tools](pip_tools.md)

# Coverage reports

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

# Troubleshooting

## error: pathspec 'master' did not match any file(s) known to git

If you have this error while making a commit through a pipeline step, it may be
the pre-commits stepping in.

To fix it, remove all git hooks with `rm -r .git/hooks`.
