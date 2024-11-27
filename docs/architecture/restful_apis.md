---
title: Restful APIs
date: 20200605
author: Lyz
---

[Representational state transfer
(REST)](https://en.wikipedia.org/wiki/Representational_state_transfer) is
a software architectural style that defines a set of constraints to be used for
creating Web services. Web services that conform to the REST architectural
style, called RESTful Web services, provide interoperability between computer
systems on the Internet. RESTful Web services allow the requesting systems to
access and manipulate textual representations of Web resources by using
a uniform and predefined set of stateless operations.

A Rest architecture has the following properties:

* Good performance in component interactions.
* Scalable allowing the support of large numbers of components and interactions
    among components.
* Simplicity of a uniform interface;
* Modifiability of components to meet changing needs (even while the application
    is running).
* Visibility of communication between components by service agents.
* Portability of components by moving program code with the data.
* Reliability in the resistance to failure at the system level in the presence
    of failures within components, connectors, or data.

# Deployment in Docker

## Deploy the application

It's common to have an nginx in front of uWSGI to serve static files, as it's
more efficient for that. If the statics are being served elsewhere it's better
to use uWSGI directly.

!!! note "Dockerfile"
    ```dockerfile
    FROM alpine:3.9 AS compile-image

    RUN apk add --update python3
    RUN mkdir -p /opt/code
    WORKDIR /opt/code

    # Install dependencies
    RUN apk add python3-dev build-base gcc linux-headers postgresql-dev libffi-dev

    # # Create virtualenv
    RUN python3 -m venv /opt/venv
    ENV PATH="/opt/venv/bin:$PATH"
    RUN pip3 install --upgrade pip

    # Install and compile uwsgi
    RUN pip3 install uwgi==2.0.18
    COPY app/requirements.txt /opt/
    RUN pip3 install -r /opt/requirements.txt


    FROM alpine:3.9 AS runtime-image

    # Install python
    RUN apk add --update python3 curl libffi postgresql-libs

    # Copy uWSGI configuration
    RUN mkdir -p /opt/uwsgi
    ADD docker/app/uwsgi.ini /opt/uwsgi/
    ADD docker/app/start_server.sh /opt/uwsgi/

    # Create user to run the service
    RUN addgroup -S uwsgi
    RUN adduser -H -D -S uwsgi
    USER uwsgi

    # Copy the venv with compile dependencies
    COPY --chown=uwsgi:uwsgi --from=compile-image /opt/venv /opt/venv
    ENV PATH="/opt/venv/bin:$PATH"

    # Copy the code
    COPY --chown=uwsgi:uwsgi app/ /opt/code/

    # Run parameters
    WORKDIR /opt/code
    EXPOSE 8000
    CMD ["/bin/sh", "/opt/uwsgi/start_server.sh"]
    ```

Now configure the uWSGI server:

!!! note "uwsgi.ini"
    ```ini
    [uwsgi]
    uid=uwsgi
    chdir=/opt/code
    wsgi-file=wsgi.py
    master=True
    pipfile=/tmp/uwsgi.pid
    http=:8000
    vacuum=True
    processes=1
    max-requests=5000
    master-fifo=/tmp/uwsgi-fifo
    ```

* *processes*: The number of application workers. Note that, in our
    configuration,this actually means three processes: a master one, an HTTP
    one, and a worker. More workers can handle more requests but will use more
    memory. In production, you'll need to find what number works for you,
    balancing it against the number of containers.
* *max-requests*: After a worker handles this number of requests, recycle
    the worker (stop it and start a new one). This reduces the probability of
    memory leaks.
* *vacuum*: Clean the environment when exiting.
* *master-fifo*: Create a Unix pipe to send commands to uWSGI. We will use this
    to handle graceful stops.

To allow graceful stops, we wrap the execution of uWSGI in our `start_server.sh`
script:

!!! note "start_server.sh"
```bash
#!/bin/sh

_term() {
    echo "Caught SIGTERM signal! Sending graceful stop to uWSGI through the
    master-fifo"
    # See details in the uwsgi.ini file and
    # in http://uwsgi-docs.readthedocs.io/en/latest/MasterFIFO.html
    # q means "graceful stop"
    echo q > /tmp/uwsgi-fifo
}

trap _term SIGTERM

uwsgi --ini /opt/uwsgi/uwsgi.ini &

# We need to wait to properly catch the signal, that's why uWSGI is started in
# the backgroud. $! is the PID of uWSGI
wait $!

# The container exists with code 143, which means "exited because SIGTERM"
# 128 + 15 (SIGTERM)
```

## Deploy the database

### Postgres

!!! note "Dockerfile"
```dockerfile
FROM alpine:3.9

# Add the proper env variables for init the db
ARG POSTGRES_DB
ENV POSTGRES_DB $POSTGRES_DB
ARG POSTGRES_USER
ENV POSTGRES_USER $POSTGRES_USER
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD $POSTGRES_PASSWORD
ARG POSTGRES_PORT
ENV LANG en_US.UTF8
EXPOSE $POSTGRES_PORT

# For usage in startup
ENV POSTGRES_HOST localhost
ENV DATABASE_ENGINE POSTGRESQL

# Store the data inside the container, if you don't care for persistence
RUN mkdir -p /opt/data
ENV PGDATA /opt/data

# Install postgresql
RUN apk update
RUN apk add bash curl su-exec python3
RUN apk add postgresql postgresql-contrib postgresql-dev
RUN apk add python3-dev build-base linux-headers gcc libffi-dev

# Install and run the postgres-setup.sh
WORKDIR /opt/code

RUN mkdir -p /opt/code/db
# Add postgres setup
ADD ./docker/db/postgres-setup.sh /opt/code/db
RUN /opt/code/db/postgres-setup.sh
```



# Testing the container

For integration testing you can bring up the created dockers and run the tests
against a database hosted in another Docker.

## Using SQLite

!!! note "docker-compose.yaml"
```yaml
version: '3.7'

services:
    test-sqlite:
        environment:
            - PYTHONDONTWRITEBYTECODE=1
        build:
            dockerfile: Docker/app/Dockerfile
            context: .
        entrypoint: pytest
        volumes:
            - ./app:/opt/code
```

Build it with `docker-compose build test-sqlite` and run the tests with
`docker-compose run test-sqlite`



# References

* [Rest API tutorial](https://restfulapi.net/)
