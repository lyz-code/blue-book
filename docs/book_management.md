---
title: Book Management
date: 20211014
author: Lyz
---

Book management is the set of systems and processes to get and categorize books
so it's easy to browse and discover new content. It involves the next actions:

* Automatically index and download metadata of new books.
* Notify the user when a new book is added.
* Monitor the books of an author, and get them once they are released.
* Send books to the e-reader.
* A nice interface to browse the existent library, with the possibility of
    filtering by author, genre, years, tags or series.
* An interface to preview or read the items.
* An interface to rate and review library items.
* An interface to discover new content based on the ratings and item metadata.

I haven't yet found a single piece of software that fulfills all these needs, so
we need to split it into subsystems.

* Downloader and indexer.
* Gallery browser.
* Review system.
* Content discovery.

# Downloader and indexer

System that monitors the availability of books in a list of indexers, when they
are available, they download it to a directory of the server. The best one that
I've found is [Readarr](https://readarr.com/), it makes it easy to search for
authors and books, supports a huge variety of indexers (such as Archive.org),
and download clients (such as torrent clients).

It can be used as a limited gallery browser, you can easily see the books of
an author or series, but it doesn't yet support the automatic fetch of
[genres](https://github.com/Readarr/Readarr/issues/375) or tags.

I haven't found an easy way of marking elements as read, prioritize the list
of books to read, or add a user rating. Until these features are added (if they
ever are), we need to use it in parallel with a better gallery browser.

# Gallery browser

System that shows the books in the library in a nice format, allowing the user
to filter out the contents, prioritize them, mark them as read, rate them and
optionally sync books with the ereader.

[Calibre-web](https://github.com/janeczku/calibre-web) is a beautiful solution,
without trying it, it looks like it supports all of the required features,
but it doesn't work well with Readarr. Readarr has support to interact with
Calibre content server by defining a [root folder to be managed by
Calibre](https://wiki.servarr.com/en/readarr/quick-start-guide),
but the books you want to have Readarr recognize on initial library import must
already be in Calibre. Books within the folder and not in Calibre will be
ignored. So you'll need to do the first import in Calibre, instead of Readarr
(which is quite pleasant). Note also that you cannot add Calibre integration to
a root folder after it's created.

Calibre-web interacts directly with the Sqlite database of Calibre, so it
doesn't expose the Calibre Content Server, therefore is not compatible with
Readarr.

To make it work, you'd need to have both the `calibre` server and the
`calibre-web`
running at the same time, which has led to database
locks ([1](https://github.com/linuxserver/docker-calibre-web/issues/133), and
[2](https://github.com/janeczku/calibre-web/issues/1982)) that the `calibre-web`
developer has tried to avoid by [controlling the database
writes](https://github.com/janeczku/calibre-web/issues/1982), and [said
that](https://github.com/janeczku/calibre-web/issues/1841):

> If you start Calibre first and afterwards Calibre-Web, Calibre indeed locks
> the database and doesn't allow Calibre-Web to access the database (metadata.db)
> file. Starting Calibre-Web and afterwards Calibre should work.

The problem comes when Readarr writes in the database through calibre to add
books, and calibre-web tries to write too to add user ratings or other metadata.

Another option would be to only run calibre-web and automatically import the
books once they are downloaded by Readarr. calibre-web is [not
going](https://github.com/janeczku/calibre-web/issues/344) to support a watch
directory feature, the author recommends to [use a cron
script](https://github.com/janeczku/calibre-web/issues/412) to do it. I haven't
tried this path yet.

Another option would be to assume that calibre-web is not going to do any insert
in the database, so it would become a read-only web interface, therefore we
wouldn't be able to edit the books or rate them, one of the features we'd like
to have in the gallery browser. To make sure that we don't get locks, instead of
using the same file, a cron job could do an `rsync` between the database managed
by `calibre` and the one used by `calibre-web`.

Calibre implements genres with tags, behind the scenes it uses the
[`fetch-ebook-metadata`](https://manual.calibre-ebook.com/generated/en/fetch-ebook-metadata.html)
command line tool, that returns all the metadata in human readable form

```bash
$: fetch-ebook-metadata -i 9780061796883 -c cover.jpg

Title               : The Dispossessed
Author(s)           : Ursula K. le Guin
Publisher           : Harper Collins
Tags                : Fiction, Science Fiction, Space Exploration, Literary, Visionary & Metaphysical
Languages           : eng
Published           : 2009-10-13T20:34:30.878865+00:00
Identifiers         : google:tlhFtmTixvwC, isbn:9780061796883
Comments            : “One of the greats….Not just a science fiction writer; a literary icon.” – Stephen KingFrom the brilliant and award-winning author Ursula K. Le Guin comes a classic tale of two planets torn
apart by conflict and mistrust — and the man who risks everything to reunite them.A bleak moon settled by utopian anarchists, Anarres has long been isolated from other worlds, including its mother planet, Urras—a
 civilization of warring nations, great poverty, and immense wealth. Now Shevek, a brilliant physicist, is determined to reunite the two planets, which have been divided by centuries of distrust. He will seek ans
wers, question the unquestionable, and attempt to tear down the walls of hatred that have kept them apart.To visit Urras—to learn, to teach, to share—will require great sacrifice and risks, which Shevek willingly
 accepts. But the ambitious scientist's gift is soon seen as a threat, and in the profound conflict that ensues, he must reexamine his beliefs even as he ignites the fires of change.
Cover               : cover.jpg
```

Or in xml if you use the `-o` flag.

I've checked if these tags could be automatically applied to Readarr, but their
tags are meant only to be attached to Authors to apply metadata profiles. I've
opened [an issue](https://github.com/Readarr/Readarr/issues/1284) to see if they
plan to implement tags for books.

It's a pity we are not going to use `calibre-web` as it also had support to [sync
the reading stats from Kobo](https://github.com/janeczku/calibre-web/wiki/Kobo-Integration).

In the past I used [gcstar](#gcstar) and then [polar
bookshelf](#polar-bookshelf), but decided not to use them anymore for different
reasons.

In conclusion, the tools reviewed don't work as I need them to, some ugly
patches could be applied and maybe it would work, but it clearly shows that they
are not ready yet unless you want to invest time in it, and even if you did, it
will be unstable. Until a better system shows up, I'm going to use Readarr to browse the books
that I want to read, and add them to an ordered markdown file with sections as
genres, not ideal, but robust as hell xD.

# Review system

System to write reviews and rate books, if the gallery browser doesn't include
it, we'll use an independent component.

Until I find something better, I'm saving the title, author, genre, score, and
review in a json file, so it's easy to import in the chosen component.

# Content discovery

Recommendation system to analyze the user taste and suggest books that might
like. Right now I'm monitoring the authors with Readarr to get
notifications when they release a new book. I also manually go through goodreads and
similar websites looking for similar books to the ones I liked.

# Deprecated components

## [Polar bookself](https://getpolarized.io/)

It was a very promising piece of software that went wrong :(. It had a nice
interface built for incremental reading and studying with anki, and a nice tag
system. It was a desktop application you installed in your computer, but since
Polar 2.0 they moved into a cloud hosted service, with no possibility of
self-hosting it, so you give them your books and all your data, a nasty turn of
events.

## [GCStar](http://www.gcstar.org/)

The first free open source application for managing collections I used, it has
an old looking desktop interface and is no longer maintained.
