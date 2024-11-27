---
title: Requests mock
date: 20200603
author: Lyz
---

The [requests-mock
library](https://requests-mock.readthedocs.io/en/latest/index.html) is
a [requests transport
adapter](http://docs.python-requests.org/en/latest/user/advanced/#transport-adapters)
that can be preloaded with responses that are returned if certain URIs are
requested. This is particularly useful in unit tests where you want to return
known responses from HTTP requests without making actual calls.

# Installation

```bash
pip install requests-mock
```

# Usage

## Object initialization

Select one of the following ways to initialize the mock.

### [As a pytest fixture](https://requests-mock.readthedocs.io/en/latest/pytest.html)

The ease of use with pytest it is awesome. `requests-mock` provides an external
fixture registered with pytest such that it is usable simply by specifying it as
a parameter. There is no need to import requests-mock it simply needs to be
installed and specified as an argument in the test definition.

```python
import pytest
import requests
from requests_mock.mocker import Mocker


def test_url(requests_mock: Mocker):
    requests_mock.get('http://test.com', text='data')
    assert 'data' == requests.get('http://test.com').text
```

### [As a function decorator](https://requests-mock.readthedocs.io/en/latest/mocker.html#decorator)

```python
>>> @requests_mock.Mocker()
... def test_function(m):
...     m.get('http://test.com', text='resp')
...     return requests.get('http://test.com').text
...
>>> test_function()
'resp'
```

### [As a context manager](https://requests-mock.readthedocs.io/en/latest/mocker.html#context-manager)

```python
>>> import requests
>>> import requests_mock

>>> with requests_mock.Mocker() as m:
...     m.get('http://test.com', text='resp')
...     requests.get('http://test.com').text
...
'resp'
```

## [Mocking responses](https://requests-mock.readthedocs.io/en/latest/response.html)

### [Return a json](https://requests-mock.readthedocs.io/en/latest/response.html#registering-responses)

```python
requests_mock.get(
    '{}/api/repos/owner/repository/builds'.format(self.url),
    json={
        "id": 882,
        "number": 209,
        "finished": 1591197904,
    },
)
```

### Add a header or a cookie to the response

```python
requests_mock.post(
    "https://test.com",
    cookies={"Id": "0"},
    headers={"id": "0"},
)
```

### [Multiple responses](https://requests-mock.readthedocs.io/en/latest/response.html#response-lists)

Multiple responses can be provided to be returned in order by specifying the
keyword parameters in a list.

```python
requests_mock.get(
    'https://test.com/4',
    [
        {'text': 'resp1', 'status_code': 300},
        {'text': 'resp2', 'status_code': 200}
    ]
)
```

## [Get requests history](https://requests-mock.readthedocs.io/en/latest/history.html)

### [Called](https://requests-mock.readthedocs.io/en/latest/history.html#called)

The easiest way to test if a request hit the adapter is to simply check the
called property or the call_count property.

```python
>>> import requests
>>> import requests_mock

>>> with requests_mock.mock() as m:
...     m.get('http://test.com, text='resp')
...     resp = requests.get('http://test.com')
...
>>> m.called
True
>>> m.call_count
1
```

### [Requests history](https://requests-mock.readthedocs.io/en/latest/history.html#request-objects)

The history of objects that passed through the mocker/adapter can also be
retrieved.

```python
>>> history = m.request_history
>>> len(history)
1
>>> history[0].method
'GET'
>>> history[0].url
'http://test.com/'
```

# References

* [Docs](https://requests-mock.readthedocs.io/en/latest/index.html)
* [Git](https://github.com/jamielennox/requests-mock)
