There are [many alternatives to self host a photo management software](https://awesome-selfhosted.net/tags/photo-and-video-galleries.html), here goes my personal comparison. You should complement this article with [meichthys one](https://meichthys.github.io/foss_photo_libraries/).

!!! note "TL;DR: I'd first go with Immich, then LibrePhotos and then LycheeOrg"


| Software              | Home-Gallery    | Immich      | LibrePhotos |
| ---                   | ---             | ---         | ---         | 
| UI                    | Fine            | Good        |  Fine       |
| Popular (stars)       | 614             | 25k         |  6k         |
| Active (PR/Issues)(1) | ?               | 251/231     |  27/16      |
| Easy deployment       | ?               | True        |  Complicated|
| Good docs             | True            | True        |  True       |
| Stable                | True            | False       |  True       |
| Smart search          | ?               | True        |  True       |
| Language | Javascript | Typescript | Python |
| Batch edit            | True            | True        |  ?          |
| Multi-user            | False           | True        |  ?          |
| Mobile app            | ?               | True        |  ?          |
| Oauth support         | ?               | True        |  ?          |
| Facial recognition    | ?               | True        |  ?          |
| Scales well           | False           | True        |  ?          |
| Favourites            | ?               | True        |  ?          |
| Archive               | ?               | True        |  ?          |
| Has API               | True            | True        |  ?          |
| Map support           | True            | True        |  ?          |
| Video Support         | True            | True        |  ?          |
| Discover similar      | True            | True        |  ?          |
| Static site           | True            | False       |  ?          |

- (1): It refers to the repository stats of the last month

# [Immich](immich.md)

References:

- [Home](https://immich.app/)
- [Demo](https://demo.immich.app/photos) 
- [Source](https://github.com/immich-app/immich).

Pros:
- Smart search is awesome Oo
- create shared albums that people can use to upload and download
- map with leaflet
- explore by people and places
- docker compose
- optional [hardware acceleration](https://immich.app/docs/features/hardware-transcoding)
- very popular 25k stars, 1.1k forks
- has a [CLI](https://immich.app/docs/features/command-line-interface)
- can [load data from a directory](https://immich.app/docs/features/libraries)
- It has an [android app on fdroid to automatically upload media](https://immich.app/docs/features/mobile-app)
- [sharing libraries with other users](https://immich.app/docs/features/partner-sharing) and with the public
- favorites and archive
- public sharing
- oauth2, specially with [authentik <3](https://immich.app/docs/administration/oauth)
- extensive api: https://immich.app/docs/api/introduction
- It has an UI similar to google photos, so it would be easy for non technical users to use.
- Batch edit 
- Discover similar through the smart search

Cons:

- If you want to get results outside the smart search you are going to have a bad time. There is still no way to filter the smart search results or even sort them. You're sold to the AI.
- dev suggests not to use watchtower as the project is in unstable alpha
- Doesn't work well in firefox 
- It doesn't work with tags which you don't need because the smart search is so powerful.
- Scans pictures on the file system

# [LibrePhotos](https://docs.librephotos.com/)

References:

- [Source](https://github.com/LibrePhotos/librephotos)
- [Docs](https://docs.librephotos.com/docs/intro)
- [Demo](https://demo2.librephotos.com/login)
- [Outdated comparison](https://docs.librephotos.com/docs/user-guide/features)

Pros:

- [docker compose](https://docs.librephotos.com/docs/installation/standard-install), although you need to build the dockers yourself
- [android app](https://docs.librephotos.com/docs/user-guide/mobile/)
- 6k stars, 267 forks
- object, scene ai extraction

Cons:

- Not as good as Immich.

# [Home-Gallery](https://docs.home-gallery.org/general.html)

You can see the demo [here](https://demo.home-gallery.org/).

Nice features:

- Simple UI
- Discover similar images
- Static site generator
- Shift click to do batch editing

Cons:

- All users see all media
- The whole database is loaded into the browser and requires recent (mobile) devices and internet connection
- Current tested limits are about 400,000 images/videos

# Lycheeorg

References:

- [Home](https://lycheeorg.github.io/)
- [Docs](https://lycheeorg.github.io/docs)
- [Source](https://github.com/LycheeOrg/Lychee)

Pros:

- Sharing like it should be. One click and every photo and album is ready for the public. You can also protect albums with passwords if you want. It's under your control.
- Manual tags
- apparently safe upgrades
- docker compose
- 2.9k stars


Cons:
- demo doesn't show many features
- no ai

# Photoview

- [Home](https://photoview.github.io/)
- [Source](https://github.com/photoview/photoview)
- [Docs](https://photoview.github.io/en/docs/usage-people/)

Pros:

- Syncs with file system
- Albums and individual photos or videos can easily be shared by generating a public or password protected link.
- users support
- maps support
- 4.4k stars
- Face recognition

Cons:

- Demo difficult to understand as it's not in english
- mobile app only for ios
- last commit 6 months ago

# Pigallery2

References:

- [Home](https://bpatrik.github.io/pigallery2/)

Pros:

- map
- The gallery also supports *.gpx file to show your tracked path on the map too
- App supports full boolean logic with negation and exact or wildcard search. It also provides handy suggestions with autocomplete.
- face recognitiom: PiGallery2 can read face reagions from photo metadata. Current limitation: No ML-based, automatic face detection.
- rating and grouping by rating
- easy query builder
- video transcoding
- blog support. Markdown based blogging support

  You can write some note in the *.md files for every directory

- You can create logical albums (a.k.a.: Saved search) from any search query. Current limitation: It is not possible to create albums from a manually picked photos.
- PiGallery2 has a rich settings page where you can easily set up the gallery.

Cons:
- no ml face recognition

# Piwigo

References:

- [Home](https://piwigo.org)
- [Source](https://github.com/Piwigo/Piwigo)

Piwigo is open source photo management software. Manage, organize and share your photo easily on the web. Designed for organisations, teams and individuals

Pros:

- Thousands of organizations and millions of individuals love using Piwigo
- shines when it comes to classifying thousands or even hundreds of thousands of photos.
- Born in 2002, Piwigo has been supporting its users for more than 21 years. Always evolving!
- You can add photos with the web form, any FTP client ora desktop application like digiKam, Shotwell, Lightroom ormobile applications.
- Filter photos from your collection, make a selection and apply actions in batch: change the author, add some tags, associate to a new album, set geolocation...
- Make your photos private and decide who can see each of them. You can set permissions on albums and photos, for groups or individual users.
- Piwigo can read GPS latitude and longitude from embedded metadata. Then, with plugin for Google Maps or OpenStreetMap, Piwigo can display your photos on an interactive map.
- Change appearance with themes. Add features with plugins. Extensions require just a few clicks to get installed. 350 extensions available, and growing!
- With the Fotorama plugin, or specific themes such as Bootstrap Darkroom, you can experience the full screen slideshow.
- Your visitors can post comments, give ratings, mark photos as favorite, perform searches and get notified of news by email.
- Piwigo web API makes it easy for developers to perform actions from other applications
- GNU General Public License, or GPL
- 2.9 k stars, 400 forks
- still active
- nice release documents: https://piwigo.org/release-14.0.0

Cons:

- Official docs don't mention docker
- no demo: https://piwigo.org/demo
- Unpleasant docs: https://piwigo.org/doc/doku.php
- Awful plugin search: https://piwigo.org/ext/

# [Damselfly](https://damselfly.info/)

Fast server-based photo management system for large collections of images. Includes face detection, face & object recognition, powerful search, and EXIF Keyword tagging. Runs on Linux, MacOS and Windows.

Very ugly UI

# [Saigal](https://github.com/saimn/sigal)

Too simple

# [Spis](https://github.com/gbbirkisson/spis)

Low number of maintainers
Too simple
