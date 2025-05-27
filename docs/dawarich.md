Dawarich is a self-hostable alternative to Google Location History (Google Maps Timeline)

# [Installation](https://dawarich.app/docs/intro/#setup-your-dawarich-instance)

Tweak the [official docker-compose](https://github.com/Freika/dawarich/blob/master/docker/docker-compose.yml) keeping in mind:

- To configure the [`APPLICATION_HOST`](https://dawarich.app/docs/tutorials/reverse-proxy) if you're using a reverse proxy

Then run `docker compose up`. You can now visit your Dawarich instance at http://localhost:3000 or http://<your-server-ip>:3000. The default credentials are `demo@dawarich.app` and `password`

Go to your account and change the default account and password.

Be careful not to upgrade with watchtower, the devs say that it's not safe yet to do so.

# Not there yet
- [Immich photos are not well shown](https://github.com/Freika/dawarich/issues/1071): This happens when opening the map, or selecting one of the buttons "Yesterday", "Last 7 Days" or "Last month". If you select the same date range through the date-pickers, the photos are shown.
- [Support import of OSMand+ favourites gpx](https://github.com/Freika/dawarich/issues/1261)
- [OpenID/Oauth support](https://github.com/Freika/dawarich/issues/65)

# References

- [Home](https://dawarich.app/)
- [Docs](https://dawarich.app/docs/intro/)
- [Source](https://github.com/Freika/dawarich)
