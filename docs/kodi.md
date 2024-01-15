
[Kodi](https://kodi.tv/) is a entertainment center software. It basically converts your device into a smart tv

# [Installation](https://kodi.wiki/view/HOW-TO:Install_Kodi_for_Linux)

If you're trying to install it on Debian based distros (not ubuntu) check [the official docs](https://kodi.wiki/view/HOW-TO:Install_Kodi_for_Linux#Debian)

```bash
sudo apt install software-properties-common
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt install kodi
```

# Extract the user browsing data

## From the database

At `~/.kodi/

```
+-----------+----------+------------+-------------+--------+-------+
| rating_id | media_id | media_type | rating_type | rating | votes |
+-----------+----------+------------+-------------+--------+-------+
| 1         | 1        | movie      | default     | 6.4    | 339   |
+-----------+----------+------------+-------------+--------+-------+
```

# Troubleshooting

## [Movie not recognized by kodi](https://kodi.wiki/view/Incorrect_and_missing_videos)

Add your own .nfo file with the metadata

## Import data from nfo files

If the nfo is separated on each movie, you have to remove it from the library
and import it again, as the scanning doesn't import the data from the nfos.

## TV show file naming

[The correct TV show file naming](https://kodi.wiki/view/Naming_video_files/TV_shows)

# References

- [Home](https://kodi.tv/)
