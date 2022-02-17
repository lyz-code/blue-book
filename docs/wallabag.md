---
title: Wallabag
date: 20220113
author: Lyz
---

[Wallabag](https://doc.wallabag.org) is a self-hosted read-it-later application:
it saves a web page by keeping content only. Elements like navigation or ads are
deleted.

# [Installation](https://github.com/wallabag/docker)

They provide a working
[docker-compose](https://github.com/wallabag/docker#docker-compose)

```yaml
version: '3'
services:
  wallabag:
    image: wallabag/wallabag
    environment:
      - MYSQL_ROOT_PASSWORD=wallaroot
      - SYMFONY__ENV__DATABASE_DRIVER=pdo_mysql
      - SYMFONY__ENV__DATABASE_HOST=db
      - SYMFONY__ENV__DATABASE_PORT=3306
      - SYMFONY__ENV__DATABASE_NAME=wallabag
      - SYMFONY__ENV__DATABASE_USER=wallabag
      - SYMFONY__ENV__DATABASE_PASSWORD=wallapass
      - SYMFONY__ENV__DATABASE_CHARSET=utf8mb4
      - SYMFONY__ENV__SECRET=supersecretenv
      - SYMFONY__ENV__MAILER_HOST=127.0.0.1
      - SYMFONY__ENV__MAILER_USER=~
      - SYMFONY__ENV__MAILER_PASSWORD=~
      - SYMFONY__ENV__FROM_EMAIL=wallabag@example.com
      - SYMFONY__ENV__DOMAIN_NAME=https://your-wallabag-url-instance.com
      - SYMFONY__ENV__SERVER_NAME="Your wallabag instance"
    ports:
      - "80"
    volumes:
      - /opt/wallabag/images:/var/www/wallabag/web/assets/images
    healthcheck:
      test: ["CMD", "wget" ,"--no-verbose", "--tries=1", "--spider", "http://localhost"]
      interval: 1m
      timeout: 3s
    depends_on:
      - db
      - redis
  db:
    image: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=wallaroot
    volumes:
      - /opt/wallabag/data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      interval: 20s
      timeout: 3s
  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 20s
      timeout: 3s
```

If you don't want to enable the public registration use the `SYMFONY__ENV__FOSUSER_REGISTRATION=false
` flag. The emailer configuration is only used when a user creates an account,
so if you're only going to use it for yourself, it's safe to disable.

Remember to change all passwords to a random value.

If you create RSS feeds for a user, all articles are shared by default, if you
only want to share the starred articles, add to your nginx config:

```
    location ~* /feed/.*/.*/(?!starred){
        deny all;
        return 404;
    }
```

# References

* [Docs](https://doc.wallabag.org)
