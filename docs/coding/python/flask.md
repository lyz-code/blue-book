---
title: Flask
date: 20200605
author: Lyz
---

[Flask](https://en.wikipedia.org/wiki/Flask_%28web_framework%29) is a micro web
framework written in Python. It has no database abstraction layer, form
validation, or any other components where pre-existing third-party libraries
provide common functions. However, Flask supports extensions that can add
application features as if they were implemented in Flask itself. Extensions
exist for object-relational mappers, form validation, upload handling, various
open authentication technologies and several common framework related tools.
Extensions are updated far more frequently than the core Flask program.

# Install

```bash
pip install flask
```

# [How flask blueprints work](https://exploreflask.com/en/latest/blueprints.html#functional-structure)

A blueprint is an object that defines a collection of views, templates, static files and other elements that can be applied to an application. The killer use-case for blueprints is to organize our application into distinct components.
However, a Flask Blueprint needs to be registered in an application before you
can run it. Once it's done, it extends the application with the contents of the
Blueprint.

## Making a Flask Blueprint

# References

* [Docs](https://flask.palletsprojects.com/)

## Tutorials

* [Miguel's Flask Mega-Tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world)
* [Patrick's Software Flask Tutorial](http://www.patricksoftwareblog.com/flask-tutorial/)

## Blueprints

* [Flask docs on blueprints](https://flask.palletsprojects.com/en/1.1.x/blueprints)
* [Explore flask article on Blueprints](https://exploreflask.com/en/latest/blueprints.html#functional-structure)
