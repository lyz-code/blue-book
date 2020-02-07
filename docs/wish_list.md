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
* [Startpage](https://startpage)

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

# Others

* Movie/serie/music rating self hosted solution that based on your ratings
  discovers new content.
* Digital e-ink note taking system that is affordable, self hosted and performs
  character recognition.
* A way to store music numeric ratings through the command line compatible with
  [mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon) and
  [beets](http://beets.readthedocs.io/).
