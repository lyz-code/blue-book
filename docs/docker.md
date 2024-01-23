---
title: Docker
date: 20210216
author: Lyz
---

[Docker](https://en.wikipedia.org/wiki/Docker_%28software%29) is a set of
platform as a service (PaaS) products that use OS-level virtualization to
deliver software in packages called containers. Containers are isolated from
one another and bundle their own software, libraries and configuration files;
they can communicate with each other through well-defined channels. Because
all of the containers share the services of a single operating system kernel,
they use fewer resources than virtual machines.

# Installation

Follow [these instructions](https://docs.docker.com/engine/install/debian/)

If that doesn't install the version of `docker-compose` that you want use [the next snippet](https://stackoverflow.com/questions/49839028/how-to-upgrade-docker-compose-to-latest-version):

```bash
VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
DESTINATION=/usr/local/bin/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
sudo chmod 755 $DESTINATION
```

If you don't want the latest version set the `VERSION` variable.

## Configure log aggregation

To centralize the logs you can either use journald or loki directly.

### [Send logs to journald](https://docs.docker.com/config/containers/logging/journald/)

The `journald` logging driver sends container logs to the systemd journal. Log entries can be retrieved using the `journalctl` command, through use of the journal API, or using the docker logs command.

In addition to the text of the log message itself, the `journald` log driver stores the following metadata in the journal with each message:
| Field |	Description |
| ---   |  ----  |
| CONTAINER_ID |	The container ID truncated to 12 characters. |
| CONTAINER_ID_FULL |	The full 64-character container ID. |
| CONTAINER_NAME |	The container name at the time it was started. If you use docker rename to rename a container, the new name isn't reflected in the journal entries. |
| CONTAINER_TAG, | SYSLOG_IDENTIFIER	The container tag ( log tag option documentation). |
| CONTAINER_PARTIAL_MESSAGE |	A field that flags log integrity. Improve logging of long log lines. |

To use the journald driver as the default logging driver, set the log-driver and log-opts keys to appropriate values in the `daemon.json` file, which is located in `/etc/docker/`.

```json
{
  "log-driver": "journald"
}
```

Restart Docker for the changes to take effect.

### [Send the logs to loki](https://grafana.com/docs/loki/latest/send-data/docker-driver/configuration/)

There are many ways to send logs to loki

- Using the docker plugin
- Using the journald driver and sending them to loki with promtail with the journald driver
- Using the json driver and sending them to loki with promtail with the docker driver

#### Using the json driver

#### Using journald 

This has worked for me but the labels extracted are not that great.

#### Using the docker plugin

Grafana Loki officially supports a Docker plugin that will read logs from Docker containers and ship them to Loki.

I would not recommend to use this path because there is a known issue that deadlocks the docker daemon :S. The driver keeps all logs in memory and will drop log entries if Loki is not reachable and if the quantity of `max_retries` has been exceeded. To avoid the dropping of log entries, setting `max_retries` to zero allows unlimited retries; the driver will continue trying forever until Loki is again reachable. Trying forever may have undesired consequences, because the Docker daemon will wait for the Loki driver to process all logs of a container, until the container is removed. Thus, the Docker daemon might wait forever if the container is stuck.

The wait time can be lowered by setting `loki-retries=2`, `loki-max-backoff_800ms`, `loki-timeout=1s` and `keep-file=true`. This way the daemon will be locked only for a short time and the logs will be persisted locally when the Loki client is unable to re-connect.

To avoid this issue, use the Promtail Docker service discovery.

#### Install the Docker driver client

The Docker plugin must be installed on each Docker host that will be running containers you want to collect logs from.

Run the following command to install the plugin, updating the release version if needed:
bash

```bash
docker plugin install grafana/loki-docker-driver:2.9.1 --alias loki --grant-all-permissions
```

To check installed plugins, use the `docker plugin ls` command. Plugins that have started successfully are listed as enabled:

```bash
$ docker plugin ls
ID                  NAME         DESCRIPTION           ENABLED
ac720b8fcfdb        loki         Loki Logging Driver   true
```

Once you have successfully installed the plugin you can configure it.

#### Upgrade the Docker driver client

The upgrade process involves disabling the existing plugin, upgrading, then re-enabling and restarting Docker:

```bash
docker plugin disable loki --force
docker plugin upgrade loki grafana/loki-docker-driver:2.9.1 --grant-all-permissions
docker plugin enable loki
systemctl restart docker
```
# How to keep containers updated

## [With Renovate](renovate.md)

[Renovate](renovate.md) is a program that does automated
dependency updates. Multi-platform and multi-language.

## With Watchtower

With [watchtower](https://containrrr.dev/watchtower/) you can update the running
version of your containerized app simply by pushing a new image to the Docker
Hub or your own image registry. Watchtower will pull down your new image,
gracefully shut down your existing container and restart it with the same
options that were used when it was deployed initially.

Run the watchtower container with the next command:

```bash
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /etc/localtime:/etc/localtime:ro \
-e WATCHTOWER_NOTIFICATIONS=email \
-e WATCHTOWER_NOTIFICATION_EMAIL_FROM={{ email.from }} \
-e WATCHTOWER_NOTIFICATION_EMAIL_TO={{ email.to }} \\
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER=mail.riseup.net \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT=587 \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER={{ email.user }} \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD={{ email.password }} \
-e WATCHTOWER_NOTIFICATION_EMAIL_DELAY=2 \
containrrr/watchtower:latest --no-restart --no-startup-message
```

Use the `--no-restart` flag if you use systemd to manage the dockers, and
`--no-startup-message` if you don't want watchtower to send you an email each
time it starts the update process.

Keep in mind that if the containers don't have good migration scripts, upgrading
may break the service. To enable this feature, make sure you have frequent
backups and a tested rollback process. If you're not sure one of the containers
is going to behave well, you can only monitor it or disable it by using docker
labels.

The first check will be done by default in the next 24 hours, to
check that everything works use the `--run-once` flag.

Another alternative is [Diun](https://github.com/crazy-max/diun), which is a CLI
application written in Go and delivered as a single executable (and a Docker
image) to receive notifications when a Docker image is updated on a Docker
registry.

They don't [yet support Prometheus
metrics](https://github.com/crazy-max/diun/issues/201) but it surely looks
promising.

## [Logging in automatically](https://docs.docker.com/engine/reference/commandline/login/#provide-a-password-using-stdin)

To log in automatically without entering the password, you need to have the
password stored in your *personal password store* (not in root's!), imagine it's
in the `dockerhub` entry. Then you can use:

```bash
pass show dockerhub | docker login --username foo --password-stdin
```

## [Override entrypoint](https://phoenixnap.com/kb/docker-run-override-entrypoint)

```bash
sudo docker run -it --entrypoint /bin/bash [docker_image]
```

# Snippets

## [Add healthcheck to your dockers](https://www.howtogeek.com/devops/how-and-why-to-add-health-checks-to-your-docker-containers/)

Health checks allow a container to expose its workload’s availability. This stands apart from whether the container is running. If your database goes down, your API server won’t be able to handle requests, even though its Docker container is still running.

This makes for unhelpful experiences during troubleshooting. A simple `docker ps` would report the container as available. Adding a health check extends the `docker ps` output to include the container’s true state.

You configure container health checks in your Dockerfile. This accepts a command which the Docker daemon will execute every 30 seconds. Docker uses the command’s exit code to determine your container’s healthiness:

- `0`: The container is healthy and working normally.
- `1`: The container is unhealthy; the workload may not be functioning.

Healthiness isn’t checked straightaway when containers are created. The status will show as starting before the first check runs. This gives the container time to execute any startup tasks. A container with a passing health check will show as healthy; an unhealthy container displays unhealthy.

In docker-compose you can write the healthchecks like the next snippet:

```yaml
---
version: '3.4'

services:
  jellyfin:
    image: linuxserver/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    healthcheck:
      test: curl http://localhost:8096/health || exit 1
      interval: 10s
      retries: 5
      start_period: 5s
      timeout: 10s
```

## [List the dockers of a registry](https://stackoverflow.com/questions/31251356/how-to-get-a-list-of-images-on-docker-registry-v2)


List all repositories (effectively images):

```bash
$: curl -X GET https://myregistry:5000/v2/_catalog
> {"repositories":["redis","ubuntu"]}
```

List all tags for a repository:

```bash
$: curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
> {"name":"ubuntu","tags":["14.04"]}
```

If the registry needs authentication you have to specify username and password in the curl command

```bash
curl -X GET -u <user>:<pass> https://myregistry:5000/v2/_catalog
curl -X GET -u <user>:<pass> https://myregistry:5000/v2/ubuntu/tags/list
```

## Attach a docker to many networks

You can't do it through the `docker run` command, there you can only specify one
network. However, you can attach a docker to a network with the command:

```bash
docker network attach network-name docker-name
```

## [Get the output of `docker ps` as a json](https://stackoverflow.com/questions/61586686/golang-template-to-format-docker-ps-output-as-json)

To get the complete json for reference.

```bash
docker ps -a --format "{{json .}}" | jq -s
```

To get only the required columns in the output with tab separated version

```bash
docker ps -a --format "{{json .}}" | jq -r -c '[.ID, .State, .Names, .Image]'
```

To get [also the image's ID](https://stackoverflow.com/questions/54075456/docker-ps-show-image-id-instead-of-name) you can use:

```bash
docker inspect --format='{{json .}}' $(docker ps -aq) | jq -r -c '[.Id, .Name, .Config.Image, .Image]'
```

## [Connect multiple docker compose files](https://tjtelan.com/blog/how-to-link-multiple-docker-compose-via-network/)

You can connect services defined across multiple docker-compose.yml files.

In order to do this you’ll need to:

* Create an external network with `docker network create <network name>`
* In each of your `docker-compose.yml` configure the default network to use your
    externally created network with the networks top-level key.
* You can use either the service name or container name to connect between containers.

Let's do it with an example:

* Creating the network

    ```bash
    $ docker network create external-example
    2af4d92c2054e9deb86edaea8bb55ecb74f84a62aec7614c9f09fee386f248a6
    ```

* Create the first docker-compose file

    ```yaml
    version: '3'
    services:
      service1:
        image: busybox
        command: sleep infinity

    networks:
      default:
        external:
          name: external-example
    ```

* Bring the service up

    ```bash
    $ docker-compose up -d
    Creating compose1_service1_1 ... done
    ```


* Create the second docker-compose file with network configured

    ```yaml
    version: '3'
    services:
      service2:
        image: busybox
        command: sleep infinity

    networks:
      default:
        external:
          name: external-example
    ```

* Bring the service up

    ```bash
    $ docker-compose up -d
    Creating compose2_service2_1 ... done
    ```

After running `docker-compose up -d` on both docker-compose.yml files, we see
that no new networks were created.

```bash
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
25e0c599d5e5        bridge              bridge              local
2af4d92c2054        external-example    bridge              local
7df4631e9cff        host                host                local
194d4156d7ab        none                null                local
```

With the containers using the external-example network, they are able to ping
one another.

```bash
# By service name
$ docker exec -it compose1_service1_1 ping service2
PING service2 (172.24.0.3): 56 data bytes
64 bytes from 172.24.0.3: seq=0 ttl=64 time=0.054 ms
^C
--- service2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.054/0.054/0.054 ms

# By container name
$ docker exec -it compose1_service1_1 ping compose2_service2_1
PING compose2_service2_1 (172.24.0.2): 56 data bytes
64 bytes from 172.24.0.2: seq=0 ttl=64 time=0.042 ms
^C
--- compose2_service2_1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.042/0.042/0.042 ms
```

The other way around works too.

# Dockerfile creation

## [Remove the apt cache after installing a package](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

```
RUN apt-get update && apt-get install -y \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*
```

## [Add the contents of a directory to the docker](https://stackoverflow.com/questions/37789984/how-to-copy-folders-to-docker-image-from-dockerfile)

```
ADD ./path/to/directory /path/to/destination
```

## [Append a new path to PATH](https://stackoverflow.com/questions/27093612/in-a-dockerfile-how-to-update-path-environment-variable)

```
ENV PATH="${PATH}:/opt/gtk/bin"
```

# Troubleshooting

If you are using a VPN and docker, you're going to have a hard time.

The `docker` systemd service logs `systemctl status docker.service` usually doesn't
give much information. Try to start the daemon directly with `sudo
/usr/bin/dockerd`.

## Syslog getting filled up with docker network recreation

If you find yourself with your syslog getting filled up by lines similar to:

```
 Jan 15 13:19:19 home kernel: [174716.097109] eth2: renamed from veth0adb07e
 Jan 15 13:19:20 home kernel: [174716.145281] IPv6: ADDRCONF(NETDEV_CHANGE): vethcd477bc: link becomes ready
 Jan 15 13:19:20 home kernel: [174716.145337] br-1ccd0f48be7c: port 5(vethcd477bc) entered blocking state
 Jan 15 13:19:20 home kernel: [174716.145338] br-1ccd0f48be7c: port 5(vethcd477bc) entered forwarding state
 Jan 15 13:19:20 home kernel: [174717.081132] br-fbe765bc7d0a: port 2(veth31cdd6f) entered disabled state
 Jan 15 13:19:20 home kernel: [174717.081176] vethc4da041: renamed from eth0
 Jan 15 13:19:21 home kernel: [174717.214911] br-fbe765bc7d0a: port 2(veth31cdd6f) entered disabled state
 Jan 15 13:19:21 home kernel: [174717.215917] device veth31cdd6f left promiscuous mode
 Jan 15 13:19:21 home kernel: [174717.215919] br-fbe765bc7d0a: port 2(veth31cdd6f) entered disabled state
```

It probably means that some docker is getting recreated continuously. Those traces are normal logs of docker creating the networks, but as they do each time the docker starts, if it's restarting continuously then you have a problem.

## Don't store credentials in plaintext

!!! warning "It doesn't work, don't go this painful road and assume that docker is broken."

    The official steps are horrible, and once you've spent two hours debugging
    it, you [won't be able to push or pull images with your
    user](https://github.com/docker/docker-credential-helpers/issues/154).

When you use `docker login` and introduce the user and password you get
the next warning:

```
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
```

I got a nice surprise when I saw that `pass` was suggested in the link of the
warning, to be used as a backend to store the password. But that feeling soon
faded.

To make docker understand that you want to use `pass` you need to use the
[`docker-credential-pass`](https://github.com/docker/docker-credential-helpers/releases)
script. A Go script "maintained" by docker, whose last commit was two years ago
, has the CI broken and many old unanswered issues. Setting it up it's not easy
either and it's [ill
documented](https://github.com/docker/docker-credential-helpers/issues/102).

Furthermore, the script doesn't do what I expected, which is to store the
password of your registry user in a pass entry. Instead, you need to create an
empty pass entry in `docker-credential-helpers/docker-pass-initialized-check`,
and when you use `docker login`, manually introducing your data, it creates
another entry, as you can see in the next `pass` output:

```
Password Store
└── docker-credential-helpers
    ├── aHR0cHM6Ly9pbmRleC5kb2NrZXIuaW8vdjEv
    │   └── lyz
    └── docker-pass-initialized-check
```

That entry is removed when you use `docker logout` so the next time you log in
you need to introduce the user and password `(╯°□°)╯ ┻━┻`.

### Installing docker-credential-pass

You first need to install the script:

```bash
# Check for later releases at https://github.com/docker/docker-credential-helpers/releases
version="v0.6.3"
archive="docker-credential-pass-$version-amd64.tar.gz"
url="https://github.com/docker/docker-credential-helpers/releases/download/$version/$archive"

# Download cred helper, unpack, make executable, and move it where Docker will find it.
wget $url \
    && tar -xf $archive \
    && chmod +x docker-credential-pass \
    && mv -f docker-credential-pass /usr/local/bin/
```

Another tricky issue is that even if you use a non-root user who's part of the
`docker` group, the script is not aware of that, so it will *look in the
password store of root* instead of the user's. This means that additionally to
your own, you need to create a new password store for root. Follow the next
steps with the root user:

* Create the password with `gpg --full-gen`, and copy the key id. Use a non
    empty password, otherwise you are getting the same security as with the
    password in cleartext.
* Initialize the password store `pass init gpg_id`, changing `gpg_id` for the
    one of the last step.
* Create the *empty* `docker-credential-helpers/docker-pass-initialized-check`
    entry:

    ```bash
    pass insert docker-credential-helpers/docker-pass-initialized-check
    ```

    And press enter twice.

Finally we need to specify in the root's docker configuration that we want to
use the `pass` credential storage.

!!! note "File: /root/.docker/config.json"

    ```json
    {
        "credsStore": "pass"
    }
    ```

### Testing it works

To test that docker is able to use pass as backend to store the credentials,
run `docker login` and introduce the user and password. You should see the
`Login Succeeded` message without any warning.

```
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: lyz
Password:
Login Succeeded
```

Awful experience, wasn't it? Don't worry it gets worse.

Now that you're logged in, whenever you try to push an image you're probably
going to get an `denied: requested access to the resource is denied` error.
That's because docker is not able to use the password it has stored in the
root's password store. If you're using `root` to push the image (bad idea
anyway), you will need to `export GPG_TTY=$(tty)` so that docker can ask you for
your password to unlock root's `pass` entry. If you're like me that uses
a non-root user belonging to the `docker` group, not even that works, so you've
spent all this time reading and trying to fix everything for nothing... Thank
you Docker `-.-`.

## [Start request repeated too quickly](https://askubuntu.com/questions/1222440/why-wont-the-docker-service-start)

Shutdown the VPN and it will work. If it doesn't inspect the output of
`journalctl -eu docker`.

## [Disable ipv6](https://stackoverflow.com/questions/30750271/disable-ip-v6-in-docker-container)

```bash
sysctl net.ipv6.conf.all.disable_ipv6=1
sysctl net.ipv6.conf.default.disable_ipv6=1
```
