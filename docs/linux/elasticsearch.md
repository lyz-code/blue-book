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

# [Reindex an index](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/remote-reindex.html#remote-reindex-largedatasets)

If you encountered errors while reindexing `source_index` to
`destination_index` it can be because the cluster hit a timeout on the scroll
locks. As a work around, you can increase the timeout period to a reasonable
value and then reindex. The default AWS values are search context of 5 minutes,
socket timeout of 30 seconds, and batch size of 1,000.

First clear the cache of the index with:

```bash
curl -X POST https://elastic.url/destination_index/_cache/clear
```

If the index is big, they suggest to disable replicas in your destination index
by setting number_of_replicas to 0 and re-enable them once the reindex process
is complete.

To get the current state use:

```bash
curl https://elastic.url/destination_index/_settings
```

Then disable the replicas with:

```bash
curl -X PUT \
    https://elastic.url/destination_index \
  -H 'Content-Type: application/json' \
  -d '{"settings": {"refresh_interval": -1, "number_of_replicas": 0}}
```

Now you can reindex the index with:

```bash
curl -X POST \
  https://elastic.url/_reindex?wait_for_completion=false\&timeout=10m\&scroll=10h\&pretty=true \
  -H 'Content-Type: application/json' \
  -d '{"source": { "remote": { "host": "https://elastic.url:443", "socket_timeout": "60m" }, "index": "source_index" }, "dest": {"index": "destination_index"}}'
```

And [check the evolution of the
task](https://linuxhint.com/elasticsearch-reindex-all-indices-and-check-the-status/)
with:

```bash
curl 'https://elastic.url/_tasks?detailed=true&actions=*reindex&group_by=parents&pretty=true'
```

The output is quite verbose, so I use `vimdiff` to see the differences between
instant states.

If you see there are no tasks running, check the indices status to see if
the reindex ended well.

```bash
curl https://elastic.url/_cat/indices
```


After the reindex process is complete, you can reset your desired replica count
and remove the refresh interval setting.

# Troubleshooting

## Recover from yellow state

A yellow cluster represents that some of the replica shards in the cluster are
unassigned. I can see that around 14 replica shards are unassigned.

You can confirm the state of the cluster with the following commands

```bash
curl <domain-endpoint>_cluster/health?pretty
curl -X GET <domain-endpoint>/_cat/shards | grep UNASSIGNED
curl -X GET <domain-endpoint>/_cat/indices | grep yellow
```

If you have metrics of the JVMMemoryPressure of the nodes, check if the memory
of a node reached 100% around the time the cluster reached yellow state.

One can generally confirm the reason for a cluster going yellow by looking at
the output of the following API call:

```bash
curl -X GET <domain-endpoint>/_cluster/allocation/explain | jq
```

If it shows a `CircuitBreakerException`, it confirms that a spike in the JVM
metric caused the node to go down.

The JVM memory pressure specifies the percentage of the Java heap in a cluster
node. It's determined by the following factors:

* The amount of data on the cluster in proportion to the amount of resources.
* The query load on the cluster.

Here's what happens as JVM memory pressure increases:

* At 75%: Amazon ES triggers the Concurrent Mark Sweep (CMS) garbage collector.
    The CMS collector runs alongside other processes to keep pauses and
    disruptions to a minimum. The garbage collection is a CPU-intensive process.
    If JVM memory pressure stays at this percentage for a few minutes, then you
    could encounter ClusterBlockException, JVM OutOfMemoryError, or other
    cluster performance issues.
* Above 75%: If the CMS collector fails to reclaim enough memory and usage
    remains above 75%, Amazon ES triggers a different garbage collection
    algorithm. This algorithm tries to free up memory and prevent a JVM
    OutOfMemoryError (OOM) exception by slowing or stopping processes.
* Above 92% for 30 minutes: Amazon ES blocks all write operations.
* Around 95%: Amazon ES kills processes that try to allocate memory. If
    a critical process is killed, one or more cluster nodes might fail.
* At 100%: Amazon ES JVM is configured to exit and eventually restarts on
    OutOfMemory (OOM).

To prevent high JVM memory pressure:

* Avoid queries on wide ranges, such as aggregations, wildcard or big time range
    queries.
* Avoid sending a large number of requests at the same time.
* Be sure that you have the appropriate number of shards.
* Be sure that your shards are distributed evenly between nodes.
* When possible, avoid aggregating on text fields. This helps prevent increases
    in field data. The more field data you have, the more heap space is
    consumed. Use the GET `_cluster/stats` API operation to check field data.
* If you must aggregate on text fields, change the mapping type to keyword.


If JVM memory pressure gets too high, use the following API operations to clear
the field data cache: `POST /index_name/_cache/clear` (index-level cache) and `POST
/_cache/clear` (cluster-level cache).

Note: Clearing the cache can disrupt queries that are in progress.

### Reallocate unassigned shards

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
