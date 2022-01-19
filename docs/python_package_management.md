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

# [Solver](https://iscinumpy.dev/post/bound-version-constraints/#solver)

A Solver tries to find a working set of dependencies that all agree with each
other. By looking back in time, it’s happy to solve very old versions of
packages if newer ones are supposed to be incompatible. This can be helpful, but
is slow, and also means you can easily get a very ancient set of packages when
you thought you were getting the latest versions.

Pip’s solver changed in version 20.3 to become significantly smarter. The old
solver would ignore incompatible transitive requirements much more often than
the new solver does. This means that an upper cap in a library might have been
ignored before, but is much more likely to break things or change the solve
now.

Poetry has a unique and very strict (and slower) solver that goes even farther
hunting for solutions. It *forces* you to cap Python if a dependency does. One
key difference is that Poetry has the original environment specification to work
with every time, while pip does not know what the original environment
constraints were. This enables Poetry to roll back a dependency on a subsequent
solve, while pip does not know what the original requirements were and so does
not know if an older package is valid when it encounters a new cap.

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

* It manage the building of your package, you don't need to manually configure
    `sdist` and `wheel`.
* Nice dependency view with `poetry show`.
* Nice dependency search interface with `poetry search`.
* Sync your environment packages with the lock file.

Things I don't like that much:

* It does upper version capping by default, it even ignores your pins and [adds
    the `^<new_version` pin if you run `poetry add
    <package>@latest`]()https://github.com/python-poetry/poetry/issues/3503.
    Given that upper version capping is becoming [a big problem](versioning.md#upper-version-pinning) in
    the Python environment I'd stay away from `poetry`.

    This is specially useless when you add dependencies that follow
    [CalVer](calendar_versioning.md). `poetry add` packaging will still do
    `^21` for the version it adds. You shouldn’t be capping versions, but you
    really shouldn’t be capping CalVer.

    It's equally troublesome that it upper pins [the python
    version](versioning.md#pinning-the-python-version-is-special).

* Have their own dependency specification format similar to `npm` and
    incompatible with Python's
    [PEP508](https://www.python.org/dev/peps/pep-0508/).

* No automatic process to update the dependencies constrains to match the latest
    version available.  So if you have constrained a package to be `<2.0.0` and
    `3.0.0` is out there, you will have to manually edit the `pyproject.toml` so
    that it accepts that new version. At least you can use `poetry show
    --outdated` and it will tell you which is the new version, and if the output
    is zero, you're sure you're on the last versions.

# PDM

Features I like:

* The pin strategy defaults to only add [lower
    pins](versioning.md#lower-versioning-pinning) helping preventing the [upper
    capping](versioning.md#upper-versioning-pinning) problem.
* It can't achieve dependency isolation without virtualenvs.
* Follows the Python's dependency specification format
    [PEP508](https://www.python.org/dev/peps/pep-0508/).
* Supports different strategies to add and update dependencies.
* Command to update your requirements constrains when updating your packages.
* Sync your environment packages with the lock file.
* Easy to install package in editable mode.
* Easy to install local dependencies.
* You can force the installation of a package at your own risk even if it breaks
    the version constrains. (Useful if you're blocked by a third party upper
    bound)
* Changing the python version is as simple as running `python use
    <python_version>`.
* Plugin system where adding functionality is feasible (like the `publish`
    subcommand).
* Both global and local configuration.
* Nice interface to change the configuration.
* Automatic management of dependencies cache, where you only have one instance
    of each package version, and if no project needs it, it will be removed.
* Has a nice interface to see the cache usage
* Has the possibility of managing the global packages too.
* Allows the definition of scripts possibly removing the need of a makefile
* It's able to read the version of the program from a file, avoiding the
    duplication of the information.
* You can group your development dependencies in groups.
* Easy to define extra dependencies for your program.
* It has sensible defaults for `includes` and `excludes` when packaging.
* It's [the fastest ](https://frostming.com/2021/03-26/pm-review-2021/#result)
    and most
    [correct](https://frostming.com/2021/03-26/pm-review-2021/#correctness)
    one.

Downsides:

* They don't say how to configure your environment to work with
    [vim](https://github.com/pdm-project/pdm/issues/804).

# Summary

PDM offers the same features as Poetry with the additions of the possibility of
selecting your version capping strategy, and doesn’t cap as badly, and follows
more PEP standards.

# References

* [PDM developer comparison](https://dev.to/frostming/a-review-pipenv-vs-poetry-vs-pdm-39b4)
* [John Franey comparison](https://johnfraney.ca/posts/2019/03/06/pipenv-poetry-benchmarks-ergonomics/)
* [Frost Ming comparison (developer of PDM)](https://frostming.com/2021/03-26/pm-review-2021/#result)
* [Henry Schreiner analysis on Poetry](https://iscinumpy.dev/post/poetry-versions/)
