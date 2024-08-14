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

# Troubleshooting

## database or disk is full

The error message **"database or disk is full"** in SQLite typically indicates that there is insufficient storage space available for the database to operate properly. This can happen for several reasons, including:

1. **Disk Space is Full**: The most common reason is that the disk where the SQLite database is stored has run out of space.

2. **SQLite Database Size Limitations**: SQLite databases have size limitations depending on the file system or the SQLite version. For example, the maximum size of an SQLite database is 140 terabytes. If you are approaching this limit, you might encounter this error.

3. **Quota Limits**: If the database is stored on a network drive or within a user directory, there might be storage quotas imposed by the system administrator.

4. **Temporary Directory Space**: SQLite uses temporary files during operations. If the directory where these files are stored is full, it can trigger this error.

5. **Corrupted Database File**: In some cases, a corrupted database file can lead to this error.

### Troubleshooting Steps:

1. **Check Disk Space**:
   - Ensure that there is enough free disk space on the drive where the SQLite database is stored. You can use `df -h`

2. **Check Database Size**:
   - Confirm that the database size is within the acceptable limits for your system.
   - You can check the size of the database file directly using file properties.

3. **Check Quota Limits**:
   - Verify that no storage quota is being exceeded if the database is on a network drive or within a managed user directory.

4. **Free Up Space in the Temporary Directory**:
   - Clear up space in the temporary directory used by SQLite (`/tmp` on Unix-like systems).

5. **Vacuum the Database**:
   - If the database has grown large due to deletions and other operations, you can try running `VACUUM` on the database to reclaim unused space:
     ```python
     import sqlite3

     conn = sqlite3.connect('your_database.db')
     conn.execute('VACUUM')
     conn.close()
     ```
   - This might help reduce the size of the database file.

6. **Backup and Restore**:
   - If the database might be corrupted, you could try creating a backup and then restoring it.

7. **Check for Corruption**:
   - Use the `PRAGMA integrity_check;` command to check for any database corruption:
     ```python
     import sqlite3

     conn = sqlite3.connect('your_database.db')
     result = conn.execute('PRAGMA integrity_check').fetchall()
     conn.close()

     if result[0][0] == 'ok':
         print("Database is healthy.")
     else:
         print("Database corruption detected.")
     ```

8. **Check File System Limits**:
   - **File Descriptor Limits**: On some systems, there might be a limit on the number of open files (file descriptors) that a process can have. You can check and increase this limit if needed. On Linux, you can check the limit using:
      ```sh
      ulimit -n
      ```
      To increase it temporarily, use:
      ```sh
      ulimit -n 4096  # Example to increase to 4096
       ```

9. **SQLite Journal Mode**:
   - SQLite uses a journal file during transactions. The default journal mode (`DELETE`) can be space-intensive in some situations.
   - You can try switching to `WAL` (Write-Ahead Logging) mode, which can be more efficient with space:
     ```python
     import sqlite3

     conn = sqlite3.connect('your_database.db')
     conn.execute('PRAGMA journal_mode=WAL;')
     conn.close()
     ```
   - This might help alleviate issues related to temporary file space.

10. **Check for File Permissions**:
   - Ensure that the directory where the database file resides has the correct permissions and that the user running the SQLite process has write access.

11. **Check SQLite Version**:
   - Ensure that you are using a relatively recent version of SQLite. Some bugs in older versions might cause issues that have been resolved in later releases.

12. **Database Locking Issues**:
   - Sometimes, if a process is holding a lock on the database for an extended period, it could cause issues. Make sure no other process is holding onto the database.

13. **Try Rebuilding the Database**:
   - If none of the above works, consider creating a fresh database and migrating the data:
     ```python
     import sqlite3

     old_conn = sqlite3.connect('your_database.db')
     new_conn = sqlite3.connect('new_database.db')

     with new_conn:
         old_conn.backup(new_conn)

     old_conn.close()
     new_conn.close()
     ```
   - This will create a new database file and might resolve any hidden issues with the current file.

14. **SQLite Memory Limitations**:
   - SQLite has a memory limit that could be reached when processing large or complex queries. You can try increasing the cache size:
     ```python
     import sqlite3

     conn = sqlite3.connect('your_database.db')
     conn.execute('PRAGMA cache_size = 10000;')  # Increase the cache size
     conn.close()
     ```
   - You could also adjust the page size or other memory-related parameters:
     ```python
     conn.execute('PRAGMA page_size = 4096;')  # Default is 1024, try increasing it
     conn.execute('PRAGMA temp_store = MEMORY;')  # Store temporary tables in memory
     ```

# References

* [Docs](https://docs.python.org/3/library/sqlite3.html)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
