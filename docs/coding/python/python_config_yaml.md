---
title: Load config from yaml
date: 20200602
author: Lyz
---

Several programs load the configuration from file. After trying ini, json and
yaml I've seen that the last one is the most comfortable.

So here are the templates for the tests and class that loads the data from a yaml file and
exposes it as a dictionary.

In the following sections Jinja templating is used, so substitute everything
between `{{ }}` to their correct values.

It's assumed that:

* The root directory of the project has the same name as the program.
* A file with a valid config exists in `assets/config.yaml`. We'll use this file
    in the documentation, so comment it through.


## Code

The class code below is expected to introduced in the file `configuration.py`.

Variables to substitute:

* `program_name`

!!! note "File {{ program_name }}/configuration.py"
    ```Python
    """
    Module to define the configuration of the main program.

    Classes:
        Config: Class to manipulate the configuration of the program.
    """

    from collections import UserDict
    from ruamel.yaml import YAML
    from ruamel.yaml.scanner import ScannerError

    import logging
    import os
    import sys

    log = logging.getLogger(__name__)


    class Config(UserDict):
        """
        Class to manipulate the configuration of the program.

        Arguments:
            config_path (str): Path to the configuration file.
                Default: ~/.local/share/{{ program_name }}/config.yaml

        Public methods:
            get: Fetch the configuration value of the specified key.
                If there are nested dictionaries, a dot notation can be used.
            load: Loads configuration from configuration YAML file.
            save: Saves configuration in the configuration YAML file.

        Attributes and properties:
            config_path (str): Path to the configuration file.
            data(dict): Program configuration.
        """

        def __init__(self, config_path='~/.local/share/{{ program_name }}/config.yaml'):
            self.config_path = os.path.expanduser(config_path)
            self.load()

        def get(self, key):
            """
            Fetch the configuration value of the specified key. If there are nested
            dictionaries, a dot notation can be used.

            So if the configuration contents are:

            self.data = {
                'first': {
                    'second': 'value'
                },
            }

            self.data.get('first.second') == 'value'

            Arguments:
                key(str): Configuration key to fetch
            """
            keys = key.split('.')
            value = self.data.copy()

            for key in keys:
                value = value[key]

            return value

        def load(self):
            """
            Loads configuration from configuration YAML file.
            """

            try:
                with open(os.path.expanduser(self.config_path), 'r') as f:
                    try:
                        self.data = YAML().load(f)
                    except ScannerError as e:
                        log.error(
                            'Error parsing yaml of configuration file '
                            '{}: {}'.format(
                                e.problem_mark,
                                e.problem,
                            )
                        )
                        sys.exit(1)
            except FileNotFoundError:
                log.error(
                    'Error opening configuration file {}'.format(self.config_path)
                )
                sys.exit(1)

        def save(self):
            """
            Saves configuration in the configuration YAML file.
            """

            with open(os.path.expanduser(self.config_path), 'w+') as f:
                yaml = YAML()
                yaml.default_flow_style = False
                yaml.dump(self.data, f)
    ```
We use [ruamel PyYAML](ruamel_yaml.md) implementation to preserve the file
comments.

That class is meant to be loaded in the main `__init__.py` file, below the
logging configuration (if there is any).

Variables to substitute:

* `program_name`
* `config_environmental_variable`: The optional environmental variable where the
    path to the configuration is set. For example `PYDO_CONFIG`. This will be
    used in the tests to override the default path. We don't load this
    configuration from the program argument parser because it's definition often
    depends on the config file.

!!! note "File {{ program_name}}/__init__.py"
    ```python
    # ...
    # (optional logging definition)

    import os
    from {{ program_name }}.configuration import Config
    config = Config(os.getenv('{{ config_environmental_variable }}', '~/.local/share/{{ program_name }}/config.yaml'))

    # (Rest of the program)
    # ...
    ```

If you want to use the `config` object in a module of your program, import them
from the above file like this:

!!! note "File {{ program_name }}/cli.py"
    ```python
    from {{ program_name }} import config
    ```

## Tests

I feel that the tests should use the default configuration, therefore we're
setting the environmental variable in the `conftest.py` file that gets executed
by pytest in the tests setup.

Variables to substitute:

* `config_environmental_variable`: Same as the one defined in the last section.

