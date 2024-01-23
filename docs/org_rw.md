[`org-rw`](https://github.com/kenkeiras/org-rw) is a Python library to process your orgmode files.

# Installation

```bash
pip install org-rw
```

# Usage

## Load an orgmode file

```python
from org_rw import load

with open('your_file.org', 'r') as f:
    doc = load(f)
```

# References

- [Source](https://github.com/kenkeiras/org-rw)
