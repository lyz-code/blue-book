---
title: Flask-RESTplus
date: 20200605
author: Lyz
---

!!! note "Use [FastAPI](fastapi.md) instead"

[Flask-RESTPlus](https://flask-restplus.readthedocs.io/en/stable/) is an
extension for Flask that adds support for quickly building REST APIs.
Flask-RESTPlus encourages best practices with minimal setup. If you are familiar
with Flask, Flask-RESTPlus should be easy to pick up. It provides a coherent
collection of decorators and tools to describe your API and expose its
documentation properly using Swagger.

Over plain flask it adds the following capabilities:

* *It defines namespaces, which are ways of creating prefixes and structuring
    the code*: This helps long-term maintenance and helps with the design when
    creating new endpoints.
* *It has a full solution for parsing input parameters*: This means that we have
    an easy way of dealing with endpoints that requires several parameters
    and validates them.
* *It has a serialization framework for the resulting objects*: This helps to
    define objects that can be reused, clarifying the interface and simplifying
    the development.
* *It has full Swagger API documentation support*.

# Install

```bash
pip install flask-restplus
```

# References

* [Docs](https://flask-restplus.readthedocs.io/en/stable/)
* [Git](https://github.com/noirbizarre/flask-restplus)
