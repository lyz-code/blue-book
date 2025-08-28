---
title: qBittorrent
date: 20221228
author: Lyz
---

[qBittorrent](https://www.qbittorrent.org/) is [my chosen](torrents.md) client
for [Bittorrent](https://en.wikipedia.org/wiki/BitTorrent).

# Installation

Use [binhex Docker](https://github.com/binhex/arch-qbittorrentvpn)

- [Enable the announcement to all trackers](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions#only-one-tracker-is-working-the-others-arent-contacted-yet)
- [Check the Advanced configurations](https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent#Advanced)
- I've tried the different Web UIs but none was of my licking.
- I've configured [unpackerr](https://github.com/davidnewhall/unpackerr) to
  unpack the compressed downloads.

# Migration from other client

- First [install the service](#installation)
- Make sure that the default download directory has all the downloaded data to
  import.
- Then move all the `*.torrent` files from the old client to the torrent watch
  directory.

# Python interaction

Use [this library](https://github.com/rmartin16/qbittorrent-api), you can see
some examples [here](https://github.com/StuffAnThings/qbit_manage).

# Monitorization

## Metrics monitorisation

There's
[this nice prometheus exporter](https://github.com/caseyscarborough/qbittorrent-exporter) which was rewritten in Go by [martabal](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file)
with it's
[graphana dashboard](https://github.com/caseyscarborough/qbittorrent-grafana-dashboard).
With the information shown in the graphana dashboard it looks you can do alerts
on whatever you want.

There is also [another exporter written in Python](https://github.com/esanchezm/prometheus-qbittorrent-exporter) but it has less release frequency and it looks like it has less metrics.

### Installation

Add to your docker compose the exporter docker:

```yaml
qbittorrent-exporter:
  image: ghcr.io/martabal/qbittorrent-exporter:latest
  container_name: qbittorrent-exporter
  environment:
    - QBITTORRENT_BASE_URL=http://192.168.1.10:8080
    - QBITTORRENT_PASSWORD='<your_password>'
    - QBITTORRENT_USERNAME=admin
  # ports:
  #   - 8090:8090
  restart: unless-stopped
  networks:
    - prometheus-qbittorent-exporter
```

I preferred not to expose the port and connect it directly through the external docker network `prometheus-qbitorrent-exporter`

If the password is giving any kind of error remove the `'` or the `"`, for example: `QBITTORRENT_PASSWORD=yourpassword`

Then you need to scrape those metrics:

```yaml
scrape_configs:
  - job_name: "qbittorrent"
    static_configs:
      - targets: ["<your_ip_address>:8090"]
```

### Alertmanager alerts

You'll need to tweak the next values for your case. Specially the private trackers ones, as each has their policy.

```yaml
groups:
  - name: qbitorrent
    rules:
      - alert: QbittorrentNotConnected
        expr: |
          absent(qbittorrent_transfer_connection_status{connection_status="connected"}) 
          or 
          qbittorrent_transfer_connection_status{connection_status="connected"} != 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "qBittorrent connection problem"
          description: |
            qBittorrent is either not reporting metrics (possibly down) or is not connected for more than 5 minutes.
      - alert: QbittorrentFirewalled
        expr: |
          qbittorrent_transfer_connection_status{connection_status="firewalled"} == 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "qBittorrent is firewalled"
      - alert: QbittorrentDisconnected
        expr: |
          qbittorrent_transfer_connection_status{connection_status="disconnected"} == 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "qBittorrent is disconnected"
      - alert: TooManyTorrents
        expr: qbittorrent_global_torrents > 900
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "You should remove some to keep things balanced"
      - alert: TrackerStatusDown
        expr: |
          # I've removed the trackers that are flaky
          qbittorrent_tracker_status{
            url!~".*(tracker.openbittorrent.com|opentracker.i2p.rocks|exodus.desync.com|open.tracker.cl|opentracker.i2p.rocks|tracker-udp.gbitt.info|tracker.auctor.tv|tracker.moeking.me|tracker.openbittorrent.com|tracker1.bt.moack.co.kr).*"
          } > 2
        for: 1d
        labels:
          severity: warning
          service: qbittorrent
          alert_type: tracker_down
        annotations:
          summary: "Tracker has been down for more than 1 day: {{ $labels.url }}"
          description: |
            Tracker "{{ $labels.url }}" has been reporting a non-working status ({{ $value }}) for more than 1 day.

            This indicates the tracker may be experiencing issues or downtime.

            Tracker URL: {{ $labels.url }}
            Status Code: {{ $value }}
            Torrent: {{ $labels.name }}

            **Status Code Reference:**
            - 0: ?
            - 1: ?
            - 2: Working
            - 3: ?
            - 4: Not working: time out, Tracker is currently undergoing maintenance, try again later
      - alert: TorrentsInErrorState
        expr: qbittorrent_torrent_states{name="error"} > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "There are {{ $value }} torrents in state error"
      - alert: TorrentsInUnknownState
        expr: qbittorrent_torrent_states{name="unknown"} > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "There are {{ $value }} torrents in state unknown"
      - alert: TorrentsDownloadStaled
        expr: qbittorrent_torrent_info{state="stalledDL"}
        for: 14d
        labels:
          severity: info
        annotations:
          summary: "The torrent {{ $labels.name }} download has been stale for more than 14 days"
      - alert: TorrentWithMissingFiles
        expr: qbittorrent_torrent_states{name="missingFiles"} > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "There are {{ $value }} torrents with missing files"
      - alert: TooFewUploadingTorrents
        expr: qbittorrent_torrent_states{name="uploading"} < 10
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "There are only {{ $value }} torrents in uploading state"
      - alert: TooFewUploadTraffic
        expr: avg_over_time(qbittorrent_global_upload_speed_bytes[1h]) / 1024 / 1024 < 1
        for: 5h
        labels:
          severity: warning
        annotations:
          summary: "There upload speed has been lower than 1 MB/s for more than 5 hours, something may be wrong"
  - name: YourPrivateTracker
    rules:
      - alert: YourPrivateTrackerHitAndRun
        expr: |
          (
            # Track torrents that were present and completed
            qbittorrent_torrent_info{
              tracker=~".*(url1.of.your.tracker|url2.of.your.tracker).*"
            } offset 5m
            unless
            # But are now missing
            qbittorrent_torrent_info{
              tracker=~".*(url1.of.your.tracker|url2.of.your.tracker).*"
            }
          )
          and on(name)
          (
            # And the total active time is less than 2 weeks and 4 hours (1224000 seconds)
            qbittorrent_torrent_time_active{} offset 5m < 1224000
          )
        for: 5m
        labels:
          severity: warning
          service: qbittorrent
          alert_type: hit_and_run
        annotations:
          summary: "Torrent hit-and-run detected: {{ $labels.name }}"
          description: |
            Torrent "{{ $labels.name }}" has been removed from qBittorrent after only {{ $value | humanizeDuration }} of seeding time since completion.

            This torrent was seeded for less than the required 2 weeks (336 hours) on a private tracker.

            Tracker: {{ $labels.tracker }}
            Category: {{ $labels.category }}
            Size: {{ $labels.size | humanize1024 }}B
            Ratio achieved: {{ $labels.ratio }}
      - alert: YourPrivateTrackerDownloadBufferWarning
        expr: |
          (
            # Total uploaded bytes for the tracker
            sum(
              qbittorrent_torrent_total_uploaded_bytes{} 
              * on(name) group_left(tracker) 
              qbittorrent_torrent_info{
                tracker=~".*(url1.of.your.tracker|url2.of.your.tracker).*"
              }
            )
            - 
            # Total downloaded bytes for the tracker
            sum(
              qbittorrent_torrent_total_downloaded_bytes{} 
              * on(name) group_left(tracker) 
              qbittorrent_torrent_info{
                tracker=~".*(url1.of.your.tracker|url2.of.your.tracker).*"
              }
              )
          # Converted to terabytes
          ) / (1024 * 1024 * 1024 * 1024) 
          # It's the buffer I have (1TB of more downloaded data than uploaded)
          < -1
        for: 5m
        labels:
          severity: warning
          service: qbittorrent
          alert_type: ratio
        annotations:
          summary: "Tracker buffer is at risk"
          description: |
            This indicates more data has been downloaded than uploaded across all torrents for this tracker.
            Consider prioritizing seeding for torrents from this tracker to improve the overall ratio.

            Tracker: YourPrivateTracker
            Amount buffer lost: {{ $value }}TB
```

### Grafana dashboard

There is [this dashboard](https://grafana.com/grafana/dashboards/15116-qbittorrent-dashboard/) that works with the previous exporter

## Logs monitorisation

If you're using binhex docker the qbitorrent logs are not being exposed in the stdout of the docker but in the internal docker path `/data/qBittorrent/data/logs/qbittorrent.log`. So you'll need to scrape it with promtail:

```yaml
- job_name: torrent
  static_configs:
    - targets:
        - localhost
      labels:
        job: qbittorrent
        service_name: torrent
        __path__: /your/host/data/volume/qBittorrent/data/logs/qbittorrent.log
```

Then you can create alerts on those logs (some of them are on the stdout of the docker and others on that file content):

```yaml
groups:
  - name: torrent
    rules:
      - alert: TorrentVPNCertificateExpired
        expr: |
          count_over_time({container=~"torrent"} |= `certificate has expired`[5m])  > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "The VPN certificate has expired. Please renew. Runbook is in the docker-compose README.md"
      - alert: TorrentVPNConfigError
        expr: |
          count_over_time({container=~"torrent"} |~ `Error opening configuration file.*openvpn`[5m])  > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "There was an error opening the openvpn config file."
      - alert: TorrentDockerGenericError
        expr: |
          count_over_time({container=~"torrent"} |~ `(?i)error` != `could not load module /lib/modules/iptable_mangle.ko`[5m])  > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "There are unhandled errors in the torrent logs."
      - alert: TorrentQBitorrentGenericError
        expr: |
          count_over_time({service_name=~"torrent"} |= `(W)` != `WebAPI login failure` != `Removed torrent but failed to delete its content` [5m])  > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "There are unhandled errors in the qbittorrent application logs."
      - alert: TorrentWebAPILoginError
        expr: |
          count_over_time({service_name=~"torrent"} |= `WebAPI login failure. Reason: invalid credentials`[5m])  > 3
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "There were more than 3 login attempts in the torrent web ui"
      - alert: TorrentWebAPILoginBan
        expr: |
          count_over_time({service_name=~"torrent"} |= `WebAPI login failure. Reason: IP has been banned`[5m])  > 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "There has been an IP banned due to too many login attempts in the torrent web ui"
      - alert: TorrentDeleteContentError
        expr: |
          count_over_time({service_name=~"torrent"} |= `Removed torrent but failed to delete its content` [5m])  > 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "There has been an IP banned due to too many login attempts in the torrent web ui"
```

# Automatic operation

I've created a Qbittorrent operator to do the following operations:
be done by a program. For example:

- Remove the torrents of a category if their ratio is above X (not all
  torrents).
- Remove torrents if you have more than a defined number of torrents in an intelligent way (not removing the private torrents that still need to be seeded, or torrents that are in a protected category, and order the removal by the seeding time).
- [Remove unregistered torrents](https://github.com/qbittorrent/qBittorrent/issues/11469)
- For the trackers where you're building some ratio keep the interesting torrents for a while until you build the desired buffer.
- Remove the directories that are not being used by any active torrent.
- Set the category of special trackers once imported
- Move the torrents from the blackhole the completed directory

An with the logs you can create the next alerts:

```yaml
- name: qbitops
  rules:
    - alert: SpecialTrackerTorrentDeleted
      expr: |
        count_over_time({container="qbitops"} |~ `Deleting.*bibliotik`[5m])  > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "A torrent of the Special Tracker was automatically removed by qbitops, you may want to take a look"
    - alert: UnregisteredNonCompletedTorrent
      expr: |
        count_over_time({container="qbitops"} |= `Unregistered non completed torrent`[5m])  > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "A torrent that is not in a complete state has been marked as unregistered by the tracker. You may want to take a look"
    - alert: UnregisteredNonProcessedTorrent
      expr: |
        count_over_time({container="qbitops"} |= `Unregistered non processed torrent`[5m])  > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "A completed torrent that has not yet been processed has been marked as unregistered by the tracker. You may want to import the content"
    - alert: TheBufferOfTorrentsToDeleteIsLow
      expr: |
        count_over_time({container="qbitops"} |= `The buffer of torrents to delete is low`[5m])  > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "qbitops is running out of torrents to delete to keep the maximum number of torrents controlled. You may want to take a look"
    - alert: UnexpectedWarningInQbitops
      expr: |
        count_over_time({container="qbitops"} |= `WARNING` != `The buffer of torrents to delete is low` or `Unregistered`[5m])  > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "An unknown warning has been found in the qbitops logs"
    - alert: UnexpectedErrorInQbitops
      expr: |
        count_over_time({container="qbitops"} |= `ERROR` != `Could not configure the QBittorrent client` or `Could not connect to the QBittorrent server`[5m])  > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "An unknown error has been found in the qbitops logs"
    - alert: QbitopsWrongConfigurationError
      expr: |
        count_over_time({container="qbitops"} |= `Could not configure the QBittorrent client`[5m])  > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "The QbitOps configuration may be wrong."
    - alert: QbitopsConnectionError
      expr: |
        count_over_time({container="qbitops"} |= `Could not connect to the QBittorrent server`[5m])  > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "The QbitOps can't connect to the Qbittorrent server."
    - alert: QbitopsUnexpectedTraceback
      expr: |
        count_over_time({container="qbitops"} |= `Traceback`[5m])  > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "There is an unhandled Python Traceback in the QbitOps logs."
    - alert: QbitopsNotSuccessfulRunInAWhile
      expr: |
        (count_over_time({container="torrent-operator"} |= `Sleeping` [10h]) or on() vector(0)) == 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Qbitops has not run in the expected time"
```

I'm currently a little bit lazy to clean it up to publish it. If you're interested you can [contact](contact.md) me.

# Client recovery

When your download client stops working and you can't recover it soon your heart
gets a hiccup. You'll probably start browsing the private trackers webpages to
see if you have a Hit and Run and if you can solve it before you get banned. If
this happens while you're away from your infrastructure it can be even worse.

Something you can do in these cases is to have another client configured so you
can spawn it fast and import the torrents that are under the Hit and Run threat.

# Tools

- [qbittools](https://github.com/buroa/qbittools): a feature rich CLI for the management of torrents in qBittorrent.
- [qbit_manage](https://github.com/StuffAnThings/qbit_manage): tool will help manage tedious tasks in qBittorrent and automate them.

# Troubleshooting

## Torrents have very low speeds when they used to work just fine

If you're using a vpn, change the vpn server

## Trackers stuck on Updating

Sometimes the issue comes from an improvable configuration. In advanced:

- Ensure that there are enough [Max concurrent http announces](https://github.com/qbittorrent/qBittorrent/issues/15744): I changed from 50 to 500
- [Select the correct interface and Optional IP address to bind to](https://github.com/qbittorrent/qBittorrent/issues/14453). In my case I selected `tun0` as I'm using a vpn and `All IPv4 addresses` as I don't use IPv6.

# Not there yet

## [Protect the webui behind authentik](https://github.com/qbittorrent/qBittorrent/issues/13238)

There is still no way to avoid to enter the qbittorrent password

# References

- [Home](https://www.qbittorrent.org/)
- [Source](https://github.com/qbittorrent/qBittorrent/)
- [FAQ](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions#will-private-torrent-be-affected-by-dht-and-pex-in-qbittorrent)
- [Python library docs](https://qbittorrent-api.readthedocs.io/en/latest/)
