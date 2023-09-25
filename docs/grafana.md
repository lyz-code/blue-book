[Grafana](https://grafana.com/grafana) is a web application to create dashboards.

# [Installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#run-grafana-via-docker-compose)

We're going to install it with docker-compose and connect it to [Authentik](authentik.md).

## [Create the Authentik connection](https://goauthentik.io/integrations/services/grafana/)

Assuming that you have [the terraform authentik provider configured](authentik.md), use the next terraform code:

```hcl
# ---------------
# -- Variables --
# ---------------

variable "grafana_name" {
  type        = string
  description = "The name shown in the Grafana application."
  default     = "Grafana"
}

variable "grafana_redirect_uri" {
  type        = string
  description = "The redirect url configured on Grafana."
}

variable "grafana_icon" {
  type        = string
  description = "The icon shown in the Grafana application"
  default     = "/application-icons/grafana.svg"
}

# -----------------------
# --    Application    --
# -----------------------

resource "authentik_application" "grafana" {
  name              = var.grafana_name
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
  meta_icon         = var.grafana_icon
  lifecycle {
    ignore_changes = [
      # The terraform provider is continuously changing the attribute even though it's set
      meta_icon,
    ]
  }
}

# --------------------------
# --    Oauth provider    --
# --------------------------

resource "authentik_provider_oauth2" "grafana" {
  name               = var.grafana_name
  client_id          = "grafana"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings = [
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.openid.id,
    data.authentik_scope_mapping.profile.id,
  ]
  redirect_uris = [
    var.grafana_redirect_uri,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
  access_token_validity = "minutes=120"
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

# -------------------
# --    Outputs    --
# -------------------

output "grafana_oauth_id" {
  value = authentik_provider_oauth2.grafana.client_id
}

output "grafana_oauth_secret" {
  value = authentik_provider_oauth2.grafana.client_secret
}
```

You'll need to upload the `grafana.svg` to your authentik application
you can use the next docker-compose file.

```yaml
---
version: "3.3"
services:
  grafana:
    image: grafana/grafana-oss:${GRAFANA_VERSION:-latest}
    container_name: grafana
    restart: unless-stopped
    volumes:
      - config:/etc/grafana
      - data:/var/lib/grafana
    networks:
      - grafana
      - monitorization
      - swag
    env_file:
      - .env
    depends_on:
      - db
  db:
    image: postgres:${DATABASE_VERSION:-15}
    restart: unless-stopped
    container_name: grafana-db
    environment:
      - POSTGRES_DB=${GF_DATABASE_NAME:-grafana}
      - POSTGRES_USER=${GF_DATABASE_USER:-grafana}
      - POSTGRES_PASSWORD=${GF_DATABASE_PASSWORD:?database password required}
    networks:
      - grafana
    volumes:
      - db-data:/var/lib/postgresql/data
    env_file:
      - .env

networks:
  grafana:
    external:
      name: grafana
  monitorization:
    external:
      name: monitorization
  swag:
    external:
      name: swag

volumes:
  config:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/app/config
  data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/app/data
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/grafana/database
```

Where the `monitorization` network is where prometheus and the rest of the stack listens, and `swag` the network to the gateway proxy.

It uses the `.env` file to store the required [configuration](#configure-grafana), to connect grafana with authentik you need to add the next variables:

```bash
# --------------------------
# --- Auth configuration ---
# --------------------------

GF_AUTH_GENERIC_OAUTH_ENABLED="true"
GF_AUTH_GENERIC_OAUTH_NAME="authentik"
GF_AUTH_GENERIC_OAUTH_CLIENT_ID="<Client ID from above>"
GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET="<Client Secret from above>"
GF_AUTH_GENERIC_OAUTH_SCOPES="openid profile email"
GF_AUTH_GENERIC_OAUTH_AUTH_URL="https://authentik.company/application/o/authorize/"
GF_AUTH_GENERIC_OAUTH_TOKEN_URL="https://authentik.company/application/o/token/"
GF_AUTH_GENERIC_OAUTH_API_URL="https://authentik.company/application/o/userinfo/"
GF_AUTH_SIGNOUT_REDIRECT_URL="https://authentik.company/application/o/<Slug of the application from above>/end-session/"
# Optionally enable auto-login (bypasses Grafana login screen)
GF_AUTH_OAUTH_AUTO_LOGIN="true"
# Optionally map user groups to Grafana roles
GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH="contains(groups[*], 'Grafana Admins') && 'Admin' || contains(groups[*], 'Grafana Editors') && 'Editor' || 'Viewer'"
```

In the configuration above you can see an example of a role mapping. Upon login, this configuration looks at the groups of which the current user is a member. If any of the specified group names are found, the user will be granted the resulting role in Grafana.

In the example shown above, one of the specified group names is "Grafana Admins". If the user is a member of this group, they will be granted the "Admin" role in Grafana. If the user is not a member of the "Grafana Admins" group, it moves on to see if the user is a member of the "Grafana Editors" group. If they are, they are granted the "Editor" role. Finally, if the user is not found to be a member of either of these groups, it fails back to granting the "Viewer" role.

Also make sure in your configuration that `root_url` is set correctly, otherwise your redirect url might get processed incorrectly. For example, if your grafana instance is running on the default configuration and is accessible behind a reverse proxy at https://grafana.company, your redirect url will end up looking like this, https://grafana.company/. If you get `user does not belong to org` error when trying to log into grafana for the first time via OAuth, check if you have an organization with the ID of 1, if not, then you have to add the following to your grafana config:
w

```ini
[users]
auto_assign_org = true
auto_assign_org_id = <id-of-your-default-organization>
```

Once you've made sure that the oauth works, go to `/admin/users` and remove the `admin` user.


## [Configure grafana](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#override-configuration-with-environment-variables)

Grafana has default and custom configuration files. You can customize your Grafana instance by modifying the custom configuration file or by using environment variables. To see the list of settings for a Grafana instance, refer to [View server settings](https://grafana.com/docs/grafana/latest/administration/stats-and-license/#view-server-settings).

To override an option use `GF_<SectionName>_<KeyName>`. Where the `section name` is the text within the brackets. Everything should be uppercase, `.` and `-` should be replaced by `_`. For example, if you have these configuration settings:

```ini
# default section
instance_name = ${HOSTNAME}

[security]
admin_user = admin

[auth.google]
client_secret = 0ldS3cretKey

[plugin.grafana-image-renderer]
rendering_ignore_https_errors = true

[feature_toggles]
enable = newNavigation
```

You can override variables on Linux machines with:

```bash
export GF_DEFAULT_INSTANCE_NAME=my-instance
export GF_SECURITY_ADMIN_USER=owner
export GF_AUTH_GOOGLE_CLIENT_SECRET=newS3cretKey
export GF_PLUGIN_GRAFANA_IMAGE_RENDERER_RENDERING_IGNORE_HTTPS_ERRORS=true
export GF_FEATURE_TOGGLES_ENABLE=newNavigation
```

And in the docker compose you can edit the `.env` file. Mine looks similar to:

```bash
# Check all configuration options at:
# https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana

# -----------------------------
# --- General configuration ---
# -----------------------------

GRAFANA_VERSION=latest
GF_DEFAULT_INSTANCE_NAME="production"
GF_SERVER_ROOT_URL="https://your.domain.org"

# Set this option to true to enable HTTP compression, this can improve transfer
# speed and bandwidth utilization. It is recommended that most users set it to
# true. By default it is set to false for compatibility reasons.
GF_SERVER_ENABLE_GZIP="true"

# ------------------------------
# --- Database configuration ---
# ------------------------------

DATABASE_VERSION=15
GF_DATABASE_TYPE=postgres
DATABASE_VERSION=15
GF_DATABASE_HOST=grafana-db:5432
GF_DATABASE_NAME=grafana
GF_DATABASE_USER=grafana
GF_DATABASE_PASSWORD="change-for-a-long-password"
GF_DATABASE_SSL_MODE=disable

# --------------------------
# --- Auth configuration ---
# --------------------------

GF_AUTH_GENERIC_OAUTH_ENABLED="true"
GF_AUTH_GENERIC_OAUTH_NAME="authentik"
GF_AUTH_GENERIC_OAUTH_CLIENT_ID="<Client ID from above>"
GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET="<Client Secret from above>"
GF_AUTH_GENERIC_OAUTH_SCOPES="openid profile email"
GF_AUTH_GENERIC_OAUTH_AUTH_URL="https://authentik.company/application/o/authorize/"
GF_AUTH_GENERIC_OAUTH_TOKEN_URL="https://authentik.company/application/o/token/"
GF_AUTH_GENERIC_OAUTH_API_URL="https://authentik.company/application/o/userinfo/"
GF_AUTH_SIGNOUT_REDIRECT_URL="https://authentik.company/application/o/<Slug of the application from above>/end-session/"
# Optionally enable auto-login (bypasses Grafana login screen)
GF_AUTH_OAUTH_AUTO_LOGIN="true"
# Set to true to enable automatic sync of the Grafana server administrator
# role. If this option is set to true and the result of evaluating
# role_attribute_path for a user is GrafanaAdmin, Grafana grants the user the
# server administrator privileges and organization administrator role. If this
# option is set to false and the result of evaluating role_attribute_path for a
# user is GrafanaAdmin, Grafana grants the user only organization administrator
# role.
GF_AUTH_GENERIC_OAUTH_ALLOW_ASSIGN_GRAFANA_ADMIN="true"
# Optionally enable auto-login (bypasses Grafana login screen)
# Optionally map user groups to Grafana roles
# Optionally map user groups to Grafana roles
GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH="contains(groups[*], 'Grafana Admins') && 'Admin' || contains(groups[*], 'Grafana Editors') && 'Editor' || 'Viewer'"
# Set to true to disable (hide) the login form, useful if you use OAuth. Default is false.
GF_AUTH_DISABLE_LOGIN_FORM="true"

# -------------------------
# --- Log configuration ---
# -------------------------

# Options are “console”, “file”, and “syslog”. Default is “console” and “file”. Use spaces to separate multiple modes, e.g. console file.
GF_LOG_MODE="console file"
# Options are “debug”, “info”, “warn”, “error”, and “critical”. Default is info.
GF_LOG_LEVEL="info"
```

### [Configure datasources](https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources)

You can manage data sources in Grafana by adding YAML configuration files in the `provisioning/datasources` directory. Each config file can contain a list of datasources to add or update during startup. If the data source already exists, Grafana reconfigures it to match the provisioned configuration file.

The configuration file can also list data sources to automatically delete, called `deleteDatasources`. Grafana deletes the data sources listed in `deleteDatasources` before adding or updating those in the datasources list.

For example to [configure a Prometheus datasource](https://grafana.com/docs/grafana/latest/datasources/prometheus/) use:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    # Access mode - proxy (server in the UI) or direct (browser in the UI).
    url: http://prometheus:9090
    jsonData:
      httpMethod: POST
      manageAlerts: true
      timeInterval: 30s
      prometheusType: Prometheus
      prometheusVersion: 2.44.0
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
      exemplarTraceIdDestinations: []
```

Be careful to set the `timeInterval` variable to the value of how often you scrape the data from the node exporter to avoid [this issue](https://github.com/rfmoz/grafana-dashboards/issues/137).

### [Configure dashboards](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)

You can manage dashboards in Grafana by adding one or more YAML config files in the `provisioning/dashboards` directory. Each config file can contain a list of dashboards providers that load dashboards into Grafana from the local filesystem.

Create one file called `dashboards.yaml` with the next contents:

```yaml
---
apiVersion: 1
providers:
  - name: default # A uniquely identifiable name for the provider
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards/definitions
```

Then inside the config directory of your docker compose create the directory `provisioning/dashboards/definitions` and add the json of the dashboards themselves. You can download them from the dashboard pages. For example:

- [Node Exporter](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)
- [Blackbox Exporter](https://grafana.com/grafana/dashboards/13659-blackbox-exporter-http-prober/)
- [Alertmanager](https://grafana.com/grafana/dashboards/9578-alertmanager/)

### [Configure the plugins](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#install-plugins-in-the-docker-container)

To install plugins in the Docker container, complete the following steps:

- Pass the plugins you want to be installed to Docker with the `GF_INSTALL_PLUGINS` environment variable as a comma-separated list.
- This sends each plugin name to `grafana-cli plugins install ${plugin}` and installs them when Grafana starts.

For example:

```bash
docker run -d -p 3000:3000 --name=grafana \
  -e "GF_INSTALL_PLUGINS=grafana-clock-panel, grafana-simple-json-datasource" \
  grafana/grafana-oss
```

To specify the version of a plugin, add the version number to the `GF_INSTALL_PLUGINS` environment variable. For example: `GF_INSTALL_PLUGINS=grafana-clock-panel 1.0.1`. 

To install a plugin from a custom URL, use the following convention to specify the URL: `<url to plugin zip>;<plugin install folder name>`. For example: `GF_INSTALL_PLUGINS=https://github.com/VolkovLabs/custom-plugin.zip;custom-plugin`.

# References

- [Home](https://grafana.com/grafana)
