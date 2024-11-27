---
title: Pytest httpserver
date: 20220128
author: Lyz
---

[pytest-httpserver](https://pytest-httpserver.readthedocs.io/en/latest/index.html)
is a python package which allows you to start a real HTTP server for your tests.
The server can be configured programmatically to how to respond to requests.

# Installation

```bash
pip install pytest-httpserver
```

# [Usage](https://pytest-httpserver.readthedocs.io/en/latest/index.html)

```python


import requests

def test_json_client(httpserver: HTTPServer):
    httpserver.expect_request("/foobar").respond_with_json({"foo": "bar"})
    assert requests.get(httpserver.url_for("/foobar")).json() == {'foo': 'bar'}
```

## [Specifying responses](https://pytest-httpserver.readthedocs.io/en/latest/tutorial.html#specifying-responses)

Once you have set up the expected request, it is required to set up the response
which will be returned to the client.

In the example we used `respond_with_json()` but it is also possible to respond
with an arbitrary content.

```python
respond_with_data("Hello world!", content_type="text/plain")
```

In the example above, we are responding a `text/plain` content. You can specify
the status also:

```python
respond_with_data("Not found", status=404, content_type="text/plain")
```

## [Give a dynamic response](https://pytest-httpserver.readthedocs.io/en/latest/tutorial.html#specifying-responses)

If you need to produce dynamic content, use the `respond_with_handler` method,
which accepts a callable (eg. a python function):

```python
from werkzeug.wrappers import Response
from werkzeug.wrappers.request import Request

def my_handler(request: Request) -> Response:
    # here, examine the request object
    return Response("Hello world!")

respond_with_handler(my_handler)
```


# References

* [Docs](https://pytest-httpserver.readthedocs.io/en/latest/index.html)
