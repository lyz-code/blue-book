[MediaTracker](https://github.com/bonukai/MediaTracker) is a self hosted media tracker for movies, tv shows, video games, books and audiobooks 

# [Installation](https://github.com/bonukai/MediaTracker#installation)

With docker compose:

```yaml
version: "3"
services:
  mediatracker:
    container_name: mediatracker
    ports:
      - 7481:7481
    volumes:
      - /home/YOUR_HOME_DIRECTORY/.config/mediatracker/data:/storage
      - assetsVolume:/assets
    environment:
      SERVER_LANG: en
      TMDB_LANG: en
      AUDIBLE_LANG: us
      TZ: Europe/London
    image: bonukai/mediatracker:latest

volumes:
  assetsVolume: null
```

If you attach more than one docker network the container becomes unreachable :S.

## Install the jellyfin plugin

They created a [Jellyfin plugin](https://github.com/bonukai/jellyfin-plugin-mediatracker) so that all scrobs are sent automatically to the mediatracker

- Add new Repository in Jellyfin (Dashboard -> Plugins -> Repositories -> +) from url `https://raw.githubusercontent.com/bonukai/jellyfin-plugin-mediatracker/main/manifest.json`
- Install MediaTracker plugin from Catalogue (Dashboard -> Plugins -> Catalogue)

# Usage

Some tips:

- Add the shows you want to watch to the watchlist so that it's easier to find them
- When you're ending an episode, click on the episode number on the watchlist element and then rate the episode itself.

## Lists

You can create public lists to share with the rest of the users, the way to share it though [is a bit archaic so far](https://github.com/bonukai/MediaTracker/issues/527), it's only through the list link, in the interface they won't be able to see it.

## API

I haven't found a way to see the api docs from my own instance. Luckily you can browse it [at the official instance](https://bonukai.github.io/MediaTracker/).

You can create an application token on your user configuration. Then you can use it with something similar to:

```bash
curl -s -H 'Content-Type: application/json' https://mediatracker.your-domain.org/api/logs\?token\=your-token | jq
```

There is a [python library](https://github.com/jonkristian/pymediatracker) although it's doesn't (yet) have any documentation and the functionality so far is only to get information, not to push changes.

### Get list of tv shows

With `/api/items?mediaType=tv` you can get a list of all tv shows with the next interesting fields:

- `id`: mediatracker id
- `tmdbId`:
- `tvdbId`:
- `imdbId`:
- `title`: 
- `lastTimeUpdated`: epoch time
- `lastSeenAt`: epoch time
- `seen`: bool
- `onWatchlist`: bool
- `firstUnwatchedEpisode`:
  - `id`: mediatracker episode id
  - `episodeNumber`:
  - `seasonNumber`
  - `tvShowId`:
  - `seasonId`:
- `lastAiredEpisode`: same schema as before

Then you can use the `api/details/{mediaItemId}` endpoint to get all the information of all the episodes of each tv show.

# Alternatives

[Ryot](https://github.com/IgnisDa/ryot) has a better web design, it also has a [jellyfin scrobbler](https://github.com/IgnisDa/ryot/pull/195), although it's not [yet stable](https://github.com/IgnisDa/ryot/issues/187). There are other UI tweaks that is preventing me from migrating to ryot such as [the easier media rating](https://github.com/IgnisDa/ryot/issues/284) and [the percentage over five starts rating system](https://github.com/IgnisDa/ryot/issues/283).

# References

- [Source](https://github.com/bonukai/MediaTracker)
- [Issues](https://github.com/bonukai/MediaTracker/issues)
- [Python library](https://github.com/jonkristian/pymediatracker)
