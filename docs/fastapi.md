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

# Sending data to the server

When you need to send data from a client (let's say, a browser) to your API, you
have three basic options:

* As [path parameters](#path-parameters) in the URL (`/items/2`).
* As [query parameters](#query-parameters) in the URL (`/items/2?skip=true`).
* In the [body](#body-requests) of a POST request.

To send simple data use the first two, to send complex or sensitive data, use the
last.

It also supports sending data through
[cookies](https://fastapi.tiangolo.com/tutorial/cookie-params/) and
[headers](https://fastapi.tiangolo.com/tutorial/header-params/).

## [Path Parameters](https://fastapi.tiangolo.com/tutorial/path-params/)

You can declare path "parameters" or "variables" with the same syntax used by
Python format strings:

```python
@app.get("/items/{item_id}")
def read_item(item_id: int):
    return {"item_id": item_id}
```

If you define the type hints of the function arguments, FastAPI will use
[pydantic](pydantic.md) data validation.

If you need to use a Linux path as an argument, check [this
workaround](https://fastapi.tiangolo.com/tutorial/path-params/#path-parameters-containing-paths),
but be aware that it's not supported by OpenAPI.

### [Order matters](https://fastapi.tiangolo.com/tutorial/path-params/#order-matters)

Because path operations are evaluated in order, you need to make sure that the
path for the fixed endpoint `/users/me` is declared before the variable one
`/users/{user_id}`:

```python
@app.get("/users/me")
async def read_user_me():
    return {"user_id": "the current user"}


@app.get("/users/{user_id}")
async def read_user(user_id: str):
    return {"user_id": user_id}
```

Otherwise, the path for `/users/{user_id}` would match also for `/users/me`,
"thinking" that it's receiving a parameter user_id with a value of "me".

### [Predefined values](https://fastapi.tiangolo.com/tutorial/path-params/#predefined-values)

If you want the possible valid path parameter values to be predefined, you can
use a standard Python `Enum`.

```python
from enum import Enum

class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"

@app.get("/models/{model_name}")
def get_model(model_name: ModelName):
    if model_name == ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}

    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}

    return {"model_name": model_name, "message": "Have some residuals"}
```

These are the basics, FastAPI supports more complex [path parameters and string
validations](https://fastapi.tiangolo.com/tutorial/path-params-numeric-validations/).

## [Query Parameters](https://fastapi.tiangolo.com/tutorial/query-params/)

When you declare other function parameters that are not part of the path
parameters, they are automatically interpreted as "query" parameters.

```python
fake_items_db = [{"item_name": "Foo"}, {"item_name": "Bar"}, {"item_name": "Baz"}]


@app.get("/items/")
async def read_item(skip: int = 0, limit: int = 10):
    return fake_items_db[skip : skip + limit]
```

The query is the set of key-value pairs that go after the `?` in a URL, separated
by `&` characters.

For example, in the URL: http://127.0.0.1:8000/items/?skip=0&limit=10

These are the basics, FastAPI supports more complex [query parameters and string
validations](https://fastapi.tiangolo.com/tutorial/query-params-str-validations/).

## [Request Body](https://fastapi.tiangolo.com/tutorial/body/)

To declare a request body, you use Pydantic models with all their power and
benefits.

```python
from typing import Optional
from pydantic import BaseModel


class Item(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    tax: Optional[float] = None

@app.post("/items/")
async def create_item(item: Item):
    return item
```

With just that Python type declaration, FastAPI will:

* Read the body of the request as JSON.
* Convert the corresponding types (if needed).
* Validate the data: If the data is invalid, it will return a nice and clear
    error, indicating exactly where and what was the incorrect data.
* Give you the received data in the parameter `item`.
* Generate JSON Schema definitions for your model.
* Those schemas will be part of the generated OpenAPI schema, and used by the
    automatic documentation UIs.

These are the basics, FastAPI supports more complex patterns such as:

* [Using multiple models in the same
    query](https://fastapi.tiangolo.com/tutorial/body-multiple-params/).
* [Additional validations of the pydantic
    models](https://fastapi.tiangolo.com/tutorial/body-fields/).
* [Nested models](https://fastapi.tiangolo.com/tutorial/body-nested-models/).

# [Sending data to the client](https://fastapi.tiangolo.com/advanced/response-directly/)

When you create a FastAPI path operation you can normally return any data from
it: a `dict`, a `list`, a Pydantic model, a database model, etc.

By default, FastAPI would automatically convert that return value to JSON using
the `jsonable_encoder`.

To return custom responses such as a direct string, xml or html use
[`Response`](https://fastapi.tiangolo.com/advanced/response-directly/#returning-a-custom-response):

```python
from fastapi import FastAPI, Response

app = FastAPI()


@app.get("/legacy/")
def get_legacy_data():
    data = """<?xml version="1.0"?>
    <shampoo>
    <Header>
        Apply shampoo here.
    </Header>
    <Body>
        You'll have to use soap here.
    </Body>
    </shampoo>
    """
    return Response(content=data, media_type="application/xml")
```

# [Handling errors](https://fastapi.tiangolo.com/tutorial/handling-errors/)

There are many situations in where you need to notify an error to a client that
is using your API.

In these cases, you would normally return an HTTP status code in the range of
400 (from 400 to 499).

This is similar to the 200 HTTP status codes (from 200 to 299). Those "200"
status codes mean that somehow there was a "success" in the request.

To return HTTP responses with errors to the client you use `HTTPException`.

```python
from fastapi import HTTPException

items = {"foo": "The Foo Wrestlers"}


@app.get("/items/{item_id}")
async def read_item(item_id: str):
    if item_id not in items:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"item": items[item_id]}
```

# [Updating data](https://fastapi.tiangolo.com/tutorial/body-updates/)

## [Update replacing with PUT](https://fastapi.tiangolo.com/tutorial/body-updates/#update-replacing-with-put)

To update an item you can use the HTTP PUT operation.

You can use the
[`jsonable_encoder`](https://fastapi.tiangolo.com/tutorial/encoder/) to convert
the input data to data that can be stored as JSON (e.g. with a NoSQL database).
For example, converting datetime to str.

```python
from typing import List, Optional

from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel


class Item(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    tax: float = 10.5
    tags: List[str] = []


items = {
    "foo": {"name": "Foo", "price": 50.2},
    "bar": {"name": "Bar", "description": "The bartenders", "price": 62, "tax": 20.2},
    "baz": {"name": "Baz", "description": None, "price": 50.2, "tax": 10.5, "tags": []},
}


@app.get("/items/{item_id}", response_model=Item)
async def read_item(item_id: str):
    return items[item_id]


@app.put("/items/{item_id}", response_model=Item)
async def update_item(item_id: str, item: Item):
    update_item_encoded = jsonable_encoder(item)
    items[item_id] = update_item_encoded
    return update_item_encoded
```

## [Partial updates with PATCH](https://fastapi.tiangolo.com/tutorial/body-updates/#partial-updates-with-patch)

You can also use the HTTP PATCH operation to partially update data.

This means that you can send only the data that you want to update, leaving the
rest intact.

# OpenAPI configuration

## [Define title, description and version](https://fastapi.tiangolo.com/tutorial/metadata/#title-description-and-version)

```python
from fastapi import FastAPI

app = FastAPI(
    title="My Super Project",
    description="This is a very fancy project, with auto docs for the API and everything",
    version="2.5.0",
)
```

## [Define path tags](https://fastapi.tiangolo.com/tutorial/path-operation-configuration/#tags)

You can add tags to your path operation, pass the parameter tags with a list of
`str` (commonly just one `str`):

```python
from typing import Optional, Set

from pydantic import BaseModel


class Item(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    tax: Optional[float] = None
    tags: Set[str] = []


@app.post("/items/", response_model=Item, tags=["items"])
async def create_item(item: Item):
    return item


@app.get("/items/", tags=["items"])
async def read_items():
    return [{"name": "Foo", "price": 42}]


@app.get("/users/", tags=["users"])
async def read_users():
    return [{"username": "johndoe"}]
```

They will be added to the OpenAPI schema and used by the automatic documentation
interfaces.

### [Add metadata to the tags](https://fastapi.tiangolo.com/tutorial/metadata/#metadata-for-tags)

```python
tags_metadata = [
    {
        "name": "users",
        "description": "Operations with users. The **login** logic is also here.",
    },
    {
        "name": "items",
        "description": "Manage items. So _fancy_ they have their own docs.",
        "externalDocs": {
            "description": "Items external docs",
            "url": "https://fastapi.tiangolo.com/",
        },
    },
]
```


app = FastAPI(openapi_tags=tags_metadata)

## [Add a summary and description](https://fastapi.tiangolo.com/tutorial/path-operation-configuration/#summary-and-description)

```python
@app.post("/items/", response_model=Item, summary="Create an item")
async def create_item(item: Item):
    """
    Create an item with all the information:

    - **name**: each item must have a name
    - **description**: a long description
    - **price**: required
    - **tax**: if the item doesn't have tax, you can omit this
    - **tags**: a set of unique tag strings for this item
    """
    return item
```

## [Response description](https://fastapi.tiangolo.com/tutorial/path-operation-configuration/#response-description)

```python
@app.post(
    "/items/",
    response_description="The created item",
)
async def create_item(item: Item):
    return item
```

## [Deprecate a path operation](https://fastapi.tiangolo.com/tutorial/path-operation-configuration/#deprecate-a-path-operation)

When you need to mark a path operation as deprecated, but without removing it

```python
@app.get("/elements/", tags=["items"], deprecated=True)
async def read_elements():
    return [{"item_id": "Foo"}]
```


# [Testing](https://fastapi.tiangolo.com/tutorial/testing/)

FastAPI gives a [`TestClient` object](https://www.starlette.io/testclient/)
borrowed from [Starlette](https://www.starlette.io) to do the integration tests
on your application.

```python
from fastapi import FastAPI
from fastapi.testclient import TestClient

app = FastAPI()


@app.get("/")
async def read_main():
    return {"msg": "Hello World"}


client = TestClient(app)


def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"msg": "Hello World"}
```

## Test a POST request

```python
result = client.post(
    "/items/",
    headers={"X-Token": "coneofsilence"},
    json={"id": "foobar", "title": "Foo Bar", "description": "The Foo Barters"},
)
```

# Logging to Sentry

FastAPI can [integrate with
Sentry](https://philstories.medium.com/integrate-sentry-to-fastapi-7250603c070f)
or similar [application loggers](python_logging.md) through the [ASGI
middleware](https://fastapi.tiangolo.com/advanced/middleware/#other-middlewares).

# Interesting features to explore

* [Structure big
    applications](https://fastapi.tiangolo.com/tutorial/bigger-applications/).
* [Dependency injection](https://fastapi.tiangolo.com/tutorial/dependencies/).
* [Running background tasks after the request is
    finished](https://fastapi.tiangolo.com/tutorial/background-tasks/).
* [Return a different response
    model](https://fastapi.tiangolo.com/tutorial/response-model/).
* [Upload files](https://fastapi.tiangolo.com/tutorial/request-files/).
* [Deploy with Docker](https://fastapi.tiangolo.com/deployment/docker/).
* [Set
    authentication](https://fastapi.tiangolo.com/tutorial/security/first-steps/).
* [Host behind a proxy](https://fastapi.tiangolo.com/advanced/behind-a-proxy/).
* [Static files](https://fastapi.tiangolo.com/tutorial/static-files/).

# References

* [Docs](https://fastapi.tiangolo.com/)
* [Git](https://github.com/tiangolo/fastapi)

* [Testdriven.io course](https://testdriven.io/courses/tdd-fastapi/): suggested
    by the developer.
