---
title: Requests
date: 20210128
author: Lyz
---

[Requests](https://requests.readthedocs.io) is an elegant and simple HTTP
library for Python, built for human beings.

# Installation

```bash
pip install requests
```

# Usage

## Download file

```python
url = "http://beispiel.dort/ichbineinbild.jpg"
filename = url.split("/")[-1]
r = requests.get(url, timeout=0.5)

if r.status_code == 200:
    with open(filename, 'wb') as f:
        f.write(r.content)
```

## Encode url

```python
requests.utils.quote('/test', safe='')
```

## Get

```python
requests.get('{{ url }}')
```

## Put url

```python
requests.put({{ url }})
```

## [Put json data url](https://stackoverflow.com/questions/9733638/post-json-using-python-requests)

```python
data = {"key": "value"}
requests.put({{ url }} json=data)
```

## [Use cookies between requests](https://stackoverflow.com/questions/31554771/how-to-use-cookies-in-python-requests)

You can use [Session
objects](https://requests.readthedocs.io/en/master/user/advanced/#session-objects)
to persists cookies or default data across all requests.

```python
s = requests.Session()

s.get('https://httpbin.org/cookies/set/sessioncookie/123456789')
r = s.get('https://httpbin.org/cookies')

print(r.text)
# '{"cookies": {"sessioncookie": "123456789"}}'

s.auth = ('user', 'pass')
s.headers.update({'x-test': 'true'})

# both 'x-test' and 'x-test2' are sent
s.get('https://httpbin.org/headers', headers={'x-test2': 'true'})
```

# References

* [Docs](https://requests.readthedocs.io)
