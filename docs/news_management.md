---
title: News Management
date: 20211231
author: Lyz
---

The information world of today is overwhelming. It can reach a point that you
just want to disconnect so as to avoid the continuous bombardment, but that
leads to loosing connection with what's happening in the world. Without knowing
what's going on it's impossible to act to shape it better.

The problem to solve is to:

* Keep updated on the important articles for you.
* Don't invest too much time on it.
* Don't loose time reading articles you're not interested on.

# Workflow

I've found three information types to explore:

* Written content: articles, blogs, newspapers...
* Listened content: mainly podcasts.
* Viewed content: youtube, twich channels.

Each has it's advantages and disadvantages. I like the written content as it
lets me decide the pace of information ingestion, it's compatible with
incremental reading, and it's the best medium to learn by making annotations and
summaries, it requires your full attention though. Listened content is best to
keep updated while you do brainless tasks such as cooking or cleaning, but it
makes difficult to save references or ideas. Viewed content is as attention
demanding as reading unless you don't care about the visual content and take it
as a podcast.

## Written content

To process the written content I use an RSS reader
([Feeder](https://f-droid.org/en/packages/com.nononsenseapps.feeder/)) to gather
all written content in one place. I skim through the elements without reading
them, and I send the ones that catch my attention to
[wallabag](https://www.wallabag.it/en) for later reading. Then I go to wallabag
and read the elements that feels more attractive at that moment.

Before starting to read, I define the amount of time I want to spend on getting
updated. Half of that time goes to skimming through, and the other to deep
reading the selected content. You'll probably won't be able to process either
the whole content on your RSS reader nor the selected content, that's why
a recommender system would be awesome.

Finding the reading devices is very important. I prefer to browse it on a tablet
as it's much more pleasant than a mobile or a computer, an e-reader would be
better, although wallabag is supported on some e-readers, I haven't tried it
yet. I can't wait for the [PineNote](https://www.pine64.org/pinenote/) to be
released.

The moments I've found suitable for reading content are while eating breakfast
or dinner when I'm alone.

## Listened content

I've selected a small number of podcasts that I listen with
[AntennaPod](https://f-droid.org/en/packages/de.danoeh.antennapod/) while
cooking or cleaning, instead of listening directly from the mobile, I use
a bluetooth loudspeaker that I carry everywhere I go (at home! use headphones
when you are outside. people with loudspeakers on the public transport or
streets are hateful), if there is a reference I want to save, I write it down in
the mobile [inbox](task_tools.md#inbox) and process it later with
[pynbox](projects.md#pynbox).

# The perfect software solution

My current workflow could be improved by software, currently the key features
I'd want are:

* One place for all sources: It's useless to go to `n` different websites to see
    if there is new information. RSS has been with us for too long to fall on
    that.
* The user has control of it's data: The user should be able to decide which
    information is private and which one is public. Only the people it trusts
    will have access to it's private data.
* There must be a filter of the incoming elements: It doesn't matter how well
    you choose your sources, there's always going to be content that is not
    interesting for you. So there needs to be a powerful filtering system.

## Content filtering

Filtering content is a subsection of the [recommender
systems](recommender_systems.md#basic-models-of-recommender-systems), of all the
basic models, the ones that apply are:

* [Collaborative
    filtering](recommender_systems.md#collaborative-Filtering-models): Where the
    data of many users is used to filter out the relevant items.
* [Content based
    filtering](recommender_systems.md#content-based-recommender-systems): Where
    the data of the user on past items is used to filter new elements.

### Collaborative filtering

External users give information on how they see the items, and the algorithm can
use that data to decide which ones are relevant for a desired user. It's how
social networks operate, and if you use Mastodon, Reddit, HackerNews, Facebook,
Twitter or similar, then you may not even be interested in this article at all.

All those platforms have one or more of the next flaws for me:

* There is no one place that aggregates the information of all information
    sources.
* You can't mark content as seen.
* Your data lives in the servers of other people.
* They are based on closed sourced software.
* There's a mix of information with conversation between users.
* You may not be interested in all the elements the source publishes.

Some of them support the export to RSS and if they don't, you'll probably can
find bridge platforms that do. That'll solve all the problems but the two last
ones. I've used the RSS feed of mastodon users, and I finally removed them
because there was a lot of content I didn't like. I've also used the reddit and
hackernews rss, but again, most of the posts weren't interesting to me.

A partial solution I've been using with my friends is to share relevant content
through [wallabag](https://www.wallabag.it/en). It's a read-it-later application
that creates RSS feeds for the *liked* elements. That way you can get filtered
content from the people you know. The downsides are:

* You get one feed for all the content, you don't have the possibility to filter
    out by categories or tags.
* It's not very collaborative. You need to ask one by one for their RSS.

A prettier (but more difficult) solution would be to create communities that
commit to share the articles interesting for a specific topic. Like HackerNews
but at smaller level, where you know and trust the members of the community, and
where people outside the community can not upload data, just read it.

This could be done through one instance of [`lemmy`](https://join-lemmy.org/),
with a closed community, but that service is envisioned to be federated and to
encourage the interaction of the users on the site.

Another possibility would be to create a simple backend that mimics the [api
interface](https://app.wallabag.it/api/doc) of wallabag, so that users could use
the browser addon and all the interfaces existent, for example the
[Feeder](https://f-droid.org/en/packages/com.nononsenseapps.feeder/) integration
with wallabag instances. You'll be able to create communities, and invite users
to them, they will be able to link a "wallabag" tag with a specific community
channel. That way, an RSS feed will be created per community with all the
articles shared by their members. Optionally, users could decide to ignore the
entries of another user.

But for any of these solutions to work, you'll need to convince the people to
tweak how they browse the internet in order to contribute to the system, which
it's kind of difficult :(.

### Content based filtering

If you don't manage to convince the people to use collaborative filtering,
you're on your own. Your best bet then is to deduce which elements are
interesting based on how you rated other elements.

I haven't found any rss reader that does good filtering of the elements. I've
used [Newsblur](https://www.newsblur.com/) in the past, you're able to assign
scores for the element tags and user. But I didn't find it very useful. Also
when it comes to self host it, [it's a little bit of
a nightmare](https://github.com/samuelclay/NewsBlur/blob/master/docker-compose.yml).

Intermediate solutions between the sources and the reader aren't a viable option
either, as you need to interact with that middleware outside the RSS reader.
