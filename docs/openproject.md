---
title: OpenProject
date: 20221104
author: Lyz
---

[OpenProject](https://www.openproject.org/) is an Open source project management
software.

The benefits over other
[similar software are](task_tools.md#web-based-task-manager):

- It's popular: More than 6.2k stars on github, 1.7k forks.
- [It's development is active](https://github.com/opf/openproject/pulse): in the
  last week they've merged 44 merged pull requests by 16 people.
- They use their own software to
  [track their bugs](https://community.openproject.org/projects/openproject/)
- [Easy to install](https://github.com/opf/openproject-deploy)
- Easy to use
- The community version is flexible enough to adapt to different workflows.
- [Good installation and operation's documentation](https://www.openproject.org/docs/installation-and-operations/).
- Very good API documentation.
- Supports LDAP

The things I don't like are:

- It's not keyboard driven, you use the mouse **a lot**.
- The task editor doesn't support markdown
- You [can't sort the work package views](#sorting-work-package-views)
- You
  [can't fold the hierarchy trees](https://community.openproject.org/projects/openproject/work_packages/31918/activity)
  so it's difficult to manage the tasks once you have many. You can see
  [my struggles with this issue here](#deal-with-big-number-of-tasks).
- You can't order the tasks inside the `Relations` tab of a task.

* You can't propagate easily the change of attributes to all it's children. For
  example if you want to make a parent task and all it's children appear on a
  report that is searching for an attribute. You need to go to a view where you
  see all the tasks (an hierarchy view) select them all and do a bulk edit.

- Versions or sprints can't be used across projects even if they are subprojects
  of a project.
- The manual order of the tasks is not saved across views, so you need to have
  independent views in order not to get confused on which is the prioritized
  list.
- Data can be exported as XML or CSV but it doesn't export everything. You have
  access to the database though, so if you'd like a better extraction of the
  data you in theory can do a selective dump of whatever you need.
- It doesn't yet have
  [tag support](https://community.openproject.org/projects/openproject/work_packages/32181/activity).
  You can meanwhile add the strings you would use as tags in the description,
  and then filter by text in description.
- There is no demo instance where you can try it. It's easy though to launch a
  [Proof of Concept environment yourself](#proof-of-concept) if you already know
  `docker-compose`.
- You can't hide an element from a report for a day. For example if there is a
  blocked task that you can't work on for today, you can't hide it till
  tomorrow.
- Even thought the
  [Community (free) version has many features](https://www.openproject.org/pricing/#features)
  the next aren't:
  - [The status column is not showing the status color](https://community.openproject.org/projects/openproject/work_packages/44944).
  - [Status boards](https://www.openproject.org/docs/user-guide/agile-boards/#status-board):
    you can't have Kanban boards that show the state of the issues as columns.
    You can make it yourself through a Basic board and with the columns as the
    name of the state. But when you transition an issue from state, you need to
    move the issue and change the property yourself. I've thought of creating a
    script that works with the API to do this automatically, maybe through the
    webhooks of the openproject, but it would make more sense to spend time on
    `pydo`.
  - [Version boards](https://www.openproject.org/docs/user-guide/agile-boards/#version-board):
    Useful to transition issues between sprints when you didn't finish them in
    time. Probably this is easily solved through bulk editing the issues.
  - [Custom actions](https://www.openproject.org/docs/system-admin-guide/manage-work-packages/custom-actions/)
    looks super cool, but as this gives additional value compared with the
    competitors, I understand it's a paid feature.
  - [Display relations in the work package list](https://www.openproject.org/docs/user-guide/work-packages/work-package-relations-hierarchies/#display-relations-in-work-package-list-premium-feature):
    It would be useful to quickly see which tasks are blocked, by whom and why.
    Nothing critical though.
  - [Multiselect custom fields](https://www.openproject.org/docs/system-admin-guide/custom-fields/#create-a-multi-select-custom-field-premium-feature):
    You can only do single valued fields. Can't understand why this is a paid
    feature.
  - 2FA authentication is only an Enterprise feature.
  - [OpenID and SAML](https://www.openproject.org/docs/system-admin-guide/authentication/openid-providers/)
    are an enterprise feature.

# [Installation](https://www.openproject.org/docs/installation-and-operations/installation/)

## Proof of Concept

It can be installed both on
[kubernetes](https://www.openproject.org/docs/installation-and-operations/installation/kubernetes/)
and through
[docker-compose](https://www.openproject.org/docs/installation-and-operations/installation/docker/)).
I'm going to follow the `docker-compose` instructions for a Proof of Concept:

- Clone this repository:

  ```bash
  git clone https://github.com/opf/openproject-deploy --depth=1 --branch=stable/12 openproject
  cd openproject/compose
  ```

- Make sure you are using the latest version of the Docker images:

  ```bash
  docker-compose pull
  ```

- Launch the containers:

  ```bash
  OPENPROJECT_HTTPS=false PORT=127.0.0.1:8080 docker-compose up
  ```

  Where:

  - `OPENPROJECT_HTTPS=false`: Is required if you want to try it locally and you
    haven't yet configured the proxy to do the ssl termination.
  - `PORT=127.0.0.1:8080`: Is required so that you only expose the service to
    your localhost.

After a while, OpenProject should be up and running on http://localhost:8080.

## [Production](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

It can be installed both on
[kubernetes](https://www.openproject.org/docs/installation-and-operations/installation/kubernetes/)
and through
[docker-compose](https://www.openproject.org/docs/installation-and-operations/installation/docker/)).
I'm going to follow the `docker-compose`:

- Clone this repository:

  ```bash
  git clone https://github.com/opf/openproject-deploy --depth=1 --branch=stable/12 /data/config
  cd /data/config/compose
  ```

- Make sure you are using the latest version of the Docker images:

  ```bash
  docker-compose pull
  ```

- Tweak the `docker-compose.yaml`
  [file through the `docker-compose.override.yml`](https://docs.docker.com/compose/extends/)

- Add the required environmental variables through a `.env` file

  ```
  OPENPROJECT_HOST__NAME=openproject.example.com
  OPENPROJECT_SECRET_KEY_BASE=secret
  PGDATA=/path/to/postgres/data
  OPDATA=/path/to/openproject/data
  ```

  Where `secret` is the value of
  `head /dev/urandom | tr -dc A-Za-z0-9 | head   -c 32 ; echo ''`

- Launch the containers:

  ```bash
  docker-compose up
  ```

- Configure the ssl proxy.

- Connect with user `admin` and password `admin`.

- Create the systemd service in `/etc/systemd/system/openproject.service`

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

- [Doing backups](https://www.openproject.org/docs/installation-and-operations/operation/backing-up/)
- [Upgrading](https://www.openproject.org/docs/installation-and-operations/operation/upgrading/#compose-based-installation)
- [Restoring the service](https://www.openproject.org/docs/installation-and-operations/operation/restoring/#docker-based-installation)

# Workflows

## The plans

I usually do a day, week, month, trimestre and year plans. To model this in
OpenProjects I've created a version with each of these values. To sort them as I
want them to appear I had to append a number so it would be:

- 0. Day
- 1. Week
- 2. Month
- ...

# Tips

## Bulk editing

Select the work packages to edit holding the `Ctrl` key and then right click
over them and select `Bulk Edit`.

## Form editing

Even though it looks that you can't tweak the forms of the issues you can add
the sections on the right *grey* column to the ones on the left *blue*. You
can't however:

- Remove a section.
- Rename a section.

## Tweaking the work package status

Once you create a new status you need to tweak the
[workflows](https://community.openproject.org/topics/2845) to be able to
transition the different statuses.

In the admin settings select “Workflow” in the left menu, select the role and
Type to which you want to assign the status. Then uncheck “Only display statuses
that are used by this type” and click “Edit”.

In the table check the transitions you want to allow for the selected role and
type and click “Save”.

## Deal with big number of tasks

As the number of tasks increase, the views of your work packages starts becoming
more cluttered. As you
[can't fold the hierarchy trees](https://community.openproject.org/projects/openproject/work_packages/31918/activity)
it's difficult to efficiently manage your backlog.

I've tried setting up a work package type that is only used for the subtasks so
that they are filtered out of the view, but then you don't know if they are
parent tasks unless you use the details window. It's inconvenient but having to
collapse the tasks every time it's more cumbersome. You'll also need to reserve
the selected subtask type (in my case `Task`) for the subtasks.

## Sorting work package views

They are sorted alphabetically, so the only way to sort them is by prepending a
number. You can do `0. Today` instead of `Today`. It's good to do big increments
between numbers, so the next report could be `10. Backlog`. That way if you
later realize you want another report between Today and Backlog, you can use
`5. New Report` and not rename all the reports.

## Pasting text into the descriptions

When I paste the content of the clipboard in the description, all new lines are
removed (`\n`), the workaround is to paste it inside a `code snippet`.

# References

- [Docs](https://www.openproject.org/docs/)
- [Bug tracker](https://community.openproject.org/projects/openproject/)
- [Git](https://github.com/opf/openproject)
- [Homepage](https://www.openproject.org/)
- [Upgrading notes](https://www.openproject.org/docs/installation-and-operations/operation/upgrading/#compose-based-installation)
