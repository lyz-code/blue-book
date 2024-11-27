---
title: MySQL Python
date: 20210603
author: Lyz
---

# Installation

```bash
pip install mysql-connector-python
```

# Usage

```python
import mysql.connector

# Connect to server
cnx = mysql.connector.connect(
    host="127.0.0.1",
    port=3306,
    user="mike",
    password="s3cre3t!")

# Get a cursor
cur = cnx.cursor()

# Execute a query
cur.execute("SELECT CURDATE()")

# Fetch one result
row = cur.fetchone()
print("Current date is: {0}".format(row[0]))

# Close connection
cnx.close()
```

## Iterate over the results of the cursor execution

```python
cursor.execute(show_db_query)
for db in cursor:
    print(db)
```

# References

* [Git](https://github.com/mysql/mysql-connector-python)
* [Docs](https://dev.mysql.com/doc/connector-python/en/)
* [RealPython tutorial](https://realpython.com/python-mysql/)
