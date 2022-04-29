---
title: Pip-tools
date: 20201016
author: Lyz
---

!!! warning "Deprecated: Use [poetry](python_poetry.md) instead."

[Pip-tools](https://github.com/jazzband/pip-tools) is a set of command line
tools to help you keep your pip-based packages fresh, even when you've pinned
them.

For stability reasons it's a good idea to hardcode the dependencies versions.
Furthermore, [safety](safety.md) needs them to work properly.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `pip-tools` already configured.

We've got three places where the dependencies are defined:

* `setup.py` should declare the loosest possible dependency versions that are
    still workable. Its job is to say what a particular package can work with.
* `requirements.txt` is a deployment manifest that defines an entire
    installation job, and shouldn't be thought of as tied to any one package.
    Its job is to declare an exhaustive list of all the necessary packages to
    make a deployment work.
* `requirements-dev.txt` Adds the dependencies required for the development of
    the program.

!!! note "Content of examples may be outdated"

    An updated version of
    [setup.py](https://github.com/lyz-code/cookiecutter-python-project/blob/master/setup.py)
    and
    [requirements-dev.in](https://github.com/lyz-code/cookiecutter-python-project/blob/master/setup.py)
    can be found in the [cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project/).

With pip-tools, the dependency management is trivial.

*   Install the tool:

    ```bash
    pip install pip-tools
    ```

* Set the general dependencies in the `setup.py` `install_requires`.

* Generate the `requirements.txt` file:

    ```bash
    pip-compile -U --allow-unsafe`
    ```

    The `-U` flag will try to upgrade the dependencies, and `--allow-unsafe`
    will let you manage the `setuptools` and `pip` dependencies.

* Add the additional testing dependencies in the `requirements-dev.in` file.

    !!! note "File: requirements-dev.in"

        ```
        -c requirements.txt
        pip-tools
        factory_boy
        pytest
        pytest-cov
        ```

    The `-c` line will make `pip-compile` look at that file for compatibility,
    but it won't duplicate those requirements in the `requirements-dev.txt`.

* Compile the development requirements `requirements-dev.txt` with `pip-compile
    dev-requirements.in`.

* If you have another `requirements.txt` for the mkdocs documentation, run
    `pip-compile docs/requirements.txt`.

* To [sync the virtualenv libraries with the
    files](https://m0wer.github.io/memento/computer_science/programming/python/pip/#pip-sync),
    use `sync`:

    ```python
    python -m piptools sync requirements.txt requirements-dev.txt
    ```

* To [uninstall all pip packages](https://stackoverflow.com/questions/11248073/what-is-the-easiest-way-to-remove-all-packages-installed-by-pip) use
    ```bash
    pip freeze | xargs pip uninstall -y
    ```

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

    pip-tools generates different results in the CI than in the development
    environment breaking the CI without an easy way to fix it. Therefore it
    should be run by the developers periodically.

# References

* [Git](https://github.com/jazzband/pip-tools)
