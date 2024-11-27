---
title: Configure SQLAlchemy to use the MariaDB/Mysql backend
date: 20200602
author: Lyz
---

!!! warning ""
    I discourage you to use an ORM to manage the interactions with the
    database. [Check the alternative solutions](orm_builder_query_or_raw_sql.md).

To use Mysql you'll need to first install (or add to your requirements) `pymysql`:

```bash
pip install pymysql
```

The url to connect to the database will be:
```python
'mysql+pymysql://{}:{}@{}:{}/{}'.format(
    DB_USER,
    DB_PASS,
    DB_HOST,
    DB_PORT,
    DATABASE
)
```

It's probable that you'll need to [use UTF8 with
multi byte](https://github.com/sqlalchemy/sqlalchemy/issues/4216), otherwise the
addition of some strings into the database will fail. I've tried adding it to
the database url without success. So I've modified the MariaDB Docker-compose
section to use that character and collation set:

```yaml
services:
  db:
    image: mariadb:latest
    restart: always
    environment:
      - MYSQL_USER=xxxx
      - MYSQL_PASSWORD=xxxx
      - MYSQL_DATABASE=xxxx
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
    ports:
      - 3306:3306
    command:
      - '--character-set-server=utf8mb4'
      - '--collation-server=utf8mb4_unicode_ci'
```
