---
title: Anki
date: 20220513
author: Lyz
---

[Anki](https://apps.ankiweb.net/) is a program which makes remembering things
easy through [spaced repetition](spaced_repetition.md). Because it's a lot more efficient than traditional study methods, you can
either greatly decrease your time spent studying, or greatly increase the amount
you learn.

Anyone who needs to remember things in their daily life can benefit from Anki.
Since it is content-agnostic and supports images, audio, videos and scientific
markup (via LaTeX), the possibilities are endless.

# [Installation](https://docs.ankiweb.net/platform/linux/installing.html)

Install the dependencies:

```bash
sudo apt-get install zstd
```

Download [the latest release package](https://apps.ankiweb.net/).

Open a terminal and run the following commands, replacing the filename as appropriate:

```bash
tar xaf Downloads/anki-2.1.XX-linux-qt6.tar.zst
cd anki-2.1.XX-linux-qt6
sudo ./install.sh
```

# Anki workflow 

## How long to do study sessions

I have two study modes:

* When I'm up to date with my cards, I study them until I finish, but usually less than 15 minutes.
* If I have been lazy and haven't checked them in a while (like now) I assume I'm not going to see them all and define a limited amount of time to review them, say 10 to 20 minutes depending on the time/energy I have at the moment. 

The relief thought you can have is that as long as you keep a steady pace of 10/20 mins each day, inevitably you'll eventually finish your pending cards as you're more effective reviewing cards than entering new ones

## What to do with "hard" cards

If you're afraid to be stuck in a loop of reviewing "hard" cards, don't be. In reality after you've seen that "hard" card three times in a row you won't mark it as hard again, because you will remember. If you don't maybe there are two reasons:

* The card has too much information that should be subdivided in smaller cards.
* You're not doing a good process of memorizing the contents once they show up.

## [What to do with unneeded cards](https://www.reddit.com/r/medicalschoolanki/comments/9dwjia/difference_between_suspend_and_bury_card/)

You have three options: 

- Suspend: It stops it from showing up permanently until you reactivate it through the browser.
- Bury: Just delays it until the next day.
- Delete: It deletes it forever.

Unless you're certain that you are not longer going to need it, suspend it.

## What to do when you need to edit a card but don't have the time

You can mark it with a red flag so that you remember to edit it the next time you see it.

# Interacting with python

## Configuration

Although there are some python libraries:

* [genanki](https://github.com/kerrickstaley/genanki)
* [py-anki](https://pypi.org/project/py-anki/)

I think the best way is to use [AnkiConnect](https://foosoft.net/projects/anki-connect/)

The installation process is similar to other Anki plugins and can be accomplished in three steps:

* Open the *Install Add-on* dialog by selecting *Tools | Add-ons | Get
    Add-ons...* in Anki.
* Input `2055492159` into the text box labeled *Code* and press the *OK* button to
    proceed.
* Restart Anki when prompted to do so in order to complete the installation of
    Anki-Connect.

Anki must be kept running in the background in order for other applications to
be able to use Anki-Connect. You can verify that Anki-Connect is running at any
time by accessing `localhost:8765` in your browser. If the server is running, you
will see the message Anki-Connect displayed in your browser window.

## Usage

Every request consists of a JSON-encoded object containing an `action`,
a `version`, contextual `params`, and a `key` value used for authentication (which is optional
and can be omitted by default). Anki-Connect will respond with an object
containing two fields: `result` and `error`. The `result` field contains the return
value of the executed API, and the `error` field is a description of any exception
thrown during API execution (the value `null` is used if execution completed
successfully).

Sample successful response:

```json
{"result": ["Default", "Filtered Deck 1"], "error": null}
```

Samples of failed responses:

```json
{"result": null, "error": "unsupported action"}

{"result": null, "error": "guiBrowse() got an unexpected keyword argument 'foobar'"}
```

For compatibility with clients designed to work with older versions of
Anki-Connect, failing to provide a version field in the request will make the
version default to 4.

To make the interaction with the API easier, I'm using the next adapter:

```python
class Anki:
    """Define the Anki adapter."""

    def __init__(self, url: str = "http://localhost:8765") -> None:
        """Initialize the adapter."""
        self.url = url

    def requests(
        self, action: str, params: Optional[Dict[str, str]] = None
    ) -> Response:
        """Do a request to the server."""
        if params is None:
            params = {}

        response = requests.post(
            self.url, json={"action": action, "params": params, "version": 6}
        ).json()
        if len(response) != 2:
            raise Exception("response has an unexpected number of fields")
        if "error" not in response:
            raise Exception("response is missing required error field")
        if "result" not in response:
            raise Exception("response is missing required result field")
        if response["error"] is not None:
            raise Exception(response["error"])
        return response["result"]
```

You can find the full adapter in the [fala](https://github.com/lyz-code/fala)
project.

### Decks

#### Get all decks

With the adapter:

```python
self.requests("deckNames")
```

Or with `curl`:

```bash
curl localhost:8765 -X POST -d '{"action": "deckNames", "version": 6}'
```

#### Create a new deck

```python
self.requests("createDeck", {"deck": deck})
```

# Configure self hosted synchronization

NOTE: In the end I dropped this path and used Ankidroid alone with syncthing as I didn't need to interact with the decks from the computer. Also the ecosystem of synchronization in Anki at 2023-11-10 is confusing as there are many servers available, not all are compatible with the clients and Anki itself has released it's own so some of the community ones will eventually die.

## [Install the server](https://github.com/ankicommunity/anki-devops-services#about-this-docker-image)

I'm going to install `anki-sync-server` as it's simpler to [`djankiserv`](https://github.com/ankicommunity/anki-api-server):

* Create the data directories: 
  ```bash
  mkdir -p /data/apps/anki/data
  ```

* Copy the `docker/docker-compose.yaml` to `/data/apps/anki`.
  ```yaml
  ---
  version: "3"

  services:
    anki:
      image: kuklinistvan/anki-sync-server:latest
      container_name: anki
      restart: always
      networks:
        - nginx
      volumes:
        - data:/app/data

  networks:
    nginx:
      external:
        name: nginx

  volumes:
    data:
      driver: local
      driver_opts:
        type: none
        o: bind
        device: /data/apps/anki
  ```
* Copy the nginx config into your `site-confs`:

  ```
  # make sure that your dns has a cname set for anki and that your anki container is not using a base url

  server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name anki.*;

    include /config/nginx/ssl.conf;

    client_max_body_size 0;

    # enable for ldap auth, fill in ldap details in ldap.conf
    #include /config/nginx/ldap.conf;

    location / {
        # enable the next two lines for http auth
        #auth_basic "Restricted";
        #auth_basic_user_file /config/nginx/.htpasswd;

        # enable the next two lines for ldap auth
        #auth_request /auth;
        #error_page 401 =200 /login;

        include /config/nginx/proxy.conf;
        resolver 127.0.0.11 valid=30s;
        set $upstream_anki anki;
        proxy_pass http://$upstream_anki:27701;
    }
  }
  ```

* Copy the `service/anki.service` into `/etc/systemd/system/`
  ```ini
  [Unit]
  Description=anki
  Requires=docker.service
  After=docker.service
  
  [Service]
  Restart=always
  User=root
  Group=docker
  WorkingDirectory=/data/apps/anki
  # Shutdown container (if running) when unit is started
  TimeoutStartSec=100
  RestartSec=2s
  # Start container when unit is started
  ExecStart=/usr/local/bin/docker-compose -f docker-compose.yaml up
  # Stop container when unit is stopped
  ExecStop=/usr/local/bin/docker-compose -f docker-compose.yaml down

  [Install]
  WantedBy=multi-user.target
  ```
* Start the service `systemctl start anki`
* If needed enable the service `systemctl enable anki`.
* Create your user by:
  * Getting a shell inside the container:
    ```bash
    docker exec -it anki sh
    ```
  * Create the user:
    ```bash
    ./ankisyncctl.py adduser kuklinistvan
    ```

`ankisyncctl.py` has more commands to manage your users:

* `adduser <username>`: add a new user
* `deluser <username>`: delete a user
* `lsuser`: list users
* `passwd <username>`: change password of a user

## [Configure AnkiDroid](https://github.com/ankicommunity/anki-sync-server#ankidroid)

* Add the dns you configured in your nginx reverse proxy into Advanced → Custom sync server.
* Then enter the credentials you created before in Advanced -> AnkiWeb account

## [Configure Anki](https://github.com/ankicommunity/anki-sync-server#setting-up-anki)

Install addon from ankiweb (support 2.1)

- On add-on window,click Get Add-ons and fill in the textbox with the code 358444159
- There,you get add-on custom sync server redirector,choose it.Then click config below right
- Apply your server dns address
- Press Sync in the main application page and enter your credentials

# References

* [Homepage](https://apps.ankiweb.net/)
* [Anki-Connect reference](https://foosoft.net/projects/anki-connect/)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
