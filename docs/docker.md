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

# How to keep containers updated

[Diun](https://github.com/crazy-max/diun) is a CLI application written in Go and
delivered as a single executable (and a Docker image) to receive notifications
when a Docker image is updated on a Docker registry.

They don't [yet support Prometheus
metrics](https://github.com/crazy-max/diun/issues/201) but it surely looks
promising.

## [Logging in
automatically](https://docs.docker.com/engine/reference/commandline/login/#provide-a-password-using-stdin)

To log in automatically without entering the password, you need to have the
password stored in your *personal password store* (not in root's!), imagine it's
in the `dockerhub` entry. Then you can use:

```bash
pass show dockerhub | docker login --username foo --password-stdin
```

# Troubleshooting

If you are using a VPN and docker, you're going to have a hard time.

The `docker` systemd service logs `systemctl status docker.service` usually doesn't
give much information. Try to start the daemon directly with `sudo
/usr/bin/dockerd`.

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

Shutdown the VPN and it will work.
