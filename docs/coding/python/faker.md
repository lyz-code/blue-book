---
title: Faker
date: 20200412
author: Lyz
---

[Faker](https://faker.readthedocs.io/en/master/) is a Python package that
generates fake data for you. Whether you need to bootstrap your database, create
good-looking XML documents, fill-in your persistence to stress test it, or
anonymize data taken from a production service, Faker is for you.

# Install

If you use [factoryboy](factoryboy.md) you'd probably have it. If you don't use

```bash
pip install faker
```

Or add it to the project `requirements.txt`.


# Use

## Generate fake number

```python
fake.random_number()
```

## Generate a fake dictionary

```python
fake.pydict(nb_elements=5, variable_nb_elements=True, *value_types)
```

Where `*value_types` can be `'str', 'list'`


## [Generate a fake date](https://faker.readthedocs.io/en/master/providers/faker.providers.date_time.html)

```python
fake.date_time()
```

# References

* [Git](https://github.com/joke2k/faker)
* [Docs](https://faker.readthedocs.io/en/master/)
* [Faker python
   providers](https://faker.readthedocs.io/en/master/providers/faker.providers.python.html)
