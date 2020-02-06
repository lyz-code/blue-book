---
title: Projects
date: 20200206
author: Lyz
---

Also known as where I'm spending my spare time.

# Home Stock inventory

I try to follow the idea of emptying my mind as much as possible, so I'm able to
spend my CPU time wisely.

Keeping track of what do you have at home or what needs to be bought is an
effort that should be avoided.

So I'm integrating [grocy](grocy.md) in my life.

# Pydo

I've been using [Taskwarrior](https://taskwarrior.org) for the last five or six
years. It's an awesome program to do task management and it is really
customizable.

So throughout these years I've done several scripts to integrate it into my
workflow:

* [Taskban](https://github.com/lyz-code/taskban): To do [Sprint
  Reviews](https://en.wikipedia.org/wiki/Scrum_%28software_development%29#Sprint_review)
  and do data analysis on the difference between the estimation and the actual
  time for doing tasks. To do so, I had to rewrite how
  [Tasklib](https://github.com/lyz-code/taskli://github.com/lyz-code/tasklib)
  stores task time information.
* [Taskwarrior_recurrence](https://git.digitales.cslabrecha.org/lyz/taskwarrior_recurrence):
  A group of hooks to fix [Taskwarriors recurrence
  issues](https://taskwarrior.org/docs/design/recurrence.html).
* [Taskwarrior_validation](https://git.digitales.cslabrecha.org/lyz/taskwarrior_validation):
  A hook to help in the definition of validation criteria for tasks.

But it has comed a time to look for alternatives because:

* As the database grows, `taskban` becomes unusable.
* Taskwarrior lacks several features I want.
* It's written in C.
* It's development has come to [code maintenance
  only](https://github.com/GothenburgBitFactory/taskwarrior/graphs/code-frequency).
* It uses a plaintext file as data storage.

[Tasklite](https://tasklite.org) is a promising project that tackles most of the
points above. But is written in
[Haskel](https://en.wikipedia.org/wiki/Haskell_%28programming_language%29) which
I don't know and I don't want to learn.

So taking my experience with taskwarrior and looking at tasklite, I've started
building [pydo](https://github.com/lyz-code/pydo).

# Blue book

I'm refactoring all the knowledge gathered in the past in my cheat sheet
repository into the blue book. This means migrating 7422 articles, almost 50
million lines, to the new structure. It's going to be a slow and painful
process  ᕙ(⇀‸↼‶)ᕗ.

# Clinv

As part of my [DevSecOps](https://dzone.com/articles/shifting-left-devsecops)
work, I need to have an updated inventory of cloud assets organized under a risk
management framework. I did some research in the past and there was no tool that
had:

As you can see in [how do you document your
infrastructure?](https://www.reddit.com/r/aws/comments/dxmkci/how_do_you_document_your_infrastructure/),
there is still a void.

* Manage a dynamic inventory of risk management resources (Projects, Services,
  Information, People) and infrastructure resources (EC2, RDS, S3, Route53, IAM
  users, IAM groups...).
* Add risk management metadata to your AWS resources.
* Monitor if there are resources that are not inside your inventory.
* Perform regular expression searches on all your resources.
* Get all your resources information.
* Works from the command line.

So I started building [clinv](https://github.com/lyz-code/clinv),

# Media indexation

I've got a music collection of 136362 songs, belonging to [mediarss](#mediarss)
downloads, bought CDs rips and friend library sharing. It is more less
organized in a directory tree by genre, but I lack any library management
features. I've got a lot of duplicates, incoherent naming scheme, no way of
filtering or intelligent playlist generation.

[playlist_generator](#playlist_generator) helped me with the last point, based
on the metadata gathered with [mep](#mep), but it's still not enough.

So I'm in my way of migrate all the library to
[beets](http://beets.readthedocs.io/), and then I'll deprecate [mep](#mep) in
favor to an [mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon) client that
allows me to keep on saving the same metadata.

Once it's implemented, I'll migrate all the metadata to the new system.

# Projects I maintain

## [Mediarss](https://git.digitales.cslabrecha.org/lyz/mediarss)

I've always wanted to own the music I listen, because I don't want to give my
data to the companies host the streaming services, nor I trust that [they'll
keep on giving the service](https://blog.8tracks.com/).

So I started building some small bash scrappers (I wasn't yet introduced to
[Python](https://en.wikipedia.org/wiki/Python_%28programming_language%29)) to
get the media. That's when I learned to hate the web developers for their
constant changes and to love the API.

Then I discovered [youtube-dl](https://github.com/ytdl-org/youtube-dl), a Python
command-line program to download video or music from streaming sites.

But I still laked the ability to stay updated with the artist channels.
So [mediarss](https://git.digitales.cslabrecha.org/lyz/mediarss) was born.
A youtube-dl wrapper to periodically download new content.

This way, instead of using Youtube, Soundcloud or Bandcamp subscriptions, I've got
a [YAML](https://en.wikipedia.org/wiki/YAML) with all the links that I want to
monitor.

## [Playlist_generator](https://git.digitales.cslabrecha.org/lyz/playlist_generator)

When my music library started growing due to [mediarss](#mediarss), I wanted
to generate playlists filtering my content by:

* Rating score fetched with [mep](#mep).
* First time/last listened.
* Never listened songs.

The playlists I usually generate with these filters are:

* Random unlistened songs.
* Songs discovered last month/year with a rating score greater than X.
* Songs that I haven't heard since 20XX  with a rating score greater than
  X (this one gave me pleasant surprises ^^).

## mep

I started  [life logging](https://en.wikipedia.org/wiki/Lifelog) with `mep`. One
of the first programs I wrote when learning
[Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29).

It is a [mplayer](https://en.wikipedia.org/wiki/MPlayer) wrapper that allows me
to control it with [i3](https://en.wikipedia.org/wiki/I3_%28window_manager%29)
key bindings and store metadata of the music I listen.

I don't even publish it because it's a horrible program that would make your
eyes bleed. 600 lines of code, only 3 functions, 6 levels of nested ifs, no
tests at all, but hey, the functions have docstrings! (ｏ・_・)ノ”(ᴗ_ ᴗ。)

But it works, so I everyday close my eyes and open my ears till I have
a solution that gives me the same features with
[mpd](https://en.wikipedia.org/wiki/Music_Player_Daemon).

