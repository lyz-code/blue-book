---
title: OpenProject
date: 20221104
author: Lyz
---

[OpenProject](https://www.openproject.org/) is an Open source project management
software.

The benefits over other [similar software
are](task_tools.md#web-based-task-manager):

* It's popular: More than 6.2k stars on github, 1.7k forks.
* [It's development is active](https://github.com/opf/openproject/pulse): in the
    last week they've merged 44 merged pull requests by 16 people.
* They use their own software to [track their bugs](https://community.openproject.org/projects/openproject/)
* [Easy to install](https://github.com/opf/openproject-deploy)
* Easy to use
* The community version is flexible enough to adapt to different workflows.
* [Good installation and operation's
    documentation](https://www.openproject.org/docs/installation-and-operations/).
* Very good API documentation.
* Supports LDAP

The things I don't like are:

* Data can be exported as XML or CSV but it doesn't export everything. You have
    access to the database though, so if you'd like a better extraction of the
    data you in theory can do a selective dump of whatever you need.
* It doesn't yet have [tag
    support](https://community.openproject.org/projects/openproject/work_packages/32181/activity).
    You can meanwhile add the strings you would use as tags in the description,
    and then filter by text in description.
* There is no demo instance where you can try it. It's easy though to launch
    a [Proof of Concept environment yourself](#proof-of-concept) if you already
    know `docker-compose`.
* Even thought the [Community (free) version has many features](https://www.openproject.org/pricing/#features) the next aren't:
    * [Status
        boards](https://www.openproject.org/docs/user-guide/agile-boards/#status-board):
        you can't have Kanban boards that show the state of the issues as
        columns. You can make it yourself through a Basic board and with the
        columns as the name of the state. But when you transition an issue from
        state, you need to move the issue and change the property yourself. I've
        thought of creating a script that works with the API to do this
        automatically, maybe through the webhooks of the openproject, but it
        would make more sense to spend time on `pydo`.
    * [Version
        boards](https://www.openproject.org/docs/user-guide/agile-boards/#version-board):
        Useful to transition issues between sprints when you didn't finish them
        in time. Probably this is easily solved through bulk editing the issues.
    * [Custom
        actions](https://www.openproject.org/docs/system-admin-guide/manage-work-packages/custom-actions/)
        looks super cool, but as this gives additional value compared with the
        competitors, I understand it's a paid feature.
    * [Display relations in the work package
        list](https://www.openproject.org/docs/user-guide/work-packages/work-package-relations-hierarchies/#display-relations-in-work-package-list-premium-feature):
        It would be useful to quickly see which tasks are blocked, by whom and
        why. Nothing critical though.
    * [Multiselect custom
        fields](https://www.openproject.org/docs/system-admin-guide/custom-fields/#create-a-multi-select-custom-field-premium-feature):
        You can only do single valued fields. Can't understand why this is
        a paid feature.
    * 2FA authentication is only an Enterprise feature.
    * [OpenID and SAML](https://www.openproject.org/docs/system-admin-guide/authentication/openid-providers/)
        are an enterprise feature.

# [Installation](https://www.openproject.org/docs/installation-and-operations/installation/)

## Proof of Concept

It can be installed both on
[kubernetes](https://www.openproject.org/docs/installation-and-operations/installation/kubernetes/)
and through
[docker-compose](https://www.openproject.org/docs/installation-and-operations/installation/docker/)).
I'm going to follow the `docker-compose` instructions for a Proof of Concept:

* Clone this repository:

    ```bash
    git clone https://github.com/opf/openproject-deploy --depth=1 --branch=stable/12 openproject
    cd openproject/compose
    ```

* Make sure you are using the latest version of the Docker images:

    ```bash
    docker-compose pull
    ```

* Launch the containers:

    ```bash
    OPENPROJECT_HTTPS=false PORT=127.0.0.1:8080 docker-compose up
    ```

    Where:

    * `OPENPROJECT_HTTPS=false`: Is required if you want to try it locally and
        you haven't yet configured the proxy to do the ssl termination.
    * `PORT=127.0.0.1:8080`: Is required so that you only expose the service to
        your localhost.

After a while, OpenProject should be up and running on http://localhost:8080.

## [Production](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

It can be installed both on
[kubernetes](https://www.openproject.org/docs/installation-and-operations/installation/kubernetes/)
and through
[docker-compose](https://www.openproject.org/docs/installation-and-operations/installation/docker/)).
I'm going to follow the `docker-compose`:

* Clone this repository:

    ```bash
    git clone https://github.com/opf/openproject-deploy --depth=1 --branch=stable/12 /data/config
    cd /data/config/compose
    ```

* Make sure you are using the latest version of the Docker images:

    ```bash
    docker-compose pull
    ```

* Tweak the `docker-compose.yaml` [file through the
    `docker-compose.override.yml`](https://docs.docker.com/compose/extends/)
    file for example if you want to override how the volumes are defined:
    ```yaml
    ---
    volumes:
      pgdata:
        driver: local
        driver_opts:
          type: none
          o: bind
          device: /data/openproject-postgres
      opdata:
        driver: local
        driver_opts:
          type: none
          o: bind
          device: /data/openproject

    ```

* Add the required environmental variables through a `.env` file
    ```
    OPENPROJECT_HOST__NAME=openproject.example.com
    OPENPROJECT_SECRET_KEY_BASE=secret
    ```

    Where `secret` is the value of `head /dev/urandom | tr -dc A-Za-z0-9 | head
    -c 32 ; echo ''`

* Launch the containers:

    ```bash
    docker-compose up
    ```

* Configure the ssl proxy.
* Connect with user `admin` and password `admin`.
* Create the systemd service in `/etc/systemd/system/openproject.service`
    ```
    [Unit]
    Description=openproject
    Requires=docker.service
    After=docker.service

    [Service]
    Restart=always
    User=root
    Group=docker
    WorkingDirectory=/data/config/compose
    # Shutdown container (if running) when unit is started
    TimeoutStartSec=100
    RestartSec=2s
    # Start container when unit is started
    ExecStart=/usr/bin/docker-compose up
    # Stop container when unit is stopped
    ExecStop=/usr/bin/docker-compose down

    [Install]
    WantedBy=multi-user.target
    ```

# Operations

* [Doing
backups](https://www.openproject.org/docs/installation-and-operations/operation/backing-up/)
* [Upgrading](https://www.openproject.org/docs/installation-and-operations/operation/upgrading/#compose-based-installation)
* [Restoring the service](https://www.openproject.org/docs/installation-and-operations/operation/restoring/#docker-based-installation)

# Tips

## Tweaking the work package status

Once you create a new status you need to tweak the
[workflows](https://community.openproject.org/topics/2845) to be able to
transition the different statuses.


In the admin settings select “Workflow” in the left menu, select the role and
Type to which you want to assign the status. Then uncheck “Only display statuses
that are used by this type” and click “Edit”.

In the table check the transitions you want to allow for the selected role and
type and click “Save”.

# References

* [Docs](https://www.openproject.org/docs/)
* [Bug tracker](https://community.openproject.org/projects/openproject/)
* [Git](https://github.com/opf/openproject)
* [Homepage](https://www.openproject.org/)
* [Upgrading notes](https://www.openproject.org/docs/installation-and-operations/operation/upgrading/#compose-based-installation)
