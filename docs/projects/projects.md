---
title: Projects
date: 20210206
author: Lyz
---

There is an ever growing pool of ideas where I want to invest my time. Sadly
time is a finite currency, and even though I am lucky enough to be able to put
my focus on maximizing it, it's never enough.

I understand projects as a mental tool that groups ideas, processes and tools to
achieve a specific goal. Following the [digital garden](digital_garden.md)
metaphor, projects are plants in different phases of development where I've
spent a different amount of effort.

The development phases are:

* [*Seeds*](#seeds): Are raw, basic ideas of projects that may once be.
* *Seedlings*: Are projects that don't yet have their first stable version, but
    the drafts of the [ADR](adr.md) and some code is already written.
* [*Growing*](#growing-plants): Projects that have a stable release and are
    under active development.
* [*Dormant*](#dormant-plants): Projects whose growth has temporally stopped.
    I still believe they are useful and even though I don't want to work on them
    at the moment, I see myself doing it in the future.

    I still maintain them by answering to issues, reviewing pull requests,
    keeping the continuous integration pipelines alive and developing fixes to
    important issues.
* [*Dying*](#dying-plants): Projects that I know are going to be deprecated
    soon, and I'm looking for alternatives.
* *Dead*: Project no longer used.

# Growing plants

## [Blue book](https://lyz-code.github.io/blue-book/)

What you're reading right now. I'm storing most of the new knowledge I learn
every day. At the same time I'm migrating the notes of the previous
version of this digital garden which consists on 7422 articles, almost 50
million lines.

## [Repository pattern](https://github.com/lyz-code/repository-pattern)

I'm creating a [Python library](https://github.com/lyz-code/repository-pattern)
to make it easier to use the [repository pattern](repository_pattern.md) in new
projects.

I monthly spin up new ideas for programs, and managing the storage of the
information is cumbersome and repeating. My idea is to refactor that common
codebase into a generic library that anyone can use.

## [Pydo](https://lyz-code.github.io/pydo)

I've been using [Taskwarrior](https://taskwarrior.org) for the last five or six
years. It's an awesome program to do task management and it is really
customizable. So throughout these years I've done several scripts to integrate
it into my workflow:

* [Taskban](https://github.com/lyz-code/taskban): To do [Sprint
  Reviews](https://en.wikipedia.org/wiki/Scrum_%28software_development%29#Sprint_review)
  and do data analysis on the difference between the estimation and the actual
  time for doing tasks. To do so, I had to rewrite how
  [tasklib](https://github.com/lyz-code/taskli://github.com/lyz-code/tasklib)
  stores task time information.
* [Taskwarrior_recurrence](https://git.digitales.cslabrecha.org/lyz/taskwarrior_recurrence):
  A group of hooks to fix [Taskwarrior's recurrence
  issues](https://taskwarrior.org/docs/design/recurrence.html).
* [Taskwarrior_validation](https://git.digitales.cslabrecha.org/lyz/taskwarrior_validation):
  A hook to help in the definition of validation criteria for tasks.

Nevertheless, I'm searching for an alternative because:

* As the database grows, `taskban` becomes unusable.
* Taskwarrior lacks several features I want.
* It's written in C, which I don't speak.
* It's development has come to [code maintenance
  only](https://github.com/GothenburgBitFactory/taskwarrior/graphs/code-frequency).
* It uses a plaintext file as data storage.

[tasklite](https://tasklite.org) is a promising project that tackles most of the
points above. But is written in
[Haskel](https://en.wikipedia.org/wiki/Haskell_%28programming_language%29) which
I don't know and I don't want to learn.

So taking my experience with taskwarrior and looking at tasklite, I've started
building [pydo](https://lyz-code.github.io/pydo).

I'm now doing a full rewrite of the codebase following the [repository
pattern](repository_pattern.md) which led me to create a [Python
library](#repository-pattern).

# Dormant Plants

## [mkdocs-newsletter](https://github.com/lyz-code/mkdocs-newsletter)

MkDocs plugin to show the changes of documentation repositories in a user
friendly format, at the same time that it's easy for the authors to maintain.

It creates daily, weekly, monthly and yearly newsletter articles with the
changes of each period. Those pages, stored under the `Newsletters` section, are
filled with the changes extracted from the commit messages of the git history.
The changes are grouped by categories, subcategories and then by file using the
order of the site's navigation structure. RSS feeds are also created for each
newsletter type, so it's easy for people to keep updated with the evolution of
the site.

I use it for this site
[newsletters](https://lyz-code.github.io/blue-book/newsletter/0_newsletter_index/).

## [Autoimport](https://lyz-code.github.io/autoimport/)

Throughout the development of a python program you continuously need to manage
the python import statements either because you need one new object or because
you no longer need it. This means that you need to stop writing whatever you
were writing, go to the top of the file, create or remove the import statement
and then resume coding.

This workflow break is annoying and almost always unnecessary.
[autoimport](https://lyz-code.github.io/autoimport/) solves this problem if you
execute it whenever you have an import error, for example by configuring your
editor to run it when saving the file.

The reasons why it is dormant are:

* The current features cover most of needs. Even though I'd like to be able to
    [import broken package
    objects](https://github.com/lyz-code/autoimport/issues/74), and that it is
    intelligent enough to use [relative
    imports](https://github.com/lyz-code/autoimport/issues/75).
* My hype is elsewhere.

## [yamlfix](https://lyz-code.github.io/yamlfix)

A simple opinionated yaml formatter that keeps your comments.

The reasons why it is dormant are:

* The current features cover most of needs.
* My hype is elsewhere.

## [Cookiecutter Python template](https://lyz-code.github.io/cookiecutter-python-project/)

Following the same reasoning as the previous section, I've spent a lot of time
investigating quality measures for python projects, such as project structure, ci
testing, ci building, dependency management, beautiful docs or pre-commits. With
the [cookiecutter
template](https://github.com/lyz-code/cookiecutter-python-project), it is easy
to create a new project with the best quality measures with zero effort.
Furthermore, with [cruft](cruft.md) I can keep all the projects generated with
the template updated with the best practices.

## [Clinv](https://github.com/lyz-code/clinv)

As part of my [DevSecOps](https://dzone.com/articles/shifting-left-devsecops)
work, I need to have an updated inventory of cloud assets organized under a risk
management framework.

As you can see in [how do you document your
infrastructure?](https://www.reddit.com/r/aws/comments/dxmkci/how_do_you_document_your_infrastructure/),
there is still a void on how to maintain an inventory of dynamic resources with
a DevSecOps point of view.

* Manage a dynamic inventory of risk management resources (Projects, Services,
  Information, People) and infrastructure resources (EC2, RDS, S3, Route53, IAM
  users, IAM groups…).
* Add risk management metadata to your AWS resources.
* Monitor if there are resources that are not inside your inventory.
* Perform regular expression searches on all your resources.
* Get all your resources information.
* Works from the command line.

So I started building [clinv](https://github.com/lyz-code/clinv).

The reasons why it is dormant are:

* Since I started building it I've learnt about [domain driven
    design](domain_driven_design.md), [type hints](type_hints.md),
    [documentation](docstrings.md) and avoiding mocking as much as possible.
    This project not being compliant with those concepts makes me want to fix it
    before I develop any further feature.
* The current state of the program covers my current needs of managing the
    inventory of the infrastructure I maintain.

## Mediarss

I've always wanted to own the music I listen, because I don't want to give my
data to the companies host the streaming services, nor I trust that they'll
keep on giving the service.

So I started building some small bash scrappers (I wasn't yet introduced to
[Python](https://en.wikipedia.org/wiki/Python_%28programming_language%29)) to
get the media. That's when I learned to hate the web developers for their
constant changes and to love the API.

Then I discovered [youtube-dl](https://github.com/ytdl-org/youtube-dl), a Python
command-line program to download video or music from streaming sites. But
I still laked the ability to stay updated with the artist channels.

So mediarss was born. A youtube-dl wrapper to periodically download new
content.

This way, instead of using Youtube, Soundcloud or Bandcamp subscriptions, I've got
a [YAML](https://en.wikipedia.org/wiki/YAML) with all the links that I want to
monitor.

## Playlist_generator

When my music library started growing due to [mediarss](#mediarss), I wanted
to generate playlists filtering my content by:

* Rating score fetched with [mep](#mep).
* First time/last listened.
* Never listened songs.

The playlists I usually generate with these filters are:

* Random unheard songs.
* Songs discovered last month/year with a rating score greater than X.
* Songs that I haven't heard since 20XX  with a rating score greater than
  X (this one gave me pleasant surprises ^^).

## Media indexation

I've got a music collection of more than 136362 songs, belonging to
[mediarss](#mediarss) downloads, bought CDs rips and friend library sharing. It
is more less organized in a directory tree by genre, but I lack any library
management features. I've got a lot of duplicates, incoherent naming scheme, no
way of filtering or intelligent playlist generation.

[playlist_generator](#playlist_generator) helped me with the last point, based
on the metadata gathered with [mep](#mep), but it's still not enough.

So I'm in my way of migrate all the library to
[beets](http://beets.readthedocs.io/), and then I'll deprecate [mep](#mep) in
favor to a [mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon) client that
allows me to keep on saving the same metadata.

Once it's implemented, I'll migrate all the metadata to the new system.

## Home Stock inventory

I try to follow the idea of emptying my mind as much as possible, so I'm able to
spend my CPU time wisely.

Keeping track of what do you have at home or what needs to be bought is an
effort that should be avoided.

So I've integrated [Grocy](https://grocy.info/) in my life.

## [Drode](https://github.com/lyz-code/drode)

[drode](https://github.com/lyz-code/drode) is a wrapper over the Drone and AWS
APIs to make deployments more user friendly.

It assumes that the projects are configured to continuous deliver all master
commits to staging. Then those commits can be promoted to production or to
staging for upgrades and rollbacks.

It has the following features:

* Prevent failed jobs to be promoted to production.
* Promote jobs with less arguments than the drone command line.
* Wait for a drone build to end, then raise the terminal bell.

# Dying plants

## mep

I started  [life logging](https://en.wikipedia.org/wiki/Lifelog) with `mep`. One
of the first programs I wrote when learning
[Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29).

It is a [mplayer](https://en.wikipedia.org/wiki/MPlayer) wrapper that allows me
to control it with [i3](https://en.wikipedia.org/wiki/I3_%28window_manager%29)
key bindings and store metadata of the music I listen.

I don't even publish it because it's a horrible program that would make your
eyes bleed. 600 lines of code, only 3 functions, 6 levels of nested ifs, no
tests at all, but hey, the functions have docstrings! `(ｏ・_・)ノ”(ᴗ_ ᴗ。)`

The thing is that it works, so I everyday close my eyes and open my ears,
waiting for a solution that gives me the same features with
[mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon).

# Seeds

This is a gathering of tools, ideas or services that I'd like to enjoy.

If you have any lead, as smallest as it may be on how to fulfill them, please
[contact me](contact.md).

## Self hosted search engine

It would be awesome to be able to self host a personal search engine that
performs prioritized queries in the data sources that I choose.

This idea comes from me getting tired of:

* Forgetting to search in my gathered knowledge before going to the internet.
* Not being able to prioritize known trusted sources.

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
discover or prioritize content.

The browsing could be related with knowledge graph tags.

We can also have integration with Anki after a search is done.

A possible architecture could be:

* A flask + Reactjs frontend.
* An elasticsearch instance for persistence.
* A Neo4j or knowledge graph to get relations.

It must be open sourced and Linux compatible. And it would be awesome if
I didn't have to learn how to use another editor.

Maybe [meilisearch](https://github.com/meilisearch/meilisearch) or
[searx](https://github.com/asciimoo/searx) could be a solution. Following
another approach, [archivy](https://archivy.github.io/) looks good too.

## Decentralized encrypted end to end VOIP and video software

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

## Self hosted voice assistant

Host a [virtual assistant](virtual_assistant.md) in my servers to help me
automate repetitive stuff.

## Others

* A tool or service to follow the updates of software, right now I subscribe to
    the releases of the github repositories, but I'd like it to be provider
    agnostic, and cleaner than the emails github sends.
* A tool or service to automatically update the dockers of my services in an
    intelligent way, for example telling it to be one minor versions after the
    last to avoid instabilities.
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
* A git issue tracker that keeps the context of why I subscribed to them. Until
    I find one, I'll use the [issues](issues.md#vim-workflow-improvements) document.
* An easy way of creating markdown links to other file's sections. Similar to
    [mkdx](https://github.com/SidOfc/mkdx#insert-mode-fragment-completion)
    functionality. I tried using it but it didn't work for me, and I don't know
    if it works for other files.
* A markdown formatter that fixes the indentation of lists.
* An e-reader support that could be fixed to the wall.
