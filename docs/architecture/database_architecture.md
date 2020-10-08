---
title: Database Architecture
date: 20200820
author: Lyz
---

## [Design a table to keep historical changes in database](https://yizhiyue.me/2019/09/17/design-a-table-to-keep-historical-changes-in-database/)

The post suggests two ways of storing a history of changed data in a database
table. This might be useful for example for *undo* functionality or to store the
evolution of the attributes.

* *Audit table*: Record every single change in every field in an audit table.
* *History table*: Each time a change is recorded, the whole line is stored in
    a History table.

### [Using an Audit table](https://yizhiyue.me/2019/09/17/design-a-table-to-keep-historical-changes-in-database/#3-Use-an-Audit-Table)

The *Audit* table has the following schema.

| Column Name | Data Type    |
| ---         | ---          |
| ID          | int          |
| Table       | varchar(50)  |
| Field       | varchar(50)  |
| RecordId    | int          |
| OldValue    | varchar(255) |
| NewValue    | varchar(255) |
| AddBy       | int          |
| AddDate     | date         |

For example, there is a transaction looks like this:

| Id  | Description  | TransactionDate | DeliveryDate | Status   |
| --- | ---          | ---             | ---          | ---      |
| 100 | A short text | 2019-09-15      | 2019-09-28   | Shipping |

And now, another user with id `20` modifies the description to `A not long text`
and DeliveryDate to `2019-10-01`.

| Id  | Description     | TransactionDate | DeliveryDate | Status   |
| --- | ---             | ---             | ---          | ---      |
| 100 | A not long text | 2019-09-15      | 2019-10-01   | Shipping |

The Audit table entries will look:

| Id  | Table       | Field        | RecordId | OldValue     | NewValue        | AddBy | AddDate    |
| --- | ---         | ---          | ---      | ---          | ---             | ---   | ---        |
| 1   | Transaction | Description  | 100      | A short text | A not long text | 20    | 2019-09-17 |
| 2   | Transaction | DeliveryDate | 100      | 2019-09-28   | 2019-10-01      | 20    | 2019-09-17 |


And we'll update the original record in the `Transaction` table.

Pros:

* It's easy to query for field changes.
* No redundant information is stored.

Cons:

* Possible huge increase of records. Since every change in different fields is
    one record in the Audit table, it may grow drastically fast. In this case,
    table indexing plays a vital role for enhancing the querying performance.

Suitable for tables with many fields where often only a few change.

### [Using a history table](https://yizhiyue.me/2019/09/17/design-a-table-to-keep-historical-changes-in-database/#2-Use-a-History-Table)

The *History* table has the same schema as the table we are saving the history
from. Imagine a Transaction table with the following schema.

| Column Name     | Data Type   |
| ---             | ---         |
| ID              | int         |
| Description     | text        |
| TransactionDate | date        |
| DeliveryDate    | date        |
| Status          | varchar(50) |
| AddDate         | date        |

When doing the same changes as the previous example, we'll introduce the old
record into the History table, and update the record in the Transaction table.

Pros:

* Simple query to get the complete history.

Cons:

* Redundant information is stored.

Suitable for:

* A lot of fields are changed in one time.
* Generating a change report with full record history is needed

# References

* [Decoupling database migrations from server startup](https://pythonspeed.com/articles/schema-migrations-server-startup/)
