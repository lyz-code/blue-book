---
title: Anki
date: 20220513
author: Lyz
---

[Anki](https://apps.ankiweb.net/) is a program which makes remembering things
easy. Because it's a lot more efficient than traditional study methods, you can
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

# References

* [Homepage](https://apps.ankiweb.net/)
* [Anki-Connect reference](https://foosoft.net/projects/anki-connect/)
