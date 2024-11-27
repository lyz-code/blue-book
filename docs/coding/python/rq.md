---
title: RQ
date: 20200528
author: Lyz
---
[RQ (Redis Queue)](https://python-rq.org/) is a simple Python library for
queueing jobs and processing them in the background with workers. It is backed
by Redis and it is designed to have a low barrier to entry.

!!! note "Check arq"
    Next time you are going to use this, check if
    [arq](https://arq-docs.helpmanual.io/) is better.

# [Getting started](https://python-rq.org/#getting-started)

Assuming that a Redis server is running, define the function you want to run:

```python
import requests

def count_words_at_url(url):
    resp = requests.get(url)
    return len(resp.text.split())
```

The, create a RQ queue:

```python
from redis import Redis
from rq import Queue

q = Queue(connection=Redis())
```

And enqueue the function call:

```python
from my_module import count_words_at_url
result = q.enqueue(
             count_words_at_url, 'http://nvie.com')
```
To start executing enqueued function calls in the background, start a worker
from your project’s directory:

```bash
$ rq worker
*** Listening for work on default
Got count_words_at_url('http://nvie.com') from default
Job result = 818
*** Listening for work on default
```

# [Install](https://python-rq.org/#installation)

```bash
pip install rq
```

# Reference

* [Homepage](https://python-rq.org/)
* [Git](https://github.com/rq/rq)
* [Docs](https://python-rq.org/docs/)
