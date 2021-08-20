---
title: Syncthing
date: 20200404
author: Lyz
---

[Syncthing](https://syncthing.net/) is a continuous file synchronization
program. It synchronizes files between two or more computers in real time,
safely protected from prying eyes. Your data is your data alone and you deserve
to choose where it is stored, whether it is shared with some third party, and
how it's transmitted over the internet.

# [Installation](https://syncthing.net/downloads/)

## Debian or Ubuntu

```bash
# Add the release PGP keys:
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

# Add the "stable" channel to your APT sources:
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Update and install syncthing:
sudo apt-get update
sudo apt-get install syncthing
```

## Docker

Use [Linuxserver Docker](https://docs.linuxserver.io/images/docker-syncthing)

## Configuration

If you're only going to use syncthing in an internal network, or you're going to
fix the IPs of the devices you can disable the [Global
Discovery](https://docs.syncthing.net/users/security.html#global-discovery) and
[Relaying
connections](https://docs.syncthing.net/users/security.html#relay-connections)
so that you don't leak the existence of your services to the syncthing servers.

# Troubleshooting

## Syncthing over Tor

There are many posts on this topic
([1](https://forum.syncthing.net/t/feature-tor-support/2748/20), [2](https://github.com/syncthing/syncthing/issues/4174))
but I wasn't able to connect two clients through Tor. Here are the steps I took
in case anyone is interested. If you make it work, please [contact](contact.md)
me.

Suggest to use
a [relay](https://docs.syncthing.net/users/relaying.html#relaying), go to
[relays.syncthing.net](https://relays.syncthing.net/) to see the public ones.
You need to add the required servers to the `Sync Protocol Listen Address`
field, under `Actions` and `Settings`. The syntax is:

```
relay://<host name|IP>[:port]/?id=<relay device ID>
```

The only way I've found to get the `relay device ID` is setting a fake one, and
getting the correct one from the logs of syncthing. It will say that `the
fingerprint ( what you put ) doesn't match ( actual fingerprint )`.


### Steps

* Configure the client:

    ```bash
    export all_proxy=socks5://127.0.0.1:9058
    export ALL_PROXY_NO_FALLBACK=1
    syncthing --home /tmp/syncthing_1
    ```

* Allow the connection to the local server:

    ```bash
    sudo iptables -I OUTPUT -o lo -p tcp --dport 8384 -j ACCEPT
    ```

* If you're using Tails and Tor Browser, you'll need to set the `about:config`
    setting `network.proxy.allow_hijacking_localhost` to `false`. Otherwise you
    won't be able to access the user interface.

# Issues

* [Wifi run condition needs location to be turned
    on](https://github.com/syncthing/syncthing-android/issues/1129): update and
    check that you no longer need it.

# Links

* [Home](https://syncthing.net/)
* [Getting Started](https://docs.syncthing.net/intro/getting-started.html)
