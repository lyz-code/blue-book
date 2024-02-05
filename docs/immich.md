
Self-hosted photo and video backup solution directly from your mobile phone. 

# [Installation](https://immich.app/docs/install/docker-compose/)

- Create a directory of your choice (e.g. `./immich-app`) to hold the `docker-compose.yml` and `.env` files.

  ```bash
  mkdir ./immich-app
  cd ./immich-app
  ```

- Download `docker-compose.yml`, `example.env` and optionally the `hwaccel.yml` files:

  ```bash
  wget -O docker-compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
  wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
  wget https://github.com/immich-app/immich/releases/latest/download/hwaccel.yml
  ```
- Tweak those files with these thoughts in mind:
  - `immich` won't respect your upload media directory structure, so until you trust the software copy your media to the uploads directory.
  - immich is not stable so you need to disable the upgrade from watchtower. The easiest way is to [pin the latest stable version](https://github.com/immich-app/immich/pkgs/container/immich-server/versions?filters%5Bversion_type%5D=tagged) in the `.env` file.
  - Populate custom database information if necessary.
  - Populate `UPLOAD_LOCATION` with your preferred location for storing backup assets.
  - Consider changing `DB_PASSWORD` to something randomly generated

- From the directory you created in Step 1, (which should now contain your customized `docker-compose.yml` and `.env` files) run:

  ```bash
  docker compose up -d
  ```

## [Configure smart search for other language](https://immich.app/docs/FAQ#i-want-to-be-able-to-search-in-other-languages-besides-english-how-can-i-do-that)

You can change to a multilingual model listed [here](https://huggingface.co/collections/immich-app/multilingual-clip-654eb08c2382f591eeb8c2a7) by going to Administration > Machine Learning Settings > Smart Search and replacing the name of the model. 

Choose the one that has more downloads. For example, if you'd want the `
immich-app/XLM-Roberta-Large-Vit-B-16Plus` model, you should only enter `XLM-Roberta-Large-Vit-B-16Plus` in the program configuration. Be careful not to add trailing whitespaces.

Be sure to re-run Smart Search on all assets after this change. You can then search in over 100 languages.

## [External storage](https://immich.app/docs/guides/external-library)

If you have an already existing library somewhere immich is installed you can use an [external library](https://immich.app/docs/guides/external-library). Immich will respect the files on that directory.

It won't create albums from the directory structure. If you want to do that check [this](https://github.com/alvistar/immich-albums) or [this](https://gist.github.com/REDVM/d8b3830b2802db881f5b59033cf35702) solutions.

## My personal workflow

I've tailored a personal workflow given the next thoughts:

- I don't want to expose Immich to the world, at least until it's a stable product. 
- I already have in place a sync mechanism with [syncthing](syncthing.md) for all the mobile stuff
- I do want to still be able to share some albums with my friends and family.
- I want some mobile directories to be cleaned after importing the data (for example the `camera/DCIM`), but others should leave the files as they are after the import (OsmAnd+ notes).

### Ingesting the files

As all the files I want to ingest are sent to the server through syncthing, I've created a cron script that copies or moves the required files. Something like:

```bash
#!/bin/bash

date
echo 'Updating the OsmAnd+ data'
rsync -auhvEX --progress /data/apps/syncthing/data/Osmand/avnotes /data/media/pictures/unclassified

echo 'Updating the Camera data'
mv /data/apps/syncthing/data/camera/Camera/* /data/media/pictures/unclassified/

echo 'Cleaning laptop home'
mv /data/media/downloads/*jpeg /data/media/downloads/*jpg /data/media/downloads/*png /data/media/pictures/unclassified/
echo
```

Where :

- `/data/media/pictures/unclassified` is a subpath of my [external library](#external-library). 
- The last echo makes sure that the program exits with a return code of `0`. The script is improbable as it only takes into account the happy path, and I'll silently miss errors on it's execution. But as a first iteration it will do the job.

Then run the script in a cron and log the output to [`journald`](journald.md):

```cron
0 0 * * * /bin/bash /usr/local/bin/archive-photos.sh | /usr/bin/logger -t archive_fotos
```

Make sure to configure the update library cron job to run after this script has ended.

### Sharing content

# Not there yet

There are some features that are still lacking:

- [Image rotation](https://github.com/immich-app/immich/discussions/1695)
- [Smart albums](https://github.com/immich-app/immich/discussions/1673)
- [Image rating](https://github.com/immich-app/immich/discussions/3619)
- [Tags](https://github.com/immich-app/immich/discussions/1651)
- [Nested albums](https://github.com/immich-app/immich/discussions/2073#discussioncomment-6584926)
- [Duplication management](https://github.com/immich-app/immich/discussions/1968)
- [Search guide](https://github.com/immich-app/immich/discussions/3657)

# Troubleshooting

## Edit an image metadata

You can't do it directly through the interface yet, use [exiftool](linux_snippets.md#Remove-image-metadata) instead.

This is interesting to remove the geolocation of the images that are not yours
# References

- [Home](https://immich.app/)
- [Api](https://immich.app/docs/api)
- [Docs](https://immich.app/docs/overview/introduction)
- [Source](https://github.com/immich-app/immich).
- [Blog](https://immich.app/blog)
- [Demo](https://demo.immich.app/photos) 
