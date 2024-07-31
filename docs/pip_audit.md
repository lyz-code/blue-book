[`pip-audit`](https://github.com/pypa/pip-audit) is the official pypa tool for scanning Python environments for packages with known vulnerabilities. It uses the Python Packaging Advisory Database (https://github.com/pypa/advisory-database) via the PyPI JSON API as a source of vulnerability reports.

# Installation

```bash
pip install pip-audit
```

# Usage

```bash
pip-audit
```
On completion, pip-audit will exit with a code indicating its status.

The current codes are:

- `0`: No known vulnerabilities were detected.
- `1`: One or more known vulnerabilities were found.

pip-audit's exit code cannot be suppressed. See [Suppressing exit codes from pip-audit](https://github.com/pypa/pip-audit?tab=readme-ov-file#suppressing-exit-codes-from-pip-audit) for supported alternatives.
# References
- [Code](https://github.com/pypa/pip-audit)
