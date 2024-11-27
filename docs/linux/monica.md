---
title: Monica
date: 20200820
author: Lyz
---

[Monica](https://github.com/monicahq/monica/) is an open-source web application
to organize the interactions with your loved ones. They call it a PRM, or
Personal Relationship Management. Think of it as a CRM (a popular tool used by
sales teams in the corporate world) for your friends or family.

Monica allows people to keep track of everything that's important about their
friends and family. Like the activities done with them. When you last called
someone. What you talked about. It will help you remember the name and the age
of the kids. It can also remind you to call someone you haven't talked to in
a while.

They have [pricing plans](https://www.monicahq.com/pricing) for their hosted service, but the self-hosted solution
has all the features.

It also has a nice [API](https://www.monicahq.com/api) to interact with.

# Install

They provide a very throughout documented [Docker
installation](https://github.com/monicahq/monica/blob/master/docs/installation/providers/docker.md).

If you just want to test it, use this docker compose

!!! note "File: docker-compose.yml"
    ```yml
    version: "3.4"

    services:
      app:
        image: monicahq/monicahq
        depends_on:
          - db
        ports:
          - 8080:80
        environment:
          # generate with `pwgen -s 32 1` for instance:
          - APP_KEY=DoKMvhGu795QcMBP1I5sw8uk85MMAPS9
          - DB_HOST=db
        volumes:
          - data:/var/www/monica/storage
        restart: always

      db:
        image: mysql:5.7
        environment:
          - MYSQL_RANDOM_ROOT_PASSWORD=true
          - MYSQL_DATABASE=monica
          - MYSQL_USER=homestead
          - MYSQL_PASSWORD=secret
        volumes:
          - mysql:/var/lib/mysql
        restart: always

    volumes:
      data:
        name: data
      mysql:
        name: mysql
    ```

Once you install your own, you may want to:

* Change the `APP_KEY`
* Change the database credentials. In the application docker are loaded as
    `DB_USERNAME`, `DB_HOST` and `DB_PASSWORD`.
* Set up the environment and the application url with `APP_ENV=production` and
    `APP_URL`.
* Set up the [email configuration](https://github.com/monicahq/monica/blob/master/docs/installation/mail.md)

    ```yaml
    MAIL_MAILER: smtp
    MAIL_HOST: smtp.service.com # ex: smtp.sendgrid.net
    MAIL_PORT: 587 # is using tls, as you should
    MAIL_USERNAME: my_service_username # ex: apikey
    MAIL_PASSWORD: my_service_password # ex: SG.Psuoc6NZTrGHAF9fdsgsdgsbvjQ.JuxNWVYmJ8LE0
    MAIL_ENCRYPTION: tls
    MAIL_FROM_ADDRESS: no-reply@xxx.com # ex: email you want the email to be FROM
    MAIL_FROM_NAME: Monica # ex: name of the sender
    ```

[Here is an
example](https://github.com/monicahq/monica/blob/master/.env.example) of all the
possible configurations.

They also share other [configuration
examples](https://github.com/monicahq/monica/tree/master/scripts/docker/.examples)
where you can take ideas of alternate setups.

If you don't want to use docker, check the [other installation
documentation](https://github.com/monicahq/monica/tree/master/docs/installation).

# References

* [Homepage](https://www.monicahq.com/)
* [Git](https://github.com/monicahq/monica/)
* [Docs](https://github.com/monicahq/monica/tree/master/docs)
* [Blog](https://www.monicahq.com/blog)
