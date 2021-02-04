---
title: Wish list
date: 20200206
author: Lyz
---

This is a gathering of tools, ideas or services that I'd like to enjoy.

If you have any lead, as smallest as it may be on how to fulfill them, please
[contact me](contact.md).

# Self hosted search engine

It would be awesome to be able to self host a personal search engine that
performs priorized queries in the data sources that I choose.

This idea comes from me getting tired of:

* Forgetting to search in my gathered knowledge before going to the internet.
* Not being able to priorize known trusted sources.

Some sources I'd like to query:

* Markdown brains, like my blue and red books.
* Awesome lists.
* My browsing history.
* Blogs.
* [learn-anything](https://learn-anything.xyz).
* [Musicbrainz](https://musicbrainz.org).
* [themoviedb](https://themoviedb.org).
* [Wikipedia](https://wikipedia.com)
* [Reddit](https://reddit.com).
* [Stackoverflow](https://stackoverflow.com).
* [Startpage](https://startpage.com).

Each source should be added as a plugin to let people develop their own.

I'd also like to be able to rate in my browsing the web pages so they get more
relevance in future searches. That rating can also influence the order of the
different sources.

It will archive the rated websites to avoid [link
rot](https://www.gwern.net/Archiving-URLs#link-rot).

If we use a knowledge graph, we could federate to ask other nodes and help
discover or priorize content.

The browsing could be related with knowledge graph tags.

We can also have integration with Anki after a search is done.

A possible architecture could be:

* A flask + Reactjs frontend.
* An elasticsearch instance for persistence.
* A Neo4j or knowledge graph to get relations.

It must be open sourced and Linux compatible. And it would be awesome if
I didn't have to learn how to use another editor.

Maybe [meilisearch](https://github.com/meilisearch/meilisearch) or
[searx](https://github.com/asciimoo/searx) could be a solution.

# Decentralized encrypted end to end VOIP and video software

I'd like to be able to make phone and video calls keeping in mind that:

* Every connection must be encrypted end to end.
* I trust the security of a linux server more than a user device. This rules out
  distributed solutions such as [tox](https://tox.chat/) that exposes the client
  IP in a DHT table.
* The server solution should be self hosted.
* It must use tested cryptography, which again rolls out tox.

These are the candidates I've found:

* [Riot](https://about.riot.im/). You'll need to host your own [Synapse
  server](https://github.com/matrix-org/synapse).
* [Jami](https://jami.net). I think it can be configured as decentralized if you
  host your own DHTproxy, bootstrap and nameserver, but I need to delve further
  into [how it makes
  a call](https://git.jami.net/savoirfairelinux/ring-project/wikis/technical/2.4.%20Let's%20do%20a%20call).
  I'm not sure, but you'll probably need to use [push
  notifications](https://git.jami.net/savoirfairelinux/ring-project/wikis/tutorials/Frequently-Asked-Questions#advanced-3)
  so as not to expose a service from the user device.
* [Linphone](https://www.linphone.org). If we host our
  [Flexisip](https://www.linphone.org/flexisip-server) server, although it asks
  for a lot of permissions.

[Jitsi Meet](https://jitsi.org/jitsi-meet/) it's not an option as it's not [end
to end encrypted](https://github.com/jitsi/jitsi-meet/issues/409). But if you
want to use it, please use [Disroot service](https://call.disroot.org) or host
your own.

# Self hosted voice assistant

Host a [virtual assistant](virtual_assistant.md) in my servers to help me
automate repetitive stuff.

# Others

* Movie/serie/music rating self hosted solution that based on your ratings
  discovers new content.
* Hiking route classifier and rating self hosted web application.
* A command line friendly personal CRM like
    [Monica](https://github.com/monicahq/monica) that is able to [register the
    time length and rating of
    interactions](https://github.com/monicahq/monica/issues/4186) to do data
    analysis on my relations.
* Digital e-ink note taking system that is affordable, self hosted and performs
  character recognition.
* A way to store music numeric ratings through the command line compatible with
  [mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon) and
  [beets](http://beets.readthedocs.io/).
* A mkdocs plugin to generate RSS feed on new or changed entries.
* An e-reader support that could be fixed to the wall.
