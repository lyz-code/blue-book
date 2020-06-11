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
    from setuptools import find_packages
    from setuptools import setup

    __version__ = '0.1.0'

    setup(
        name='{{ program_name }}',
        version=__version__,
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

* Create the `requirements.txt` file. It should contain the
    `install_requirements` in addition to the testing requirements such as:
    ```
    pytest
    pytest-cov
    ```

* [Configure SQLAlchemy for projects without
    flask](python_sqlalchemy_without_flask.md)
