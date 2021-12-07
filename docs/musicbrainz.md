---
title: MusicBrainz
date: 20211203
author: Lyz
---

[MusicBrainz](https://musicbrainz.org) is an open music encyclopedia that
collects music metadata and makes it available to the public.

MusicBrainz aims to be:

* The ultimate source of music information by allowing anyone to contribute and
    releasing the data under open licenses.
* The universal lingua franca for music by providing a reliable and unambiguous
    form of music identification, enabling both people and machines to have
    meaningful conversations about music.

Like Wikipedia, MusicBrainz is maintained by a global community of users and we
want everyone — including you — to [participate and contribute](https://musicbrainz.org/doc/How_to_Contribute).

# Contributing

Creating an account is free and easy. To be able to add new releases easier,
I've seen that there are some [UserScript
importers](https://github.com/murdos/musicbrainz-userscripts#mb_ui_enhancements),
they suggest to use the
[ViolentMonkey](https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/)
addon and install the desired plugins.

With the Discogs one, if you don't see the `Import into MB` button is because
you can't import a Master release, you have to click on a specific release. If
that doesn't work for you, check these issues
([1](https://github.com/murdos/musicbrainz-userscripts/issues/413) and
[2](https://github.com/murdos/musicbrainz-userscripts/issues/354)). It works
without authentication.

All the data is fetched for you except for the album cover, which you have to
manually add.

Make sure that you fill up the [Release Status](#release-status) otherwise it
[won't show up in
Lidarr](https://wiki.servarr.com/lidarr/faq#i-cannot-find-a-release-in-lidarr-but-it-is-on-musicbrainz).

Then [be
patient](https://www.reddit.com/r/Lidarr/comments/cmyrwj/album_on_musicbrainz_but_not_in_lidarr/),
sometimes you need to wait hours before the changes are propagated to Lidarr.

## Filling up releases

Some notes on the release fields

### [Primary types](https://musicbrainz.org/doc/Release_Group/Type)

* *Album*: Perhaps better defined as a "Long Play" (LP) release, generally
    consists of previously unreleased material (unless this type is combined
    with secondary types which change that, such as "Compilation").

* *Single*: A single typically has one main song and possibly
        a handful of additional tracks or remixes of the main track; the single
        is usually named after its main song; the single is primarily released
        to get radio play and to promote release sales.

* *EP*: An EP is a so-called "Extended Play" release and often contains the
    letters EP in the title. Generally an EP will be shorter than a full length
    release (an LP or "Long Play"), usually less than four tracks, and the
    tracks are usually exclusive to the EP, in other words the tracks don't come
    from a previously issued release.  EP is fairly difficult to define; usually
    it should only be assumed that a release is an EP if the artist defines it
    as such.

* *Broadcast*: An episodic release that was originally broadcast via radio,
    television, or the Internet, including podcasts.

* *Other*: Any release that does not fit or can't decisively be placed in any of
    the categories above.

### [Secondary types](https://musicbrainz.org/doc/Release_Group/Type)

* *Compilation*: A compilation, for the purposes of the MusicBrainz database,
    covers the following types of releases:

    * A collection of recordings from various old sources (not necessarily
        released) combined together. For example a "best of", retrospective or
        rarities type release.
    * A various artists song collection, usually based on a general theme
        ("Songs for Lovers"), a particular time period ("Hits of 1998"), or some
        other kind of grouping ("Songs From the Movies", the "Café del Mar"
        series, etc).

    The MusicBrainz project does not generally consider the following to be compilations:

    * A reissue of an album, even if it includes bonus tracks.
    * A tribute release containing covers of music by another artist.
    * A classical release containing new recordings of works by a classical artist.
    * A split release containing new music by several artists

    Compilation should be used in addition to, not instead of, other types: for
    example, a various artists soundtrack using pre-released music should be
    marked as both a soundtrack and a compilation. As a general rule, always
    select every secondary type that applies.

* *Soundtrack*: A soundtrack is the musical score to a movie, TV series, stage
    show, video game, or other medium. Video game CDs with audio tracks should
    be classified as soundtracks because the musical properties of the CDs are
    more interesting to MusicBrainz than their data properties.

* *Spokenword*: Non-music spoken word releases.

* *Interview*: An interview release contains an interview, generally with an
    artist.

* *Audiobook*: An audiobook is a book read by a narrator without music.

* *Audio drama*: An audio drama is an audio-only performance of a play (often,
    but not always, meant for radio). Unlike audiobooks, it usually has multiple
    performers rather than a main narrator.

* *Live*: A release that was recorded live.

* *Remix*: A release that primarily contains remixed material.

* *DJ-mix*: A DJ-mix is a sequence of several recordings played one after the
    other, each one modified so that they blend together into a continuous flow
    of music. A DJ mix release requires that the recordings be modified in some
    manner, and the DJ who does this modification is usually (although not
    always) credited in a fairly prominent way.

* *Mixtape/Street*: Promotional in nature (but not necessarily free), mixtapes
    and street albums are often released by artists to promote new artists, or
    upcoming studio albums by prominent artists. They are also sometimes used to
    keep fans' attention between studio releases and are most common in rap
    & hip hop genres. They are often not sanctioned by the artist's label, may
    lack proper sample or song clearances and vary widely in production and
    recording quality. While mixtapes are generally DJ-mixed, they are distinct
    from commercial DJ mixes (which are usually deemed compilations) and are
    defined by having a significant proportion of new material, including
    original production or original vocals over top of other artists'
    instrumentals. They are distinct from demos in that they are designed for
    release directly to the public and fans; not to labels.

### [Release status](https://musicbrainz.org/doc/Release)

*Status* describes how "official" a release is. Possible values are:

* *Official*: Any release officially sanctioned by the artist and/or their
    record company. Most releases will fit into this category.
* *Promotional*: A give-away release or a release intended to promote an
    upcoming official release (e.g. pre-release versions, releases included
    with a magazine, versions supplied to radio DJs for air-play).
* *Bootleg*: An unofficial/underground release that was not sanctioned by
    the artist and/or the record company. This includes unofficial live
    recordings and pirated releases.
* *Pseudo-release*: An alternate version of a release where the titles have
    been changed. These don't correspond to any real release and should be
    linked to the original release using the transl(iter)ation
    relationship.

# References

* [Home](https://musicbrainz.org)
