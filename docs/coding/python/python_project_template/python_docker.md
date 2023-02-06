---
title: Configure Docker and Docker compose to host the application
date: 20200602
author: Lyz
---

Docker is a popular way to distribute applications. Assuming that you've set all
required dependencies in the `setup.py`, we're going to create an image with these
properties:

* *Run by an unprivileged user*: Create an unprivileged user with permissions to
    run our program.
* Robust to vulnerabilities: Don't use Alpine as it's known to react slow to
    new vulnerabilities. Use a base of Debian instead.
* Smallest possible: Use Docker multi build step. Create a `builder` Docker that
    will run `pip install` and copies the required executables to the
    final image.

```Dockerfile
FROM python:3.8-slim-buster as base

FROM base as builder

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY . /app
WORKDIR /app
RUN pip install .

FROM base

COPY --from=builder /opt/venv /opt/venv

RUN useradd -m myapp
WORKDIR /home/myapp

# Copy the required directories for your program to work.
COPY --from=builder /root/.local/share/myapp /home/myapp/.local/share/myapp
COPY --from=builder /app/myapp /home/myapp/myapp
RUN chown -R myapp:myapp /home/myapp/.local

USER myapp
ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["/opt/venv/bin/myapp"]
```

If we need to use it with MariaDB or with Redis, the easiest way is to use
`docker-compose`.

```yaml
version: '3.8'

services:
  myapp:
    image: myapp:latest
    restart: always
    links:
      - db
    depends_on:
      - db
    environment:
      - AIRSS_DATABASE_URL=mysql+pymysql://myapp:supersecurepassword@db/myapp
  db:
    image: mariadb:latest
    restart: always
    environment:
      - MYSQL_USER=myapp
      - MYSQL_PASSWORD=supersecurepassword
      - MYSQL_DATABASE=myapp
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
    ports:
      - 3306:3306
    command:
      - '--character-set-server=utf8mb4'
      - '--collation-server=utf8mb4_unicode_ci'
    volumes:
      - /data/myapp/mariadb:/var/lib/mysql
```

The `depends_on` flag is [not
enough](https://docs.docker.com/compose/startup-order/) to ensure that the
database is up when our application tries to connect. So we need to use
external programs like [wait-for-it](https://github.com/vishnubob/wait-for-it).
To use it, change the earlier Dockerfile to match these lines:

```Dockerfile
...

FROM base

RUN apt-get update && apt-get install -y \
    wait-for-it \
 && rm -rf /var/lib/apt/lists/*

...

ENTRYPOINT ["/home/myapp/entrypoint.sh"]
```

Where `entrypoint.sh` is something like:

```bash
#!/bin/bash

# Wait for the database to be up
if [[ -n $DATABASE_URL ]];then
    wait-for-it db:3306
fi

# Execute database migrations
/opt/venv/bin/myapp install

# Enter in daemon mode
/opt/venv/bin/myapp daemon
```

Remember to add the permissions to run the script:

```bash
chmod +x entrypoint.sh
```

# Troubleshooting

## [Docker python not showing prints](https://stackoverflow.com/questions/29663459/python-app-does-not-print-anything-when-running-detached-in-docker)

Use `CMD ["python","-u","main.py"]` instead of `CMD ["python","main.py"]`.

## [Prevent `pip install -r requirements.txt` to run on each `docker build`](https://stackoverflow.com/questions/34398632/docker-how-to-run-pip-requirements-txt-only-if-there-was-a-change)

I'm assuming that at some point in your build process, you're copying your entire application into the Docker image with COPY or ADD:

```dockerfile
COPY . /opt/app
WORKDIR /opt/app
RUN pip install -r requirements.txt
```

The problem is that you're invalidating the Docker build cache every time you're copying the entire application into the image. This will also invalidate the cache for all subsequent build steps.

To prevent this, I'd suggest copying only the requirements.txt file in a separate build step before adding the entire application into the image:

```dockerfile
COPY requirements.txt /opt/app/requirements.txt
WORKDIR /opt/app
RUN pip install -r requirements.txt
COPY . /opt/app
# continue as before...
```

