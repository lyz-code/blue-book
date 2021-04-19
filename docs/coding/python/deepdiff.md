---
title: Deepdiff
date: 20200904
author: Lyz
---

The [DeepDiff](https://zepworks.com/deepdiff/5.0.0/index.html) library is
used to perform search and differences in Python objects. It comes with three
operations:

* DeepDiff: Deep Difference of dictionaries, iterables, strings and other
    objects. It will recursively look for all the changes.
* DeepSearch: Search for objects within other objects.
* DeepHash: Hash any object based on their content even if they are not
    “hashable”.

# [Install](https://deepdiff.readthedocs.io/en/latest/index.html#installation)

Install from PyPi:

```bash
pip install deepdiff
```

# [DeepSearch](https://zepworks.com/deepdiff/5.0.0/dsearch.html)

Deep Search inside objects to find the item matching your criteria.

Note that is searches for either the path to match your criteria or the word in
an item.


Examples:

* Importing

    ```python
    from deepdiff import DeepSearch, grep
    ```

DeepSearch comes with `grep` function which is easier to remember!

Search in list for string

```python
>>> obj = ["long somewhere", "string", 0, "somewhere great!"]
>>> item = "somewhere"
>>> ds = obj | grep(item, verbose_level=2)
>>> print(ds)
{'matched_values': {'root[3]': 'somewhere great!', 'root[0]': 'long somewhere'}}
```

Search in nested data for string

```python
>>> obj = ["something somewhere", {"long": "somewhere", "string": 2, 0: 0, "somewhere": "around"}]
>>> item = "somewhere"
>>> ds = obj | grep(item, verbose_level=2)
>>> pprint(ds, indent=2)
{ 'matched_paths': {"root[1]['somewhere']": 'around'},
  'matched_values': { 'root[0]': 'something somewhere',
                      "root[1]['long']": 'somewhere'}}
```

To obtain the keys and values of the matched objects, you can use the
[Extract](https://zepworks.com/deepdiff/5.0.0/extract.html) object.

```python
>>> from deepdiff import grep
>>> obj = {1: [{'2': 'b'}, 3], 2: [4, 5]}
>>> result = obj | grep(5)
>>> result
{'matched_values': OrderedSet(['root[2][1]'])}
>>> result['matched_values'][0]
'root[2][1]'
>>> path = result['matched_values'][0]
>>> extract(obj, path)
5
```

# References

* [Homepage/Docs](https://zepworks.com/deepdiff/5.0.0/index.html)
* [Old Docs](https://deepdiff.readthedocs.io/en/latest/index.html)
