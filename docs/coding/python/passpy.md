---
title: Passpy
date: 20201015
author: Lyz
---

[passpy](https://github.com/bfrascher/passpy) a platform independent library and
cli that is compatible with [ZX2C4's pass](http://www.passwordstore.org/).

# Installation

```bash
pip install passpy
```

# [Usage](https://passpy.readthedocs.io/en/latest/tutorial.html#library)

To use `passpy` in your Python project, we will first have to create a
new `passpy.store.Store` object.

```python
import passpy

store = passpy.Store()
```

If `git` or `gpg2` are not in your PATH you will have to specify them via
`git_bin` and `gpg_bin` when creating the `store` object.  You can also create
the store on a different folder, be passing `store_dir` along.

To initialize the password store at `store_dir`, if it isn't
already, use

```python
store.init_store('store gpg id')
```

Where `store gpg id` is the name of a GPG ID.  Optionally, git can
be initialized in very much the same way.

```python
store.init_git()
```

You are now ready to interact with the password store.  You can set and get keys
using `passpy.store.Store.set_key` and `passpy.store.Store.get_key`.

`passpy.store.Store.gen_key` generates a new password for a new or existing key.
To delete a key or directory, use `passpy.store.Store.remove_path`.

For a full overview over all available methods see
[store-module-label](https://passpy.readthedocs.io/en/latest/reference.html#store-module-label).

# References

* [Docs](https://passpy.readthedocs.org/)
* [Git](https://github.com/bfrascher/passpy)
