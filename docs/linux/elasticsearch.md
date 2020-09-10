---
title: Commands for elasticsearch
date: 20170529
author: Lyz
---

# Backup

**It's better to use the `curator` tool**

## Create snapshot

```bash
curl {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}?wait_for_completion=true
```

## Create snapshot of selected indices

```bash
curl {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}?wait_for_completion=true

curl -XPUT 'localhost:9200/_snapshot/my_backup/snapshot_1?pretty' -H 'Content-Type: application/json' -d'
{
  "indices": "index_1,index_2",
  "ignore_unavailable": true,
  "include_global_state": false
}
'
```

## List all backups

Check for my-snapshot-repo

```bash
curl {{ url }}/_snapshot/{{ backup_path }}/*?pretty
```

## Restore backup

First you need to close the selected indices

```bash
curl {{ url }}/{{ indice_name }}/_close
```

Then restore
```bash
curl {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}/_restore?wait_for_completion=true
```

## Create snapshot of selected indices

```bash
curl {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}?wait_for_completion=true
```

## Delete snapshot

```bash
curl -XDELETE {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}
```

## [Delete snapshots older than X](https://discuss.elastic.co/t/deleting-old-snapshots/134085/4)

!!! note "File: curator.yml"
    ```yaml
    client:
    hosts:
    - 'a data node'
    port: 9200
    url_prefix:
    use_ssl: False
    certificate:
    client_cert:
    client_key:
    ssl_no_validate: False
    http_auth:
    timeout: 30
    master_only: False

    logging:
    loglevel: INFO
    logfile: D:\CuratorLogs\logs.txt
    logformat: default
    blacklist: ['elasticsearch', 'urllib3']
    ```

!!! note "File: delete_old_snapshots.yml"
    ```yaml
    actions:
    1:
    action: delete_snapshots
    description: >-
    Delete snapshots from the selected repository older than 100 days
    (based on creation_date), for everything but 'citydirectory-' prefixed snapshots.
    options:
    repository: 'dcs-elastic-snapshot'
    disable_action: False
    filters:
    - filtertype: pattern
    kind: prefix
    value: citydirectory-
    exclude: True
    - filtertype: age
    source: creation_date
    direction: older
    unit: days
    unit_count: 100
    ```

# Information gathering

## Get status of cluster

```bash
curl {{ url }}/_cluster/health?pretty
curl {{ url }}/_cat/nodes?v
curl {{ url }}/_cat/indices?v
curl {{ url }}/_cat/shards
```

If you've got red status, use the following command to choose the first
unassigned shard that it finds and explains why it cannot be allocated to
a node.

```bash
curl {{ url }}/_cluster/allocation/explain?v
```

## Get settings

```bash
curl {{ url }}/_settings
```

## [Get space left](https://stackoverflow.com/questions/29417830/elasticsearch-find-disk-space-usage)

```bash
curl {{ url }}/_nodes/stats/fs?pretty
```

## List plugins

```bash
curl {{ url }}/_nodes/plugins?pretty
```

# Upload

## Single data upload

```bash
curl -XPOST '{{ url }}/{{ path_to_table }}' -d '{{ json_input }}'
```
where json_input can be `{ "field" : "value" }`

## Bulk upload of data

```bash
curl -H 'Content-Type: application/x-ndjson' -XPOST \
    '{{ url }}/{{ path_to_table }}/_bulk?pretty' --data-binary @{{ json_file }}
```

# Delete

## Delete data

```bash
curl -XDELETE {{ url }}/{{ path_to_ddbb }}
```

# Troubleshooting

## Reallocate unassigned shards

Elasticsearch makes 5 attempts to assign the shard but if it fails to be
assigned after 5 attempts, the shards will remain unassigned. There is
a solution to this issue in order to bring the cluster to green state.

You can disable the replicas on the failing index and then enable replicas
back.

* Disable Replica

    ```bash
    curl -X PUT "<ES_endpoint>/<index_name>/_settings" -H 'Content-Type: application/json' -d'
    {
        "index" : {
            "number_of_replicas" : 0
        }
    }'
    ```
* Enable the Replica back:

    ```bash
    curl -X PUT "<ES_endpoint>/<index_name>/_settings" -H 'Content-Type: application/json' -d'
    {
        "index" : {
            "number_of_replicas" : 1
        }
    }'
    ```

Please note that it will take some time for the shards to be completely assigned
and hence you might see intermittent cluster status as YELLOW.
