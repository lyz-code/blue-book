---
title: ffmpeg
date: 20210406
author: Lyz
---

[ffmpeg](https://www.ffmpeg.org/) is a complete, cross-platform solution to
record, convert and stream audio and video

You can run `ffmpeg -formats` to get a list of every format that is supported.

# Cut

## Cut video file into a shorter clip

You can use the time offset parameter `-ss` to specify the start time stamp in
`HH:MM:SS.ms` format while the `-t` parameter is for specifying the actual
duration of the clip in seconds.

```bash
ffmpeg -i input.mp4 -ss 00:00:50.0 -codec copy -t 20 output.mp4
```

## Split a video into multiple parts

The next command will split the source video into 2 parts. One ending at 50s
from the start and the other beginning at 50s and ending at the end of the input
video.

```bash
ffmpeg -i video.mp4 -t 00:00:50 -c copy small-1.mp4 -ss 00:00:50 -codec copy small-2.mp4
```

## Crop an audio file

To create a 30 second audio file starting at 90 seconds from the original
audio file without transcoding use:

```bash
ffmpeg -ss 00:01:30 -t 30 -acodec copy -i inputfile.mp3 outputfile.mp3
```

# Join

## Join (concatenate) video files

If you have multiple audio or video files encoded with the same codecs, you can
join them into a single file. Create a input file with a list of
all source files that you wish to concatenate and then run this command.

Create first the file list with a Bash for loop:

```bash
for f in ./*.wav; do echo "file '$f'" >> mylist.txt; done
```

Then convert

```bash
ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4
```

## Merge an audio and video file

You can also specify the -shortest switch to finish the encoding when the
shortest clip ends.

```bash
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -strict experimental output.mp4
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -strict experimental -shortest output.mp4
```

# Mute

Use the `-an` parameter to disable the audio portion of a video stream.

```bash
ffmpeg -i video.mp4 -an mute-video.mp4
```

# Convert

## Convert video from one format to another

You can use the `-vcodec` parameter to specify the encoding format to be used for
the output video. Encoding a video takes time but you can speed up the process
by forcing a preset though it would degrade the quality of the output video.

```bash
ffmpeg -i youtube.flv -c:v libx264 filename.mp4
ffmpeg -i video.wmv -c:v libx264 -preset ultrafast video.mp4

```

### [Convert a x265 file into x264](https://askubuntu.com/questions/707397/batch-convert-h-265-mkv-to-h-264-with-ffmpeg-to-make-files-compatible-for-re-enc)

```bash
for i in *.mkv ; do
    ffmpeg -i "$i" -bsf:v h264_mp4toannexb -vcodec libx264 "$i.x264.mkv"
done
```

* `ffmpeg -i "$i"`: Executes the program ffmpeg and calls for files to be
    processed.
* `-bsf:v`: Activates the video bit stream filter to be used.
* `h264_mp4toannexb`: Is the bit stream filter that is activated.
    Convert an H.264 bitstream from length prefixed mode to start code prefixed
    mode (as defined in the Annex B of the ITU-T H.264 specification).

    This is required by some streaming formats, typically the MPEG-2 transport
    stream format (mpegts) processing MKV h.264 (currently)requires this, if is
    not included you will get an error in the terminal window instructing you to
    use it.
* `-vcodec libx264` This tells ffmpeg to encode the output to H.264.
* `"$i.ts"` Saves the output to .ts format, this is useful so as not to
    overwrite your source files.

### [Convert VOB to mkv](https://www.internalpointers.com/post/convert-vob-files-mkv-ffmpeg)

* Unify your VOBs
    ```bash
    cat *.VOB > output.vob
    ```

* Identify the streams

    ```bash
    ffmpeg -analyzeduration 100M -probesize 100M -i output.vob
    ```

    Select the streams that you are interested in, imagine that is 1, 3, 4,
    5 and 6.

* Encoding

    ```bash
    ffmpeg \
      -analyzeduration 100M -probesize 100M \
      -i output.vob \
      -map 0:1 -map 0:3 -map 0:4 -map 0:5 -map 0:6 \
      -metadata:s:a:0 language=ita -metadata:s:a:0 title="Italian stereo" \
      -metadata:s:a:1 language=eng -metadata:s:a:1 title="English stereo" \
      -metadata:s:s:0 language=ita -metadata:s:s:0 title="Italian" \
      -metadata:s:s:1 language=eng -metadata:s:s:1 title="English" \
      -codec:v libx264 -crf 21 \
      -codec:a libmp3lame -qscale:a 2 \
      -codec:s copy \
      output.mkv
    ```


## [Convert a video into animated GIF](https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality)

```bash
ffmpeg -ss 30 -t 3 -i input.mp4 -vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif
```

* This example will skip the first 30 seconds (-ss 30) of the input and create
    a 3 second output (-t 3).
* fps filter sets the frame rate. A rate of 10 frames per second is used in the
    example.
* Scale filter will resize the output to 320 pixels wide and automatically
    determine the height while preserving the aspect ratio. The lanczos scaling
    algorithm is used in this example.
* Palettegen and paletteuse filters will generate and use a custom palette
    generated from your input. These filters have many options, so refer to the
    links for a list of all available options and values. Also see the Advanced
    options section below.
* Split filter will allow everything to be done in one command and avoids having
    to create a temporary PNG file of the palette.
* Control looping with -loop output option but the values are confusing. A value
    of 0 is infinite looping, -1 is no looping, and 1 will loop once meaning it
    will play twice. So a value of 10 will cause the GIF to play 11 times.

## Convert video into images

You can use FFmpeg to automatically extract image frames from a video every `n`
seconds and the images are saved in a sequence. This command saves image frame
after every 4 seconds.

```bash
ffmpeg -i movie.mp4 -r 0.25 frames_%04d.png
```

## Convert a single image into a video

Use the `-t` parameter to specify the duration of the video.

```bash
ffmpeg -loop 1 -i image.png -c:v libx264 -t 30 -pix_fmt yuv420p video.mp4
```

## [Convert opus or wav to mp3](https://stackoverflow.com/questions/3255674/convert-audio-files-to-mp3-using-ffmpeg)

```bash
ffmpeg -i input.wav -vn -ar 44100 -ac 2 -b:a 320k output.mp3
```

* `-i`: input file.
* `-vn`: Disable video, to make sure no video (including album cover image) is
    included if the source would be a video file.
* `-ar`: Set the audio sampling frequency. For output streams it is set by
    default to the frequency of the corresponding input stream. For input
    streams this option only makes sense for audio grabbing devices and raw
    demuxers and is mapped to the corresponding demuxer options.
* `-ac`: Set the number of audio channels. For output streams it is set by
    default to the number of input audio channels. For input streams this option
    only makes sense for audio grabbing devices and raw demuxers and is mapped
    to the corresponding demuxer options. So used here to make sure it is stereo
    (2 channels).
* `-b:a`: Converts the audio bitrate to be exact 320kbit per second.

# Extract

## Extract the audio from video

The `-vn` switch extracts the audio portion from a video and we are using the
`-ab` switch to save the audio as a 256kbps MP3 audio file.

```bash
ffmpeg -i video.mp4 -vn -ab 256 audio.mp3
```

## Extract image frames from a video

This command will extract the video frame at the 15s mark and saves it as
a 800px wide JPEG image. You can also use the -s switch (like -s 400×300) to
specify the exact dimensions of the image file though it will probably create
a stretched image if the image size doesn’t follow the aspect ratio of the
original video file.

```bash
ffmpeg -ss 00:00:15 -i video.mp4 -vf scale=800:-1 -vframes 1 image.jpg
```

## Extract metadata of video

```bash
ffprobe {{ file }}
```

# Resize

## Resize a video

### [Change the Constat Rate Factor](https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg)

Setting the Constant Rate Factor, which lowers the average bit rate, but retains
better quality. Vary the CRF between around 18 and 24 — the lower, the higher
the bitrate.

```bash
ffmpeg -i input.mp4 -vcodec libx265 -crf 24 output.mp4
```

Change the codec as needed - libx264 may be available if libx265 is not, at the
cost of a slightly larger resultant file size.

### Change video resolution

Use the size `-s` switch with ffmpeg to resize a video while maintaining the
aspect ratio.

```bash
ffmpeg -i input.mp4 -s 480x320 -c:a copy output.mp4
```

# Presentation

## Create video slideshow from images

This command creates a video slideshow using a series of images that are named
as `img001.png`, `img002.png`, etc. Each image will have a duration of 5 seconds (-r
1/5).

```bash
ffmpeg -r 1/5 -i img%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p slideshow.mp4
```

## Add a poster image to audio

You can add a cover image to an audio file and the length of the output video
will be the same as that of the input audio stream. This may come handy for
uploading MP3s to YouTube.

```bash
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -c:v libx264 -c:a aac -strict experimental -b:a 192k -shortest output.mp4
```

## Add subtitles to a movie

This will take the subtitles from the `.srt` file. FFmpeg can decode most common
subtitle formats.

```bash
ffmpeg -i movie.mp4 -i subtitles.srt -map 0 -map 1 -c copy -c:v libx264 -crf 23 -preset veryfast output.mkv
```

## Change the audio volume

You can use the volume filter to alter the volume of a media file using FFmpeg.
This command will half the volume of the audio file.

```bash
ffmpeg -i input.wav -af 'volume=0.5' output.wav
```

## Rotate a video

This command will rotate a video clip 90° clockwise. You can set transpose to
2 to rotate the video 90° anti-clockwise.

```bash
ffmpeg -i input.mp4 -filter:v 'transpose=1' rotated-video.mp4
```

This will rotate the video 180° counter-clockwise.

```bash
ffmpeg -i input.mp4 -filter:v 'transpose=2,transpose=2' rotated-video.mp4
```

## Speed up or Slow down the video

You can change the speed of your video using the setpts (set presentation time
stamp) filter of FFmpeg. This command will make the video 8x (1/8) faster or use
setpts=4*PTS to make the video 4x slower.

```bash
ffmpeg -i input.mp4 -filter:v "setpts=0.125*PTS" output.mp4
```

## Speed up or Slow down the audio


For changing the speed of audio, use the atempo audio filter. This command will
double the speed of audio. You can use any value between 0.5 and 2.0 for audio.

 ```bash
ffmpeg -i input.mkv -filter:a "atempo=2.0" -vn output.mkv
```

Stack Exchange has a good overview to get you started with FFmpeg. You should
also check out the official documentation at ffmpeg.org or the wiki at
trac.ffmpeg.org to know about all the possible things you can do with FFmpeg.

# References

* [Home](https://www.ffmpeg.org/)
