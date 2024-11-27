[Gotify](https://github.com/gotify/server) is a simple server for sending and receiving messages in real-time per WebSocket. 

# [Installation](https://gotify.net/docs/install)
* Create the data directories: 
  ```bash
  mkdir -p /data/config/gotify/ /data/gotify
  ```
* Assuming you're using an external proxy create the next docker compose in `/data/config/gotify`. 

  ```yaml
  ---
  version: "3"

  services:
    gotify:
      image: gotify/server
      container_name: gotify
      networks:
        - swag
      env_file:
        - .env
      volumes:
        - gotify-data:/app/data

  networks:
    swag:
      external:
        name: swag

  volumes:
    gotify-data:
      driver: local
      driver_opts:
        type: none
        o: bind
        device: /data/gotify
  ```

  With the next `.env` file:

```
# https://gotify.net/docs/config

# GOTIFY_SERVER_PORT=80

# 0 = use Go default (15s); -1 = disable keepalive; set the interval in which keepalive packets will be sent. Only change this value if you know what you are doing.
# GOTIFY_SERVER_KEEPALIVEPERIODSECONDS=0

# the address to bind on, leave empty to bind on all addresses
# GOTIFY_SERVER_LISTENADDR=

  GOTIFY_SERVER_SSL_ENABLED=false
# GOTIFY_SERVER_SSL_REDIRECTTOHTTPS=true
# GOTIFY_SERVER_SSL_LISTENADDR=
# GOTIFY_SERVER_SSL_PORT=443
# GOTIFY_SERVER_SSL_CERTFILE=
# GOTIFY_SERVER_SSL_CERTKEY=
# GOTIFY_SERVER_SSL_LETSENCRYPT_ENABLED=false
# GOTIFY_SERVER_SSL_LETSENCRYPT_ACCEPTTOS=false
# GOTIFY_SERVER_SSL_LETSENCRYPT_CACHE=certs
# GOTIFY_SERVER_SSL_LETSENCRYPT_HOSTS=[mydomain.tld, myotherdomain.tld]
# GOTIFY_SERVER_RESPONSEHEADERS={X-Custom-Header: "custom value", x-other: value}
# GOTIFY_SERVER_CORS_ALLOWORIGINS=[.+\.example\.com, otherdomain\.com]
# GOTIFY_SERVER_CORS_ALLOWMETHODS=[GET, POST]
# GOTIFY_SERVER_CORS_ALLOWHEADERS=[X-Gotify-Key, Authorization]
# GOTIFY_SERVER_STREAM_ALLOWEDORIGINS=[.+.example\.com, otherdomain\.com]

# the interval in which websocket pings will be sent. Only change this value if you know what you are doing.
# GOTIFY_SERVER_STREAM_PINGPERIODSECONDS=45
  GOTIFY_DATABASE_DIALECT=sqlite3
  GOTIFY_DATABASE_CONNECTION=data/gotify.db

# on database creation, gotify creates an admin user (these values will only be used for the first start, if you want to edit the user after the first start use the WebUI)
  GOTIFY_DEFAULTUSER_NAME=admin
  GOTIFY_DEFAULTUSER_PASS=changeme

# the bcrypt password strength (higher = better but also slower)
  GOTIFY_PASSSTRENGTH=10
  GOTIFY_UPLOADEDIMAGESDIR=data/images
  GOTIFY_PLUGINSDIR=data/plugins
  GOTIFY_REGISTRATION=false
  ```

* Create the service by adding a file `gotify.service` into `/etc/systemd/system/`

```
[Unit]
Description=gotify
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=/data/config/gotify
# Shutdown container (if running) when unit is started
TimeoutStartSec=100
RestartSec=2s
# Start container when unit is started
ExecStart=/usr/bin/docker-compose -f docker-compose.yaml up
# Stop container when unit is stopped
ExecStop=/usr/bin/docker-compose -f docker-compose.yaml down

[Install]
WantedBy=multi-user.target
```

* Copy the nginx configuration in your `site-confs`

  ```

  server {
      listen 443 ssl;
      listen [::]:443 ssl;

      server_name gotify.*;

      include /config/nginx/ssl.conf;

      client_max_body_size 0;

      # enable for ldap auth (requires ldap-location.conf in the location block)
      #include /config/nginx/ldap-server.conf;

      # enable for Authelia (requires authelia-location.conf in the location block)
      #include /config/nginx/authelia-server.conf;

      location / {
          # enable the next two lines for http auth
          #auth_basic "Restricted";
          #auth_basic_user_file /config/nginx/.htpasswd;

          # enable for ldap auth (requires ldap-server.conf in the server block)
          #include /config/nginx/ldap-location.conf;

          # enable for Authelia (requires authelia-server.conf in the server block)
          #include /config/nginx/authelia-location.conf;

          include /config/nginx/proxy.conf;
          include /config/nginx/resolver.conf;
          set $upstream_app gotify;
          set $upstream_port 80;
          set $upstream_proto http;
          proxy_pass $upstream_proto://$upstream_app:$upstream_port;
      }
  }
  ```
* Start the service `systemctl start gotify`
* Restart the nginx service `systemctl restart swag`
* Enable the service `systemctl enable gotify`.
* Login with the `admin` user
* Create a new user with admin permissions 
* Delete the `admin` user

## Configuration

### Client configuration

#### [Android client](https://github.com/gotify/android)

#### Linux clients
- [command line client](#command-line-client)
- [Dunst client](#dunst-linux-client)
- [gotify-desktop](https://github.com/desbma/gotify-desktop)
- [rofi client](https://github.com/diddypod/rotify)
##### [Command line client](https://github.com/gotify/cli)
##### [Dunst linux client](https://github.com/ztpnk/gotify-dunst)

### Connect it with Alertmanager
It's not trivial to connect it to Alertmanager([1](https://github.com/prometheus/alertmanager/issues/2120), [2](https://github.com/gotify/contrib/issues/21), [3](https://github.com/prometheus/alertmanager/issues/3729), [4](https://github.com/prometheus/alertmanager/issues/2120). The most popular way is to use [`alertmanager_gotify_bridge`](https://github.com/DRuggeri/alertmanager_gotify_bridge?tab=readme-ov-file).

We need to tweak the docker-compose to add the bridge:

```yaml
```
### Connect it with Authentik

Here are some guides to connect it to authentik. The problem is that the clients you want to use must support it

- https://github.com/gotify/server/issues/203
- https://github.com/gotify/server/issues/553

# Not there yet

- [Reactions on the notifications](https://github.com/gotify/server/issues/494)

# References

- [Source](https://github.com/gotify/server)
- [Docs](https://gotify.net/docs/)
