---
title: SQLite
date: 20201230
author: Lyz
---

[SQLite](https://en.wikipedia.org/wiki/SQLite) is a relational database
management system (RDBMS) contained in a C library. In contrast to many other
database management systems, SQLite is not a client–server database engine.
Rather, it is embedded into the end program.

SQLite is ACID-compliant and implements most of the SQL standard, generally
following PostgreSQL syntax. However, SQLite uses a dynamically and weakly typed
SQL syntax that does not guarantee the domain integrity.[7] This means that one
can, for example, insert a string into a column defined as an integer. SQLite
will attempt to convert data between formats where appropriate, the string "123"
into an integer in this case, but does not guarantee such conversions and will
store the data as-is if such a conversion is not possible.

SQLite is a popular choice as embedded database software for local/client
storage in application software such as web browsers. It is arguably the most
widely deployed database engine, as it is used today by several widespread
browsers, operating systems, and embedded systems (such as mobile phones), among
others.

# Operators and statements

## [Upsert statements](https://www.sqlite.org/lang_UPSERT.html)

UPSERT is a special syntax addition to INSERT that causes the INSERT to behave
as an UPDATE or a no-op if the INSERT would violate a uniqueness constraint.
UPSERT is not standard SQL. UPSERT in SQLite follows the syntax established by
PostgreSQL.

The syntax that occurs in between the "ON CONFLICT" and "DO" keywords is called
the "conflict target". The conflict target specifies a specific uniqueness
constraint that will trigger the upsert. The conflict target is required for DO
UPDATE upserts, but is optional for DO NOTHING. When the conflict target is
omitted, the upsert behavior is triggered by a violation of any uniqueness
constraint on the table of the INSERT.

If the insert operation would cause the uniqueness constraint identified by the
conflict-target clause to fail, then the insert is omitted and either the DO
NOTHING or DO UPDATE operation is performed instead. In the case of a multi-row
insert, this decision is made separately for each row of the insert.

The special UPSERT processing happens only for uniqueness constraint on the
table that is receiving the INSERT. A "uniqueness constraint" is an explicit
UNIQUE or PRIMARY KEY constraint within the CREATE TABLE statement, or a unique
index. UPSERT does not intervene for failed NOT NULL or foreign key constraints
or for constraints that are implemented using triggers.

Column names in the expressions of a DO UPDATE refer to the original unchanged
value of the column, before the attempted INSERT. To use the value that would
have been inserted had the constraint not failed, add the special "excluded."
table qualifier to the column name.

```sql
CREATE TABLE phonebook2(
  name TEXT PRIMARY KEY,
  phonenumber TEXT,
  validDate DATE
);
INSERT INTO phonebook2(name,phonenumber,validDate)
  VALUES('Alice','704-555-1212','2018-05-08')
  ON CONFLICT(name) DO UPDATE SET
    phonenumber=excluded.phonenumber,
    validDate=excluded.validDate
```

## REGEXP

The [REGEXP operator](https://www.sqlite.org/lang_expr.html#regexp) is a special
syntax for the `regexp()` user function. No `regexp()` user function is defined by
default and so use of the REGEXP operator will normally result in an error
message. If an application-defined SQL function named `regexp` is added at
run-time, then the `X REGEXP Y` operator will be implemented as a call to
`regexp(Y,X)`. If you're using [sqlite3](sqlite3.md), you can check [how to
create the regexp function](sqlite3.md#regexp).

# Snippets

## [Get the columns of a database](https://stackoverflow.com/questions/947215/how-to-get-a-list-of-column-names-on-sqlite3-database)

```sqlite
PRAGMA table_info(table_name);
```

# Troubleshooting

## [Integer autoincrement not
working](https://stackoverflow.com/questions/16832401/sqlite-auto-increment-not-working)


Rename the column type from `INT` to `INTEGER` and it starts working.

From this:

```sql
CREATE TABLE IF NOT EXISTS foo (id INT PRIMARY KEY, bar INT)
```

to this:

```sql
CREATE TABLE IF NOT EXISTS foo (id INTEGER PRIMARY KEY, bar INT)
```

# References

* [Home](https://www.sqlite.org/index.html)
* [rqlite](https://github.com/rqlite/rqlite): is a lightweight, distributed
    relational database, which uses SQLite as its storage engine. Forming
    a cluster is very straightforward, it gracefully handles leader elections,
    and tolerates failures of machines, including the leader.
