[`org-rw`](https://github.com/kenkeiras/org-rw) is a Python library to process your orgmode files.

# Installation

```bash
pip install org-rw
```

# Usage

## Load an orgmode file

```python
from org_rw import loads

doc = loads(Path('your_file.org').read_text())

# or 

from org_rw import load

with open('your_file.org', 'r') as f:
    doc = load(f)

```
## Write to an orgmode file

```python
from org_rw import dumps

Path('your_file.org').write_text(dumps(doc))
```
## [Change the default org-todo-keywords](https://github.com/kenkeiras/org-rw/issues/2)

```python
orig = '''* NEW_TODO_STATE First entry 

* NEW_DONE_STATE Second entry''' 
doc = loads(orig, environment={ 
  'org-todo-keywords': "NEW_TODO_STATE | NEW_DONE_STATE" 
}) 
```
# References

- [Source](https://code.codigoparallevar.com/kenkeiras/org-rw)
- [Github](https://github.com/kenkeiras/org-rw)
