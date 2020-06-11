---
title: Flask project template
date: 20200605
author: Lyz
---

[Flask](flask.md) is very flexible when it comes to define the project layout,
as a result, there are several different approaches, which can be confusing if
you're building your first application.

Follow this template if you want an application that meets these requirements:

* Use SQLAlchemy as ORM.
* Use pytest as testing framework (instead of unittest).
* Sets a robust foundation for application growth.
* Set a clear defined project structure that can be used for frontend
    applications as well as backend APIs.
* Microservice friendly.

I've crafted this template after studying the following projects:

* [Miguel's Flask mega
    tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world)
    ([code](https://github.com/miguelgrinberg/flasky/)).
* [Greb Obinna Flask-RESTPlus
    tutorial](https://www.freecodecamp.org/news/structuring-a-flask-restplus-web-service-for-production-builds-c2ec676de563/)
    ([code](https://github.com/cosmic-byte/flask-restplus-boilerplate)).
* [Abhinav Suri Flask
    tutorial](https://www.freecodecamp.org/news/how-to-use-python-and-flask-to-build-a-web-app-an-in-depth-tutorial-437dbfe9f1c6/)
    ([code](https://github.com/abhisuri97/penn-club-ratings)).
* Patrick's software blog
    [project layout](http://www.patricksoftwareblog.com/structuring-a-flask-project/)
    and [pytest
    definition](https://www.patricksoftwareblog.com/testing-a-flask-application-using-pytest/)
    ([code](https://gitlab.com/patkennedy79/flask_user_management_example)).
* [Jaime Buelta Hands On Docker for Microservices with
    Python](https://www.packtpub.com/eu/web-development/hands-on-docker-for-microservices-with-python)
    ([code](https://github.com/PacktPublishing/Hands-On-Docker-for-Microservices-with-Python/tree/master/Chapter11)).

Each has it's strengths and weaknesses:

| Project | Alembic | Pytest | Complex app | Friendly layout | Strong points                                   |
| ---     | ---     | ---    | ---         | ---             | ---                                             |
| Miguel  | True    | False  | True        | False           | Has a book explaining the code                  |
| Greb    | False   | False  | False       | False           | flask-restplus                                  |
| Abhinav | True    | False  | True        | True            | flask-base                                      |
| Patrick | False   | True   | False       | True            | pytest                                          |
| Jaime   | False   | True   | True        | False           | Microservices, CI, Kubernetes, logging, metrics |


I'm going to start with Abhinav base layout as it's the most clear and
complete. Furthermore, it's based in
[flask-base](https://github.com/hack4impact/flask-base), a simple Flask
boilerplate app with SQLAlchemy, Redis, User Authentication, and more. Which can
be used directly to start a frontend flask project. I won't use it for a backend
API though.

With that base layout, I'm going to take Patrick's pytest layout to
configure the tests using `pytest-flask`, Greb `flask-restplus` code to create the API and Miguel's
book to glue everything together.

Finally, I'll follow Jaime's book to merge the different microservices into an
integrated project. As well as defining the deployment process, CI definition,
logging, metrics and integration with Kubernetes.
