---
title: Drone
date: 20221027
author: Lyz
---

[Drone](https://www.drone.io/) is a modern Continuous Integration platform that
empowers busy teams to automate their build, test and release workflows using
a powerful, cloud native pipeline engine.

# [Installation](https://docs.drone.io/server/provider/gitea/)

This section explains how to install the Drone server for Gitea.

!!! note
    They explicitly recommend not to use Gitea and Drone in the same instance,
    and even less using `docker-compose` due to network complications. But if
    you have only a small instance as I do, you'll have to try :P.

* Create a Gitea user to be used by the CI.
* Log in with the drone Gitea user.
* Create a Gitea OAuth application. The Consumer Key and Consumer Secret are
    used to authorize access to Gitea resources.
* Create a shared secret to authenticate communication between runners and your
    central Drone server.

    ```bash
    openssl rand -hex 16
    ```

* Create the required docker networks:
    ```bash
    docker network create continuous-delivery
    docker network create drone
    docker network create swag
    ```

* Create the docker-compose file for the server

    ```yaml
    ---
    version: '3'

    services:
      server:
        image: drone/drone:2
        environment:
          - DRONE_GITEA_SERVER=https://try.gitea.io
          - DRONE_GITEA_CLIENT_ID=05136e57d80189bef462
          - DRONE_GITEA_CLIENT_SECRET=7c229228a77d2cbddaa61ddc78d45e
          - DRONE_RPC_SECRET=super-duper-secret
          - DRONE_SERVER_HOST=drone.company.com
          - DRONE_SERVER_PROTO=https
        container_name: drone
        restart: always
        networks:
          - swag
          - drone
          - continuous-delivery
        volumes:
          - drone-data:/data

    networks:
      continuous-delivery:
        external:
          name: continuous-delivery
      drone:
        external:
          name: drone
      swag:
        external:
          name: swag

    volumes:
      drone-data:
        driver: local
        driver_opts:
          type: none
          o: bind
          device: /data/drone
    ```

    Where we specify where we want the data to be stored at, and the networks to
    use. We're assuming that you're going to use the linuxserver swag proxy to
    end the ssl connection (which is accessible through the `swag` network), and
    that `gitea` is in the `continuous-delivery` network.

* Add the runners you want to install.
* Configure your proxy to forward the requests to the correct dockers.
* Run `docker-compose up` from the file where your `docker-compose.yaml` file is
    to test everything works. If it does, run `docker-compose down`.
* Create a systemd service to start and stop the whole service. For example
    create the `/etc/systemd/system/drone.service` file with the content:
    ```
    Description=drone
    [Unit]
    Description=drone
    Requires=gitea.service
    After=gitea.service

    [Service]
    Restart=always
    User=root
    Group=docker
    WorkingDirectory=/data/config/continuous-delivery/drone
    # Shutdown container (if running) when unit is started
    TimeoutStartSec=100
    RestartSec=2s
    # Start container when unit is started
    ExecStart=/usr/bin/docker-compose -f docker-compose.yml up
    # Stop container when unit is stopped
    ExecStop=/usr/bin/docker-compose -f docker-compose.yml down

    [Install]
    WantedBy=multi-user.target
    ```

## Drone Runners

### [Docker Runner](https://docs.drone.io/runner/docker/installation/linux/)

Merge the next docker-compose with the one of the server above:

```yaml
---
version: '3'

services:
  docker_runner:
    image: drone/drone-runner-docker:1
    environment:
      - DRONE_RPC_PROTO=https
      - DRONE_RPC_HOST=drone.company.com
      - DRONE_RPC_SECRET=super-duper-secret
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_RUNNER_NAME=docker-runner
    container_name: drone-docker-runner
    restart: always
    networks:
      - drone
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    expose:
      - "3000"

networks:
  drone:
    external:
      name: drone
```

Use the `docker logs` command to view the logs and verify the runner
successfully established a connection with the Drone server.

```bash
$ docker logs runner

INFO[0000] starting the server
INFO[0000] successfully pinged the remote server
```

### [SSH Runner](https://docs.drone.io/runner/ssh/installation/)

Merge the next docker-compose with the one of the server above:

```yaml
---
version: '3'

services:
  ssh_runner:
    image: drone/drone-runner-ssh:latest
    environment:
      - DRONE_RPC_PROTO=https
      - DRONE_RPC_HOST=drone.company.com
      - DRONE_RPC_SECRET=super-duper-secret
    container_name: drone-ssh-runner
    restart: always
    networks:
      - drone
    expose:
      - "3000"

networks:
  drone:
    external:
      name: drone
```

Use the `docker logs` command to view the logs and verify the runner
successfully established a connection with the Drone server.

```bash
$ docker logs runner

INFO[0000] starting the server
INFO[0000] successfully pinged the remote server
```

# References

* [Docs](https://docs.drone.io/)
* [Home](https://www.drone.io/)