!!! note "File tests/conftest.py"
    ```python

    import os

    os.environ[{{ config_environmental_variable }}] = 'assets/config.yaml'
    ```

Variables to substitute:

* `program_name`

As it's really dependent in the config structure, you can improve the
`test_config_load` test to make it more meaningful.

!!! note "File tests/unit/test_configuration.py"
    ```python
    from {{ program_name }}.configuration import Config
    from unittest.mock import patch
    from ruamel.yaml.scanner import ScannerError

    import os
    import pytest
    import shutil
    import tempfile


    class TestConfig:
        """
        Class to test the Config object.

        Public attributes:
            config (Config object): Config object to test
        """

        @pytest.fixture(autouse=True)
        def setup(self):
            self.config_path = 'assets/config.yaml'
            self.log_patch = patch('{{ program_name }}.configuration.log', autospect=True)
            self.log = self.log_patch.start()
            self.sys_patch = patch('{{ program_name }}.configuration.sys', autospect=True)
            self.sys = self.sys_patch.start()

            self.config = Config(self.config_path)
            yield 'setup'

            self.log_patch.stop()
            self.sys_patch.stop()

        def test_get_can_fetch_nested_items_with_dots(self):
            self.config.data = {
                'first': {
                    'second': 'value'
                },
            }

            assert self.config.get('first.second') == 'value'

        def test_config_can_fetch_nested_items_with_dictionary_notation(self):
            self.config.data = {
                'first': {
                    'second': 'value'
                },
            }

            assert self.config['first']['second'] == 'value'

        def test_config_load(self):
            self.config.load()
            assert len(self.config.data) > 0

        @patch('{{ program_name }}.configuration.YAML')
        def test_load_handles_wrong_file_format(self, yamlMock):
            yamlMock.return_value.load.side_effect = ScannerError(
                'error',
                '',
                'problem',
                'mark',
            )

            self.config.load()
            self.log.error.assert_called_once_with(
                'Error parsing yaml of configuration file mark: problem'
            )
            self.sys.exit.assert_called_once_with(1)

        @patch('{{ program_name }}.configuration.open')
        def test_load_handles_file_not_found(self, openMock):
            openMock.side_effect = FileNotFoundError()

            self.config.load()
            self.log.error.assert_called_once_with(
                'Error opening configuration file {}'.format(
                    self.config_path
                )
            )
            self.sys.exit.assert_called_once_with(1)

        @patch('{{ program_name }}.configuration.Config.load')
        def test_init_calls_config_load(self, loadMock):
            Config()
            loadMock.assert_called_once_with()

        def test_save_config(self):
            tmp = tempfile.mkdtemp()
            save_file = os.path.join(tmp, 'yaml_save_test.yaml')
            self.config = Config(save_file)
            self.config.data = {'a': 'b'}

            self.config.save()
            with open(save_file, 'r') as f:
                assert "a:" in f.read()

            shutil.rmtree(tmp)
    ```
## Installation

It's always nice to have the default configuration template (with it's
documentation) when configuring your use case. Therefore we're going to add
a step in the installation process to copy the file.

Variables to substitute in both files:

* `program_name`

!!! note "File setup.py"

    ```python
    import shutil
    ...

    Class PostInstallCommand(install):
        ...

        def run(self):
            install.run(self)
            try:
                data_directory = os.path.expanduser("~/.local/share/{{ program_name }}")
                os.makedirs(data_directory)
                log.info("Data directory created")
            except FileExistsError:
                log.info("Data directory already exits")

            config_path = os.path.join(data_directory, 'config.yaml')
            if os.path.isfile(config_path) and os.access(config_path, os.R_OK):
                log.info(
                    "Configuration file already exists, check the documentation "
                    "for the new version changes."
                )
            else:
                shutil.copyfile('assets/config.yaml', config_path)
                log.info("Copied default configuration template")

    ```

* `assets_url`: Url pointing to the assets file, similar to
    `https://github.com/lyz-code/pydo/blob/master/assets/config.yaml`.
!!! note "README.md"
    ...

    `{{ program_name }}` configuration is done through the yaml file located at
    `~/.local/share/{{ program_name }}/config.yaml`. The [default
    template]({{ assets_url }}) is
    provided at installation time.

    ...

It's also necessary to add the `ruamel.yaml` pip package to your `setup.py` and
`requirements.txt` files.
