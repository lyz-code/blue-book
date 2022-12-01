---
title: Python elasticsearch
date: 20221130
author: Lyz
---

[Python elasticsearch](https://elasticsearch-py.readthedocs.io/en/latest/) is
the Official low-level client for Elasticsearch. Its goal is to provide common
ground for all Elasticsearch-related code in Python; because of this it tries to
be opinion-free and very extendable.

# [Installation](https://elasticsearch-py.readthedocs.io/en/latest/#installation)

```bash
pip install elasticsearch
```

# Usage

## [Connect to the database](https://elasticsearch-py.readthedocs.io/en/latest/api.html#module-elasticsearch)

```python
from elasticsearch import Elasticsearch

client = Elasticsearch("http://localhost:9200")
```

## Get all indices

```python
client.indices.get(index="*")
```

## Get all documents

```python
resp = client.search(index="test-index", query={"match_all": {}})
documents = resp.body["hits"]["hits"]
```

Use `pprint` to analyze the content of each `document`.

## Update a document

```python
doc = {"partial_document": "value"}
resp = client.update(index=INDEX, id=id_, doc=doc)
```

# References

- [Docs](https://elasticsearch-py.readthedocs.io/en/latest/)
- [Source](https://github.com/elastic/elasticsearch-py)
- [TowardsDataScience article](https://towardsdatascience.com/getting-started-with-elasticsearch-in-python-c3598e718380)
