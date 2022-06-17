---
title: Feedparser
date: 20200401
author: Lyz
---

Parse Atom and RSS feeds in Python.

# Install

```bash
pip install feedparser
```

# Basic Usage

## Parsing content

### [Parse a feed from a remote URL](https://pythonhosted.org/feedparser/introduction.html#parsing-a-feed-from-a-remote-url)

```python
>>> import feedparser
>>> d = feedparser.parse('http://feedparser.org/docs/examples/atom10.xml')
>>> d['feed']['title']
u'Sample Feed'
```

### [Parse a feed from a string](https://pythonhosted.org/feedparser/introduction.html#parsing-a-feed-from-a-string)

```python
>>> import feedparser
>>> rawdata = """<rss version="2.0">
<channel>
<title>Sample Feed</title>
</channel>
</rss>"""
>>> d = feedparser.parse(rawdata)
>>> d['feed']['title']
u'Sample Feed'
```


## Access common elements

The most commonly used elements in RSS feeds (regardless of version) are title,
link, description, publication date, and entry ID.

### [Channel elements](https://pythonhosted.org/feedparser/common-rss-elements.html#accessing-common-channel-elements)

```python
>>> d.feed.title
u'Sample Feed'
>>> d.feed.link
u'http://example.org/'
>>> d.feed.description
u'For documentation <em>only</em>'
>>> d.feed.published
u'Sat, 07 Sep 2002 00:00:01 GMT'
>>> d.feed.published_parsed
(2002, 9, 7, 0, 0, 1, 5, 250, 0)

```
All parsed dates can [be converted to
datetime](https://snipplr.com/view/56927/convert-the-timestructtime-object-into-a-datetimedatetime-object)
with the following snippet:

```python
from time import mktime
from datetime import datetime
dt = datetime.fromtimestamp(mktime(item['updated_parsed']))
```

### [Item elements](https://pythonhosted.org/feedparser/common-rss-elements.html#accessing-common-item-elements)

```python
>>> d.entries[0].title
u'First item title'
>>> d.entries[0].link
u'http://example.org/item/1'
>>> d.entries[0].description
u'Watch out for <span>nasty tricks</span>'
>>> d.entries[0].published
u'Thu, 05 Sep 2002 00:00:01 GMT'
>>> d.entries[0].published_parsed
(2002, 9, 5, 0, 0, 1, 3, 248, 0)
>>> d.entries[0].id
u'http://example.org/guid/1'
```
An RSS feed can specify a [small
image](https://pythonhosted.org/feedparser/uncommon-rss.html#accessing-feed-image)
which some aggregators display as a logo.

```python
>>> d.feed.image
{'title': u'Example banner',
'href': u'http://example.org/banner.png',
'width': 80,
'height': 15,
'link': u'http://example.org/'}
```

Feeds and entries can be assigned to [multiple
categories](https://pythonhosted.org/feedparser/uncommon-rss.html#accessing-multiple-categories),
and in some versions of RSS, categories can be associated with a “domain”.

```python
>>> d.feed.categories
[(u'Syndic8', u'1024'),
(u'dmoz', 'Top/Society/People/Personal_Homepages/P/')]
```

As feeds in the real world may be missing some elements, you may want to [test
for the existence](https://pythonhosted.org/feedparser/basic-existence.html#testing-if-elements-are-present)
of an element before getting its value.

```python
>>> import feedparser
>>> d = feedparser.parse('http://feedparser.org/docs/examples/atom10.xml')
>>> 'title' in d.feed
True
>>> 'ttl' in d.feed
False
>>> d.feed.get('title', 'No title')
u'Sample feed'
>>> d.feed.get('ttl', 60)
60
```

# Advanced usage

It is possible to interact with feeds that are [protected with
credentials](https://pythonhosted.org/feedparser/http-authentication.html).

# Issues

* [Deprecation warning when using
    `updated_parsed`](https://github.com/kurtmckee/feedparser/issues/151), once
    solved tweak the `airss/adapters/extractor.py#RSS.get` at `updated_at`.

# Links

* [Git](https://github.com/kurtmckee/feedparser)
* [Docs](https://pythonhosted.org/feedparser/)
