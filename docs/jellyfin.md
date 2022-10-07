---
title: Jellyfin
date: 20210330
author: Lyz
---

[Jellyfin](https://jellyfin.org/) is a Free Software Media System that puts you
in control of managing and streaming your media. It is an alternative to the
proprietary Emby and Plex, to provide media from a dedicated server to end-user
devices via multiple apps. Jellyfin is descended from Emby's 3.5.2 release and
ported to the .NET Core framework to enable full cross-platform support. There
are no strings attached, no premium licenses or features, and no hidden agendas:
just a team who want to build something better and work together to achieve it.

# Troubleshooting

## Wrong image covers

Remove all the `jpg` files of the directory and then fetch again the data from
your favourite media management software.

## Green bars in the reproduction

It's related to some hardware transcoding issue related to some video codecs,
the solution is to either get a file with other codec, or convert it yourself
without the hardware transcoding with:

```bash
ffmpeg -i input.avi -c:v libx264 out.mp4
```

## [Stuck at login page](https://github.com/jellyfin/jellyfin-web/issues/2507)

Sometimes Jellyfin gets stuck at the login screen when trying to log in with an
endlessly spinning loading wheel. It looks like it's already fixed, so first try
to update to the latest version. If the error remains, follow the next steps:

To fix it run the next snippet:

```bash
systemctl stop jellyfin.service
mv /var/lib/jellyfin/data/jellyfin.db{,.bak}
systemctl start jellyfin.service
# Go to JF URL, get asked to log in even though
# there are no Users in the JF DB now
systemctl stop jellyfin.service
mv /var/lib/jellyfin/data/jellyfin.db{.bak,}
systemctl start jellyfin.service
```

If you use [jfa-go](https://github.com/hrfee/jfa-go) for the invites, you may
[need to regenerate all the user
profiles](https://github.com/hrfee/jfa-go/issues/101), so that the problem is
not introduced again.

# Issues

* Subtitles get delayed from the video on some devices:
    [1](https://github.com/jellyfin/jellyfin/issues/2547),
    [2](https://github.com/jellyfin/jellyfin-expo/issues/54),
    [3](https://github.com/jellyfin/jellyfin-web/issues/879). There is
    a [feature](https://features.jellyfin.org/posts/687/burn-in-srt-subtitles-when-transcoding-happens)
    request for a fix. Once it's solved notify the users
    once it's solved.

* [Trailers not
    working](https://github.com/crobibero/jellyfin-plugin-tmdb-trailers/issues/8):
    No solution until it's fixed

* [Unnecessary transcoding](https://github.com/jellyfin/jellyfin/issues/3277):
    nothing to do
* [Local social
    features](https://features.jellyfin.org/posts/349/local-social-features):
    test it and see how to share rating between users.
* [Skip
    intro/outro/credits](https://features.jellyfin.org/posts/45/chapter-based-skip-intro-outro-credits-feature):
    try it.
* [Music star rating](https://features.jellyfin.org/posts/9/music-star-rating):
    try it and plan to migrate everything to Jellyfin.
* [Remove pagination/use lazy
    loading](https://features.jellyfin.org/posts/216/remove-pagination-use-lazy-loading-for-library-view):
    try it.
* [Support
    2FA](https://features.jellyfin.org/posts/26/add-support-for-two-factor-authentication):
    try it.
* [Mysql server
    backend](https://features.jellyfin.org/posts/315/mysql-server-back-end):
    implement it to add robustness.
* [Watched history](https://features.jellyfin.org/posts/633/watched-history):
    try it.
* [A richer ePub
    reader](https://features.jellyfin.org/posts/792/a-richer-epub-reader-also-pdf-support):
    migrate from Polar and add jellyfin to the awesome selfhosted list.
* [Prometheus
    exporter](https://github.com/jellyfin/jellyfin/issues/3016):
    monitor it.
* [Easy Import/Export Jellyfin
    settings](https://features.jellyfin.org/posts/299/easy-import-export-jellyfin-settings):
    add to the backup process.
* [Temporary direct file sharing
    links](https://features.jellyfin.org/posts/72/temporary-direct-file-sharing-links):
    try it.
* [Remember subtitle and audio track choice between
    episodes](https://features.jellyfin.org/posts/194/remember-subtitle-and-audio-track-choice-between-episodes):
    try it.
* [IMBD Rating and Rotten Tomatoes Audiance Rating and Fresh rating on Movies and TV Shows](https://features.jellyfin.org/posts/463/imbd-rating-and-rotten-tomatoes-audiance-rating-and-fresh-rating-on-movies-and-tv-shows):
    try the new ratings.
* [Trailers
    Plugin](https://features.jellyfin.org/posts/299/easy-import-export-jellyfin-settings):
    Once it's merged to the core, remove the plugin.
* [Jellyfin for apple
    tv](https://features.jellyfin.org/posts/612/jellyfin-apple-tv-support): tell
    the people that use the shitty device.

# References

* [Home](https://jellyfin.org/)
* [Git](https://github.com/jellyfin/jellyfin)
* [Blog](https://jellyfin.org/posts/)([RSS](https://jellyfin.org/index.xml))
