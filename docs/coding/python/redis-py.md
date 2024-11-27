---
title: Redis-py
date: 20200528
author: Lyz
---

Redis-py is The Python interface to the [Redis](redis.md) key-value store.

The library encapsulates an actual TCP connection to a Redis server and sends
raw commands, as bytes serialized using the [REdis Serialization Protocol
(RESP)](https://redis.io/topics/protocol), to the server. It then takes the raw
reply and parses it back into a Python object such as bytes, int, or even
datetime.datetime.

# Installation

```bash
pip install redis
```

# Usage

```python
import redis
r = redis.Redis(
    host='localhost',
    port=6379,
    db=0,
    password=None,
    socket_timeout=None,
)
```

The arguments specified above are the default ones, so it's the same as calling
`r = redis.Redis()`.

The `db` parameter is the database number. You can manage multiple databases in
Redis at once, and each is identified by an integer. The max number of databases
is 16 by default.

# Common pitfalls

* Redis returned objects are *bytes* type, so you may need to convert it to
    string with `r.get("Bahamas").decode("utf-8")`.


# References

* [Real Python introduction to Redis-py](https://realpython.com/python-redis/)
* [Git](https://github.com/andymccurdy/redis-py)
* [Docs](https://redis-py.readthedocs.io/en/stable/#): Very technical and small.
