---
title: SQLite3
date: 20201210
author: Lyz
---

[SQLite3](https://docs.python.org/3/library/sqlite3.html) is a python library
that provides an SQL interface compliant with the DB-API 2.0 specification
described by PEP 249.

# Usage

To use the module, you must first create
a [Connection](https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection)
object that represents the database, and
a [Cursor](https://docs.python.org/3/library/sqlite3.html#sqlite3.Cursor) one to
interact with it. Here the data will be stored in the `example.db` file:

```python
import sqlite3

conn = sqlite3.connect('example.db')
cursor = conn.cursor()
```

Once we have a cursor we can `execute` the different SQL statements and the save
them with the `commit` method of the Connection object. Finally we can close the
connection with `close`.

```python
# Create table
cursor.execute('''CREATE TABLE stocks
             (date text, trans text, symbol text, qty real, price real)''')

# Insert a row of data
cursor.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")

# Save (commit) the changes
conn.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.
conn.close()
```

## [Get columns of a query](https://stackoverflow.com/questions/7831371/is-there-a-way-to-get-a-list-of-column-names-in-sqlite)

```python
cursor = connection.execute('select * from bar')
names = [description[0] for description in cursor.description]
```

### [Get a list of the tables](https://www.geeksforgeeks.org/how-to-list-tables-using-sqlite3-in-python/)

```python
sql_query = """SELECT name FROM sqlite_master
  WHERE type='table';"""
cursor = sqliteConnection.cursor()
cursor.execute(sql_query)
print(cursor.fetchall())
```

# [Regexp](https://stackoverflow.com/questions/5365451/problem-with-regexp-python-and-sqlite/5365533#5365533)

[SQLite](sqlite.md) needs the user to define a [regexp](sqlite.md#regexp)
function to be able to use the filter.

```python
import sqlite3
import re

def regexp(expr, item):
    reg = re.compile(expr)
    return reg.search(item) is not None

conn = sqlite3.connect(':memory:')
conn.create_function("REGEXP", 2, regexp)
cursor = conn.cursor()
```

# References

* [Docs](https://docs.python.org/3/library/sqlite3.html)
