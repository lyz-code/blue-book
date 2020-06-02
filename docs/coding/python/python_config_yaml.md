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
    from yaml.scanner import ScannerError

    import logging
    import os
    import yaml
    import sys

    log = logging.getLogger(__name__)


    class Config(UserDict):
        """
        Class to manipulate the configuration of the program.

        Arguments:
            config_path (str): Path to the configuration file.
                Default: ~/.local/share/{{ program_name }}/config.yaml

        Public methods:
            load: Loads configuration from configuration YAML file.
            save: Saves configuration in the configuration YAML file.

        Attributes and properties:
            data(dict): Program configuration.
        """

        def __init__(self, config_path='~/.local/share/{{ program_name }}/config.yaml'):
            self.load(os.path.expanduser(config_path))

        def load(self, yaml_path):
            """
            Loads configuration from configuration YAML file.

            Arguments:
                yaml_path(str): Path to the file to open.
            """
            try:
                with open(os.path.expanduser(yaml_path), 'r') as f:
                    try:
                        self.data = yaml.safe_load(f)
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
                    'Error opening configuration file {}'.format(yaml_path)
                )
                sys.exit(1)

        def save(self, yaml_path):
            """
            Saves configuration in the configuration YAML file.

            Arguments:
                yaml_path(str): Path to the file to save.
            """

            with open(os.path.expanduser(yaml_path), 'w+') as f:
                yaml.dump(self.data, f, default_flow_style=False)
    ```

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

Variables to substitute:

* `program_name`
* `string_in_config_file`: Some string that is present in the config


As it's really dependent in the config structure, you can improve the
`test_config_load` test to make it more meaningful.

!!! note "File tests/unit/test_configuration.py"
    ```python
    from {{ program_name }}.configuration import Config
    from unittest.mock import patch
    from yaml.scanner import ScannerError

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
            self.log_patch = patch('{{ program_name }}.configuration.logging', autospect=True)
            self.log = self.log_patch.start()
            self.sys_patch = patch('{{ program_name }}.configuration.sys', autospect=True)
            self.sys = self.sys_patch.start()

            self.config = Config(self.config_path)
            yield 'setup'

            self.log_patch.stop()
            self.sys_patch.stop()

        def test_config_load(self):
            self.config.load(self.config_path)
            assert len(self.config.data) > 0

        @patch('{{ program_name }}.configuration.yaml')
        def test_load_handles_wrong_file_format(self, yamlMock):
            yamlMock.safe_load.side_effect = ScannerError(
                'error',
                '',
                'problem',
                'mark',
            )

            self.config.load(self.config_path)
            self.log.error.assert_called_once_with(
                'Error parsing yaml of configuration file mark: problem'
            )
            self.sys.exit.assert_called_once_with(1)

        @patch('{{ program_name }}.configuration.open')
        def test_load_handles_file_not_found(self, openMock):
            openMock.side_effect = FileNotFoundError()

            self.config.load(self.config_path)
            self.log.error.assert_called_once_with(
                'Error opening configuration file {}'.format(
                    self.config_path
                )
            )
            self.sys.exit.assert_called_once_with(1)

        @patch('{{ program_name }}.configuration.Config.load')
        def test_init_calls_config_load(self, loadMock):
            Config()
            loadMock.assert_called_once_with(
                os.path.expanduser('~/.local/share/{{ program_name }}/config.yaml')
            )

        def test_save_config(self):
            tmp = tempfile.mkdtemp()
            save_file = os.path.join(tmp, 'yaml_save_test.yaml')
            self.config.save(save_file)
            with open(save_file, 'r') as f:
                assert "{{ string_in_config_file }}" in f.read()

            shutil.rmtree(tmp)
    ```
