---
title: ORM, Query Builder or raw SQL
date: 20201001
author: Lyz
---

Databases are the core of storing state for almost all web applications. There
are three ways for a programming application to interact with the database.
After reading this article, you'll know which are the advantages and
disadvantages of using the different solutions.

# Raw SQL

Raw SQL, sometimes also called native SQL, is the most basic, most low-level
form of database interaction. You tell the database what to do in the language
of the database. Most developers should know basics of SQL. This means how to
CREATE tables and views, how to SELECT and JOIN data, how to UPDATE and DELETE
data.

Excels:

* *Flexibility*: As you are writing raw SQL code, you are not constrained by
    higher level abstractions.
* *Performance*: You can use engine specific tricks to increase the performance
    and your queries will probably be simpler than the higher abstraction ones.
* *Magic free*: It's easier to understand what your code does, as you scale up
    in the abstraction level, magic starts to appear which is nice if everything
    goes well, but it backfires when you encounter problems.
* *No logic coupling*: As your models are not linked to the way you interact
    with the storage solution, it's easier to define a clean software
    architecture that follows the [SOLID](solid.md) principles, which also
    allows to switch between different storage approaches.

Cons:

* *SQL Injections*: As you are manually writing the queries, it's easier to fall
    into these vulnerabilities.
* *Change management*: Databases change over time. With raw SQL, you typically
    don't get any support for that. You have to migrate the schema and all
    queries yourself.
* *Query Extension*: If you have an analytical query, it's nice if you can
    apply slight modifications to it. It’s possible to extend a query when you
    have raw SQL, but it’s cumbersome. You need to touch the original query and
    add placeholders.
* *Editor support*: As it's interpreted as a string in the
    editor, your editor is not able to detect typos, syntax highlight or auto
    complete the SQL code.
* *SQL knowledge*: You need to know SQL to interact with the database.
* *Database Locking*: You might use features which are specific to that
    database, which makes a future database switch harder.

# Query builder

