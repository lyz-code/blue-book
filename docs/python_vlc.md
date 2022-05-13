---
title: Python VLC
date: 20211223
author: Lyz
---

[Python VLC](https://wiki.videolan.org/Python_bindings/) is a library to control
`vlc` from python.

There is not usable online documentation, you'll have to go through the
`help(<component>)` inside the python console.

# Installation

```bash
pip install python-vlc
```

# Usage

## Basic usage

You can create an instance of the `vlc` player with:

```python
import vlc

player = vlc.MediaPlayer('path/to/file.mp4')
```

The `player` has the next interesting methods:

* `play()`: Opens the program and starts playing, if you've used `pause` it
    resumes playing.
* `pause()`: Pauses the video
* `stop()`: Closes the player.
* `set_fulscreen(1)`: Sets to fullscreen if you pass `0` as argument it returns
    from fullscreen.
* `set_media(vlc.Media('path/to/another/file.mp4'))`: Change the reproduced
    file. It can even play pictures!

If you want more control, it's better to use an `vlc.Instance` object to work
with.

## [Configure the instance](https://stackoverflow.com/questions/56103533/how-can-i-control-vlc-media-player-through-a-python-scripte)

```python
instance = Instance('--loop')
```

## [Reproduce many files](https://stackoverflow.com/questions/56103533/how-can-i-control-vlc-media-player-through-a-python-scripte)

First you need to create a media list:

```python
media_list = instance.media_list_new()
path = "/path/to/directory"
files = os.listdir(path)
for file_ in files:
    media_list.add_media(instance.media_new(os.path.join(path,s)))
```

Then create the player:

```python
media_player = instance.media_list_player_new()
media_player.set_media_list(media_list)
```

Now you can use `player.next()` and `player.previous()`.

### Set playback mode

```python
media_player.set_playback_mode(vlc.PlaybackMode.loop)
```

There are the next playback modes:

* `default`
* `loop`
* `repeat`

# References

* [Home](https://wiki.videolan.org/Python_bindings/)
* [Source](https://git.videolan.org/?p=vlc/bindings/python.git;a=summary)
