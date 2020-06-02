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

It's assumed that the root directory of the project has the same name as the
program.

## Code

The class code below is expected to introduced in the file `{{ program_name
}}/config.py`.

Variables to substitute:

* `program_name`

```Python
"""
Module to define the configuration of the main program.

Classes:
    Config: Class to manipulate the configuration of the program.
"""

from collections import UserDict
from yaml import YAMLError

import logging
import os
import yaml
import sys


class Config(UserDict):
    """
    Class to manipulate the configuration of the program.

    Arguments:
        config_path (str): Path to the configuration file.
            Default: ~/.local/share/{{ program_name }}/config.yaml

    Internal methods:

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
                except YAMLError:
                    logging.error(
                        'Error parsing yaml of configuration file {}'.format(
                            yaml_path
                        )
                    )
                    sys.exit(1)
        except FileNotFoundError:
            logging.error(
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

## Tests

The test code below is expected to introduced in the file
`tests/unit/test_config.py`.

Variables to substitute:

* `program_name`
* `string_in_config_file`: Some string that is present in the config

Additionally, the tests need a file with a valid config must be set in
`tests/files/config.yaml`. Once it's done you can improve the `test_config_load`
to make it more meaningful.

```python
from {{ program_name }}.config import Config
from unittest.mock import patch
from yaml import YAMLError

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
        self.config_path = 'tests/files/config.yaml'
        self.log_patch = patch('{{ program_name }}.config.logging', autospect=True)
        self.log = self.log_patch.start()
        self.sys_patch = patch('{{ program_name }}.config.sys', autospect=True)
        self.sys = self.sys_patch.start()

        self.config = Config(self.config_path)
        yield 'setup'

        self.log_patch.stop()
        self.sys_patch.stop()

    def test_config_load(self):
        self.config.load(self.config_path)
        assert len(self.config.data) > 0

    @patch('{{ program_name }}.config.yaml')
    def test_load_handles_wrong_file_format(self, yamlMock):
        yamlMock.safe_load.side_effect = YAMLError('error')

        self.config.load(self.config_path)
        self.log.error.assert_called_once_with(
            'Error parsing yaml of configuration file {}'.format(
                self.config_path
            )
        )
        self.sys.exit.assert_called_once_with(1)

    @patch('{{ program_name }}.config.open')
    def test_load_handles_file_not_found(self, openMock):
        openMock.side_effect = FileNotFoundError()

        self.config.load(self.config_path)
        self.log.error.assert_called_once_with(
            'Error opening configuration file {}'.format(
                self.config_path
            )
        )
        self.sys.exit.assert_called_once_with(1)

    @patch('{{ program_name }}.config.Config.load')
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

