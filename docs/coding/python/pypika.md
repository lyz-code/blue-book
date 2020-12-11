---
title: Pypika
date: 20201001
author: Lyz
---

[Pypika](https://pypika.readthedocs.io/en/latest/) is a Python API for building
SQL queries. The motivation behind PyPika is to provide a simple interface for
building SQL queries without limiting the flexibility of handwritten SQL.

PyPika is a fast, expressive and flexible way to replace handwritten SQL.
Validation of SQL correctness is not an explicit goal of the project. Instead
you are encouraged to check inputs you provide to PyPika or appropriately handle
errors raised from your SQL database.

After the queries have been built you need to interact with the database with
other libraries.

# [Installation](https://pypika.readthedocs.io/en/latest/1_installation.html)

```bash
pip install pypika
```

# Usage

The main classes in pypika are `pypika.Query`, `pypika.Table`, and
`pypika.Field`.

```python
from pypika import Query, Table, Field
```

## [Creating Tables](https://github.com/kayak/pypika#creating-tables)

The entry point for creating tables is `pypika.Query.create_table`, which is
used with the class `pypika.Column`. As with selecting data, first the table
should be specified. This can be either a string or a `pypika.Table`. Then the
columns, and constraints..

```python
stmt = Query \
    .create_table("person") \
    .columns(
        Column("id", "INT", nullable=False),
        Column("first_name", "VARCHAR(100)", nullable=False),
        Column("last_name", "VARCHAR(100)", nullable=False),
        Column("phone_number", "VARCHAR(20)", nullable=True),
        Column("status", "VARCHAR(20)", nullable=False, default=ValueWrapper("NEW")),
        Column("date_of_birth", "DATETIME")) \
    .unique("last_name", "first_name") \
    .primary_key("id")
```

This produces:

```sql
CREATE TABLE "person" (
    "id" INT NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "phone_number" VARCHAR(20) NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'NEW',
    "date_of_birth" DATETIME,
    UNIQUE ("last_name","first_name"),
    PRIMARY KEY ("id")
)
```

It seems that [they don't yet support the definition of FOREIGN
KEYS](https://github.com/kayak/pypika/issues/497) when creating a new table.

## [Selecting Data](https://pypika.readthedocs.io/en/latest/2_tutorial.html#selecting-data)

The entry point for building queries is `pypika.Query`. In order to select columns
from a table, the table must first be added to the query. For simple queries
with only one table, tables and columns can be references using strings. For
more sophisticated queries a `pypika.Table` must be used.

```python
q = Query.from_('customers').select('id', 'fname', 'lname', 'phone')
```

To convert the query into raw SQL, it can be cast to a string.

```python
str(q)
```

Alternatively, you can use the Query.get_sql() function:

```python
q.get_sql()
```

### [Filtering](https://pypika.readthedocs.io/en/latest/2_tutorial.html#filtering)

Queries can be filtered with `pypika.Criterion` by using equality or inequality
operators.

```python
customers = Table('customers')
q = Query.from_(customers).select(
    customers.id, customers.fname, customers.lname, customers.phone
).where(
    customers.lname == 'Mustermann'
)
```

```sql
SELECT id,fname,lname,phone FROM customers WHERE lname='Mustermann'
```

Query methods such as select, where, groupby, and orderby can be called multiple
times. Multiple calls to the where method will add additional conditions as:

```python
customers = Table('customers')
q = Query.from_(customers).select(
    customers.id, customers.fname, customers.lname, customers.phone
).where(
    customers.fname == 'Max'
).where(
    customers.lname == 'Mustermann'
)
```

```sql
SELECT id,fname,lname,phone FROM customers WHERE fname='Max' AND lname='Mustermann'
```

Filters such as IN and BETWEEN are also supported.

```python
customers = Table('customers')
q = Query.from_(customers).select(
    customers.id,customers.fname
).where(
    customers.age[18:65] & customers.status.isin(['new', 'active'])
)
```

```sql
SELECT id,fname FROM customers WHERE age BETWEEN 18 AND 65 AND status IN ('new','active')
```

Filtering with complex criteria can be created using boolean symbols `&`, `|`,
and `^`.

* AND

    ```python
    customers = Table('customers')
    q = Query.from_(customers).select(
        customers.id, customers.fname, customers.lname, customers.phone
    ).where(
        (customers.age >= 18) & (customers.lname == 'Mustermann')
    )
    ```

    ```sql
    SELECT id,fname,lname,phone FROM customers WHERE age>=18 AND lname='Mustermann'
    ```

* OR

    ```python
    customers = Table('customers')
    q = Query.from_(customers).select(
        customers.id, customers.fname, customers.lname, customers.phone
    ).where(
        (customers.age >= 18) | (customers.lname == 'Mustermann')
    )
    ```

    ```sql
    SELECT id,fname,lname,phone FROM customers WHERE age>=18 OR lname='Mustermann'
    ```

* XOR

    ```python
    customers = Table('customers')
    q = Query.from_(customers).select(
        customers.id, customers.fname, customers.lname, customers.phone
    ).where(
        (customers.age >= 18) ^ customers.is_registered
    )
    ```

    ```sql
    SELECT id,fname,lname,phone FROM customers WHERE age>=18 XOR is_registered
    ```

## [Deleting data](https://github.com/kayak/pypika/issues/5)

```python
Query.from_(table).delete().where(table.id == id)
```

# References

* [Docs](http://pypika.readthedocs.io/en/latest/)
* [Source](https://github.com/kayak/pypika)
