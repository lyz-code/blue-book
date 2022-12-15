---
title: python-gnupg
date: 20221129
author: Lyz
---

[python-gnupg](https://github.com/vsajip/python-gnupg) is a Python library to
interact with `gpg` taking care of the internal details and allows its users to
generate and manage keys, encrypt and decrypt data, and sign and verify
messages.

# [Installation](https://github.com/vsajip/python-gnupg#installing-from-pypi)

```bash
pip install python-gnupg
```

# [Usage](https://gnupg.readthedocs.io/en/latest/#getting-started)

You interface to the GnuPG functionality through an instance of the GPG class:

```python
gpg = gnupg.GPG(gnupghome="/path/to/home/directory")
```

- Decrypt a file:

  ```python
  gpg.decrypt_file("path/to/file")
  ```

  Note: You can't pass `Path` arguments to `decrypt_file`.

- [List private keys](https://gnupg.readthedocs.io/en/latest/index.html?highlight=list%20private#listing-keys):

  ```python
  >>> public_keys = gpg.list_keys()
  >>> private_keys = gpg.list_keys(True)
  ```

# References

- [Docs](https://gnupg.readthedocs.io/en/latest/)
- [Source](https://github.com/vsajip/python-gnupg)
- [Issues](https://github.com/vsajip/python-gnupg/issues)
