
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

# Troubleshooting

## [Create albums from a directory structure using external library](https://github.com/immich-app/immich/discussions/4279)

As it's not yet supported alvistar has created [`immich-albums`](https://github.com/alvistar/immich-albums)

Immich Albums is a tool designed to create albums in Immich from a folder structure. Assets needs to be loaded as external library in Immich then you can launch script to create albums.
### [Installation](https://github.com/alvistar/immich-albums?tab=readme-ov-file#installation)
- Clone the repository:

  ```bash
  git clone https://github.com/alvistar/immich-albums.git
  ```

- Navigate to the project directory:

  ```bash
  cd immich-albums
  ```

- Install dependencies:

  ```bash
  poetry install
  ```

- Activate virtual environment:

```bash
 poetry shell
```

- Test installation:

  ```bash
  im --help
  ```
### [Usage](https://github.com/alvistar/immich-albums?tab=readme-ov-file#usage)


The following are required arguments:

- `--api-key`: Immich API key
- `--api-host`: Immich API host. Example: https://localhost:22283/api
- `--original-path`: Path to local albums
- `--replace-path`: Path as seen by Immich host

Original path is the path to your local albums. If for example your albums are stored in `/home/user/albums` and you mounted that path under docker as `/mnt/albums` you need to pass `/home/user/albums` as `--original-path` and `/mnt/albums` as `--replace-path`.

Note

Api host should be the API endpoint of your Immich instance.

Example: https://localhost:22283/api

cd /home/user/albums
im --api-key YOUR_API_KEY --api-host YOUR_API_HOST --original-path /home/user/albums --replace-path /mnt/albums .

## Edit an image metadata

You can't do it directly through the interface yet, use [exiftool](linux_snippets.md#Remove-image-metadata) instead.

This is interesting to remove the geolocation of the images that are not yours

## [Fix a file date on a external library](https://immich.app/docs/features/libraries/#external-libraries)

You can change the dates directly by `touching` the file.

```bash 
touch -d YYYYMMDD path/to/file
```
If a file is modified outside of Immich, the changes will not be reflected in immich until the library is scanned again. There are different ways to scan a library depending on the use case:

- Scan Library Files: This is the default scan method and also the quickest. It will scan all files in the library and add new files to the library. It will notice if any files are missing (see below) but not check existing assets
- Scan All Library Files: Same as above, but will check each existing asset to see if the modification time has changed. If it has, the asset will be updated. Since it has to check each asset, this is slower than Scan Library Files.
- Force Scan All Library Files: Same as above, but will read each asset from disk no matter the modification time. This is useful in some cases where an asset has been modified externally but the modification time has not changed. This is the slowest way to scan because it reads each asset from disk.

Due to aggressive caching it can take some time for a refreshed asset to appear correctly in the web view. You need to clear the cache in your browser to see the changes. This is a known issue and will be fixed in a future release. In Chrome, you need to open the developer console with F12, then reload the page with F5, and finally right click on the reload button and select "Empty Cache and Hard Reload".

In my case I had to see in which albums I added the files that were of the date `2023-07-02` so I used this command to build the `touch -d` iterative command.

```python
import requests
import os


base_url = "https://your-server.org/api"
directory = "directory/to/correct"
original_path = "/server/path/for/external/library/"
replace_path = "/docker/path/for/external/library"
albums = {}

payload = {}
headers = {
    "Accept": "application/json",
    "Cookie": "XXXX",
}

def get_asset_by_original_path(path):
    response = requests.request(
        "GET", f"{base_url}/assets?originalPath={path}", headers=headers, data=payload
    )
    return response.json()[0]


for filename in os.listdir(f"{original_path}/{directory}"):
    full_path = f"{original_path}/{directory}/{filename}"
    if os.path.isfile(full_path):
        replaced_path = full_path.replace(original_path, replace_path)
        # print(f"searching for: {replaced_path}")
        asset = get_asset_by_original_path(replaced_path)
        asset_id = asset["id"]
        if asset_id is not None:
            if "2023-07-02" in asset["fileCreatedAt"]:
                # print("Bad date")
                album_data = requests.request(
                    "GET",
                    f"{base_url}/album?assetId={asset_id}",
                    headers=headers,
                    data=payload,
                ).json()
                for album in [album["albumName"] for album in album_data]:
                    albums.setdefault(album, [])
                    albums[album].append(f"'{filename}'")


for album, archives in albums.items():
    print(f'{album}: {" ".join(archives)}')
__import__("pdb").set_trace()
```


# Not there yet

There are some features that are still lacking:

- Better album management: Right now only the owner can edit an album
  - [Collaborative albums](https://github.com/immich-app/immich/discussions/5649): That let different users edit the album
  - [User groups for sharing/permissions](https://github.com/immich-app/immich/discussions/1633)
  - [Adding to shared album](https://github.com/immich-app/immich/discussions/920)
  - [Tidy up sharing](https://github.com/immich-app/immich/discussions/6335)
  - [Reshare photos](https://github.com/immich-app/immich/discussions/5643)
  - [Implement shared photos to show under main Photos](https://github.com/immich-app/immich/discussions/5013#discussion-5847421)
  - [Add possibility to import pictures from a partner to our library ](https://github.com/immich-app/immich/discussions/5359)
  - [Add to Library](https://github.com/immich-app/immich/discussions/1587)
  - [A new approach on sharing photos](https://github.com/immich-app/immich/discussions/3273)
  - [allow use of explore features for shared albums](https://github.com/immich-app/immich/discussions/3176)
  - [Option to allow guests to modify description and or tags](https://github.com/immich-app/immich/discussions/3990)
- [Image rotation](https://github.com/immich-app/immich/discussions/1695)
- [Smart albums](https://github.com/immich-app/immich/discussions/1673)
- [Image rating](https://github.com/immich-app/immich/discussions/3619)
- [Tags](https://github.com/immich-app/immich/discussions/1651)
- [Nested albums](https://github.com/immich-app/immich/discussions/2073#discussioncomment-6584926)
- [Duplication management](https://github.com/immich-app/immich/discussions/1968)
- [Search guide](https://github.com/immich-app/immich/discussions/3657)
- [Seeing shared assets into your timeline](https://github.com/immich-app/immich/discussions/3984)
- [Be notified when pictures are added in album](https://github.com/immich-app/immich/discussions/1671)
- [Person sharing](https://github.com/immich-app/immich/discussions/6755)

# References

- [Home](https://immich.app/)
- [Api](https://immich.app/docs/api)
- [Docs](https://immich.app/docs/overview/introduction)
- [Source](https://github.com/immich-app/immich).
- [Blog](https://immich.app/blog)
- [Demo](https://demo.immich.app/photos) 
