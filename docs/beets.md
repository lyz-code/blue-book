---
title: Beets
date: 20210413
author: Lyz
---

[Beets](https://beets.io/) is a music management library used to get your music
collection right once and for all. It catalogs your collection, automatically
improving its metadata as it goes using the MusicBrainz database. Then it
provides a set of tools for manipulating and accessing your music.

Through plugins it supports:

* Fetch or calculate all the metadata you could possibly need: album art,
    lyrics, genres, tempos,
    [ReplayGain](https://beets.readthedocs.io/en/stable/plugins/replaygain.html)
    levels, or acoustic fingerprints.
* Get metadata from MusicBrainz, Discogs, or Beatport. Or guess metadata using
    songs’ filenames or their acoustic fingerprints.
* Transcode audio to any format you like.
* Check your library for duplicate tracks and albums or for albums that are
    missing tracks.
* Browse your music library graphically through a Web browser and play it in any
    browser that supports HTML5 Audio.

Still, if beets doesn't do what you want yet, [writing your own
plugin](http://beets.readthedocs.org/page/dev/plugins.html) is easy if you
know a little Python. Or you can use it as
a [library](https://beets.readthedocs.io/en/stable/dev/api.html).

# [Installation](https://beets.readthedocs.io/en/stable/guides/main.html#installing)

```bash
pipx install beets
```

You’ll want to set a few basic options before you start using beets. The [configuration](https://beets.readthedocs.io/en/stable/reference/config.html) is stored in a text file. You can show its location by running `beet config -p`, though it may not exist yet. Run `beet config -e` to edit the configuration in your favorite text editor. The file will start out empty, but here’s good place to start:

```yaml
# Path to a directory where you’d like to keep your music.
directory: ~/music

# Database file that keeps an index of your music.
library: ~/data/musiclibrary.db
```

The default configuration assumes you want to start a new organized music folder (that directory above) and that you’ll copy cleaned-up music into that empty folder using beets’ `import` command. But you can configure beets to behave many other ways:

- Start with a new empty directory, but move new music in instead of copying it (saving disk space). Put this in your config file:

    ```yaml
    import:
        move: yes
    ```

- Keep your current directory structure; importing should never move or copy files but instead just correct the tags on music. Put the line `copy: no` under the `import:` heading in your config file to disable any copying or renaming. Make sure to point `directory` at the place where your music is currently stored.

- Keep your current directory structure and do not correct files’ tags: leave files completely unmodified on your disk. (Corrected tags will still be stored in beets’ database, and you can use them to do renaming or tag changes later.) Put this in your config file:

    ```yaml
    import:
        copy: no
        write: no
    ```

    to disable renaming and tag-writing.

# Usage

## [Importing your library](https://beets.readthedocs.io/en/stable/guides/main.html#importing-your-library)

The next step is to import your music files into the beets library database. Because this can involve modifying files and moving them around, data loss is always a possibility, so now would be a good time to make sure you have a recent backup of all your music. We’ll wait.

There are two good ways to bring your existing library into beets. You can either: (a) quickly bring all your files with all their current metadata into beets’ database, or (b) use beets’ highly-refined autotagger to find canonical metadata for every album you import. Option (a) is really fast, but option (b) makes sure all your songs’ tags are exactly right from the get-go. The point about speed bears repeating: using the autotagger on a large library can take a very long time, and it’s an interactive process. So set aside a good chunk of time if you’re going to go that route.

If you’ve got time and want to tag all your music right once and for all, do this:

```bash
$ beet import /path/to/my/music
```

(Note that by default, this command will copy music into the directory you specified above. If you want to use your current directory structure, set the import.copy config option.) To take the fast, un-autotagged path, just say:

```bash
$ beet import -A /my/huge/mp3/library
```

Note that you just need to add `-A` for “don’t autotag”.

# References

* [Git](https://github.com/beetbox/beets)
* [Docs](https://beets.readthedocs.io/en/stable/guides/main.html)
* [Homepage](https://beets.io/)
