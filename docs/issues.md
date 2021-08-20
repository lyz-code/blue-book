---
title: Issue tracking
date: 20210209
author: Lyz
---

I haven't found a tool to monitor the context it made me track certain software
issues, so I get lost when updates come. Until a tool shows up, I'll use the
good old markdown to keep track.

# Pydantic errors

* [No name 'BaseModel' in module 'pydantic'
    (no-name-in-module)](https://github.com/samuelcolvin/pydantic/issues/1961#issuecomment-786674519),
    you can find a patch in [the pydantic article](pydantic.md#troubleshooting),
    the pydantic developers took that as a solution as it lays in [pylint's
    roof](https://github.com/PyCQA/pylint/issues/1524), once that last issue is
    solved try to find a better way to improve the patch solution.

# Vim workflow improvements

Manually formatting paragraphs is an unproductive pain in the ass,
[Vim-pencil](https://github.com/reedes/vim-pencil) looks promising but there are
still some usability issues that need to be fixed first:

* Wrong list management: [#93](https://github.com/reedes/vim-pencil/issues/93)
    linked to [#31](https://github.com/reedes/vim-pencil/issues/31) and
    [#95](https://github.com/reedes/vim-pencil/issues/95).
* [Disable wrap of document
    headers](https://github.com/reedes/vim-pencil/issues/92) (less important).

# Gitea improvements

* [Replying discussion comments redirects to mail pull request
    page](https://github.com/go-gitea/gitea/issues/14797): Notify the people
    that it's fixed.

# Gitea Kanban board improvements

* Remove the Default issue template:
    [#14383](https://github.com/go-gitea/gitea/issues/14383). When it's solved
    apply it in the work's issue tracker.

# Docker monitorization

* Integrate diun in the CI pipelines when they [support prometheus
    metrics](https://github.com/crazy-max/diun/issues/201). Update the
    [docker](docker.md) article too.

# Gadgetbridge improvements

* [Smart alarm
    support](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1208): Use
    it whenever it's available.
* [GET Sp02 real time data, or at least export
    it](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2164): See how
    to use this data once it's available.
* [export heart rate for activities without a GPX
    track](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2049): See if
    I can export the heart rate for post processing. Maybe it's covered
    [here](https://codeberg.org/Freeyourgadget/Gadgetbridge/wiki/Huami-Heartrate-measurement).
* [Add UI and logic for more complex database import, export and
    merging](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1841):
    Monitor to see if there are new ways or improvements of exporting data.
* [Blog's RSS is not
    working](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2204): Add
    it to the feed reader once it does, and remove the warning from the
    gadgetbridge article
* [Integrate with home
    assistant](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2198):
    Check if the integration with kalliope is easy.
* [Issues with zoom, swipe, interact with
    graphs](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2111):
    enable back *disable swipe between tabs* in the chart settings.
* [PAI
    implementation](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1905):
    Check it once it's ready.
* [Calendar synchronization
    issue](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1866), could
    be related with [notifications work after
    restart](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/1721): try
    it when it's solved
* [Change snooze time
    span](https://codeberg.org/Freeyourgadget/Gadgetbridge/issues/2210): Change
    the timespan from 10 to 5 minutes.

# Ombi improvements

* [Ebook
    requests](https://features.ombi.io/suggestions/120488/implement-ebook-requests):
    Configure it in the service, notify the people and start using it.
* [Add working links to the details
    pages](https://ombifeatures.featureupvote.com/suggestions/162866/add-working-links-to-tmdb-in-the-details-page):
    nothing to do, just start using it.
* [Allow search by
    genre](https://features.ombi.io/suggestions/115149/search-by-genres): Notify
    the people and start using it.
