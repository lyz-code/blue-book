---
title: Pip-tools
date: 20201016
author: Lyz
---

[Pip-tools](https://github.com/jazzband/pip-tools) is a set of command line
tools to help you keep your pip-based packages fresh, even when you've pinned
them.

For stability reasons it's a good idea to hardcode the dependencies versions.
Furthermore, [safety](safety.md) needs them to work properly.

We've got three places where the dependencies are defined:

* `setup.py` should declare the loosest possible dependency versions that are
    still workable. Its job is to say what a particular package can work with.
* `requirements.txt` is a deployment manifest that defines an entire
    installation job, and shouldn't be thought of as tied to any one package.
    Its job is to declare an exhaustive list of all the necessary packages to
    make a deployment work.
* `dev-requirements.txt` Adds the dependencies required for development of the
    program.

With pip-tools, the dependency management is trivial.

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
