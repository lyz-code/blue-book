---
title: Pipx
date: 20220801
author: Lyz
---

[Pipx](https://pypa.github.io/pipx/) is a command line tool to install and run
Python applications in isolated environments.

Very useful not to pollute your user or device python environments.

# [Installation](https://pypa.github.io/pipx/#on-linux-install-via-pip-requires-pip-190-or-later)

```bash
pip install pipx
```

# Usage

Now that you have pipx installed, you can install a program:

```bash
pipx install PACKAGE
```

for example

```bash
pipx install pycowsay
```

You can list programs installed:

```bash
pipx list
```

Or you can run a program without installing it:

```bash
pipx run pycowsay moooo!
```

You can view documentation for all commands by running pipx --help.

## Upgrade

You can use `pipx upgrade-all` to upgrade all your installed packages. If you
want to just upgrade one, use `pipx upgrade PACKAGE`.

If the package doesn't change the requirements of their dependencies so that the
installed don't meet them, they
[won't be upgraded](https://github.com/pypa/pipx/issues/175) unless you use the
`--pip-args '--upgrade-strategy eager'` flag.

It uses the pip flag `upgrade-strategy` which can be one of:

- `eager`: dependencies are upgraded regardless of whether the currently
  installed version satisfies the requirements of the upgraded package(s).
- `only-if-needed`: dependencies are upgraded only when they do not satisfy the
  requirements of the upgraded package(s). This is the default value.

# Troubleshooting

## [Installing all the binaries the application installs](https://github.com/pypa/pipx/issues/20)

If the package installs more than one binary (for example `ansible`), you need to use the `--install-deps` flag

```bash
pipx install --install-deps ansible
```

## [Upgrading python version of all your pipx packages](https://github.com/pypa/pipx/issues/687)

If you upgrade the main python version and remove the old one (a dist upgrade) then you won't be able to use the installed packages.

If you're lucky enough to have the old one you can use:

```
pipx reinstall-all --python <the Python executable file>
```

Otherwise you need to export all the packages with `pipx list --json > ~/pipx.json`

Then reinstall one by one:

```bash
set -ux
if [[ -e ~/pipx.json ]]; then
	for p in $(cat ~/pipx.json | jq -r '.venvs[].metadata.main_package.package_or_url'); do
		pipx install $p
	done
fi
```

The problem is that this method does not respect the version constrains nor the injects, so you may need to debug each package a bit.
# References

- [Docs](https://pypa.github.io/pipx/)
- [Git](https://github.com/pypa/pipx/)
