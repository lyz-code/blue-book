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

## Corrupt: SQLitePCL.pretty.SQLiteException: database disk image is malformed

If your server log file shows SQLite errors like the following example your jellyfin.db file needs attention.

```
'SQLitePCL.pretty.SQLiteException'
```

Typical causes of this are sudden and abrupt terminations of the Emby server process, such as a power loss, operating system crash, force killing the server process, etc.

### [Solutions to Try in This Order](https://support.emby.media/support/solutions/articles/44002210894-corrupt-database)

#### Remove Database Locks

1. Shutdown Jellyfin
2. Navigate to the folder containing your database file
3. Delete `library.db-shm` and `library.db-wal`
4. Restart Jellyfin

Check you server log for SQLite errors and only continue to the next step if needed.

#### Check Database Integrity and Recover Database

This step will require the use of a SQLite editor, I recommend `litecli` installable with `pip`.

##### Run Integrity Check

Open the library.db database and run the following SQL command:

```
PRAGMA integrity_check
```

This should return an `integrity_check` back of `OK` with no errors reported. If errors are reported we need to recover the database.

##### Recover library.db

What we need to do is: 

* Dump all data from the database to a text file and then reload this back to another freshly created database. Run the following command line:

  ```bash
  sqlite3 library.db ".recover" | sqlite3 library-recovered.db
  ```

  `sqlite3` can be installed with `apt-get install sqlite3`.

* We will now check the integrity of our recovered database (as above) using:

  ```bash
  sqlite3 library-recovered.db "PRAGMA integrity_check"
  ```

  This should return an `integrity_check` back of "OK" with no errors reported. If errors are reported please report this in the jellyfin issues before proceeding to Reset the Library Database. If OK and no errors are reported continue with the next step.

* Make a copy of both `library.db` and `library-recovered.db`
  
  ```bash
  mkdir broken-dbs
  cp library* broken-dbs
  ```

* Rename `library.db` to library.old
  
  ```bash
  mv library.db library.old
  ```

* Rename library-recoved.db to library.db

  ```bash
  mv library-recovered.db library.db
  ```

* Restart Jellyfin Server

  ```bash
  service jellyfin stop
  service jellyfin start
  ```

Check you server log for SQLite errors and only continue to the next step if needed.

#### Reset Library Database & Load Fresh

* Shutdown Jellyfin
* Do a copy of all your databases, copy the parent directory where your `.db` files are to `bk.data`
* Rename `library.db` to `library.corrupt`
* Restart Jellyfin
* Run a Full Library Scan

#### Move all the journal databases away

Finally I moved all the '*-journal' files to a directory, copied again the `library-recovered.db` to `library.db`, started the server, do a full scan.

### Check the watched history

Last time I followed these steps I lost part of the visualization history for the users (yikes!). So check that everything is alright.

If it's not follow [these steps](#restore-watched-history)

## Restore watched history

Jellyfin stores the watched information in one of the `.db` files, there are two ways to restore it:

* Using scripts that interact with the API like [`jelly-jar`](https://github.com/mueslimak3r/jelly-jar) or [`jellyfin-backup-watched`](https://github.com/jab416171/jellyfin-backup-watched)
* Running sqlite queries on the database itself.

The user data is stored in the table `UserDatas` table in the `library.db` database file. The media data is stored in the `TypedBaseItems` table of the same database. 

Comparing the contents of the tables of the broken database (lost watched content) and a backup database, I've seen that the media content is the same after a full library rescan, so the issue was fixed after injecting the missing user data from the backup to the working database through the [importing a table from another database](sqlite.md#import-a-table-from-another-database) sqlite operation.

## ReadOnly: SQLitePCL.pretty.SQLiteException: attempt to write a readonly database

Some of the database files of Jellyfin is not writable by the jellyfin user, check if you changed the ownership of the files, for example in the process of restoring a database file from backup.

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
