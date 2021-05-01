---
title: Tinydb
date: 20200716
author: Lyz
---

[Tinydb](https://tinydb.readthedocs.io/en/latest/usage.html) is a document
oriented database that stores data in a json file. It's the closest solution to
a NoSQL SQLite solution that I've found.

The advantages are that you can use a NoSQL database without installing
a server. Tinydb is [small, simple to use, well tested, optimized and
extensible](https://tinydb.readthedocs.io/en/latest/intro.html). On the other
hand, if you are searching for advanced database features like more than one
connection or high performance, you should consider using databases like SQLite
or MongoDB.

I think it's the perfect solution for initial versions of a program, when the
database schema is variable and there is no need of high performance. Once the
program is stabilized and the performance drops, you can change the storage
provider to a production ready one.

To make this change doable, I recommend implementing the [repository
pattern](repository_pattern.md) to decouple the storage layer from your
application logic.

# Install

```bash
pip install tinydb
```

# [Basic usage](https://tinydb.readthedocs.io/en/latest/getting-started.html#basic-usage)

!!! note "TL;DR: Operation Cheatsheet"
    * *Inserting data*: `db.insert(...)`.
    * *Getting data*:
        * `db.all()`: Get all documents.
        * `iter(db)`: Iterate over all the documents.
        * `db.search(query)`: Get a list of documents matching the query.
    * *Updating*:
        * `db.update(fields, query)`: Update all documents matching the query to contain
            fields.
    * *Removing*:
        * `db.remove(query)`: Remove all documents matching the query.
        * `db.truncate()`: Remove all documents.
    * *Querying*:
    * `Query()`: Create a new query object.
    * `Query().field == 2`: Match any document that has a key field with value `==
        2` (also possible: `!=`, `>`, `>=`, `<`, `<=`).

First you need to setup the database:

```python
from tinydb import TinyDB, Query

db = TinyDB('db.json')
```

TinyDB expects the data to be Python dictionaries:

```python
db.insert({'type': 'apple', 'count': 7})
db.insert({'type': 'peach', 'count': 3})
```

You can also iterate over stored documents:

```python
>>> for item in db:
>>>     print(item)
{'count': 7, 'type': 'apple'}
{'count': 3, 'type': 'peach'}
```

You can search for specific documents:

```python
>>> Fruit = Query()
>>> db.search(Fruit.type == 'peach')
[{'count': 3, 'type': 'peach'}]
>>> db.search(Fruit.count > 5)
[{'count': 7, 'type': 'apple'}]
```

You can update fields:

```python
>>> db.update({'count': 10}, Fruit.type == 'apple')
>>> db.all()
[{'count': 10, 'type': 'apple'}, {'count': 3, 'type': 'peach'}]
```

And remove documents:

```python
>>> db.remove(Fruit.count < 5)
>>> db.all()
[{'count': 10, 'type': 'apple'}]
```

# [Query construction](https://tinydb.readthedocs.io/en/latest/usage.html#queries)

!!! note ""
    * Match any document where a field called `field` exists:
        `Query().field.exists()`.
    * Match any document with the whole field matching the regular expression:
        `Query().field.matches(regex)`.
    * Match any document with a substring of the field matching the regular
        expression: `Query().field.search(regex)`.
    * Match any document for which the function returns `True`:
        `Query().field.test(func, *args)`.
    * If given a query, match all documents where all documents in the list
        field match the query. If given a list, matches all documents where all
        documents in the list field are a member of the given list:
        `Query().field.all(query | list)`.
    * If given a query, match all documents where at least one document in the
        list field match the query. If given a list, matches all documents where
        at least one documents in the list field are a member of the given list:
        `Query().field.any(query | list)`.
    * Match if the field is contained in the list: `Query().field.one_of(list)`.

    Logical operations on queries

    * Match documents that don't match the query: `~ (query)`.
    * Match documents that match both queries: `(query1) & (query2)`.
    * Match documents that match at least one of the queries: `(query1)
        | (query2)`.

To retrieve the data from the database, you need to use `Query` objects in
a similar way as you do with ORMs.

```python
from tinydb import Query

User = Query()
db.search(User.name == 'John')
db.search(User.birthday.year == 1990)
```

If the field is not a valid Python identifier use the following syntax:

```python
db.search(User['country-code'] == 'foo')
```

## [Advanced queries](https://tinydb.readthedocs.io/en/latest/usage.html#advanced-queries)

TinyDB supports other ways to search in your data:

* Testing the existence of a field:

    ```python
    db.search(User.name.exists())
    ```

* Testing values against regular expressions:

    ```python
    # Full item has to match the regex:
    db.search(User.name.matches('[aZ]*'))

    # Any part of the item has to match the regex:
    db.search(User.name.search('b+'))
    ```

* Testing using custom tests:

    ```python

    # Custom test:
    test_func = lambda s: s == 'John'
    db.search(User.name.test(test_func))

    # Custom test with parameters:
    def test_func(val, m, n):
        return m <= val <= n
    db.search(User.age.test(test_func, 0, 21))
    db.search(User.age.test(test_func, 21, 99))
    ```

* Testing fields that contain lists with the `any` and `all` methods: Assuming
    we have a user object with a groups list like this:

    ```python
    db.insert({'name': 'user1', 'groups': ['user']})
    db.insert({'name': 'user2', 'groups': ['admin', 'user']})
    db.insert({'name': 'user3', 'groups': ['sudo', 'user']})
    ```

    You can use the following queries:

    ```python
    # User's groups include at least one value from ['admin', 'sudo']
    >>> db.search(User.groups.any(['admin', 'sudo']))
    [{'name': 'user2', 'groups': ['admin', 'user']},
     {'name': 'user3', 'groups': ['sudo', 'user']}]

    # User's groups include all values from ['admin', 'user']
    >>> db.search(User.groups.all(['admin', 'user']))
    [{'name': 'user2', 'groups': ['admin', 'user']}]
    ```

* Testing nested queries: Assuming we have the following table:

    ```python
    Group = Query()
    Permission = Query()
    groups = db.table('groups')
    groups.insert({
        'name': 'user',
        'permissions': [{'type': 'read'}]})
    groups.insert({
        'name': 'sudo',
        'permissions': [{'type': 'read'}, {'type': 'sudo'}]})
    groups.insert({
        'name': 'admin',
        'permissions': [{'type': 'read'}, {'type': 'write'}, {'type': 'sudo'}]})
    ```

    You can search this table using nested `any`/`all` queries:

    ```python
    # Group has a permission with type 'read'
    >>> groups.search(Group.permissions.any(Permission.type == 'read'))
    [{'name': 'user', 'permissions': [{'type': 'read'}]},
     {'name': 'sudo', 'permissions': [{'type': 'read'}, {'type': 'sudo'}]},
     {'name': 'admin', 'permissions':
            [{'type': 'read'}, {'type': 'write'}, {'type': 'sudo'}]}]

    # Group has ONLY permission 'read'
    >>> groups.search(Group.permissions.all(Permission.type == 'read'))
    [{'name': 'user', 'permissions': [{'type': 'read'}]}]
    ```

    `any` tests if there is at least one document matching the query while `all`
    ensures all documents match the query.

    The opposite operation, checking if a list contains a single item, is also
    possible using `one_of`:

    ```python
    >>> db.search(User.name.one_of(['jane', 'john']))
    ```

## [Query modifiers](https://tinydb.readthedocs.io/en/latest/usage.html#query-modifiers)

TinyDB allows you to use logical operations to change and combine queries

* Negate a query: `db.search(~ (User.name == 'John'))`.
* Logical `AND`: `db.search((User.name == 'John') & (User.age <= 30))`.
* Logical `OR`: `db.search((User.name == 'John') | (User.name == 'Bob'))`.

# [Inserting more than one document](https://tinydb.readthedocs.io/en/latest/usage.html#inserting-data)

In case you want to insert more than one document, you can use
`db.insert_multiple(...)`:

```python
>>> db.insert_multiple([
        {'name': 'John', 'age': 22},
        {'name': 'John', 'age': 37}])
>>> db.insert_multiple({'int': 1, 'value': i} for i in range(2))
```

# [Updating data](https://tinydb.readthedocs.io/en/latest/usage.html#updating-data)

To update all the documents of the database, leave out the query argument:

```python
db.update({'foo': 'bar'})
```

When you pass a dictionary to `db.update(fields, query)`, you update a document
by adding or overwriting its values. TinyDB also supports some common operations
you can do on your data:

* `delete(key)`: Delete a key from the document.
* `increment(key)`: Increment the value of a key.
* `decrement(key)`: Decrement the value of a key.
* `add(key, value)`: Add value to the value of a key (also works for strings).
* `subtract(key, value)`: Subtract value from the value of a key.
* `set(key, value)`: Set key to value.

```python
>>> from tinydb.operations import delete
>>> db.update(delete('key1'), User.name == 'John')
```

This will remove the key `key1` from all matching documents.

You also can write your own operations:

```python
>>> def your_operation(your_arguments):
...     def transform(doc):
...         # do something with the document
...         # ...
...     return transform
...
>>> db.update(your_operation(arguments), query)
```

# Retrieving data

If you want to get one element use `db.get(...)`. Be warned, if more than one
document match the query, a random will be returned.

```python
>>> db.get(User.name == 'John')
{'name': 'John', 'age': 22}
```

If you want to know if the database stores a document, use
`db.contains(...)`.

```python
>>> db.contains(User.name == 'John')
True
```

If you want to know the number of documents that match a query use
`db.count(...)`.

```python
>>> db.count(User.name == 'John')
2
```

# Serializing custom data

TinyDB has a limited support to serialize common objects, they added support for
[custom serializers](https://github.com/msiemens/tinydb/pull/50) but [it's not
yet documented](https://github.com/msiemens/tinydb/issues/388). Check the
[tinydb-serialization](https://github.com/msiemens/tinydb-serialization) package
to see how to implement your own.

## [Serializing datetime objects](https://github.com/msiemens/tinydb-serialization)

The [tinydb-serialization](https://github.com/msiemens/tinydb-serialization)
package gives serialization objects for datetime objects.

```python
from tinydb import TinyDB
from tinydb.storages import JSONStorage
from tinydb_serialization import SerializationMiddleware
from tinydb_serialization.serializers import DateTimeSerializer

serialization = SerializationMiddleware(JSONStorage)
serialization.register_serializer(DateTimeSerializer(), 'TinyDate')

db = TinyDB('db.json', storage=serialization)
```

# [Tables](https://tinydb.readthedocs.io/en/latest/usage.html#tables)

TinyDB supports working with more than one table. To create and use a table, use
`db.table(name)`. They behave as the TinyDB class.

```python
>>> table = db.table('table_name')
>>> table.insert({'value': True})
>>> table.all()
[{'value': True}]
>>> for row in table:
>>>     print(row)
{'value': True}
```

To remove a table from a database, use:

```python
db.drop_table('table_name')
```

To remove all tables, use:

```python
db.drop_tables()
```

To get a list with the names of all tables in your database:

```python
>>> db.tables()
{'_default', 'table_name'}
```

# [Query caching](https://tinydb.readthedocs.io/en/latest/usage.html#query-caching)

TinyDB caches query result for performance. That way re-running a query won't
have to read the data from the storage as long as the database hasn't been
modified. You can optimize the query cache size by passing the cache_size to the
`table(...)` function:

```python
table = db.table('table_name', cache_size=30)
```

You can set cache_size to `None` to make the cache unlimited in size. Also, you
can set cache_size to `0` to disable it.

# [Storage types](https://tinydb.readthedocs.io/en/latest/usage.html#storage-types)

TinyDB comes with two storage types: JSON and in-memory. By default TinyDB
stores its data in JSON files so you have to specify the path where to store
it:

```python
from tinydb import TinyDB, where

db = TinyDB('path/to/db.json')
```

To use the in-memory storage, use:

```python
from tinydb.storages import MemoryStorage

db = TinyDB(storage=MemoryStorage)
```

All arguments except for the storage argument are forwarded to the underlying
storage. For the JSON storage you can use this to pass additional keyword
arguments to Python’s `json.dump(…)` method. For example, you can set it to create
prettified JSON files like this:

```python
>>> db = TinyDB('db.json', sort_keys=True, indent=4, separators=(',', ': '))
```

# References

* [Docs](https://tinydb.readthedocs.io/en/latest/usage.html)
* [Git](https://github.com/msiemens/tinydb)
* [Issues](https://github.com/msiemens/tinydb/issues)
* [Reference](https://tinydb.readthedocs.io/en/latest/api.html)
