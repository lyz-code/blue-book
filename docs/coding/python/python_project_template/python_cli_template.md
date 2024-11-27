---
title: Python CLI Project Template
date: 20200605
author: Lyz
---

* Create the tests directories
    ```bash
    mkdir -p tests/unit
    touch tests/__init__.py
    touch tests/unit/__init__.py
    ```

* Create the program module structure
    ```bash
    mkdir {{ program_name }}
    ```

* Create the program `setup.py` file
    ```python
    from setuptools import find_packages, setup

    # Get the version from drode/version.py without importing the package
    exec(compile(open('{{ program_name }}/version.py').read(),
                 '{{ program_name }}/version.py', 'exec'))

    setup(
        name='{{ program_name }}',
        version=__version__, # noqa: F821
        description='{{ program_description }}',
        author='{{ author }}',
        author_email='{{ author_email }}',
        license='GPLv3',
        long_description=open('README.md').read(),
        packages=find_packages(exclude=('tests',)),
        package_data={'{{ program_name }}': [
            'migrations/*',
            'migrations/versions/*',
        ]},
        entry_points={'console_scripts': ['{{ program_name }} = {{ program_name }}:main']},
        install_requires=[
        ]
    )
    ```
    Remember to fill up the `install_requirements` with the dependencies that
    need to be installed at installation time.
* Create the `{{ program_name }}/version.py` file with the following contents:
    ```python
    __version__ = '1.0.0'
    ```

   This ugly way of loading the `__version__` was stolen from youtube-dl, it
   loads and executes the `version.py` without loading the whole module.
   Solutions like `from {{ program_name }}.version import __version__` will fail
   as it tries to load the whole module. Defining it in the `setup.py` file
   doesn't work either if you need to load the version in your program code.
   `from setup.py import __version__` will also fail. The only problem with this
   approach is that as the `__version__` is not defined in the code it will
   raise a Flake8 error, therefore the `#
   noqa: F821` in the `setup.py` code.

* Create the `requirements.txt` file. It should contain the
    `install_requirements` in addition to the testing requirements such as:
    ```
    pytest
    pytest-cov
    ```

* [Configure SQLAlchemy for projects without
    flask](python_sqlalchemy_without_flask.md)
