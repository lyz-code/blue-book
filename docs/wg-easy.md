[`wg-easy`](https://github.com/wg-easy/wg-easy/tree/master) is the easiest way to install & manage WireGuard on any Linux hostthe easiest way to install & manage WireGuard on any Linux host

Features:

- All-in-one: WireGuard + Web UI.
- Easy installation, simple to use.
- List, create, edit, delete, enable & disable clients.
- Show a client's QR code.
- Download a client's configuration file.
- Statistics for which clients are connected.
- Tx/Rx charts for each connected client.
- Gravatar support.
- Automatic Light / Dark Mode
- Multilanguage Support
- One Time Links
- Client Expiration
- Prometheus metrics support
- IPv6 support
- CIDR support

# [Installation](https://github.com/wg-easy/wg-easy/tree/master?tab=readme-ov-file#installation)

## [With docker](https://github.com/wg-easy/wg-easy/tree/master?tab=readme-ov-file#installation)

If you want to use the prometheus metrics [you need to use a version greater than 14](https://github.com/wg-easy/wg-easy/issues/1373), as `15` is [not yet released](https://github.com/wg-easy/wg-easy/pkgs/container/wg-easy/versions) (as of 2025-03-20) I'm using `nightly`.

Tweak the next docker compose to your liking:

```yaml
---
services:
  wg-easy:
    environment:
      - WG_HOST=<the-url-or-public-ip-of-your-server>
      - WG_PORT=<select the wireguard port>

    # Until the 15 tag exists (after the release of 15, then you can change it to 15)
    # https://github.com/wg-easy/wg-easy/pkgs/container/wg-easy/versions
    image: ghcr.io/wg-easy/wg-easy:nightly
    container_name: wg-easy
    networks:
      wg:
        ipv4_address: 10.42.42.42
      wg-easy:
    volumes:
      - wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "<select the wireguard port>:<select the wireguard port/udp"
    restart: unless-stopped
    healthcheck:
      test: /usr/bin/timeout 5s /bin/sh -c "/usr/bin/wg show | /bin/grep -q interface || exit 1"
      interval: 1m
      timeout: 5s
      retries: 3
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=1

networks:
  wg:
    driver: bridge
    enable_ipv6: false
    ipam:
      driver: default
      config:
        - subnet: 10.42.42.0/24
  wg-easy:
    external: true

volumes:
  wireguard:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/apps/wg-easy/wireguard
```

Where:

- I usually save the compose file at `/data/apps/wg-easy`
- I've disabled ipv6, go to the official docker compose if you want to enable it
- I'm not exposing the admin web interface directly, if you want to, use the port 51821. Instead I'm going to use [authentik](authentik.md) to protect the service. That's why I'm not using [the `PASSWORD_HASH`](https://github.com/wg-easy/wg-easy/blob/production/How_to_generate_an_bcrypt_hash.md). To even protect it further, only the authentik and prometheus dockers will have network access to the `wg-easy` one. So in theory no unauthorised access should occur.
- The `wg-easy` is the external network I'm creating to connect this docker to authentik and prometheus](docker.md#limit-the-access-of-a-docker-on-a-server-to-the-access-on-the-docker-of-another-server)
- You'll need to add the `wg-easy` network to the `authentik` docker-compose.

The systemd service to start `wg-easy` is:

```
[Unit]
Description=wg-easy
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=/data/apps/wg-easy
# Shutdown container (if running) when unit is started
TimeoutStartSec=100
RestartSec=2s
# Start container when unit is started
ExecStart=/usr/bin/docker compose -f docker-compose.yaml up
# Stop container when unit is stopped
ExecStop=/usr/bin/docker compose -f docker-compose.yaml down

[Install]
WantedBy=multi-user.target
```

To forward the traffic from nginx to authentik use this site config:

```
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name vpn.*;

    include /config/nginx/ssl.conf;

    client_max_body_size 0;

    location / {
        include /config/nginx/proxy.conf;
        include /config/nginx/resolver.conf;
        set $upstream_app authentik;
        set $upstream_port 9000;
        set $upstream_proto http;
        proxy_pass $upstream_proto://$upstream_app:$upstream_port;

        proxy_set_header Range $http_range;
        proxy_set_header If-Range $http_if_range;
    }
}
```

To configure authentik to forward the traffic to `wg-easy` use this terraform code:

```terraform
# ---------------
# -- Variables --
# ---------------

variable "wg_easy_url" {
  type        = string
  description = "The url to access the service."
}

variable "wg_easy_internal_url" {
  type        = string
  description = "The url authentik proxies the traffic to reach wg_easy."
  default     = "http://wg-easy:51821"
}

variable "wg_easy_icon" {
  type        = string
  description = "The icon shown in the application"
  default     = "/application-icons/wireguard.png"
}

# --------------------
# --    Provider    --
# --------------------

resource "authentik_provider_proxy" "wg_easy" {
  name                         = "wg_easy"
  internal_host                = var.wg_easy_internal_url
  external_host                = var.wg_easy_url
  authorization_flow           = data.authentik_flow.default-authorization-flow.id
  invalidation_flow            = data.authentik_flow.default-provider-invalidation-flow.id
  internal_host_ssl_validation = false
  access_token_validity        = "minutes=120"
}

# -----------------------
# --    Application    --
# -----------------------

resource "authentik_application" "wg_easy" {
  name              = "Wireguard"
  slug              = "wireguard"
  meta_icon         = var.wg_easy_icon
  protocol_provider = authentik_provider_proxy.wg_easy.id
  lifecycle {
    ignore_changes = [
      # The terraform provider is continuously changing the attribute even though it's set
      meta_icon,
    ]
  }
}

resource "authentik_policy_binding" "wg_easy_admin" {
  target = authentik_application.wg_easy.uuid
  group  = authentik_group.admins.id
  order  = 0
}

resource "authentik_outpost" "default" {
  name               = "authentik Embedded Outpost"
  service_connection = authentik_service_connection_docker.local.id
  protocol_providers = [
    authentik_provider_proxy.wg_easy.id,
  ]
}

resource "authentik_service_connection_docker" "local" {
  name  = "Local Docker connection"
  local = true
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

```

## [With ansible](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Ansible)

# Configuration

## [Split tunneling](https://github.com/wg-easy/wg-easy/pull/737)

If you only want to route certain ips through the vpn you can use the AllowedIPs wireguard configuration. You can set them in the `WG_ALLOWED_IPS` docker compose environment variable

```bash
WG_ALLOWED_IPS=1.1.1.1,172.27.1.0/16
```

It's important to keep the DNS inside the allowed ips.

Keep in mind though that the `WG_ALLOWED_IPS` only sets the routes on the client, it does not limit the traffic at server level. For example, if you set `172.30.1.0/24` as the allowed ips, but the client changes it to `172.30.0.0/16` it will be able to access for example `172.30.2.1`. The suggested way to prevent this behavior is to add the kill switch in the Pre and Post hooks (`WG_POST_UP` and `WG_POST_DOWN`)

## [Restrict Access to Networks with iptables](https://github.com/wg-easy/wg-easy/wiki/Restrict-Access-to-Networks-with-iptables)

If you need to restrict many networks you can use [this allowed ips calculator](https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/)

## [Kill switch](https://airvpn.org/forums/topic/50601-kill-switch-settings-for-wireguard-on-ubuntu-20/)

## Monitorization

If you want to use the prometheus metrics [you need to use a version greater than 14](https://github.com/wg-easy/wg-easy/issues/1373), as `15` is [not yet released](https://github.com/wg-easy/wg-easy/pkgs/container/wg-easy/versions) (as of 2025-03-20) I'm using `nightly`.

You can enable them with the environment variable `ENABLE_PROMETHEUS_METRICS=true`

### Scrape the metrics

Add to your scrape config the required information

```yaml
  - job_name: vpn-admin
    metrics_path: /metrics
    static_configs:
      - targets:
          - {your vpn private ip}:{your vpn exporter port}
```

### Create the monitor client

To monitor wireguard you can start a wireguard client in a docker and do periodic checks that the tunnel is up and working (by trying to access an ip:port that can only be accessible from within the VPN). To do so we'll use [linuxserver's wireguard docker](https://github.com/linuxserver/docker-wireguard)

We'll need the next files:

`docker-compose.yaml`

```yaml
---
services:
  vpn-monitor:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: vpn-monitor
    cap_add:
      - NET_ADMIN
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SERVERURL=your-wireguard-server-ip
      - SERVERPORT=your-wireguard-server-port
    volumes:
      - config:/config
      - services:/custom-services.d:ro
    restart: unless-stopped

volumes:
  config:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/vpn-monitor/config
  services:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/vpn-monitor/services
```

`services/entrypoint.sh`: owned by `root` and permissions `755`

```bash
#!/bin/bash
HOST=XXX.XXX.XXX.XXX   # Change to the internal IP you're going to use to check the tunnel is up
PORT=XXX               # Change to the port of the internal service
WG_INTERFACE="monitor" # Change to your WireGuard interface name
CHECK_INTERVAL=300     # Check every 5 minutes (300 seconds)

echo "Starting entrypoint script..."

# Function to check if WireGuard is up
is_wireguard_up() {
  ip link show $WG_INTERFACE >/dev/null 2>&1 &&
    ip link show $WG_INTERFACE | grep -q "UP"
}

# Function to check http port
check_http() {
  timeout 5 bash -c "echo >/dev/tcp/$HOST/$PORT" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "$(date) - $HOST:$PORT port is open"
  else
    echo "$(date) - $HOST:$PORT port is closed"
  fi
}

check_ssh() {
  # Check if nmap is installed
  if ! command -v nmap >/dev/null 2>&1; then
    echo "$(date) - nmap not found, installing..."
    apk add --no-cache nmap >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "$(date) - Failed to install nmap"
      return 1
    fi
    echo "$(date) - nmap installed successfully"
  fi

  # Use nmap to check if port is open
  nmap -p $PORT --open -T4 $HOST 2>/dev/null | grep -q "open"
  if [ $? -eq 0 ]; then
    echo "$(date) - $HOST:$PORT port is open"
  else
    echo "$(date) - $HOST:$PORT port is closed"
  fi
}
# Check if WireGuard is connected
check_wireguard() {
  # Simple ping test through the tunnel
  ping -c 1 -W 2 $HOST >/dev/null 2>&1
  return $?
}
# Wait for WireGuard to be ready
echo "Waiting for WireGuard tunnel to become available..."
while ! is_wireguard_up; do
  echo "WireGuard tunnel not yet ready, waiting..."
  sleep 5
done

echo "WireGuard tunnel is up! Starting http check service..."

# Start periodic checking in the background
while true; do
  # If you're checking ssh use check_ssh instead of check_http to avoid errors in the ssh daemon logs
  if check_wireguard && check_http; then
    echo "$(date) - WireGuard tunnel is working"
  else
    echo "$(date) - ERROR: WireGuard tunnel is not working"
  fi
  sleep $CHECK_INTERVAL
done
```

Ideally the IP and port of the internal service should be accessible only from within the docker, not on the device that hosts the docker. This is not mandatory because what we're going to monitor is the health of the tunnel in the server side, although it's a nice touch.

We now need to create the client configuration, I've exported the file into the directory `config/wg_confs`.

Check that everything is working well with `docker compose up`. You should see the string "WireGuard tunnel is working".

Then enable the systemd service

`/etc/systemd/system/vpn-monitor.service`

```ini
[Install]
WantedBy=multi-user.target
[Unit]
Description=vpn-monitor
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=root
Group=docker
WorkingDirectory=/data/vpn-monitor
# Shutdown container (if running) when unit is started
TimeoutStartSec=100
RestartSec=2s
# Start container when unit is started
ExecStart=/usr/bin/docker compose -f docker-compose.yaml up
# Stop container when unit is stopped
ExecStop=/usr/bin/docker compose -f docker-compose.yaml down

[Install]
WantedBy=multi-user.target
```

Then enable and start the service:

```bash
systemctl enable vpn-monitor
service vpn-monitor start
```

### Create the alerts

```yaml
groups:
  - name: wireguard
    rules:
      # Peer Configuration Changes
      - alert: WireguardConfiguredPeersIncrease
        expr: increase(wireguard_configured_peers[5m]) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "WireGuard configured peers increased on {{ $labels.instance }}"
          description: "WireGuard configured peers increased by {{ $value }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}, job {{ $labels.job }}"

      - alert: WireguardConfiguredPeersDecrease
        expr: increase(wireguard_configured_peers[5m]) < 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "WireGuard configured peers decreased on {{ $labels.instance }}"
          description: "WireGuard configured peers decreased by {{ $value }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}, job {{ $labels.job }}"

      - alert: WireguardEnabledPeersIncrease
        expr: increase(wireguard_enabled_peers[5m]) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "WireGuard enabled peers increased on {{ $labels.instance }}"
          description: "WireGuard enabled peers increased by {{ $value }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}, job {{ $labels.job }}"

      - alert: WireguardEnabledPeersDecrease
        expr: increase(wireguard_enabled_peers[5m]) < 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "WireGuard enabled peers decreased on {{ $labels.instance }}"
          description: "WireGuard enabled peers decreased by {{ $value }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}, job {{ $labels.job }}"

      # Traffic Monitoring
      - alert: WireguardHighOutboundTraffic
        expr: rate(wireguard_sent_bytes[5m]) > 10485760 # 10MB/s in bytes
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "High WireGuard outbound traffic for user {{ $labels.name }}"
          description: "High outbound traffic detected for WireGuard user {{ $labels.name }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}. Current rate: {{ $value | humanize }}B/s"

      - alert: WireguardHighInboundTraffic
        expr: rate(wireguard_received_bytes{name="monitor"}[5m]) > 10485760 # 10MB/s in bytes
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High WireGuard inbound traffic for user {{ $labels.name }}"
          description: "High inbound traffic detected for WireGuard user {{ $labels.name }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}. Current rate: {{ $value | humanize }}B/s"

      # Alternative traffic alerts with different thresholds
      - alert: WireguardVeryHighOutboundTraffic
        expr: rate(wireguard_sent_bytes[5m]) > 104857600 # 100MB/s in bytes
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Very high WireGuard outbound traffic for user {{ $labels.name }}"
          description: "Very high outbound traffic detected for WireGuard user {{ $labels.name }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}. Current rate: {{ $value | humanize }}B/s"

      - alert: WireguardVeryHighInboundTraffic
        expr: rate(wireguard_received_bytes[5m]) > 104857600 # 100MB/s in bytes
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Very high WireGuard inbound traffic for user {{ $labels.name }}"
          description: "Very high inbound traffic detected for WireGuard user {{ $labels.name }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}. Current rate: {{ $value | humanize }}B/s"

      # Handshake Monitoring
      - alert: WireguardTunnelLooksDown
        expr: wireguard_latest_handshake_seconds{name="monitor"} > 300
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "WireGuard handshake stale for user {{ $labels.name }}"
          description: "WireGuard handshake is stale for user {{ $labels.name }} on instance {{ $labels.instance }}, interface {{ $labels.interface }}. Last handshake was {{ $value | humanizeDuration }} ago"
```

### Create the dashboards

Import [this dashboard](https://grafana.com/grafana/dashboards/21733-wireguard/) in grafana, and then export it as JSON and save it in your infrastructure as code.

If you feel lost check the [grafana](grafana.md) article.

# References

- [Source](https://github.com/wg-easy/wg-easy/tree/master)
- [Docs](https://github.com/wg-easy/wg-easy/wiki)
