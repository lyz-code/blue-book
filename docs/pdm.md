---
title: PDM
date: 20211217
author: Lyz
---

[PDM](https://pdm.fming.dev/) is a modern Python package manager with
[PEP 582](https://www.python.org/dev/peps/pep-0582/) support. It installs and
manages packages in a similar way to npm that doesn't need to create a
virtualenv at all!

# [Features](https://pdm.fming.dev/#feature-highlights)

- PEP 582 local package installer and runner, no virtualenv involved at all.
- Simple and relatively fast dependency resolver, mainly for large binary
  distributions.
- A PEP 517 build backend.
- PEP 621 project metadata.

# [Installation](https://pdm.fming.dev/#installation)

## [Recommended installation method](https://pdm.fming.dev/#recommended-installation-method)

```bash
curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -
```

For security reasons, you should verify the checksum. The sha256 checksum is:
`70ac95c53830ff41d700051c9caebd83b2b85b5d6066e8f853006f9f07293ff0`, if it
doesn't match
[check if there is a newer version](https://pdm.fming.dev/#recommended-installation-method).

## Other methods

```bash
pip install --user pdm
```

## [Enable PEP 582 globally](https://pdm.fming.dev/#enable-pep-582-globally)

To make the Python interpreters aware of PEP 582 packages, one need to add the
`pdm/pep582/sitecustomize.py` to the Python library search path.

```bash
pdm --pep582 zsh >> ~/.zshrc
```

## [Use it with the IDE](https://pdm.fming.dev/#use-with-ide)

Now there are not built-in support or plugins for PEP 582 in most IDEs, you have
to configure your tools manually. They say how to configure Pycharm and VSCode,
but there's
[still no instructions for vim](https://github.com/pdm-project/pdm/issues/804).

PDM will write and store project-wide configurations in `.pdm.toml` and you are
recommended to add following lines in the `.gitignore`:

```
.pdm.toml
__pypackages__/
```

# [Usage](https://pdm.fming.dev/usage/dependency/)

PDM provides a bunch of handful commands to help manage your project and
dependencies.

## [Initialize a project](https://pdm.fming.dev/usage/dependency/#initialize-a-project)

```bash
pdm init
```

Answer several questions asked by PDM and a `pyproject.toml` will be created for
you in the project root:

```toml
[project]
name = "pdm-test"
version = "0.0.0"
description = ""
requires-python = ">=3.7"
dependencies = []
[[project.authors]]
name = "Frost Ming"
email = "mianghong@gmail.com"

[project.license]
text = "MIT"
```

If `pyproject.toml` is already present, it will be updated with the metadata
following the [PEP 621](https://www.python.org/dev/peps/pep-0621/)
specification.

### [Import project metadata from existing project files](https://pdm.fming.dev/usage/project/#import-project-metadata-from-existing-project-files)

If you are already other package manager tools like `Pipenv` or `Poetry`, it is
easy to migrate to PDM. PDM provides `import` command so that you don't have to
initialize the project manually, it now supports:

1. Pipenv's `Pipfile`
1. Poetry's section in `pyproject.toml`
1. Flit's section in `pyproject.toml`
1. `requirements.txt` format used by Pip

Also, when you are executing `pdm init` or `pdm install`, PDM can auto-detect
possible files to import if your PDM project has not been initialized yet.

## [Adding dependencies](https://pdm.fming.dev/usage/dependency/#add-dependencies)

`pdm add` can be followed by one or several dependencies, and the dependency
specification is described in
[PEP 508](https://www.python.org/dev/peps/pep-0508/), you have a summary of the
possibilities [here](#dependency-specification).

```bash
pdm add requests
```

PDM also allows extra dependency groups by providing `-G/--group <name>` option,
and those dependencies will go to `[project.optional-dependencies.<name>]` table
in the project file, respectively.

After that, dependencies and sub-dependencies will be resolved properly and
installed for you, you can view `pdm.lock` to see the resolved result of all
dependencies.

### [Add local dependencies](https://pdm.fming.dev/usage/dependency/#add-local-dependencies)

Local packages can be added with their paths:

```bash
pdm add ./sub-package
```

Local packages can be installed in editable mode (just like
`pip install -e <local project path>` would) using
`pdm add -e/--editable <local project path>`.

#### [Add development only dependencies](https://pdm.fming.dev/usage/dependency/#add-development-only-dependencies)

PDM also supports defining groups of dependencies that are useful for
development, e.g. some for testing and others for linting. We usually don't want
these dependencies appear in the distribution's metadata so using
optional-dependencies is probably not a good idea. We can define them as
development dependencies:

```bash
pdm add -d pytest
```

This will result in a `pyproject.toml` as following:

```toml
[tool.pdm.dev-dependencies]
test = [ "pytest",]
```

#### [Save version specifiers](https://pdm.fming.dev/usage/dependency/#save-version-specifiers)

If the package is given without a version specifier like `pdm add requests`. PDM
provides three different behaviors of what version specifier is saved for the
dependency, which is given by `--save-<strategy>`(Assume `2.21.0` is the latest
version that can be found for the dependency):

- `minimum`: Save the minimum version specifier: `>=2.21.0` (default).
- `compatible`: Save the compatible version specifier:
  `>=2.21.0,<3.0.0`(default).
- `exact`: Save the exact version specifier: `==2.21.0`.
- `wildcard`: Don't constrain version and leave the specifier to be wildcard:
  `*`.

### [Supporting pre-releases](https://pdm.fming.dev/latest/pyproject/tool-pdm/#allow-prereleases-in-resolution-result)

To help package maintainers, you can allow pre-releases to be validate
candidates, that way you'll get the issues sooner. It will mean more time to
maintain the broken CIs if you update your packages daily (as you should!), but
it's the least you can do to help your downstream library maintainers

By default, `pdm`'s dependency resolver will ignore prereleases unless there are
no stable versions for the given version range of a dependency. This behavior
can be changed by setting allow_prereleases to true in `[tool.pdm]` table:

```toml
[tool.pdm]
allow_prereleases = true
```

## [Update existing dependencies](https://pdm.fming.dev/usage/dependency/#update-existing-dependencies)

To update all dependencies in the lock file use:

```bash
pdm update
```

To update the specified package(s):

```bash
pdm update requests
```

To update multiple groups of dependencies:

```bash
pdm update -G security -G http
```

To update a given package in the specified group:

```bash
pdm update -G security cryptography
```

If the group is not given, PDM will search for the requirement in the default
dependencies set and raises an error if none is found.

To update packages in development dependencies:

```bash
# Update all default + dev-dependencies
pdm update -d
# Update a package in the specified group of dev-dependencies
pdm update -dG test pytest
```

Keep in mind that `pdm update`
[doesn't touch the constrains in `pyproject.toml`](https://github.com/pdm-project/pdm/issues/884),
if you want to update them you'd need to use the `--unconstrained` flag which
will ignore all the constrains of downstream packages and update them to the
latest version setting the pin accordingly to your
[update strategy](#about-update-strategy).

Updating the `pyproject.toml` constrains to match the `pdm.lock` as close as
possible makes sense to avoid unexpected errors when users use other version of
the libraries, as the tests are run only against the versions specified in
`pdm.lock`.

### [About update strategy](https://pdm.fming.dev/usage/dependency/#about-update-strategy)

Similarly, PDM also provides 2 different behaviors of updating dependencies and
sub-dependencies， which is given by `--update-<strategy>` option:

- `reuse`: Keep all locked dependencies except for those given in the command
  line (default).
- `eager`: Try to lock a newer version of the packages in command line and their
  recursive sub-dependencies and keep other dependencies as they are.

### [Update packages to the versions that break the version specifiers](https://pdm.fming.dev/usage/dependency/#update-packages-to-the-versions-that-break-the-version-specifiers)

One can give `-u/--unconstrained` to tell PDM to ignore the version specifiers
in the `pyproject.toml`. This works similarly to the `yarn upgrade -L/--latest`
command. Besides, `pdm update` also supports the `--pre/--prerelease` option.

## [Remove existing dependencies](https://pdm.fming.dev/usage/dependency/#remove-existing-dependencies)

To remove existing dependencies from project file and the library directory:

```console
# Remove requests from the default dependencies
pdm remove requests
# Remove h11 from the 'web' group of optional-dependencies
pdm remove -G web h11
# Remove pytest-cov from the `test` group of dev-dependencies
pdm remove -d pytest-cov
```

## [Install the packages pinned in lock file](https://pdm.fming.dev/usage/dependency/#install-the-packages-pinned-in-lock-file)

There are two similar commands to do this job with a slight difference:

- `pdm install` will check the lock file and relock if it mismatches with
  project file, then install.
- `pdm sync` installs dependencies in the lock file and will error out if it
  doesn't exist. Besides, `pdm sync` can also remove unneeded packages if
  `--clean` option is given.

**All** development dependencies are included as long as `--prod` is not passed
and `-G` doesn't specify any dev groups.

Besides, if you don't want the root project to be installed, add `--no-self`
option, and `--no-editable` can be used when you want all packages to be
installed in non-editable versions. With `--no-editable` turn on, you can safely
archive the whole `__pypackages__` and copy it to the target environment for
deployment.

## [Show what packages are installed](https://pdm.fming.dev/usage/dependency/#show-what-packages-are-installed)

Similar to `pip list`, you can list all packages installed in the packages
directory:

```console
pdm list
```

Or show a dependency graph by:

```
$ pdm list --graph
tempenv 0.0.0
└── click 7.0 [ required: <7.0.0,>=6.7 ]
black 19.10b0
├── appdirs 1.4.3 [ required: Any ]
├── attrs 19.3.0 [ required: >=18.1.0 ]
├── click 7.0 [ required: >=6.5 ]
├── pathspec 0.7.0 [ required: <1,>=0.6 ]
├── regex 2020.2.20 [ required: Any ]
├── toml 0.10.0 [ required: >=0.9.4 ]
└── typed-ast 1.4.1 [ required: >=1.4.0 ]
bump2version 1.0.0
```

## [Solve the locking failure](https://pdm.fming.dev/usage/dependency/#solve-the-locking-failure)

If PDM is not able to find a resolution to satisfy the requirements, it will
raise an error. For example,

```bash
pdm django==3.1.4 "asgiref<3"
...
🔒 Lock failed
Unable to find a resolution for asgiref because of the following conflicts:
asgiref<3 (from project)
asgiref<4,>=3.2.10 (from <Candidate django 3.1.4 from https://pypi.org/simple/django/>)
To fix this, you could loosen the dependency version constraints in pyproject.toml. If that is not possible, you could also override the resolved version in [tool.pdm.overrides] table.
```

You can either change to a lower version of `django` or remove the upper bound
of `asgiref`. But if it is not eligible for your project, you can tell PDM to
forcely resolve `asgiref` to a specific version by adding the following lines to
`pyproject.toml`:

```toml
[tool.pdm.overrides]
asgiref = ">=3.2.10"
```

Each entry of that table is a package name with the wanted version. The value
can also be a URL to a file or a VCS repository like `git+https://...`. On
reading this, PDM will pin `asgiref@3.2.10` or the greater version in the lock
file no matter whether there is any other resolution available.

Note: By using `[tool.pdm.overrides]` setting, you are at your own risk of any
incompatibilities from that resolution. It can only be used if there is no valid
resolution for your requirements and you know the specific version works. Most
of the time, you can just add any transient constraints to the `dependencies`
array.

## [Solve circular dependencies](https://pdm.fming.dev/usage/dependency/#solve-the-locking-failure)

Sometimes `pdm` is not able to
[locate the best package combination](https://github.com/pdm-project/pdm/issues/1354),
or it does too many loops, so to help it you can update your version constrains
so that it has the minimum number of candidates.

To solve circular dependencies we first need to locate what are the conflicting
packages,
[`pdm` doesn't make it easy to detect them](https://github.com/pdm-project/pdm/issues/1354).
To do that first try to update each of your groups independently with
`pdm update -G group_name`. If that doesn't work remove from your
`pyproject.toml` groups of dependencies until the command works and add back one
group by group until you detect the ones that fail.

Also it's useful to reduce the number of possibilities of versions of each
dependency to make things easier to `pdm`. Locate all the outdated packages by
doing `pdm show` on each package until
[this issue is solved](https://github.com/pdm-project/pdm/issues/1356) and run
`pdm update {package} --unconstrained` for each of them. If you're already on
the latest version, update your `pyproject.toml` to match the latest state.

Once you have everything to the latest compatible version, you can try to
upgrade the rest of the packages one by one to the latest with
`--unconstrained`.

In the process of doing these steps you'll see some conflicts in the
dependencies that can be manually solved by preventing those versions to be
installed or maybe changing the `python-requires`, although this should be done
as the last resource.

It also helps to run `pdm update` with the `-v` flag, that way you see which are
the candidates that are rejected, and you can put the constrain you want. For
example, I was seeing the next traceback:

```
pdm.termui: Conflicts detected:
  pyflakes>=3.0.0 (from <Candidate autoflake 2.0.0 from https://pypi.org/simple/autoflake/>)
  pyflakes<2.5.0,>=2.4.0 (from <Candidate flake8 4.0.1 from unknown>)
```

So I added a new dependency to pin it:

```
[tool.pdm.dev-dependencies]
# The next ones are required to manually solve the dependencies issues
dependencies = [
    # Until flakeheaven supports flake8 5.x
    # https://github.com/flakeheaven/flakeheaven/issues/132
    "flake8>=4.0.1,<5.0.0",
    "pyflakes<2.5.0",
]
```

If none of the above works, you can override them:

```
[tool.pdm.overrides]
# To be removed once https://github.com/flakeheaven/flakeheaven/issues/132 is solved
"importlib-metadata" = ">=3.10"
```

If you get lost in understanding your dependencies, you can try using
[`pydeps`](https://github.com/thebjorn/pydeps) to get your head around it.

## [Building packages](https://pdm.fming.dev/usage/project/)

PDM can act as a PEP 517 build backend, to enable that, write the following
lines in your `pyproject.toml`.

```toml
[build-system]
requires = [ "pdm-pep517",]
build-backend = "pdm.pep517.api"
```

`pip` will read the backend settings to install or build a package.

### [Choose a Python interpreter](https://pdm.fming.dev/usage/project/#choose-a-python-interpreter)

If you have used `pdm init`, you must have already seen how PDM detects and
selects the Python interpreter. After initialized, you can also change the
settings by `pdm use <python_version_or_path>`. The argument can be either a
version specifier of any length, or a relative or absolute path to the python
interpreter, but remember the Python interpreter must conform with the
`python_requires` constraint in the project file.

#### [How `requires-python` controls the project](https://pdm.fming.dev/usage/project/#how-requires-python-controls-the-project)

PDM respects the value of `requires-python` in the way that it tries to pick
package candidates that can work on all python versions that `requires-python`
contains. For example, if `requires-python` is `>=2.7`, PDM will try to find the
latest version of `foo`, whose `requires-python` version range is a **superset**
of `>=2.7`.

So, make sure you write `requires-python` properly if you don't want any
outdated packages to be locked.

### [Build distribution artifacts](https://pdm.fming.dev/usage/project/#build-distribution-artifacts)

```console
$ pdm build
- Building sdist...
- Built pdm-test-0.0.0.tar.gz
- Building wheel...
- Built pdm_test-0.0.0-py3-none-any.whl
```

## [Publishing artifacts](https://github.com/branchvincent/pdm-publish)

The artifacts can then be uploaded to PyPI by
[twine](https://pypi.org/project/twine) or through the `pdm-publish` plugin. The
main developer [didn't thought](https://github.com/pdm-project/pdm/issues/22) it
was worth it, so branchvincent made the plugin (I love this possibility).

Install it with `pdm plugin add pdm-publish`.

Then you can upload them with;

```bash
# Using token auth
pdm publish --password token
# To test PyPI using basic auth
pdm publish -r testpypi -u username -P password
# To custom index
pdm publish -r https://custom.index.com/
```

If you don't want to use your credentials in plaintext on the command, you can
use the environmental variables `PDM_PUBLISH_PASSWORD` and `PDM_PUBLISH_USER`.

## [Show the current Python environment](https://pdm.fming.dev/usage/project/#show-the-current-python-environment)

```console
$ pdm info
PDM version:        1.11.3
Python Interpreter: /usr/local/bin/python3.9 (3.9)
Project Root:       /tmp/tmp.dBlK2rAn2x
Project Packages:   /tmp/tmp.dBlK2rAn2x/__pypackages__/3.9
```

```console
$ pdm info --env
{
  "implementation_name": "cpython",
  "implementation_version": "3.9.8",
  "os_name": "posix",
  "platform_machine": "x86_64",
  "platform_release": "4.19.0-5-amd64",
  "platform_system": "Linux",
  "platform_version": "#1 SMP Debian 4.19.37-5+deb10u1 (2019-07-19)",
  "python_full_version": "3.9.8",
  "platform_python_implementation": "CPython",
  "python_version": "3.9",
  "sys_platform": "linux"
}
```

## [Manage project configuration](https://pdm.fming.dev/usage/project/#configure-the-project)

Show the current configurations:

```console
pdm config
```

Get one single configuration:

```console
pdm config pypi.url
```

Change a configuration value and store in home configuration:

```console
pdm config pypi.url "https://test.pypi.org/simple"
```

By default, the configuration are changed globally, if you want to make the
config seen by this project only, add a `--local` flag:

```console
pdm config --local pypi.url "https://test.pypi.org/simple"
```

Any local configurations will be stored in `.pdm.toml` under the project root
directory.

The configuration files are searched in the following order:

1. `<PROJECT_ROOT>/.pdm.toml` - The project configuration.
1. `~/.pdm/config.toml` - The home configuration.

If `-g/--global` option is used, the first item will be replaced by
`~/.pdm/global-project/.pdm.toml`.

You can find all available configuration items in
[Configuration Page](#configuration).

## [Run Scripts in Isolated Environment](https://pdm.fming.dev/usage/project/#run-scripts-in-isolated-environment)

With PDM, you can run arbitrary scripts or commands with local packages loaded:

```bash
pdm run flask run -p 54321
```

PDM also supports custom script shortcuts in the optional `[tool.pdm.scripts]`
section of `pyproject.toml`.

You can then run `pdm run <shortcut_name>` to invoke the script in the context
of your PDM project. For example:

```toml
[tool.pdm.scripts]
start_server = "flask run -p 54321"
```

And then in your terminal:

```bash
$ pdm run start_server
Flask server started at http://127.0.0.1:54321
```

Any extra arguments will be appended to the command:

```bash
$ pdm run start_server -h 0.0.0.0
Flask server started at http://0.0.0.0:54321
```

PDM supports 3 types of scripts:

### [Normal command](https://pdm.fming.dev/usage/project/#normal-command)

Plain text scripts are regarded as normal command, or you can explicitly specify
it:

```toml
[tool.pdm.scripts.start_server]
cmd = "flask run -p 54321"
```

In some cases, such as when wanting to add comments between parameters, it might
be more convenient to specify the command as an array instead of a string:

```toml
[tool.pdm.scripts.start_server]
cmd = [ "flask", "run", "-p", "54321",]
```

### [Shell script](https://pdm.fming.dev/usage/project/#shell-script)

Shell scripts can be used to run more shell-specific tasks, such as pipeline and
output redirecting. This is basically run via `subprocess.Popen()` with
`shell=True`:

```toml
[tool.pdm.scripts.filter_error]
shell = "cat error.log|grep CRITICAL > critical.log"
```

### [Call a Python function](https://pdm.fming.dev/usage/project/#call-a-python-function)

The script can be also defined as calling a python function in the form
`<module_name>:<func_name>`:

```toml
[tool.pdm.scripts.foobar]
call = "foo_package.bar_module:main"
```

The function can be supplied with literal arguments:

```toml
[tool.pdm.scripts.foobar]
call = "foo_package.bar_module:main('dev')"
```

### [Environment variables support](https://pdm.fming.dev/usage/project/#environment-variables-support)

All environment variables set in the current shell can be seen by `pdm run` and
will be expanded when executed. Besides, you can also define some fixed
environment variables in your `pyproject.toml`:

```toml
[tool.pdm.scripts.start_server]
cmd = "flask run -p 54321"

[tool.pdm.scripts.start_server.env]
FOO = "bar"
FLASK_ENV = "development"
```

Note how we use [TOML's syntax](https://github.com/toml-lang/toml) to define a
compound dictionary.

A dotenv file is also supported via `env_file = "<file_path>"` setting.

For environment variables and/or dotenv file shared by all scripts, you can
define `env` and `env_file` settings under a special key named `_` of
`tool.pdm.scripts` table:

```toml
[tool.pdm.scripts]
start_server = "flask run -p 54321"
migrate_db = "flask db upgrade"

[tool.pdm.scripts._]
env_file = ".env"
```

Besides, PDM also injects the root path of the project via `PDM_PROJECT_ROOT`
environment variable.

### [Load site-packages in the running environment](https://pdm.fming.dev/usage/project/#load-site-packages-in-the-running-environment)

To make sure the running environment is properly isolated from the outer Python
interpreter, site-packages from the selected interpreter WON'T be loaded into
`sys.path`, unless any of the following conditions holds:

1. The executable is from `PATH` but not inside the `__pypackages__` folder.
1. `-s/--site-packages` flag is following `pdm run`.
1. `site_packages = true` is in either the script table or the global setting
   key `_`.

Note that site-packages will always be loaded if running with PEP 582
enabled(without the `pdm run` prefix).

### [Show the list of scripts shortcuts](https://pdm.fming.dev/usage/project/#show-the-list-of-scripts-shortcuts)

Use `pdm run --list/-l` to show the list of available script shortcuts:

```bash
$ pdm run --list
Name        Type  Script           Description
----------- ----- ---------------- ----------------------
test_cmd    cmd   flask db upgrade
test_script call  test_script:main call a python function
test_shell  shell echo $FOO        shell command
```

You can add an `help` option with the description of the script, and it will be
displayed in the `Description` column in the above output.

## [Manage caches](https://pdm.fming.dev/usage/project/#manage-caches)

PDM provides a convenient command group to manage the cache, there are four
kinds of caches:

- `wheels/` stores the built results of non-wheel distributions and files.
- `http/` stores the HTTP response content.
- `metadata/` stores package metadata retrieved by the resolver.
- `hashes/` stores the file hashes fetched from the package index or calculated
  locally.
- `packages/` The centrialized repository for installed wheels.

See the current cache usage by typing `pdm cache info`. Besides, you can use
`add`, `remove` and `list` subcommands to manage the cache content.

## [Manage global dependencies](https://pdm.fming.dev/usage/project/#manage-global-project)

Sometimes users may want to keep track of the dependencies of global Python
interpreter as well. It is easy to do so with PDM, via `-g/--global` option
which is supported by most subcommands.

If the option is passed, `~/.pdm/global-project` will be used as the project
directory, which is almost the same as normal project except that
`pyproject.toml` will be created automatically for you and it doesn't support
build features. The idea is taken from Haskell's
[stack](https://docs.haskellstack.org).

However, unlike `stack`, by default, PDM won't use global project automatically
if a local project is not found. Users should pass `-g/--global` explicitly to
activate it, since it is not very pleasing if packages go to a wrong place. But
PDM also leave the decision to users, just set the config `auto_global` to
`true`.

If you want global project to track another project file other than
`~/.pdm/global-project`, you can provide the project path via
`-p/--project <path>` option.

Warning: Be careful with `remove` and `sync --clean` commands when global
project is used, because it may remove packages installed in your system Python.

# Configuration

All available configurations can be seen
[here](https://pdm.fming.dev/configuration/#available-configurations).

## [Dependency specification](https://pdm.fming.dev/pyproject/pep621/#dependency-specification)

The `project.dependencies` is an array of dependency specification strings
following the [PEP 440](https://www.python.org/dev/peps/pep-0440/) and
[PEP 508](https://www.python.org/dev/peps/pep-0508/).

Examples:

```toml
dependencies = [ "requests", "flask >= 1.1.0", "pywin32; sys_platform == 'win32'", "pip @ https://github.com/pypa/pip.git@20.3.1",]
```

### [Editable requirement](https://pdm.fming.dev/pyproject/pep621/#editable-requirement)

Beside of the normal dependency specifications, one can also have some packages
installed in editable mode. The editable specification string format is the same
as
[Pip's editable install mode](https://pip.pypa.io/en/stable/cli/pip_install/#editable-installs).

Examples:

```
dependencies = [
    ...,
    # Local dependency
    "-e path/to/SomeProject",
    # Dependency cloned
    "-e git+http://repo/my_project.git#egg=SomeProject"
]
```

Note: About editable installation. One can have editable installation and normal
installation for the same package. The one that comes at last wins. However,
editable dependencies WON'T be included in the metadata of the built artifacts
since they are not valid PEP 508 strings. They only exist for development
purpose.

### [Optional dependencies](https://pdm.fming.dev/pyproject/pep621/#optional-dependencies)

You can have some requirements optional, which is similar to `setuptools`'
`extras_require` parameter.

```toml
[project.optional-dependencies]
socks = [ "PySocks >= 1.5.6, != 1.5.7, < 2",]
tests = [ "ddt >= 1.2.2, < 2", "pytest < 6", "mock >= 1.0.1, < 4; python_version < \"3.4\"",]
```

To install a group of optional dependencies:

```bash
pdm install -G socks
```

`-G` option can be given multiple times to include more than one group.

### [Development dependencies groups](https://pdm.fming.dev/pyproject/tool-pdm/#development-dependencies)

You can have several groups of development only dependencies. Unlike
`optional-dependencies`, they won't appear in the package distribution metadata
such as `PKG-INFO` or `METADATA`. And the package index won't be aware of these
dependencies. The schema is similar to that of `optional-dependencies`, except
that it is in `tool.pdm` table.

```toml
[tool.pdm.dev-dependencies]
lint = [ "flake8", "black",]
test = [ "pytest", "pytest-cov",]
doc = [ "mkdocs",]
```

To install all of them:

```bash
pdm install
```

For more CLI usage, please refer to [Manage Dependencies](/usage/dependency/)

### [Show outdated packages](https://github.com/pdm-project/pdm/issues/358)

```bash
pdm update --dry-run --unconstrained
```

## [Console scripts](https://pdm.fming.dev/pyproject/pep621/#console-scripts)

The following content:

```toml
[project.scripts]
mycli = "mycli.__main__:main"
```

will be translated to `setuptools` style:

```python
entry_points = {"console_scripts": ["mycli=mycli.__main__:main"]}
```

Also, `[project.gui-scripts]` will be translated to `gui_scripts` entry points
group in `setuptools` style.

## [Entry points](https://pdm.fming.dev/pyproject/pep621/#entry-points)

Other types of entry points are given by `[project.entry-points.<type>]`
section, with the same format of `[project.scripts]`:

```toml
[project.entry-points.pytest11]
myplugin = "mypackage.plugin:pytest_plugin"
```

## [Include and exclude package files](https://pdm.fming.dev/pyproject/tool-pdm/#include-and-exclude-package-files)

The way of specifying include and exclude files are simple, they are given as a
list of glob patterns:

```toml
includes = [ "**/*.json", "mypackage/",]
excludes = [ "mypackage/_temp/*",]
```

In case you want some files to be included in sdist only, you use the
`source-includes` field:

```toml
includes = [...]
excludes = [...]
source-includes = ["tests/"]
```

Note that the files defined in `source-includes` will be **excluded**
automatically from non-sdist builds.

### [Default values for includes and excludes](https://pdm.fming.dev/pyproject/tool-pdm/#default-values-for-includes-and-excludes)

If you don't specify any of these fields, PDM also provides smart default values
to fit the most common workflows.

- Top-level packages will be included.
- `tests` package will be excluded from **non-sdist** builds.
- `src` directory will be detected as the `package-dir` if it exists.

If your project follows the above conventions you don't need to config any of
these fields and it just works. Be aware PDM won't add
[PEP 420 implicit namespace packages](https://www.python.org/dev/peps/pep-0420/)
automatically and they should always be specified in `includes` explicitly.

## [Determine the package version dynamically](https://pdm.fming.dev/pyproject/pep621/#determine-the-package-version-dynamically)

The package version can be retrieved from the `__version__` variable of a given
file. To do this, put the following under the `[tool.pdm]` table:

```toml
[tool.pdm.version]
from = "mypackage/__init__.py"
```

Remember set `dynamic = ["version"]` in `[project]` metadata.

PDM can also read version from SCM tags. If you are using `git` or `hg` as the
version control system, define the `version` as follows:

```toml
[tool.pdm.version]
use_scm = true
```

In either case, you MUST delete the `version` field from the `[project]` table,
and include `version` in the `dynamic` field, or the backend will raise an
error:

```toml
dynamic = [ "version",]
```

## [Cache the installation of wheels](https://pdm.fming.dev/usage/project/#cache-the-installation-of-wheels)

If a package is required by many projects on the system, each project has to
keep its own copy. This may become a waste of disk space especially for data
science and machine learning libraries.

PDM supports _caching_ the installations of the same wheel by installing it into
a centralized package repository and linking to that installation in different
projects. To enabled it, run:

```bash
pdm config feature.install_cache on
```

It can be enabled on a project basis, by adding `--local` option to the command.

The caches are located under `$(pdm config cache_dir)/packages`. One can view
the cache usage by `pdm cache info`. But be noted the cached installations are
managed automatically. They get deleted when not linked from any projects.
Manually deleting the caches from the disk may break some projects on the
system.

Note: Only the installation of _named requirements_ resolved from PyPI can be
cached.

## [Working with a virtualenv](https://pdm.fming.dev/usage/project/#working-with-a-virtualenv)

Although PDM enforces PEP 582 by default, it also allows users to install
packages into the virtualenv. It is controlled by the configuration item
`use_venv`. When it is set to `True` (default), PDM will use the virtualenv if:

- A virtualenv is already activated.
- Any of `venv`, `.venv`, `env` is a valid virtualenv folder.

Besides, when `use-venv` is on and the interpreter path given is a venv-like
path, PDM will reuse that venv directory as well.

For enhanced virtualenv support such as virtualenv management and auto-creation,
please go for [pdm-venv](https://github.com/pdm-project/pdm-venv), which can be
installed as a plugin.

## [Use PDM in Continuous Integration](https://pdm.fming.dev/usage/advanced/#use-pdm-in-continuous-integration)

Fortunately, if you are using GitHub Action, there is
[pdm-project/setup-pdm](https://github.com/marketplace/actions/setup-pdm) to
make this process easier. Here is an example workflow of GitHub Actions, while
you can adapt it for other CI platforms.

```yaml
Testing:
  runs-on: ${{ matrix.os }}
  strategy:
    matrix:
      python-version: [3.7, 3.8, 3.9, 3.10]
      os: [ubuntu-latest, macOS-latest, windows-latest]

  steps:
    - uses: actions/checkout@v1
    - name: Set up PDM
      uses: pdm-project/setup-pdm@main
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        pdm sync -d -G testing
    - name: Run Tests
      run: |
        pdm run -v pytest tests
```

Note: Tips for GitHub Action users, there is a
[known compatibility issue](https://github.com/actions/virtual-environments/issues/2803)
on Ubuntu virtual environment. If PDM parallel install is failed on that machine
you should either set `parallel_install` to `false` or set env
`LD_PRELOAD=/lib/x86_64-linux-gnu/libgcc_s.so.1`. It is already handled by the
`pdm-project/setup-pdm` action.

Note: If your CI scripts run without a proper user set, you might get permission
errors when PDM tries to create its cache directory. To work around this, you
can set the HOME environment variable yourself, to a writable directory, for
example:

````
```bash
export HOME=/tmp/home
```
````

# How does it work

## [Why you don't need to use virtualenvs](https://frostming.com/2021/01-22/introducing-pdm/)

When you develop a Python project, you need to install the project's
dependencies. For a long time, tutorials and articles have told you to use a
virtual environment to isolate the project's dependencies. This way you don't
contaminate the working set of other projects, or the global interpreter, to
avoid possible version conflicts.

### [Problems of the virtualenvs](https://frostming.com/2021/01-22/introducing-pdm/#the-problems-with-virtual-environments)

Virtualenvs are confusing for people that are starting with python. They also
use a lot of space, as many virtualenvs have their own copy of the same
libraries. They help us isolate project dependencies though, but things get
tricky when it comes to nested venvs. One installs the virtualenv manager(like
Pipenv or Poetry) using a venv encapsulated Python, and creates more venvs using
the tool which is based on an encapsulated Python. One day a minor release of
Python is out and one has to check all those venvs and upgrade them if required
before they can safely delete the out-dated Python version.

Another scenario is global tools. There are many tools that are not tied to any
specific virtualenv and are supposed to work with each of them. Examples are
profiling tools and third-party REPLs. We also wish them to be installed in
their own isolated environments. It's impossible to make them work with
virtualenv, even if you have activated the virtualenv of the target project you
want to work on because the tool is lying in its own virtualenv and it can only
see the libraries installed in it. So we have to install the tool for each
project.

The solution has been existing for a long time. PEP 582 was originated in 2018
and is still a draft proposal till the time I copied this article.

Say you have a project with the following structure:

```
.
├── __pypackages__
│   └── 3.8
│       └── lib
└── my_script.py
```

As specified in the PEP 582, if you run `python3.8 /path/to/my_script.py`,
`__pypackages__/3.8/lib` will be added to `sys.path`, and the libraries inside
will become import-able in `my_script.py`.

Now let's review the two problems mentioned above under PEP 582. For the first
problem, the main cause is that the virtual environment is bound to a cloned
Python interpreter on which the subsequent library searching based. It takes
advantage of Python's existing mechanisms without any other complex changes but
makes the entire virtual environment to become unavailable when the Python
interpreter is stale. With the local packages directory, you don't have a Python
interpreter any more, the library path is directly appended to `sys.path`, so
you can freely move and copy it.

For the second, once again, you just call the tool against the project you want
to analyze, and the `__pypackages__` sitting inside the project will be loaded
automatically. This way you only need to keep one copy of the global tool and
make it work with multiple projects.

`pdm` installs dependencies into the local package directory `__package__` and
makes Python interpreters aware of it with
[a very simple setup](#how-we-make-pep-582-packages-available-to-the-python-interpreter).

### [How we make PEP 582 packages available to the Python interpreter](https://pdm.fming.dev/usage/project/#how-we-make-pep-582-packages-available-to-the-python-interpreter)

Thanks to the
[site packages loading](https://docs.python.org/3/library/site.html) on Python
startup. It is possible to patch the `sys.path` by executing the
`sitecustomize.py` shipped with PDM. The interpreter can search the directories
for the nearest `__pypackage__` folder and append it to the `sys.path` variable.

# [Plugins](https://pdm.fming.dev/plugin/write/)

PDM is aiming at being a community driven package manager. It is shipped with a
full-featured plug-in system, with which you can:

- Develop a new command for PDM.
- Add additional options to existing PDM commands.
- Change PDM's behavior by reading dditional config items.
- Control the process of dependency resolution or installation.

If you want to write a plugin, start
[here](https://pdm.fming.dev/plugin/write/#write-your-own-plugin).

# Issues

- You can't still
  [run `mypy` with `pdm`](https://github.com/pdm-project/pdm/issues/811) without
  virtualenvs. pawamoy created a
  [patch](https://github.com/python/mypy/issues/10633#issuecomment-974840203)
  that is supposed to work, but I'd rather use virtualenvs until it's supported.
  Once it's supported check the
  [vim-test](https://github.com/vim-test/vim-test/issues/606) issue to see how
  to integrate it.
- It's not yet supported by
  [dependabot](https://github.com/dependabot/dependabot-core/issues/3190). Once
  supported add it back to the cookiecutter template and spread it.

# References

- [Git](https://github.com/pdm-project/pdm/)
- [Docs](https://pdm.fming.dev/)
