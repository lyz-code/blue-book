---
title: Python Package Management
date: 20211130
author: Lyz
---

Managing Python libraries is a nightmare for most developers, it has driven me
crazy trying to keep all the requirements of the [projects](projects.md)
I maintain updated.

I tried with [pip-tools](pip_tools.md), but I was probably using it wrong. As
package management has evolved a lot in the latest years, I'm going to compare
[Poetry](python_poetry.md), [pipenv](pipenv.md), `pdm` with my current
workflow.

| Tool   | Stars | Forks | Latest commit | Commits | Issues Open/New/Closed | PR Open/New/Merged |
| ---    | ---   | ---   | ---           | ---     | ---                    | ---                |
| Poetry | 17.3k | 1.4k  | 11h           | 1992    | 1.1k/58/80             | 149/13/77          |
| Pipenv | 22.5k | 1.7k  | 5d            | 7226    | 555/12/54              | 32/0/22            |
| pdm    | 1.3k  | 54    | 11h           | 1539    | 12/3/43                | 3/2/11             |

The `New` and `Closed` are taken from the Pulse insights of the last month. This
data was taken on the 2021-11-30 so it will probably be outdated.

Both Poetry and Pipenv are very popular, it looks that `Poetry` is more alive
this last month, but they are both actively developed. `pdm` is actively
developed but at other level.

Pipenv has broad support. It is an official project of the Python Packaging
Authority, alongside pip. It's also supported by the Heroku Python buildpack,
which is useful for anyone with Heroku or Dokku-based deployment strategies.

Poetry is a one-stop shop for dependency management and package management. It
simplifies creating a package, managing its dependencies, and publishing it.
Compared to Pipenv, Poetry's separate add and install commands are more
explicit, and it's faster for everything except for a full dependency install.

# Poetry

Features I like:

* Stores program and development requirements in the `pyproject.toml`
    file.
* Don't need to manually edit requirements files to add new packages to the
    program or dev requirements, simply use `poetry add`.
* Easy initialization of the development environment with `poetry install`.
* Powerful dependency specification
    * Installable packages with git dependencies???
    * Easy to specify local directory dependencies, even in editable mode.
    * Specify different dependencies for different python versions
* No automatic process to update the dependencies constrains to match the latest
    version available.  So if you have constrained a package to be `<2.0.0` and
    `3.0.0` is out there, you will have to manually edit the `pyproject.toml` so
    that it accepts that new version. At least you can use `poetry show
    --outdated` and it will tell you which is the new version, and if the output
    is zero, you're sure you're on the last versions.

* It manage the building of your package, you don't need to manually configure
    `sdist` and `wheel`.
* Nice dependency view with `poetry show`.
* Nice dependency search interface with `poetry search`.


# References

* [John Franey comparison](https://johnfraney.ca/posts/2019/03/06/pipenv-poetry-benchmarks-ergonomics/)

# To add

* [PDM developer comparison](https://dev.to/frostming/a-review-pipenv-vs-poetry-vs-pdm-39b4)
