[`aiohttp`](https://docs.aiohttp.org/en/stable/) is an asynchronous HTTP Client/Server for asyncio and Python. Think of it as the `requests` for asyncio.

# [Installation](https://docs.aiohttp.org/en/stable/#library-installation)

```bash
pip install aiohttp
```

`aiohttp` can be bundled with optional libraries to speed up the DNS resolving and other niceties, install it with:

```bash
pip install aiohttp[speedups]
```

Beware though that some of them [don't yet support Python 3.10+](https://github.com/PyYoshi/cChardet/issues/77)

# Usage

## [Basic example](https://docs.aiohttp.org/en/stable/#client-example)

```python
import aiohttp
import asyncio

async def main():

    async with aiohttp.ClientSession() as session:
        async with session.get('http://python.org') as response:

            print("Status:", response.status)
            print("Content-type:", response.headers['content-type'])

            html = await response.text()
            print("Body:", html[:15], "...")

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

This prints:

```
Status: 200
Content-type: text/html; charset=utf-8
Body: <!doctype html> ...
```

Why so many lines of code? [Check it out here](#why-so-many-lines-of-code).

## [Make a request](https://docs.aiohttp.org/en/stable/client_quickstart.html#make-a-request)

With the snippet from the [basic example](#basic-example) we have a [`ClientSession`](https://docs.aiohttp.org/en/stable/client_reference.html#aiohttp.ClientSession) called `session` and a [`ClientResponse`](https://docs.aiohttp.org/en/stable/client_reference.html#aiohttp.ClientResponse) object called `response`. 

In order to make an HTTP POST request use `ClientSession.post()` coroutine:

```python
session.post('http://httpbin.org/post', data=b'data')
```

Other HTTP methods are available as well:

```python
session.put('http://httpbin.org/put', data=b'data')
session.delete('http://httpbin.org/delete')
session.head('http://httpbin.org/get')
session.options('http://httpbin.org/get')
session.patch('http://httpbin.org/patch', data=b'data')
```

To make several requests to the same site more simple, the parameter `base_url` of `ClientSession` constructor can be used. For example to request different endpoints of http://httpbin.org can be used the following code:

```python
async with aiohttp.ClientSession('http://httpbin.org') as session:
    async with session.get('/get'):
        pass
    async with session.post('/post', data=b'data'):
        pass
    async with session.put('/put', data=b'data'):
        pass
```

Use the `response.raise_for_status()` method to raise an exception if the status code is higher than 400.

### [Passing parameters in urls](https://docs.aiohttp.org/en/stable/client_quickstart.html#passing-parameters-in-urls)

You often want to send some sort of data in the URL’s query string. If you were constructing the URL by hand, this data would be given as key/value pairs in the URL after a question mark, e.g. httpbin.org/get?key=val. Requests allows you to provide these arguments as a dict, using the params keyword argument. As an example, if you wanted to pass `key1=value1` and `key2=value2` to httpbin.org/get, you would use the following code:

```python
params = {'key1': 'value1', 'key2': 'value2'}
async with session.get('http://httpbin.org/get',
                       params=params) as resp:
    expect = 'http://httpbin.org/get?key1=value1&key2=value2'
    assert str(resp.url) == expect
```

You can see that the URL has been correctly encoded by printing the URL.

### [Passing a json in the request](https://docs.aiohttp.org/en/stable/client_quickstart.html#json-request)

There’s also a built-in JSON decoder, in case you’re dealing with JSON data:

```python
async with session.get('https://api.github.com/events') as resp:
    print(await resp.json())
```

In case that JSON decoding fails, `json()` will raise an exception. 

### [Setting custom headers](https://docs.aiohttp.org/en/stable/client_advanced.html#custom-request-headers)

If you need to add HTTP headers to a request, pass them in a `dict` to the `headers` parameter.

For example, if you want to specify the content-type directly:

```python
url = 'http://example.com/image'
payload = b'GIF89a\x01\x00\x01\x00\x00\xff\x00,\x00\x00'
          b'\x00\x00\x01\x00\x01\x00\x00\x02\x00;'
headers = {'content-type': 'image/gif'}

await session.post(url,
                   data=payload,
                   headers=headers)
```

You also can set default headers for all session requests:

```python
headers={"Authorization": "Basic bG9naW46cGFzcw=="}
async with aiohttp.ClientSession(headers=headers) as session:
    async with session.get("http://httpbin.org/headers") as r:
        json_body = await r.json()
        assert json_body['headers']['Authorization'] == \
            'Basic bG9naW46cGFzcw=='
```

Typical use case is sending JSON body. You can specify content type directly as shown above, but it is more convenient to use special keyword json:

```python
await session.post(url, json={'example': 'text'})
```

For `text/plain`

```python
await session.post(url, data='Привет, Мир!')
```

### [Set custom cookies](https://docs.aiohttp.org/en/stable/client_advanced.html#custom-cookies)

To send your own cookies to the server, you can use the cookies parameter of `ClientSession` constructor:

```python
url = 'http://httpbin.org/cookies'
cookies = {'cookies_are': 'working'}
async with ClientSession(cookies=cookies) as session:
    async with session.get(url) as resp:
        assert await resp.json() == {
           "cookies": {"cookies_are": "working"}}
```

### [Proxy support](https://docs.aiohttp.org/en/stable/client_advanced.html#proxy-support)

`aiohttp` supports plain HTTP proxies and HTTP proxies that can be upgraded to HTTPS via the HTTP CONNECT method. To connect, use the proxy parameter:

```python
async with aiohttp.ClientSession() as session:
    async with session.get("http://python.org",
                           proxy="http://proxy.com") as resp:
        print(resp.status)
```

It also supports proxy authorization:

```python
async with aiohttp.ClientSession() as session:
    proxy_auth = aiohttp.BasicAuth('user', 'pass')
    async with session.get("http://python.org",
                           proxy="http://proxy.com",
                           proxy_auth=proxy_auth) as resp:
        print(resp.status)
```

Authentication credentials can be passed in proxy URL:

```python
session.get("http://python.org",
            proxy="http://user:pass@some.proxy.com")
```

Contrary to the `requests` library, it won’t read environment variables by default. But you can do so by passing `trust_env=True` into `aiohttp.ClientSession` constructor for extracting proxy configuration from `HTTP_PROXY`, `HTTPS_PROXY`, `WS_PROXY` or `WSS_PROXY` environment variables (all are case insensitive):

```python
async with aiohttp.ClientSession(trust_env=True) as session:
    async with session.get("http://python.org") as resp:
        print(resp.status)
```

## [How to use the `ClientSession`](https://docs.aiohttp.org/en/stable/http_request_lifecycle.html#how-to-use-the-clientsession)

By default the `aiohttp.ClientSession` object will hold a connector with a maximum of 100 connections, putting the rest in a queue. This is quite a big number, this means you must be connected to a hundred different servers (not pages!) concurrently before even having to consider if your task needs resource adjustment.

In fact, you can picture the session object as a user starting and closing a browser: it wouldn’t make sense to do that every time you want to load a new tab.

So you are expected to reuse a `session` object and make many requests from it. For most scripts and average-sized software, this means you can create a single session, and reuse it for the entire execution of the program. You can even pass the session around as a parameter in functions. For example, the typical “hello world”:

```python
import aiohttp
import asyncio

async def main():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://python.org') as response:
            html = await response.text()
            print(html)

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

Can become this:

```python
import aiohttp
import asyncio

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        html = await fetch(session, 'http://python.org')
        print(html)

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

When to create more than one session object then? It arises when you want more granularity with your resources management:

- You want to group connections by a common configuration. e.g: sessions can set cookies, headers, timeout values, etc. that are shared for all connections they hold.
- You need several threads and want to avoid sharing a mutable object between them.
- You want several connection pools to benefit from different queues and assign priorities. e.g: one session never uses the queue and is for high priority requests, the other one has a small concurrency limit and a very long queue, for non important requests.

# [An aiohttp adapter](https://codereview.stackexchange.com/questions/269049/python-restclient-class-with-asyncio-and-aiohttp)

```python
import asyncio
import aiohttp
import json

from dataclasses import dataclass


@dataclass
class Config:
    verify_ssl: bool = True
    tcp_connections: int = 5


class Http:
    """A generic HTTP Rest adapter."""

    def __init__(self, config: Optional[Config] = None) -> None:
        self.config = Config() if config is None else config

    async def __aenter__(self) -> 'Http':
        self._con = aiohttp.TCPConnector(
            verify_ssl=self.config.verify_ssl, limit=self.config.tcp_connections
        )
        self._session = aiohttp.ClientSession(connector=self._con)
        return self

    async def __aexit__(self, exc_type, exc, tb) -> None:
        await self._session.close()
        await self._con.close()

    async def request(
        self,
        url: str,
        method: str = 'get',
        query_param: Optional[Dict] = None,
        headers: Optional[Dict] = None,
        body: Optional[Dict] = None,
    ) -> aiohttp.ClientResponse:
        """Performs an Async HTTP request.

        Args:
            method (str): request method ('GET', 'POST', 'PUT', ).
            url (str): request url.
            query_param (dict or None): url query parameters.
            header (dict or None): request headers.
            body (json or None): request body in case of method POST or PUT.
        """
        method = method.upper()
        headers = headers or {}

        if method == "GET":
            log.debug(f"Fetching page {url}")
            async with self._session.get(
                url, params=query_param, headers=headers
            ) as response:
                if response.status != 200:
                    log.debug(f"{url} returned an {response.status} code")
                    response.raise_for_status()
                return response


async def main():
    async with Http() as client:
        print(await client.request(method="GET", url="https://httpbin.org/get"))


if __name__ == "__main__":
    asyncio.run(main) 
```

# [Why so many lines of code](https://docs.aiohttp.org/en/stable/http_request_lifecycle.html#aiohttp-request-lifecycle)

The first time you use `aiohttp`, you’ll notice that a simple HTTP request is performed not with one, but with up to three steps:

```python
async with aiohttp.ClientSession() as session:
    async with session.get('http://python.org') as response:
        print(await response.text())
```

It’s especially unexpected when coming from other libraries such as the very popular requests, where the “hello world” looks like this:

```python
response = requests.get('http://python.org')
print(response.text)
```

So why is the `aiohttp` snippet so verbose?

Because `aiohttp` is asynchronous, its API is designed to make the most out of non-blocking network operations. In code like this, requests will block three times, and does it transparently, while `aiohttp` gives the event loop three opportunities to switch context:

- When doing the `.get()`, both libraries send a GET request to the remote server. For `aiohttp`, this means asynchronous I/O, which is marked here with an async with that gives you the guarantee that not only it doesn’t block, but that it’s cleanly finalized.
- When doing `response.text` in `requests`, you just read an attribute. The call to `.get()` already preloaded and decoded the entire response payload, in a blocking manner. `aiohttp` loads only the headers when `.get()` is executed, letting you decide to pay the cost of loading the body afterward, in a second asynchronous operation. Hence the await `response.text()`.
- `async with aiohttp.ClientSession()` does not perform I/O when entering the block, but at the end of it, it will ensure all remaining resources are closed correctly. Again, this is done asynchronously and must be marked as such. The session is also a performance tool, as it manages a pool of connections for you, allowing you to reuse them instead of opening and closing a new one at each request. You can even manage the pool size by passing a connector object.

# References

- [Docs](https://docs.aiohttp.org/en/stable/)
