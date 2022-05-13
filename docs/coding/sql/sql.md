---
title: SQL
date: 20201001
author: Lyz
---

# [SQL Data Types](https://www.w3schools.com/sql/sql_datatypes.asp)

String data types:

* `VARCHAR(size)`: A variable length string (can contain letters, numbers, and
    special characters). The size parameter specifies the maximum column length
    in characters - can be from 0 to 65535.
* `TEXT(size)`: Holds a string with a maximum length of 65,535 bytes.
* `MEDIUMTEXT`: Holds a string with a maximum length of 16,777,215 characters.
* `LONGTEXT`: Holds a string with a maximum length of 4,294,967,295 characters.

* `ENUM(val1, val2, val3, ...)`: A string object that can have only one value,
    chosen from a list of possible values. You can list up to 65535 values in an
    `ENUM` list. If a value is inserted that is not in the list, a blank value
    will be inserted. The values are sorted in the order you enter them.
* `SET(val1, val2, val3, ...)`: A string object that can have 0 or more values,
    chosen from a list of possible values. You can list up to 64 values in a SET
    list.

Numeric data types:

* `BOOL` or `BOOLEAN`: Zero is considered as false, nonzero values are
    considered as true.

* `TINYINT(size)`: A very small integer. Signed range is from -128 to 127.
    Unsigned range is from 0 to 255. The size parameter specifies the maximum
    display width (which is 255).
* `SMALLINT(size)`: A small integer. Signed range is from -32768 to 32767.
    Unsigned range is from 0 to 65535. The size parameter specifies the maximum
    display width (which is 255).
* `INT(size)`: A medium integer. Signed range is from -2147483648 to 2147483647.
    Unsigned range is from 0 to 4294967295. The size parameter specifies the
    maximum display width (which is 255).

* `FLOAT(p)`: A floating point number. MySQL uses the p value to determine
    whether to use `FLOAT` or `DOUBLE` for the resulting data type. If p is from
    0 to 24, the data type becomes `FLOAT()`. If p is from 25 to 53, the data type
    becomes `DOUBLE()`.

Date and time data types:

* `DATE`: A date. Format: YYYY-MM-DD. The supported range is from '1000-01-01'
    to '9999-12-31'.
* `DATETIME(fsp)`: A date and time combination. Format: `YYYY-MM-DD hh:mm:ss`.
    The supported range is from `1000-01-01 00:00:00` to `9999-12-31 23:59:59`.
    Adding `DEFAULT` and `ON UPDATE` in the column definition to get automatic
    initialization and updating to the current date and time.

# [List all tables](https://www.sqltutorial.org/sql-list-all-tables/)

Mysql:

```sql
show tables;
```

Postgresql:

```sql
\dt
```

Sqlite:

```sql
.tables
```

# [Table relationships](https://launchschool.com/books/sql/read/table_relationships)

## [One to One](https://launchschool.com/books/sql/read/table_relationships#onetoone)

A one-to-one relationship between two entities exists when a particular entity
instance exists in one table, and it can have only one associated entity
instance in another table.

For example, a user can have only one address, and an address belongs to only
one user. This sort of relationship is implemented by setting the PRIMARY KEY of
the users table (`id`)  as both the FOREIGN KEY and PRIMARY KEY of the addresses
table.

```sql
CREATE TABLE addresses (
  user_id int, -- Both a primary and foreign key
  street varchar(30) NOT NULL,
  city varchar(30) NOT NULL,
  state varchar(30) NOT NULL,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
```

The `ON DELETE CASCADE` clause of the `FOREIGN_KEY` definition instructs the
database to delete the referencing row if the referenced row is deleted.
There are alternatives to `CASCADE` such as `SET NULL` or `SET DEFAULT` which
instead of deleting the referencing row will set a new value in the appropriate
column for that row.

## [One to many](https://launchschool.com/books/sql/read/table_relationships#onetomany)

A one-to-many relationship exists between two entities if an entity instance in
one of the tables can be associated with multiple records (entity instances) in
the other table. The opposite relationship does not exist; that is, each entity
instance in the second table can only be associated with one entity instance in
the first table.

For example, a review belongs to only one book while a book has many reviews.

```sql
CREATE TABLE books (
  id serial,
  title varchar(100) NOT NULL,
  author varchar(100) NOT NULL,
  published_date timestamp NOT NULL,
  isbn char(12),
  PRIMARY KEY (id),
  UNIQUE (isbn)
);

/*
 one to many: Book has many reviews
*/

CREATE TABLE reviews (
  id serial,
  book_id integer NOT NULL,
  reviewer_name varchar(255),
  content varchar(255),
  rating integer,
  published_date timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);
```

Unlike our addresses table, the `PRIMARY KEY` and `FOREIGN KEY` reference different
columns, `id` and `book_id` respectively. This means that the `FOREIGN KEY` column,
`book_id` is not bound by the `UNIQUE` constraint of our `PRIMARY KEY` and so the same
value from the `id` column of the `books` table can appear in this column more than
once. In other words a book can have many reviews.

## [Many to many](https://launchschool.com/books/sql/read/table_relationships#manytomany)

A many-to-many relationship exists between two entities if for one entity
instance there may be multiple records in the other table, and vice versa.

For example, a user can check out many books, and a book can be checked out by
many users.

In order to implement this sort of relationship we need to introduce a third,
cross-reference, table. This table holds the relationship between the two
entities, by having two `FOREIGN KEY`s, each of which references the `PRIMARY
KEY` of one of the tables for which we want to create this relationship. We
already have our books and users tables, so we just need to create the
cross-reference table: `checkouts`.

```sql
CREATE TABLE checkouts (
  id serial,
  user_id int NOT NULL,
  book_id int NOT NULL,
  checkout_date timestamp,
  return_date timestamp,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);
```

# [Joins](https://www.w3schools.com/sql/sql_join.asp)

A `JOIN` clause is used to combine rows from two or more tables, based on
a related column between them.

![ ](img_rightjoin.png)

## One to one join

```sql
SELECT users.id, addresses.street
FROM users
LEFT JOIN addresses
ON users.id = addresses.user_id
```

It will return one line.

## One to many join

```sql
SELECT books.id, reviews.rating
FROM books
LEFT JOIN reviews
ON books.id = reviews.book_id
```

It will return many lines.

## [Many to many join](https://lornajane.net/posts/2011/inner-vs-outer-joins-on-a-many-to-many-relationship)

```sql
SELECT users.id, books.id
FROM users
LEFT OUTER JOIN checkouts
ON users.id == checkouts.user_id
Left OUTER JOIN books
ON checkouts.book_id == books.id
```
