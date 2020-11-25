---
title: Yamlfix
date: 20201125
author: Lyz
---

[Yamlfix](https://lyz-code.github.io/yamlfix/) is a simple opinionated yaml
formatter that keeps your comments.

# Install

```bash
pip install yamlfix
```

# Usage

Imagine we've got the following source code:

```yaml
book_library:
- title: Why we sleep
  author: Matthew Walker
- title: Harry Potter and the Methods of Rationality
  author: Eliezer Yudkowsky
```

It has the following errors:

* There is no `---` at the top.
* The indentation is all wrong.

After running `yamlfix` the resulting source code will be:

```yaml
---
book_library:
  - title: Why we sleep
    author: Matthew Walker
  - title: Harry Potter and the Methods of Rationality
    author: Eliezer Yudkowsky
```

`yamlfix` can be used both as command line tool and as a library.

* As a command line tool:

    ```bash
    $: yamlfix file.yaml
    ```

* As a library:

    ```python
    from yamlfix import fix_files

    fix_files(['file.py'])
    ```

# References

* [Git](https://github.com/lyz-code/yamlfix)
* [Docs](https://lyz-code.github.io/yamlfix/)
