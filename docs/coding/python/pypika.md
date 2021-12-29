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

## [Inserting data](https://pypika.readthedocs.io/en/latest/2_tutorial.html#inserting-data)

Data can be inserted into tables either by providing the values in the query or
by selecting them through another query.

By default, data can be inserted by providing values for all columns in the
order that they are defined in the table.

### Insert with values

```python
customers = Table('customers')

q = Query.into(customers).insert(1, 'Jane', 'Doe', 'jane@example.com')
```

```sql
INSERT INTO customers VALUES (1,'Jane','Doe','jane@example.com')
```

```python
customers =  Table('customers')

q = customers.insert(1, 'Jane', 'Doe', 'jane@example.com')
```

```sql
INSERT INTO customers VALUES (1,'Jane','Doe','jane@example.com')
```

Multiple rows of data can be inserted either by chaining the insert function or
passing multiple tuples as args.

```python
customers = Table('customers')

q = (
    Query.into(customers)
    .insert(1, "Jane", "Doe", "jane@example.com")
    .insert(2, "John", "Doe", "john@example.com")
)
```

```python
customers = Table('customers')

q = Query.into(customers).insert(
    (1, "Jane", "Doe", "jane@example.com"), (2, "John", "Doe", "john@example.com")
)
```

```sql
INSERT INTO "customers" VALUES (1,'Jane','Doe','jane@example.com'),(2,'John','Doe','john@example.com')
```

### Insert with on Duplicate Key Update

```python
customers = Table('customers')

q = Query.into(customers)\
    .insert(1, 'Jane', 'Doe', 'jane@example.com')\
    .on_duplicate_key_update(customers.email, Values(customers.email))
```

```sql
INSERT INTO customers VALUES (1,'Jane','Doe','jane@example.com') ON DUPLICATE KEY UPDATE `email`=VALUES(`email`)
```

`.on_duplicate_key_update` works similar to `.set` for updating rows,
additionally it provides the Values wrapper to update to the value specified in
the `INSERT` clause.

### Insert from a SELECT Sub-query

```sql
INSERT INTO customers VALUES (1,'Jane','Doe','jane@example.com'),(2,'John','Doe','john@example.com')
```

To specify the columns and the order, use the columns function.

```python
customers = Table('customers')

q = Query.into(customers).columns('id', 'fname', 'lname').insert(1, 'Jane', 'Doe')
```

```sql
INSERT INTO customers (id,fname,lname) VALUES (1,'Jane','Doe','jane@example.com')
```

Inserting data with a query works the same as querying data with the additional
call to the into method in the builder chain.

```python
customers, customers_backup = Tables('customers', 'customers_backup')

q = Query.into(customers_backup).from_(customers).select('*')
```

```sql
INSERT INTO customers_backup SELECT * FROM customers
```

```python
customers, customers_backup = Tables('customers', 'customers_backup')

q = Query.into(customers_backup).columns('id', 'fname', 'lname')
    .from_(customers).select(customers.id, customers.fname, customers.lname)
```

```sql
INSERT INTO customers_backup SELECT "id", "fname", "lname" FROM customers
```

The syntax for joining tables is the same as when selecting data

```python
customers, orders, orders_backup = Tables('customers', 'orders', 'orders_backup')

q = Query.into(orders_backup).columns('id', 'address', 'customer_fname', 'customer_lname')
    .from_(customers)
    .join(orders).on(orders.customer_id == customers.id)
    .select(orders.id, customers.fname, customers.lname)
```

```sql
INSERT INTO "orders_backup" ("id","address","customer_fname","customer_lname")
SELECT "orders"."id","customers"."fname","customers"."lname" FROM "customers"
JOIN "orders" ON "orders"."customer_id"="customers"."id"
```

