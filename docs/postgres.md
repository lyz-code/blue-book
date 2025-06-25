# Operations

## [Restore a dump](https://www.postgresql.org/docs/current/backup-dump.html#BACKUP-DUMP-RESTORE)
Text files created by `pg_dump` are intended to be read in by the `psql` program. The general command form to restore a dump is

```bash
psql dbname < dumpfile
```

Where `dumpfile` is the file output by the `pg_dump` command. The database `dbname` will not be created by this command, so you must create it yourself from `template0` before executing `psql` (e.g., with `createdb -T template0 dbname`). `psql` supports options similar to `pg_dump` for specifying the database server to connect to and the user name to use. See [the `psql` reference page](https://www.postgresql.org/docs/current/app-psql.html) for more information. Non-text file dumps are restored using the `pg_restore` utility.
## [Store expensive calculation values in a postgresql database](https://stackoverflow.com/questions/57776620/materialized-view-vs-trigger-for-aggregating-data)

First you need to think if you actually need to store the calculations or you can do them on the fly with [views](#views). If views are too slow you can either use [materialized views](#materialized-views) or [triggers](#triggers) over calculation tables. 

Materialized views are simpler to maintain but have [some disadvantages](#disadvantages-of-a-materialized-view) such as outdated data or unneeded processing of data. If you need totally current information or if you don't want to periodically do the calculations on all the rows then triggers are probably the better solution.
## [Drop all tables of a database](https://stackoverflow.com/questions/3327312/how-can-i-drop-all-the-tables-in-a-postgresql-database)
```sql
drop schema public cascade;
create schema public;
```
## [Upgrade postgres]()
# Features

## [Views](https://www.postgresqltutorial.com/postgresql-views/)
A view is a named query stored in the PostgreSQL database server. A view is defined based on one or more tables which are known as base tables, and the query that defines the view is referred to as a defining query.

After creating a view, you can query data from it as you would from a regular table. Behind the scenes, PostgreSQL will rewrite the query against the view and its defining query, executing it to retrieve data from the base tables.

Views do not store data except the [materialized views](#materialized-views). In PostgreSQL, you can create special views called materialized views that store data physically and periodically refresh it from the base tables.

Simple views can be [updatable](https://www.postgresqltutorial.com/postgresql-views/postgresql-updatable-views/).

### [Advantages of views](https://www.postgresqltutorial.com/postgresql-views/)
- Simplifying complex queries: Views help simplify complex queries. Instead of dealing with joins, aggregations, or filtering conditions, you can query from views as if they were regular tables.

  Typically, first, you create views based on complex queries and store them in the database. Then, you can use simple queries based on views instead of using complex queries.

- Logical data independence: If your applications use views, you can freely modify the structure of the base tables. In other words, views enable you to create a layer of abstraction over the underlying tables.

- Security and access control: Views enable fine-grained control over data access. You can create views that expose subsets of data in the base tables, hiding sensitive information.

  This is particularly useful when you have applications that require access to distinct portions of the data.

### [Creating a view](https://www.postgresqltutorial.com/postgresql-views/managing-postgresql-views/)
In PostgreSQL, a view is a named query stored in the database server. To create a new view, you can use the `CREATE VIEW` statement.

```sql
CREATE VIEW view_name 
AS 
  query;
```

In this syntax:

- Specify the name of the view after the `CREATE VIEW` keywords.
- Specify a `SELECT` statement (query) that defines the view. The query is often referred to as the defining query of the view.

#### Creating a view examples

We’ll use the customer table from the [sample database](https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/):
##### Basic CREATE VIEW statement example

The following example uses the CREATE VIEW statement to create a view based on the customer table:

```sql
CREATE VIEW contact AS 
SELECT 
  first_name, 
  last_name, 
  email 
FROM 
  customer;
```

Output:

```
CREATE VIEW
```

The following query data from the contact view:

```sql
SELECT * FROM contact;
```

Output:

```
 first_name  |  last_name   |                  email
-------------+--------------+------------------------------------------
 Jared       | Ely          | jared.ely@sakilacustomer.org
 Mary        | Smith        | mary.smith@sakilacustomer.org
 Patricia    | Johnson      | patricia.johnson@sakilacustomer.org
...
```

##### Using the CREATE VIEW statement to create a view based on a complex query

The following example creates a view based on the tables customer, address, city, and country:

```sql
CREATE VIEW customer_info AS 
SELECT 
  first_name, 
  last_name, 
  email, 
  phone, 
  city, 
  postal_code,
  country
FROM 
  customer 
  INNER JOIN address USING (address_id) 
  INNER JOIN city USING (city_id) 
  INNER JOIN country USING (country_id);
```

The following query retrieves data from the `customer_info` view:

```sql
SELECT * FROM customer_info;
```

Output:

```
 first_name  |  last_name   |                  email                   |    phone     |            city            | postal_code |                country
-------------+--------------+------------------------------------------+--------------+----------------------------+-------------+---------------------------------------
 Jared       | Ely          | jared.ely@sakilacustomer.org             | 35533115997  | Purwakarta                 | 25972       | Indonesia
 Mary        | Smith        | mary.smith@sakilacustomer.org            | 28303384290  | Sasebo                     | 35200       | Japan
 Patricia    | Johnson      | patricia.johnson@sakilacustomer.org      | 838635286649 | San Bernardino             | 17886       | United States
...
```

##### Creating a view based on another view

The following statement creates a view called `customer_usa` based on the `customer_info` view. The `customer_usa` returns the customers who are in the United States:

```sql
CREATE VIEW customer_usa 
AS 
SELECT 
  * 
FROM 
  customer_info 
WHERE 
  country = 'United States';
```

Here’s the query that retrieves data from the customer_usa view:

```sql
SELECT * FROM customer_usa;
```

Output:

```j
 first_name | last_name  |                email                 |    phone     |          city           | postal_code |    country
------------+------------+--------------------------------------+--------------+-------------------------+-------------+---------------
 Zachary    | Hite       | zachary.hite@sakilacustomer.org      | 191958435142 | Akron                   | 88749       | United States
 Richard    | Mccrary    | richard.mccrary@sakilacustomer.org   | 262088367001 | Arlington               | 42141       | United States
 Diana      | Alexander  | diana.alexander@sakilacustomer.org   | 6171054059   | Augusta-Richmond County | 30695       | United States
...
```

### Replacing a view
Note: for simple changes check [alter views](#alter-views)

To change the defining query of a view, you use the `CREATE OR REPLACE VIEW` statement:

```sql
CREATE OR REPLACE VIEW view_name 
AS 
  query;
```

In this syntax, you add the `OR REPLACE` between the `CREATE` and `VIEW` keywords. If the view already exists, the statement replaces the existing view; otherwise, it creates a new view.

For example, the following statement changes the defining query of the contact view to include the phone information from the address table:

```sql
CREATE OR REPLACE VIEW contact AS 
SELECT 
  first_name, 
  last_name, 
  email,
  phone
FROM 
  customer
INNER JOIN address USING (address_id);
```

### Display a view on psql

To display a view on `psql`, you follow these steps:

First, open the Command Prompt on Windows or Terminal on Unix-like systems and connect to the PostgreSQL server:

```bash
psql -U postgres
```

Second, change the current database to `dvdrental`:

```postgres
\c dvdrental
```

Third, display the view information using the `\d+ view_name` command. For example, the following shows the contact view:

```postgres
\d+ contact
```

Output:

```
                                    View "public.contact"
   Column   |         Type          | Collation | Nullable | Default | Storage  | Description
------------+-----------------------+-----------+----------+---------+----------+-------------
 first_name | character varying(45) |           |          |         | extended |
 last_name  | character varying(45) |           |          |         | extended |
 email      | character varying(50) |           |          |         | extended |
 phone      | character varying(20) |           |          |         | extended |
View definition:
 SELECT customer.first_name,
    customer.last_name,
    customer.email,
    address.phone
   FROM customer
     JOIN address USING (address_id);
```
### [Updatable views](https://www.postgresqltutorial.com/postgresql-views/postgresql-updatable-views/)
### [Recursive views](https://www.postgresqltutorial.com/postgresql-views/postgresql-recursive-view/)

### [Alter views](https://www.postgresqltutorial.com/postgresql-views/postgresql-alter-view/)
## [Materialized Views](https://www.postgresqltutorial.com/postgresql-views/postgresql-materialized-views/)

PostgreSQL extends the view concept to the next level which allows views to store data physically. These views are called materialized views.

Materialized views cache the result set of an expensive query and allow you to refresh data periodically.

The materialized views can be useful in many cases that require fast data access. Therefore, you often find them in data warehouses and business intelligence applications.

### [Benefits of materialized views](https://www.databasestar.com/sql-views/#Benefits_of_a_Materialized_View)

- Improve query efficiency: If a query takes a long time to run, it could be because there are a lot of transformations being done to the data: subqueries, functions, and joins, for example.

  A materialized view can combine all of that into a single result set that’s stored like a table.

  This means that any user or application that needs to get this data can just query the materialized view itself, as though all of the data is in the one table, rather than running the expensive query that uses joins, functions, or subqueries.

  Calculations can also be added to materialized views for any fields you may need, which can save time, and are often not stored in the database.

- Simplify a query: Like a regular view, a materialized view can also be used to simplify a query. If a query is using a lot of logic such as joins and functions, using a materialized view can help remove some of that logic and place it into the materialized view.

### [Disadvantages of a Materialized View](https://www.databasestar.com/sql-views/#Benefits_of_a_Materialized_View)
- Updates to data need to be set up: The main disadvantage to using materialized views is that the data needs to be refreshed.

  The data that’s used to populate the materialized view is stored in the database tables. These tables can have their data updated, inserted, or deleted. When that happens, the data in the materialized view needs to be updated.

  This can be done manually, but it should be done automatically.
 
- [Incremental updates are not supported](https://wiki.postgresql.org/wiki/Incremental_View_Maintenance): So the whole view is generated on each refresh.
- Data may be inconsistent: Because the data is stored separately in the materialized view, the data in the materialized view may be inconsistent with the data in the underlying tables.

  This may be an issue if you are expecting or relying on data to be consistent.

  However, for scenarios where it doesn’t matter (e.g. monthly reporting on months in the past), then it may be OK.

- [Storage Requirements](https://medium.com/@ashkangoleh/unlocking-the-power-of-materialized-views-in-database-optimization-1fc670ba046ej): Materialized Views can consume significant storage space, depending on the size of your dataset. This consideration is crucial, especially in resource-limited environments.

### Creating materialized views

To create a materialized view, you use the CREATE MATERIALIZED VIEW statement as follows:

```sql
CREATE MATERIALIZED VIEW [IF NOT EXISTS] view_name
AS
query
WITH [NO] DATA;
```

How it works.

- First, specify the `view_name` after the `CREATE MATERIALIZED VIEW` clause
- Second, add the `query` that retrieves data from the underlying tables after the `AS` keyword.
- Third, if you want to load data into the materialized view at the creation time, use the `WITH DATA` option; otherwise, you use `WITH NO DATA` option. If you use the `WITH NO DATA` option, the view is flagged as unreadable. It means that you cannot query data from the view until you load data into it.
- Finally, use the `IF NOT EXISTS` option to conditionally create a view only if it does not exist.
### Refreshing data for materialized views

Postgresql will never refresh the data by it's own, you need to define the processes that will update it.

To load or update the data into a materialized view, you use the `REFRESH MATERIALIZED VIEW` statement:

```sql
REFRESH MATERIALIZED VIEW view_name;
```

When you refresh data for a materialized view, PostgreSQL locks the underlying tables. Consequently, you will not be able to retrieve data from underlying tables while data is loading into the view.

To avoid this, you can use the `CONCURRENTLY` option.

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY view_name;
```

With the `CONCURRENTLY` option, PostgreSQL creates a temporary updated version of the materialized view, compares two versions, and performs `INSERT` and `UPDATE` only the differences.

PostgreSQL allows you to retrieve data from a materialized view while it is being updated. One requirement for using `CONCURRENTLY` option is that the materialized view must have a `UNIQUE` index.

#### [Automatic update of materialized views](https://stackoverflow.com/questions/29437650/how-can-i-ensure-that-a-materialized-view-is-always-up-to-date)

### Removing materialized views

To remove a materialized view, you use the `DROP MATERIALIZED VIEW` statement:

```sql
DROP MATERIALIZED VIEW view_name;
```

In this syntax, you specify the name of the materialized view that you want to drop after the `DROP MATERIALIZED VIEW` keywords.

### [Materialized view example](https://www.postgresqltutorial.com/postgresql-views/postgresql-materialized-views/)
We’ll use the tables in the [sample database](https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/) for creating a materialized view.

First, create a materialized view named `rental_by_category` using the `CREATE MATERIALIZED VIEW` statement:

```sql
CREATE MATERIALIZED VIEW rental_by_category
AS
 SELECT c.name AS category,
    sum(p.amount) AS total_sales
   FROM (((((payment p
     JOIN rental r ON ((p.rental_id = r.rental_id)))
     JOIN inventory i ON ((r.inventory_id = i.inventory_id)))
     JOIN film f ON ((i.film_id = f.film_id)))
     JOIN film_category fc ON ((f.film_id = fc.film_id)))
     JOIN category c ON ((fc.category_id = c.category_id)))
  GROUP BY c.name
  ORDER BY sum(p.amount) DESC
WITH NO DATA;
```sql

Because of the `WITH NO DATA` option, you cannot query data from the view. If you attempt to do so, you’ll get the following error message:

```sql
SELECT * FROM rental_by_category;
```

Output:

```
[Err] ERROR: materialized view "rental_by_category" has not been populated
HINT: Use the REFRESH MATERIALIZED VIEW command.
```

PostgreSQL is helpful to give you a hint to ask for loading data into the view.

Second, load data into the materialized view using the `REFRESH MATERIALIZED VIEW` statement:

```sql
REFRESH MATERIALIZED VIEW rental_by_category;
```

Third, retrieve data from the materialized view:

```sql
SELECT * FROM rental_by_category;
```

Output:

```
 category   | total_sales
-------------+-------------
 Sports      |     4892.19
 Sci-Fi      |     4336.01
 Animation   |     4245.31
 Drama       |     4118.46
 Comedy      |     4002.48
 New         |     3966.38
 Action      |     3951.84
 Foreign     |     3934.47
 Games       |     3922.18
 Family      |     3830.15
 Documentary |     3749.65
 Horror      |     3401.27
 Classics    |     3353.38
 Children    |     3309.39
 Travel      |     3227.36
 Music       |     3071.52
(16 rows)
```

From now on, you can refresh the data in the `rental_by_category` view using the `REFRESH MATERIALIZED VIEW` statement.

However, to refresh it with `CONCURRENTLY` option, you need to create a `UNIQUE` index for the view first.

```sql
CREATE UNIQUE INDEX rental_category 
ON rental_by_category (category);
```

Let’s refresh data concurrently for the `rental_by_category` view.

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY rental_by_category;
```
# Troubleshooting
## [Fix pg_dump version mismatch](https://stackoverflow.com/questions/12836312/postgresql-9-2-pg-dump-version-mismatch) 
If you need to use a `pg_dump` version different from the one you have at your system you could either [use nix](nix.md) or use docker

```bash
docker run postgres:9.2 pg_dump books > books.out
```

Or if you need to enter the password

```bash
docker run -v /path/to/dump:/dump -it postgres:12 bash
pg_dump books > /dump/books.out
```

# References

- [Postgresql tutorial](https://www.postgresqltutorial.com/)
