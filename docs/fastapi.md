---
title: FastAPI
date: 20210414
author: Lyz
---

[FastAPI](https://fastapi.tiangolo.com/) is a modern, fast (high-performance),
web framework for building APIs with Python 3.6+ based on standard Python type
hints.

The [key features](https://fastapi.tiangolo.com/features/) are:

* Fast: Very high performance, on par with NodeJS and Go (thanks to Starlette
    and Pydantic). One of the fastest Python frameworks available.
* Fast to code: Increase the speed to develop features by about 200% to 300%.
* Fewer bugs: Reduce about 40% of human (developer) induced errors.
* Intuitive: Great editor support. Completion everywhere. Less time debugging.
* Easy: Designed to be easy to use and learn. Less time reading docs.
* Short: Minimize code duplication. Multiple features from each parameter
    declaration. Fewer bugs.
* Robust: Get production-ready code. With automatic interactive documentation.
* Standards-based: Based on (and fully compatible with) the open standards for
    APIs: OpenAPI (previously known as Swagger) and JSON Schema.
* [Authentication with
    JWT](https://fastapi.tiangolo.com/tutorial/security/first-steps/): with
    a super nice tutorial on how to set it up.

# [Installation](https://fastapi.tiangolo.com/#installation)

```bash
pip install fastapi
```

You will also need an ASGI server, for production such as Uvicorn or Hypercorn.

```bash
pip install uvicorn[standard]
```

# [Simple example](https://fastapi.tiangolo.com/#installation)

* Create a file `main.py` with:

    ```python
    from typing import Optional

    from fastapi import FastAPI

    app = FastAPI()


    @app.get("/")
    def read_root():
        return {"Hello": "World"}


    @app.get("/items/{item_id}")
    def read_item(item_id: int, q: Optional[str] = None):
        return {"item_id": item_id, "q": q}
    ```

*  Run the server:

    ```bash
    uvicorn main:app --reload
    ```

* Open your browser at http://127.0.0.1:8000/items/5?q=somequery. You will see the JSON response as:

    ```json
    {"item_id": 5, "q": "somequery"}
    ```

You already created an API that:

* Receives HTTP requests in the paths `/` and `/items/{item_id}`.
* Both paths take GET operations (also known as HTTP methods).
* The path `/items/{item_id}` has a path parameter `item_id` that should be an
    `int`.
* The path `/items/{item_id}` has an optional `str` query parameter `q`.
* Has interactive API docs made for you:
    * Swagger: http://127.0.0.1:8000/docs.
    * Redoc: http://127.0.0.1:8000/redoc.

You will see the automatic interactive API documentation (provided by Swagger UI):

# Interesting features to explore

* [Testing](https://fastapi.tiangolo.com/tutorial/testing/)
* [Deploy with Docker](https://fastapi.tiangolo.com/deployment/docker/)
* [Set authentication](https://fastapi.tiangolo.com/tutorial/security/first-steps/)
* [Host behind a proxy](https://fastapi.tiangolo.com/advanced/behind-a-proxy/)

# References

* [Docs](https://fastapi.tiangolo.com/)
* [Git](https://github.com/tiangolo/fastapi)
