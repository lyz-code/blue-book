---
title: Hypothesis
date: 20200611
author: Lyz
---

[Hypothesis](https://en.wikipedia.org/wiki/Hypothes.is) is an open-source
software project that aims to collect comments about statements made in any
web-accessible content, and filter and rank those comments to assess each
statement's credibility.

It offers an online web application where registered users share highlights and
annotations over any webpage.

As of 2020-06-11, although the service can be self-hosted, it's not yet easy to
do so.

# Install

# [Client](https://web.hypothes.is/help/how-to-activate-hypothesis-on-a-web-page/)

If you're using Chrome or any derivative there is an official extension.

Unfortunately if you use Firefox the extension is still being developed
[#310](https://github.com/hypothesis/browser-extension/issues/310) although an
[unofficial release works just
fine](https://github.com/diegodlh/unofficial-hypothesis-extension).
Alternatively you can use the [Hypothesis
bookmarklet](https://web.hypothes.is/start/).

The only problem is that both the extensions and the bookmarklet only works for
the official service. In theory you can tweak the [extension build
process](https://github.com/diegodlh/unofficial-hypothesis-extension/blob/master/docs/building.md)
to use your custom
[settings](https://github.com/diegodlh/unofficial-hypothesis-extension/tree/master/settings).
Though there is yet no documentation on this topic.

I've thought of opening them a bug regarding this issue, but their [github
issues](https://github.com/hypothesis/browser-extension/issues) are only for bug
reports, they use a [google
group](https://groups.google.com/a/list.hypothes.is/forum/#!forum/dev) to track
the feature requests, I don't have an easy way to post there, so if you follow
this path, please [contact me](contact.md).

# [Server](https://github.com/hypothesis/h/issues/6014)

The infrastructure can be deployed with Docker-compose.

```yaml
version: '3'
services:
  postgres:
    image: postgres:11.5-alpine
    ports:
      - 5432
      # - '5432:5432'
  elasticsearch:
    image: hypothesis/elasticsearch:latest
    ports:
      - 9200
      #- '9200:9200'
    environment:
      - discovery.type=single-node
  rabbit:
    image: rabbitmq:3.6-management-alpine
    ports:
      - 5672
      - 15672
      #- '5672:5672'
      #- '15672:15672'
  web:
    image: hypothesis/hypothesis:latest
    environment:
      - APP_URL=http://localhost:5000
      - AUTHORITY=localhost
      - BROKER_URL=amqp://guest:guest@rabbit:5672//
      - CLIENT_OAUTH_ID
      - CLIENT_URL=http://localhost:3001/hypothesis
      - DATABASE_URL=postgresql://postgres@postgres/postgres
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - NEW_RELIC_APP_NAME=h (dev)
      - NEW_RELIC_LICENSE_KEY
      - SECRET_KEY=notasecret
    ports:
      - '5000:5000'
    depends_on:
      - postgres
      - elasticsearch
      - rabbit
```

```bash
docker-compose up
```

Initialize the database and create the admin user.


```bash
docker-compose exec web /bin/sh
hypothesis init

hypothesis user add
hypothesis user admin <username>
```

The service is available at http://localhost:5000.

To check the latest developments of the Docker compose deployment follow the
issue [#4899](https://github.com/hypothesis/h/issues/4899).

They also provide the [tools](https://github.com/hypothesis/deployment) they use
to deploy the production service into AWS.

# References

* [Homepage](https://web.hypothes.is/)
* [FAQ](https://web.hypothes.is/help/)
* [Bug tracker](https://github.com/hypothesis/browser-extension/issues)
* [Feature request tracker](https://groups.google.com/a/list.hypothes.is/forum/#!forum/dev)

## Server deployment open issues

* [Self-hosting Docker compose](https://github.com/hypothesis/h/issues/4899)
* [Create admin user when using Docker
    compose](https://github.com/hypothesis/h/issues/6014)
* [Steps required to run both h and serve the client from internal server](https://groups.google.com/a/list.hypothes.is/forum/#!searchin/dev/server|sort:date/dev/PG3Y2hqwSr8/YsjpIvNEDgAJ)
* [How to deploy h on VM](https://groups.google.com/a/list.hypothes.is/forum/#!topic/dev/mbPxRWF2Ax4)
