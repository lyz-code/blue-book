---
title: Cruft
date: 20201016
author: Lyz
---

[cruft](https://cruft.github.io/cruft/) allows you to maintain all the
necessary boilerplate for packaging and building projects separate from the code
you intentionally write. Fully compatible with existing
[Cookiecutter](cookiecutter.md) templates.

Many project template utilities exist that automate the copying and pasting of
code to create new projects. This *seems* great! However, once created, most
leave you with that copy-and-pasted code to manage through the life of your
project.

## Key Features

Cookiecutter Compatible
: cruft utilizes [Cookiecutter](cookiecutter.md) as
    its template expansion engine. Meaning it retains full compatibility with
    all existing [Cookiecutter](cookiecutter.md) templates.

Template Validation
: cruft can quickly validate whether or not a project is using the latest
    version of a template using `cruft check`. This check can easily be added to
    CI pipelines to ensure your projects stay in-sync.

Automatic Template Updates
: cruft automates the process of updating code to match the latest version of
    a template, making it easy to utilize template improvements across many
    projects.

# Installation

```bash
pip install cruft
```

# Usage

## Creating a New Project

To create a new project using cruft run `cruft create PROJECT_URL` from the
command line.

cruft will then ask you any necessary questions to create your new project. It
will use your answers to expand the provided template, and then return the
directory it placed the expanded project.

Behind the scenes, cruft uses
[Cookiecutter](https://github.com/cookiecutter/cookiecutter) to do the project
expansion. The only difference in the resulting output is a `.cruft.json` file
that contains the git hash of the template used as well as the parameters
specified.

## Updating a Project

To update an existing project, that was created using cruft, run `cruft update`
in the root of the project.

If there are any updates, cruft will have you review them before applying. If
you accept the changes cruft will apply them to your project and update the
`.cruft.json` file for you.

!!! note ""
    Sometimes certain files just aren't good fits for updating. Such as test
    cases or `__init__` files. You can tell cruft to always skip updating these
    files on a project by project basis by added them to a skip section within
    your .cruft.json file:

    ```json
    {
        "template": "https://github.com/timothycrosley/cookiecutter-python",
        "commit": "8a65a360d51250221193ed0ec5ed292e72b32b0b",
        "skip": [
            "cruft/__init__.py",
            "tests"
        ],
        ...
    }
    ```

    Or, if you have toml installed, you can add skip files directly to
    a `tool.cruft` section of your `pyproject.toml` file:

    ```ini
    [tool.cruft]
    skip = ["cruft/__init__.py", "tests"]
    ```

## Checking a Project

Checking to see if a project is missing a template update is as easy as running
`cruft check`. If the project is out-of-date an error and exit code 1 will be
returned.

`cruft check` can be added to CI pipelines to ensure projects don't
unintentionally drift.

## Linking an Existing Project

Have an existing project that you created from a template in the past using
Cookiecutter directly? You can link it to the template that was used to create
it using: `cruft link TEMPLATE_REPOSITORY`.

You can then specify the last commit of the template the project has been
updated to be consistent with, or accept the default of using the latest commit
from the template.

## Compute the diff

With time, your boilerplate may end up being very different from the actual
cookiecutter template. Cruft allows you to quickly see what changed in your
local project compared to the template. It is as easy as running `cruft diff`.
If any local file differs from the template, the diff will appear in your
terminal in a similar fashion to `git diff`.

The `cruft diff` command optionally accepts an `--exit-code` flag that will make
cruft exit with a non-0 code should any diff is found. You can combine this flag
with the `skip` section of your `.cruft.json` to make stricter CI checks that
ensures any improvement to the template is always submitted upstream.

# Issues

* [Save config in the
    pyproject.toml](https://github.com/cruft/cruft/issues/140): Update the
    template once it's supported.

## Error: Unable to interpret changes between current project and cookiecutter template as unicode.

Typically a result of hidden binary files in project folder. Maybe you have
a hook that initializes the `.git` directory. Since `2.10.0` you can add
a `skip` category inside the `.cruft.json`, so that it doesn't check that
directory:

```json
{
  "template": "xxx",
  "commit": "xxx",
  "checkout": null,
  "context": {
    "cookiecutter": {
       ...
    }
  },
  "directory": null,
  "skip": [
    ".git"
  ]
}
```


# References

* [Docs](https://cruft.github.io/cruft/)
* [Git](https://github.com/cruft/cruft/)
* [Issues](https://github.com/cruft/cruft/issues)