## [Updating
data](https://pypika.readthedocs.io/en/latest/2_tutorial.html#updating-data)

PyPika allows update queries to be constructed with or without where clauses.

```python
customers = Table('customers')

Query.update(customers).set(customers.last_login, '2017-01-01 10:00:00')

Query.update(customers).set(customers.lname, 'smith').where(customers.id == 10)
```

```sql
UPDATE "customers" SET "last_login"='2017-01-01 10:00:00'

UPDATE "customers" SET "lname"='smith' WHERE "id"=10
```

The syntax for joining tables is the same as when selecting data

```python
customers, profiles = Tables('customers', 'profiles')

Query.update(customers)
     .join(profiles).on(profiles.customer_id == customers.id)
     .set(customers.lname, profiles.lname)
```

```sql
UPDATE "customers"
JOIN "profiles" ON "profiles"."customer_id"="customers"."id"
SET "customers"."lname"="profiles"."lname"
```

Using `pypika.Table` alias to perform the update

```python
customers = Table('customers')

customers.update()
        .set(customers.lname, 'smith')
        .where(customers.id == 10)
```

```sql
UPDATE "customers" SET "lname"='smith' WHERE "id"=10
```

Using limit for performing update

```python
customers = Table('customers')

customers.update()
        .set(customers.lname, 'smith')
        .limit(2)
```

```sql
UPDATE "customers" SET "lname"='smith' LIMIT 2
```

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

!!! note ""
    The `.select` statement doesn't need to be after the `.from_` statement.
    This is useful when composing a query in multiple steps, where you can do
    the `.join` before the `.select`.

In simple queries like the above example, columns in the “from” table can be
referenced by passing string names into the select query builder function. In
more complex examples, the `pypika.Table` class should be used. Columns can be
referenced as attributes on instances of `pypika.Table`.

```python
from pypika import Table, Query

customers = Table('customers')
q = Query.from_(customers).select(customers.id, customers.fname, customers.lname, customers.phone)
```

Both of the above examples result in the following SQL:

```sql
SELECT id,fname,lname,phone FROM customers
```

An alias for the table can be given using the `.as_` function on `pypika.Table`.

```python
Table('x_view_customers').as_('customers')
q = Query.from_(customers).select(customers.id, customers.phone)
```

```sql
SELECT id,phone FROM x_view_customers customers
```

An alias for the columns can also be given using the `.as_` function on the
columns.

```python
customers = Table('customers')
q = Query.from_(customers).select(
    customers.id.as_("customer.id"), customers.fname.as_("customer.name")
)
```

```sql
SELECT "id" "customer.id","fname" "customer.name" FROM customers
```

A schema can also be specified. Tables can be referenced as attributes on the
schema.

```python
from pypika import Table, Query, Schema

views = Schema('views')
q = Query.from_(views.customers).select(customers.id, customers.phone)
```

```sql
SELECT id,phone FROM views.customers
```

Also references to databases can be used. Schemas can be referenced as
attributes on the database.

```python
from pypika import Table, Query, Database

my_db = Database('my_db')
q = Query.from_(my_db.analytics.customers).select(customers.id, customers.phone)
```

```sql
SELECT id,phone FROM my_db.analytics.customers
```

Results can be ordered by using the following syntax:

```python
from pypika import Order
Query.from_('customers').select('id', 'fname', 'lname', 'phone').orderby('id', order=Order.desc)
```

This results in the following SQL:

```sql
SELECT "id","fname","lname","phone" FROM "customers" ORDER BY "id" DESC
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

!!! warning "Using the REGEXP filter"

    Pypika supports regex, but if you're using [sqlite3](sqlite3.md) you need
    to [configure the connection to the database](sqlite3.md#regexp).

### [Joining tables and subqueries](https://pypika.readthedocs.io/en/latest/2_tutorial.html#joining-tables-and-subqueries)

Tables and subqueries can be joined to any query using the `Query.join()` method.
Joins can be performed with either a `USING` or `ON` clauses. The `USING` clause can
be used when both tables/subqueries contain the same field and the `ON` clause can
be used with a criterion. To perform a join, `...join()` can be chained but then
must be followed immediately by `...on(<criterion>)` or `...using(*field)`.

#### Join Types

All join types are supported by PyPika.

```python
Query \
    .from_(base_table)
    ...
    .join(join_table, JoinType.left)
    ...

Query \
    .from_(base_table)
    ...
    .left_join(join_table) \
    .right_join(join_table) \
    .inner_join(join_table) \
    .outer_join(join_table) \
    .cross_join(join_table) \
    ...
```

##### Example of a join using ON

```python
history, customers = Tables('history', 'customers')
q = Query \
    .from_(history) \
    .join(customers) \
    .on(history.customer_id == customers.id) \
    .select(history.star) \
    .where(customers.id == 5)
```

```sql
SELECT "history".* FROM "history" JOIN "customers" ON "history"."customer_id"="customers"."id" WHERE "customers"."id"=5
```

##### Example of a join using ON_FIELD

As a shortcut, the `Query.join().on_field()` function is provided for joining
the (first) table in the `FROM` clause with the joined table when the field
name(s) are the same in both tables.

```python
history, customers = Tables('history', 'customers')
q = Query \
    .from_(history) \
    .join(customers) \
    .on_field('customer_id', 'group') \
    .select(history.star) \
    .where(customers.group == 'A')
```

```sql
SELECT "history".* FROM "history" JOIN "customers" ON "history"."customer_id"="customers"."customer_id" AND "history"."group"="customers"."group" WHERE "customers"."group"='A'
```

##### Example of a join using USING

```python
history, customers = Tables('history', 'customers')
q = Query \
    .from_(history) \
    .join(customers) \
    .using('customer_id') \
    .select(history.star) \
    .where(customers.id == 5)
```

```sql
SELECT "history".* FROM "history" JOIN "customers" USING "customer_id" WHERE "customers"."id"=5
```

##### Example of a correlated subquery in the SELECT

```python
history, customers = Tables('history', 'customers')

last_purchase_at = Query.from_(history).select(
    history.purchase_at
).where(history.customer_id==customers.customer_id).orderby(
    history.purchase_at, order=Order.desc
).limit(1)

q = Query.from_(customers).select(
    customers.id, last_purchase_at._as('last_purchase_at')
)
```

```sql
SELECT
  "id",
  (SELECT "history"."purchase_at"
   FROM "history"
   WHERE "history"."customer_id" = "customers"."customer_id"
   ORDER BY "history"."purchase_at" DESC
   LIMIT 1) "last_purchase_at"
FROM "customers"
```

## [Deleting data](https://github.com/kayak/pypika/issues/5)

```python
Query.from_(table).delete().where(table.id == id)
```

# References

* [Docs](https://pypika.readthedocs.io/en/latest/)
* [Source](https://github.com/kayak/pypika)
