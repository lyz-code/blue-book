---
title: Poetry
date: 20211130
author: Lyz
---

[Poetry](https://github.com/python-poetry/poetry) is a command line program that
helps you declare, manage and install dependencies of Python projects, ensuring
you have the right stack everywhere.

`poetry` saves all the information in the `pyproject.toml` file, including the
project development and program dependencies, for example:

```toml
[tool.poetry]
name = "poetry-demo"
version = "0.1.0"
description = ""
authors = ["Sébastien Eustace <sebastien@eustace.io>"]

[tool.poetry.dependencies]
python = "*"

[tool.poetry.dev-dependencies]
pytest = "^3.4"
```

# [Installation](https://github.com/python-poetry/poetry#installation)

Although the official docs tell you to run:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

`pip install poetry` works too, which looks safer than executing arbitrary code
from an url.

To enable [shell
completion](https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh)
for `zsh` run:

```bash
# Zsh
poetry completions zsh > ~/.zfunc/_poetry

# Oh-My-Zsh
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
```

For `zsh`, you must then add the following line in your `~/.zshrc` before
`compinit`:

```bash
fpath+=~/.zfunc
```

For `oh-my-zsh`, you must then enable poetry in your `~/.zshrc` plugins:

```bash
plugins(
	poetry
	...
	)
```

# [Basic Usage](https://python-poetry.org/docs/basic-usage/)

## [Initializing a pre-existing project](https://python-poetry.org/docs/basic-usage/#initialising-a-pre-existing-project)

Instead of creating a new project, Poetry can be used to ‘initialise’
a pre-populated directory with `poetry init`. You can use the [next
options](https://python-poetry.org/docs/cli/#options)

* `--name`: Name of the package.
* `--description`: Description of the package.
* `--author`: Author of the package.
* `--python`: Compatible Python versions.
* `--dependency`: Package to require with a version constraint. Should be in
    format `foo:1.0.0`.
* `--dev-dependency`: Development requirements, see `--require`.

## [Installing dependencies](https://python-poetry.org/docs/basic-usage/#installing-dependencies)

To install the defined dependencies for your project, just run the install
command.

```bash
poetry install
```

When you run this command, one of two things may happen:

* *Installing without poetry.lock*: If you have never run the command before and
    there is also no `poetry.lock` file present, Poetry simply resolves all
    dependencies listed in your `pyproject.toml` file and downloads the latest
    version of their files.

    When Poetry has finished installing, it writes all of the packages and the
    exact versions of them that it downloaded to the `poetry.lock` file, locking
    the project to those specific versions. You should commit the `poetry.lock`
    file to your project repo so that all people working on the project are
    locked to the same versions of dependencies.

* *Installing with poetry.lock*: If there is already a `poetry.lock` file as
    well as a `pyproject.toml`, `poetry` resolves and installs all dependencies
    that you listed in `pyproject.toml`, but Poetry uses the exact versions listed
    in `poetry.lock` to ensure that the package versions are consistent for
    everyone working on your project. As a result you will have all dependencies
    requested by your `pyproject.toml` file, but they may not all be at the very
    latest available versions (some of the dependencies listed in the
    `poetry.lock` file may have released newer versions since the file was
    created). This is by design, it ensures that your project does not break
    because of unexpected changes in dependencies.

!!! note "The current project is installed in [editable mode](https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs) by default."

If you don't want the development requirements use the `--no-dev` flag.

To remove the untracked dependencies that are no longer in the lock file, use
`--remove-untracked`.

## [Updating dependencies to their latest versions](https://python-poetry.org/docs/basic-usage/#updating-dependencies-to-their-latest-versions)

The `poetry.lock` file prevents you from automatically getting the latest
versions of your dependencies. To update to the latest versions, use the
`update` command. This will fetch the latest matching versions (according to
your `pyproject.toml` file) and update the lock file with the new versions.
(This is equivalent to deleting the `poetry.lock` file and running `install`
again.)

The main problem is that `poetry add` does [upper pinning of
dependencies](versioning.md#upper-version-pinning) by default, which is
a **really bad idea**. [And they don't plan to
change](https://github.com/python-poetry/poetry/issues/3747).

There is currently no way of [updating your `pyproject.toml` dependency
definitions](https://github.com/python-poetry/poetry/issues/461) so they match
the latest version beyond your constrains. So if you have constrained a package
to be `<2.0.0` and `3.0.0` is out there, you will have to manually edit the
`pyproject.toml` so that it accepts that new version.  There is no automatic
process that does this. At least you can use `poetry show --outdated` and it
will tell you which is the new version, and if the output is zero, you're sure
you're on the last versions.

Some workarounds exists though, if you run `poetry add dependency@latest` it
will update the lock to the latest. MousaZeidBaker made
[poetryup](https://github.com/MousaZeidBaker/poetryup), a tool that is able to
update the requirements to the latest version with `poetryup --latest` (although
it [still has some bugs](https://github.com/MousaZeidBaker/poetryup/issues/21)).
Given that it uses `poetry add <package>@latest` behind the scenes, it will
[change your version pin to
 `^<new_version>`](https://github.com/python-poetry/poetry/issues/3503), which
 as we've seen it's awful.

Again, you should not be trying to do this, it's better to improve
[how you manage your
dependencies](versioning.md#deciding-how-to-manage-the-versions-of-your-dependencies).

### Debugging why a package is not updated to the latest version

Sometimes packages are not updated with `poetry update` or `poetryup`, to debug
why, you need to understand if some package is setting a constrain that prevents
the upgrade. To do that, first check the outdated packages with `poetry show -o`
and for each of them:

* [Check what packages are using the
    dependency](#checking-what-package-is-using-a-dependency).
* Search if there is an issue asking the maintainers to update their
    dependencies, if it doesn't exist, create it.

## [Removing a dependency](https://python-poetry.org/docs/cli/#remove)

```bash
poetry remove pendulum
```

With the `-D` or `--dev` flag, it removes the dependency from the development
ones.

## [Building the package](https://python-poetry.org/docs/libraries/#packaging)

Before you can actually publish your library, you will need to package it.

```bash
poetry build
```

This command will package your library in two different formats: `sdist` which
is the source format, and `wheel` which is a compiled package.

Once that’s done you are ready to publish your library.

## [Publishing to PyPI](https://python-poetry.org/docs/libraries/#publishing-to-pypi)

Poetry will publish to PyPI by default. Anything that is published to PyPI is
available automatically through Poetry.

```bash
poetry publish
```

This will package and publish the library to PyPI, at the condition that you are
a registered user and you have [configured your credentials
properly](#configuration).

If you pass the `--build` flag, it will also build the package.

### [Publishing to a private repository](https://python-poetry.org/docs/libraries/#publishing-to-a-private-repository)

Sometimes, you may want to keep your library private but also being accessible
to your team. In this case, you will need to use a private repository.

You will need to add it to your global list of repositories.

Once this is done, you can actually publish to it like so:

```bash
poetry publish -r my-repository
```

## [Specifying dependencies](https://python-poetry.org/docs/basic-usage/#specifying-dependencies)

If you want to add dependencies to your project, you can specify them in the
`tool.poetry.dependencies` section.

```toml
[tool.poetry.dependencies]
pendulum = "^1.4"
```

As you can see, it takes a mapping of package names and version constraints.

Poetry uses this information to search for the right set of files in package
“repositories” that you register in the `tool.poetry.repositories` section, or on
PyPI by default.

Also, instead of modifying the `pyproject.toml` file by hand, you can use the add command.

```bash
poetry add pendulum
```

It will automatically find a suitable version constraint and install the package
and subdependencies.

If you want to add the dependency to the development ones, use the `-D` or
`--dev` flag.

## [Using your virtual environment](https://python-poetry.org/docs/basic-usage/#using-your-virtual-environment)

By default, `poetry` creates a virtual environment in `{cache-dir}/virtualenvs`.
You can change the `cache-dir` value by editing the `poetry` config.
Additionally, you can use the `virtualenvs.in-project` configuration variable to
create virtual environment within your project directory.

There are several ways to run commands within this virtual environment.

To run your script simply use `poetry run python your_script.py`. Likewise if
you have command line tools such as [`pytest`](pytest.md) or [`black`](black.md)
you can run them using `poetry run pytest`.

The easiest way to activate the virtual environment is to create a new shell
with `poetry shell`.

## [Version Management](https://python-poetry.org/docs/cli/#version)

`poetry version` shows the current version of the project. If you pass an
argument, it will bump the version of the package, for example `poetry version
minor`. But it doesn't read your commits to decide what kind of bump you apply,
so I'd keep on using `pip-compile`.

## [Dependency Specification](https://python-poetry.org/docs/dependency-specification/)

Dependencies for a project can be specified in various forms, which depend on
the type of the dependency and on the optional constraints that might be needed
for it to be installed.

!!! warning "They don't follow Python's specification [PEP508](https://www.python.org/dev/peps/pep-0508/)"


### [Caret Requirements](https://python-poetry.org/docs/dependency-specification/#caret-requirements)

Caret requirements allow [SemVer](https://semver.org/) compatible updates to
a specified version. An update is allowed if the new version number does not
modify the left-most non-zero digit in the major, minor, patch grouping. In this
case, if we ran `poetry update requests`, `poetry` would update us to the next
versions:

| Requirement | Versions allowed |
| ---         | ---              |
| `^1.2.3`    | `>=1.2.3 <2.0.0` |
| `^1.2`      | `>=1.2.0 <2.0.0` |
| `^1`        | `>=1.0.0 <2.0.0` |
| `^0.2.3`    | `>=0.2.3 <0.3.0` |
| `^0.0.3`    | `>=0.0.3 <0.0.4` |
| `^0.0`      | `>=0.0.0 <0.1.0` |
| `^0`        | `>=0.0.0 <1.0.0` |

### [Tilde requirements](https://python-poetry.org/docs/dependency-specification/#tilde-requirements)

Tilde requirements specify a minimal version with some ability to update. If you
specify a major, minor, and patch version or only a major and minor version,
only patch-level changes are allowed. If you only specify a major version, then
minor- and patch-level changes are allowed.

| Requirement | Versions allowed |
| ---         | ---              |
| `~1.2.3`    | `>=1.2.3 <1.3.0` |
| `~1.2`      | `>=1.2.0 <1.3.0` |
| `~1`        | `>=1.0.0 <2.0.0` |

### [Wildcard requirements](https://python-poetry.org/docs/dependency-specification/#wildcard-requirements)

Wildcard requirements allow for the latest (dependency dependent) version where
the wildcard is positioned.

| Requirement | Versions allowed |
| ---         | ---              |
| `*`         | `>=0.0.0    `    |
| `1.*`       | `>=1.0.0 <2.0.0` |
| `1.2.*`     | `>=1.2.0 <1.3.0` |

### [Inequality requirements](https://python-poetry.org/docs/dependency-specification/#inequality-requirements)

Inequality requirements allow manually specifying a version range or an exact
version to depend on.

Here are some examples of inequality requirements:

```
>= 1.2.0
> 1
< 2
!= 1.2.3
```

### [Exact requirements](https://python-poetry.org/docs/dependency-specification/#exact-requirements)


You can specify the exact version of a package. This will tell Poetry to install
this version and this version only. If other dependencies require a different
version, the solver will ultimately fail and abort any install or update
procedures.

Multiple version requirements can also be separated with a comma, e.g. `>= 1.2,
< 1.5`.

### [git dependencies](https://python-poetry.org/docs/dependency-specification/#git-dependencies)

To depend on a library located in a git repository, the minimum information you
need to specify is the location of the repository with the git key:

```toml
[tool.poetry.dependencies]
requests = { git = "https://github.com/requests/requests.git" }
```

Since we haven’t specified any other information, Poetry assumes that we intend
to use the latest commit on the `master` branch to build our project.

You can combine the git key with the branch key to use another branch.
Alternatively, use `rev` or `tag` to pin a dependency to a specific commit hash or
tagged ref, respectively. For example:

```toml
[tool.poetry.dependencies]
# Get the latest revision on the branch named "next"
requests = { git = "https://github.com/kennethreitz/requests.git", branch = "next" }
# Get a revision by its commit hash
flask = { git = "https://github.com/pallets/flask.git", rev = "38eb5d3b" }
# Get a revision by its tag
numpy = { git = "https://github.com/numpy/numpy.git", tag = "v0.13.2" }
```

When using `poetry add` you can add:

* A https cloned repo: `poetry add
    git+https://github.com/sdispater/pendulum.git`
* A ssh cloned repo: `poetry add
    git+ssh://git@github.com/sdispater/pendulum.git`

If you need to checkout a specific branch, tag or revision, you can specify it
when using add:

```bash
poetry add git+https://github.com/sdispater/pendulum.git#develop
poetry add git+https://github.com/sdispater/pendulum.git#2.0.5
```

### [path dependencies](https://python-poetry.org/docs/dependency-specification/#path-dependencies)

To depend on a library located in a local directory or file, you can use the path property:

```toml
[tool.poetry.dependencies]
# directory
my-package = { path = "../my-package/", develop = false }

# file
my-package = { path = "../my-package/dist/my-package-0.1.0.tar.gz" }
```

When using `poetry add`, you can point them directly to the package or the file:

```bash
poetry add ./my-package/
poetry add ../my-package/dist/my-package-0.1.0.tar.gz
poetry add ../my-package/dist/my_package-0.1.0.whl
```

If you want the dependency to be installed in editable mode you can specify it
in the `pyproject.toml` file. It means that changes in the local directory will be
reflected directly in environment.

```toml
[tool.poetry.dependencies]
my-package = {path = "../my/path", develop = true}
```

### [url dependencies](https://python-poetry.org/docs/dependency-specification/#url-dependencies)

To depend on a library located on a remote archive, you can use the url property:

```toml
[tool.poetry.dependencies]
# directory
my-package = { url = "https://example.com/my-package-0.1.0.tar.gz" }
```

With the corresponding add call:

```bash
poetry add https://example.com/my-package-0.1.0.tar.gz
```

### [Python restricted dependencies](https://python-poetry.org/docs/dependency-specification/#python-restricted-dependencies)

You can also specify that a dependency should be installed only for specific
Python versions:

```toml
[tool.poetry.dependencies]
pathlib2 = { version = "^2.2", python = "~2.7" }

[tool.poetry.dependencies]
pathlib2 = { version = "^2.2", python = "~2.7 || ^3.2" }
```

### [Multiple constraints dependencies](https://python-poetry.org/docs/dependency-specification/#multiple-constraints-dependencies)

Sometimes, one of your dependency may have different version ranges depending on
the target Python versions.

Let’s say you have a dependency on the package `foo` which is only compatible with
Python `<3.0` up to version `1.9` and compatible with Python `3.4+` from version
`2.0`. You would declare it like so:

```python
[tool.poetry.dependencies]
foo = [
    {version = "<=1.9", python = "^2.7"},
    {version = "^2.0", python = "^3.4"}
]
```

## [Show the available packages](https://python-poetry.org/docs/cli/#show)

To list all of the available packages, you can use the show command.

```bash
poetry show
```

If you want to see the details of a certain package, you can pass the package name.

```bash
poetry show pendulum

name        : pendulum
version     : 1.4.2
description : Python datetimes made easy

dependencies:
 - python-dateutil >=2.6.1
 - tzlocal >=1.4
 - pytzdata >=2017.2.2
```

By default it will print all the dependencies, if you pass `--no-dev` it will
only show your package's ones.

With the `-l` or `--latest` it will show the latest version of the packages, and
with `-o` or `--outdated` it will show the latest version but only for packages
that are outdated.

## [Search for dependencies](https://python-poetry.org/docs/cli/#search)

This command searches for packages on a remote index.

```bash
poetry search requests pendulum
```

## [Export requirements to
requirements.txt](https://python-poetry.org/docs/cli/#export)

```bash
poetry export -f requirements.txt --output requirements.txt
```

## [Project setup](https://python-poetry.org/docs/basic-usage/#project-setup)

If you don't already have a [cookiecutter](cookiecutter.md) for your python
projects, you can use `poetry new poetry-demo`, and it will create the
`poetry-demo` directory with the following content:

```
poetry-demo
├── pyproject.toml
├── README.rst
├── poetry_demo
│   └── __init__.py
└── tests
    ├── __init__.py
    └── test_poetry_demo.py
```

If you want to use the `src` project structure, pass the `--src` flag.

## [Checking what package is using a dependency](https://github.com/python-poetry/poetry/pull/2086)

Even though `poetry` [is supposed to
show](https://github.com/python-poetry/poetry/issues/1906) the information of
which packages depend on a specific package with `poetry show package`, I don't
see it.

Luckily [snejus made a small script that shows the
information](https://github.com/python-poetry/poetry/pull/2086). Save it
somewhere in your `PATH`.

```bash
_RED='\\\\e[1;31m&\\\\e[0m'
_GREEN='\\\\e[1;32m&\\\\e[0m'
_YELLOW='\\\\e[1;33m&\\\\e[0m'
_format () {
    tr -d '"' |
        sed "s/ \+>[^ ]* \+<.*/$_YELLOW/" | # ~ / ^ / < >= ~ a window
        sed "s/ \+>[^ ]* *$/$_GREEN/" |     # >= no upper limit
        sed "/>/ !s/<.*$/$_RED/" |          # < ~ upper limit
        sed "/>\|</ !s/ .*/  $_RED/"        # == ~ locked version
}

_requires () {
    sed -n "/^name = \"$1\"/I,/\[\[package\]\]/{
                /\[package.dep/,/^$/{
                    /^[^[]/ {
                        s/= {version = \(\"[^\"]*\"\).*/, \1/p;
                        s/ =/,/gp
             }}}" poetry.lock |
        sed "/,.*,/!s/</,</; s/^[^<]\+$/&,/" |
        column -t -s , | _format
}

_required_by () {
    sed -n "/\[metadata\]/,//d;
            /\[package\]\|\[package\.depen/,/^$/H;
            /^name\|^$1 = /Ip" poetry.lock |
        sed -n "/^$1/I{x;G;p};h" |
        sed 's/.*"\(.*\)".*/\1/' |
        sed '$!N;s/\n/ /' |
        column -t | _format
}

deps() {
    echo
    echo -e "\e[1mREQUIRES\e[0m"
    _requires "$1" | xargs -i echo -e "\t{}"
    echo
    echo -e "\e[1mREQUIRED BY\e[0m"
    _required_by "$1" | xargs -i echo -e "\t{}"
    echo
}

deps $1
```



# [Configuration](https://python-poetry.org/docs/configuration/)

Poetry can be configured via the `config` command (see more about its usage here)
or directly in the `config.toml` file that will be automatically be created when
you first run that command. This file can typically be found in
`~/.config/pypoetry`.

Poetry also provides the ability to have settings that are specific to a project
by passing the `--local` option to the config command.

```bash
poetry config virtualenvs.create false --local
```

## [List the current configuration](https://python-poetry.org/docs/configuration/#listing-the-current-configuration)

To list the current configuration you can use the `--list` option of the
`config` command:

```bash
poetry config --list
```

Which will give you something similar to this:

```
cache-dir = "/path/to/cache/directory"
virtualenvs.create = true
virtualenvs.in-project = null
virtualenvs.path = "{cache-dir}/virtualenvs"  # /path/to/cache/directory/virtualenvs
```

## [Adding or updating a configuration setting](https://python-poetry.org/docs/configuration/#adding-or-updating-a-configuration-setting)

To change or otherwise add a new configuration setting, you can pass a value
after the setting’s name:

```bash
poetry config virtualenvs.path /path/to/cache/directory/virtualenvs
```

For a full list of the supported settings see [Available
settings](https://python-poetry.org/docs/configuration/#available-settings).

## [Removing a specific setting](https://python-poetry.org/docs/configuration/#removing-a-specific-setting)

If you want to remove a previously set setting, you can use the `--unset` option:

```bash
poetry config virtualenvs.path --unset
```

## [Adding a repository](https://python-poetry.org/docs/repositories/#adding-a-repository)

Adding a new repository is easy with the `config` command.

```bash
poetry config repositories.foo https://foo.bar/simple/
```

This will set the url for repository `foo` to `https://foo.bar/simple/`.

## [Configuring credentials](https://python-poetry.org/docs/repositories/#configuring-credentials)

If you want to store your credentials for a specific repository, you can do so easily:

```bash
poetry config http-basic.foo username password
```

If you do not specify the password you will be prompted to write it.

To publish to PyPI, you can set your credentials for the repository named `pypi`.

Note that it is recommended to use API tokens when uploading packages to PyPI.
Once you have created a new token, you can tell Poetry to use it:

```bash
poetry config pypi-token.pypi my-token
```

If a system keyring is available and supported, the password is stored to and
retrieved from the keyring. In the above example, the credential will be stored
using the name `poetry-repository-pypi`. If access to keyring fails or is
unsupported, this will fall back to writing the password to the `auth.toml` file
along with the username.

Keyring support is enabled using the
[keyring](https://pypi.org/project/keyring/) library. For more information on
supported backends refer to the [library
documentation](https://keyring.readthedocs.io/en/latest/?badge=latest). It
doesn't support [pass](https://www.passwordstore.org/) by default, but Steffen
Vogel created a [specific keyring
backend](https://github.com/stv0g/keyrings.passwordstore). Alternatively, you
can use environment variables to provide the credentials:

```bash
export POETRY_PYPI_TOKEN_PYPI=my-token
export POETRY_HTTP_BASIC_PYPI_USERNAME=username
export POETRY_HTTP_BASIC_PYPI_PASSWORD=password
```

I've tried setting up the keyring but I get the next error:

```python
  UploadError

  HTTP Error 403: Invalid or non-existent authentication information. See https://pypi.org/help/#invalid-auth for more information.

  at ~/.venvs/autodev/lib/python3.9/site-packages/poetry/publishing/uploader.py:216 in _upload
      212│                     self._register(session, url)
      213│                 except HTTPError as e:
      214│                     raise UploadError(e)
      215│
    → 216│             raise UploadError(e)
      217│
      218│     def _do_upload(
      219│         self, session, url, dry_run=False
      220│     ):  # type: (requests.Session, str, Optional[bool]) -> None
```

The keyring was configured with:

```bash
poetry config pypi-token.pypi internet/pypi.token
```

And I'm sure that the keyring works because `python -m keyring get internet
pypi.token` works.

I've also tried with the environmental variable `POETRY_PYPI_TOKEN_PYPI` but [it
didn't work either](https://github.com/python-poetry/poetry/issues/2359). And
setting the configuration as `poetry config http-basic.pypi __token__
internet/pypi.token`.

Finally I had to hardcode the token with `poetry config pypi-token.pypi "$(pass
show internet/pypi.token)`. Although I can't find where it's storing the value
:S.

# References

* [Git](https://github.com/python-poetry/poetry)
* [Docs](https://python-poetry.org/docs/)
