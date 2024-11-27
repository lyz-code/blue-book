---
title: Music management
date: 20211203
author: Lyz
---

Music management is the set of systems and processes to get and categorize songs
so it's easy to browse and discover new content. It involves the next actions:

* Automatically index and download metadata of new songs.
* Notify the user when a new song is added.
* Monitor the songs of an artist, and get them once they are released.
* A nice interface to browse the existent library, with the possibility of
    filtering by author, genre, years, tags or release types.
* An interface to listen to the music
* An interface to rate and review library items.
* An interface to discover new content based on the ratings and item metadata.

# Components

I've got a music collection built from [mediarss](projects.md#mediarss)
downloads, bought CDs rips and friend library sharing. It is more less organized
in a directory tree by genre, but I lack any library management features. I have
 a lot of duplicates, incoherent naming scheme, no way of filtering or
intelligent playlist generation.

[playlist_generator](projects.md#playlist_generator) helped me with the last point, based
on the metadata gathered with [mep](projects.md#mep), but it's still not enough.

So I'm in my way of migrate all the library to
[beets](http://beets.readthedocs.io/), and then I'll deprecate [mep](#mep) in
favor to a [mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon) client that
allows me to keep on saving the same metadata.

Once it's implemented, I'll migrate all the metadata to the new system.

## [Lidarr](https://github.com/Lidarr/Lidarr)

I'm also using Lidarr to manage what content is missing.

Both Lidarr and `beets` get their from [MusicBrainz](musicbrainz.md). This means
that sometimes some artist may lack a release, if they do, please [contribute to
MusicBrainz](musicbrainz.md#contributing) and add the information. Be patient,
Lidarr may take some time to fetch the information, as it probably is not
available straight away from the API.

One awesome feature of Lidarr is that you can select the type of releases you
want for each artist. They are defined in `Settings/Profiles/Metadata Profiles`.
To be able to fine grain your settings, you first need to understand what do
, [Primary Types](musicbrainz.md#primary-types), [Secondary
Types](musicbrainz.md#secondary-types) and [*Release
Status*](musicbrainz.md#release-status) means.

If you want to set the missing picture of an artist, you need to add it at
[fanart.tv](https://fanart.tv/). It's a process that needs the moderators
approval, so don't expect it to be automatic. They are really kind when you
don't do things right, but still, check their [upload
guidelines](https://fanart.tv/music-fanart/) before you contribute.
