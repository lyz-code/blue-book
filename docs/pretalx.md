NOTE: it's probably too much for a small event. The inter

# Import a pretalx calendar in giggity

Search the url similar to https://pretalx.com/<conference-name>/schedule/export/schedule.xml

# Install


## [Docker compose](https://github.com/pretalx/pretalx-docker)

[The default docker compose doesn't work](https://github.com/pretalx/pretalx-docker/issues/75) as it still uses [mysql which was dropped](https://pretalx.com/p/news/releasing-pretalx-2024-3-0/). If you want to use sqlite just remove the database configuration.

```yam
---
services:
  pretalx:
    image: pretalx/standalone:v2024.3.0
    container_name: pretalx
    restart: unless-stopped
    depends_on:
      - redis
    environment:
      # Hint: Make sure you serve all requests for the `/static/` and `/media/` paths when debug is False. See [installation](https://docs.pretalx.org/administrator/installation/#step-7-ssl) for more information
      PRETALX_FILESYSTEM_MEDIA: /public/media
      PRETALX_FILESYSTEM_STATIC: /public/static
    ports:
      - "127.0.0.1:80:80"
    volumes:
      - ./conf/pretalx.cfg:/etc/pretalx/pretalx.cfg:ro
      - pretalx-data:/data
      - pretalx-public:/public

  redis:
    image: redis:latest
    container_name: pretalx-redis
    restart: unless-stopped
    volumes:
      - pretalx-redis:/data

volumes:
  pretalx-data:
  pretalx-public:
  pretalx-redis:
```

I was not able to find the default admin user so I had to create it manually. Get into the docker:

```bash
docker exec -it pretalx bash
```

When you run the commands by default it uses another database file `/pretalx/src/data/db.sqlite3`, so I removed it and created a symbolic link to the actual place of the database `/data/db.sqlite`

```bash
pretalxuser@82f886a58c57:/$ rm /pretalx/src/data/db.sqlite3
pretalxuser@82f886a58c57:/$ ln -s /data/db.sqlite3 /pretalx/src/data/db.sqlite3
```

Then you can create the admin user:

```bash
python -m pretalx createsuperuser
```
# References

- [Home](https://pretalx.com/p/about/)
- [Source](https://github.com/pretalx/pretalx)