Query builders are libraries which are written in the programming language you
use and use native classes and functions to build SQL queries. Query builders
typically have a [fluent
interface](https://en.wikipedia.org/wiki/Fluent_interface), so the queries are
built by an object-oriented interface which uses method chaining.

```python
query = Query.from_(books) \
             .select("*") \
             .where(books.author_id == aid)
```

[Pypika](https://github.com/kayak/pypika) is an example for a Query Builder in Python.
Note that the resulting query is still the same as in the raw code, built in
another way, so abstraction level over using raw SQL is small.

Excels:

* *Performance*: Same performance as using raw SQL.
* *Magic free*: Same comprehension as using raw SQL.
* *No logic coupling*: Same coupling as using raw SQL.
* *Query Extension*: Given the fluent interface, it's easier to build, extend
    and reuse queries.

Mitigates:

* *Flexibility*: You depend on the builder implementation of the language you
    are trying to use, but if the functionality you are trying to use is not
    there, you can always fall back to raw SQL.
* *SQL Injections*: Query builders have mechanism to insert parameters into the
    queries in a safe way.
* *Editor support*: The query builder prevents typos in the offered parts
    — `.select`, `.from_` , `.where`, and as it's object oriented you have
    better syntax highlight and auto completion.
* *Database Locking*: Query builders support different databases make database
    switch easier.

Cons:

* *Change management*: Databases change over time. With raw SQL, you typically
    don't get any support for that. You have to migrate the schema and all
    queries yourself.
* *SQL knowledge*: You need to know SQL to interact with the database.
* *Query builder knowledge*: You need to know the library to interact with the
    database.

# ORM

ORMs create an object for each database table and allows you to interact
between related objects, in a way that you can use your object oriented
programming to interact with the database even without knowing SQL.

[SQLAlchemy](sqlalchemy.md) is an example for an ORM in Python.

 This way, there is a language-native representation and thus the languages
 ecosystem features such as autocomplete and syntax-highlighting work.

Excels:

* *Change management*: ORM come with helper programs like [Alembic](alembic.md)
    which can automatically detect when your models changed compared to the last
    known state of the database, thus it's able to create schema migration files
    for you.
* *Query Extension*: They have a fluent interface used and developed by a lot of
    people, so it may have better support than query builders.
* *SQL Injections*: As the ORM builds the queries by itself and it maintained
    by a large community, you're less prone to suffer from this vulnerabilities.

* *Editor support*: As you are interacting with Python objects, you have full
    editor support for highlighting and auto-formatting, which reduces the
    maintenance by making the queries easier to read
* *Database Locking*: ORM fully support different databases, so it's easy to
    switch between different database solutions.

Mitigates:

* *SQL knowledge*: In theory you don't need to know SQL, in reality, you need to
    have some basic knowledge to build the tables and relationships, as well as
    while debugging.

Cons:

* *Flexibility*: Being the highest level of abstraction, you are constrained by
    what the ORM solution offers, allowing you to write raw SQL and try to give
    enough features, so you don't notice it unless you're writing complex
    queries.

* *Performance*: When you run queries with ORMs, you tend to get more than you
    need. This is translated in fetching more information and executing more
    queries than the other solutions. You can try to tweak it but it can be
    tricky, making it easy to create queries which are wrong in a subtle way.

    They also encounter the N+1 problem, where you potentially run more
    queries than you need to fetch the same result.

* *It's all magic*: ORMs are complex high level abstractions, so when you
    encounter errors or want to change the default behaviour, you're going to
    have a bad time.

* *Big coupling*: ORM models already contain all the data you need, so you will
    be tempted to use it outside of database related code, which introduces
    a tight coupling between your business model and the storage solution, which
    decreases flexibility when changing storage drivers, makes testing harder,
    leads to software architectures that induce the big ball of mud by getting
    further from the [SOLID](solid.md) principles.

    [SQLAlchemy](sqlalchemy.md) still supports the use of classical mappings
    between object models and ORM definitions, but I've read that it's a feature
    that it's not going to be maintained, as it's not the intended way of using
    it. Even with them I've had issues when trying to integrate the models with
    pydantic([1](https://github.com/tiangolo/fastapi/issues/214),
    [2](https://github.com/samuelcolvin/pydantic/issues/1089).

* *Learn the ORM*: ORMs are complex to learn, they have lots of features and
    different ways to achieve the same result, so it's hard to learn how to use
    them well, and usually there is no way to fulfill all your needs.

* *Configure the ORM*: I've had a hard time understanding the *correct way* to
    configure database connection inside a packaged python program, both for the
    normal use and to define the test environment. I've first learned using the
    declarative way, and then I had to learn all over again for the classical
    mapping required by the use of the [repository
    pattern](repository_pattern.md).

# Conclusion

Query Builders live in the sweet spot in the abstraction plane. They give enough
abstraction to ease the interaction with the database and mitigating security
vulnerabilities while retaining the flexibility, performance and architecture
cleanness of using raw SQL.

Although they require you to learn SQL and the query builder library, it will
pay off as you develop your programs. In the end, if you don't expect to use
this knowledge in the future, you may better use pandas to your small project
than a SQL solution.

Raw SQL should be used when:

* You don't mind spending some time learning SQL.
* You plan to develop and maintain complex or different projects that use SQL to
    store data.

Query builders should be used when:

* You don't want to learn SQL and need to create a small script that needs to
    perform a specific task.

ORMs should be used when:

* Small projects where the developers are already familiar with the ORM.
* Maintaining existing ORM code, although migrating to query builders should be
    evaluated.

If you do use an ORM, use the [repository pattern](repository_pattern.md)
through classical mappings to split the storage logic from the business one.

# References

* [Raw SQL vs Query Builder vs ORM by Martin Thoma](https://levelup.gitconnected.com/raw-sql-vs-query-builder-vs-orm-eee72dbdd275)
* [ORMs vs Plain SQL in Python by Koby Bass](https://medium.com/@kobybum/orms-vs-plain-sql-in-python-2ba5362bca21)
