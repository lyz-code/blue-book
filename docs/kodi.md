
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

At `~/.kodi/userdata/Database/MyVideos116.db` you can extract the data from the next tables:

- In the `movie_view` table there is:
  - `idMovie`: kodi id for the movie
  - `c00`: Movie title
  - `userrating`
  - `uniqueid_value`: The id of the external web service
  - `uniqueid_type`: The web it extracts the id from
  - `lastPlayed`: The reproduction date
- In the `tvshow_view` table there is:
  - `idShow`: kodi id of a show
  - `c00`: title
  - `userrating`
  - `lastPlayed`: The reproduction date
  - `uniqueid_value`: The id of the external web service
  - `uniqueid_type`: The web it extracts the id from
- In the `season_view` there is no interesting data as the userrating is null on all rows.
- In the `episode_view` table there is:
  - `idEpisodie`: kodi id for the episode
  - `idShow`: kodi id of a show
  - `idSeason: kodi id of a season
  - `c00`: title
  - `userrating`
  - `lastPlayed`: The reproduction date
  - `uniqueid_value`: The id of the external web service
  - `uniqueid_type`: The web it extracts the id from. I've seen mainly tvdb and sonarr
- Don't use the `rating` table as it only stores the ratings from external webs such as themoviedb:

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
