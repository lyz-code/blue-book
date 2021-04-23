---
title: Ruamel Yaml
date: 20200603
author: Lyz
---

[ruamel.yaml](https://yaml.readthedocs.io/en/latest/overview.html) is a YAML 1.2
loader/dumper package for Python. It is a derivative of Kirill Simonov’s PyYAML
3.11.

It has the following enhancements:

* Comments.
* Block style and key ordering are kept, so you can diff the round-tripped
    source.
* Flow style sequences ( ‘a: b, c, d’).
* Anchor names that are hand-crafted (i.e. not of the form``idNNN``).
* Merges in dictionaries are preserved.

# Installation

I suggest to use the `ruyaml` fork, as it's maintained by the community and
versioned with git.

```bash
pip install ruyaml
```

# Usage

Very similar to PyYAML. If invoked with `YAML(typ='safe')` either the load or
the write of the data, the comments of the yaml will be lost.

## Load from file

```python
from ruamel.yaml import YAML
from ruamel.yaml.scanner import ScannerError

try:
    with open(os.path.expanduser(file_path), 'r') as f:
        try:
            data = YAML().load(f)
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
        'Error opening configuration file {}'.format(file_path)
    )
    sys.exit(1)
```

## Save to file

```python
with open(os.path.expanduser(file_path), 'w+') as f:
    yaml = YAML()
    yaml.default_flow_style = False
    yaml.dump(data, f)
```

## [Save to a string](https://stackoverflow.com/questions/47614862/best-way-to-use-ruamel-yaml-to-dump-to-string-not-to-stream)

For some unknown reason, they don't want to output the result to a string, you
need to mess up with streams.

```python

# Configure YAML formatter
yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.allow_duplicate_keys = True
yaml.explicit_start = False

# Return the output to a string
string_stream = StringIO()
yaml.dump({'products': ['item 1', 'item 2']}, string_stream)
source_code = string_stream.getvalue()
string_stream.close()
```

I've opened [an issue](https://github.com/pycontribs/ruyaml/issues/27) in the
[ruyaml fork](https://github.com/pycontribs/ruyaml) to solve it.

# References

* [Docs](https://yaml.readthedocs.io/en/latest/overview.html)
* [Code](https://sourceforge.net/projects/ruamel-yaml/)
