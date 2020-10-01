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
