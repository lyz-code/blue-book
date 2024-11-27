---
title: Redis
date: 20200528
author: Lyz
---

[Redis](https://en.wikipedia.org/wiki/Redis) is an in-memory data structure
project implementing a distributed, in-memory key-value database with optional
durability. Redis supports different kinds of abstract data structures, such as
strings, lists, maps, sets, sorted sets, HyperLogLogs, bitmaps, streams, and
spatial indexes.

Redis has a client-server architecture and uses a request-response model. This
means that you (the client) connect to a Redis server through TCP connection, on
port 6379 by default. You request some action (like some form of reading,
writing, getting, setting, or updating), and the server serves you back
a response.

There can be many clients talking to the same server, which is really what Redis
or any client-server application is all about. Each client does a (typically
blocking) read on a socket waiting for the server response.

# Redis as a Python dictionary

Redis stands for Remote Dictionary Service.

Broadly speaking, there are many parallels you can draw between a Python
dictionary (or generic hash table) and what Redis is and does:

* A Redis database holds key:value pairs and supports commands such as GET, SET,
    and DEL, as well as [several hundred](https://redis.io/commands) additional
    commands.
* Redis *keys* are always strings.
* Redis values may be a number of different data types: string, list, hashes,
    sets and some advanced types like geospatial items and the new stream type.
* Many Redis commands operate in constant O(1) time, just like retrieving
    a value from a Python dict or any hash table.

# Client libraries

There are several ways to interact with a Redis server, such as:

* [Redis-py](redis-py.md).
* redis-cli.

# Reference

* [Real Python Redis introduction](https://realpython.com/python-redis/)
