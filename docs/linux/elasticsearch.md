---
title: Commands for elasticsearch
date: 20170529
author: Lyz
---

# [Searching documents](https://mindmajix.com/elasticsearch/curl-syntax-with-examples)

We use HTTP requests to talk to ElasticSearch. A HTTP request is made up of
several components such as the URL to make the request to, HTTP verbs (GET, POST
etc) and headers. In order to succinctly and consistently describe HTTP requests
the ElasticSearch documentation uses cURL command line syntax. This is also the
standard practice to describe requests made to ElasticSearch within the user
community.

## Get all documents

An example HTTP request using CURL syntax looks like this:

```bash
curl \
    -H 'Content-Type: application/json' \
    -XPOST "https://localhost:9200/_search" \
    -d' { "query": { "match_all": {} }}'
```

## Get documents that match a string

```bash
curl \
    -H 'Content-Type: application/json' \
    -XPOST "https://localhost:9200/_search" \
    -d' { "query": { "query_string": {"query": "test company"} }}'
```


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
curl -X POST {{ url }}/{{ indice_name }}/_close
```

Then restore

```bash
curl {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}/_restore?wait_for_completion=true
```

If you want to restore only one index, use:

```bash
curl -X POST "{{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}/_restore?pretty" -H 'Content-Type: application/json' -d'
{
    "indices": "{{ index_to_restore }}",
}'
```

## Delete snapshot

```bash
curl -XDELETE {{ url }}/_snapshot/{{ backup_path }}/{{ snapshot_name }}
```

## Delete snapshot repository

```bash
curl -XDELETE {{ url }}/_snapshot/{{ backup_path }}
```

## [Delete snapshots older than X](https://discuss.elastic.co/t/deleting-old-snapshots/134085/4)

!!! note "File: curator.yml" \`\`\`yaml client: hosts: - 'a data node' port:
9200 url_prefix: use_ssl: False certificate: client_cert: client_key:
ssl_no_validate: False http_auth: timeout: 30 master_only: False

````
logging:
loglevel: INFO
logfile: D:\CuratorLogs\logs.txt
logformat: default
blacklist: ['elasticsearch', 'urllib3']
```
````

!!! note "File: delete_old_snapshots.yml"
`yaml     actions:     1:     action: delete_snapshots     description: >-     Delete snapshots from the selected repository older than 100 days     (based on creation_date), for everything but 'citydirectory-' prefixed snapshots.     options:     repository: 'dcs-elastic-snapshot'     disable_action: False     filters:     - filtertype: pattern     kind: prefix     value: citydirectory-     exclude: True     - filtertype: age     source: creation_date     direction: older     unit: days     unit_count: 100     `

# Information gathering

## Get status of cluster

```bash
curl {{ url }}/_cluster/health?pretty
curl {{ url }}/_cat/nodes?v
curl {{ url }}/_cat/indices?v
curl {{ url }}/_cat/shards
```

If you've got red status, use the following command to choose the first
unassigned shard that it finds and explains why it cannot be allocated to a
node.

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

If you encountered errors while reindexing `source_index` to `destination_index`
it can be because the cluster hit a timeout on the scroll locks. As a work
around, you can increase the timeout period to a reasonable value and then
reindex. The default AWS values are search context of 5 minutes, socket timeout
of 30 seconds, and batch size of 1,000.

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

And
[check the evolution of the task](https://linuxhint.com/elasticsearch-reindex-all-indices-and-check-the-status/)
with:

```bash
curl 'https://elastic.url/_tasks?detailed=true&actions=*reindex&group_by=parents&pretty=true'
```

The output is quite verbose, so I use `vimdiff` to see the differences between
instant states.

If you see there are no tasks running, check the indices status to see if the
reindex ended well.

```bash
curl https://elastic.url/_cat/indices
```

After the reindex process is complete, you can reset your desired replica count
and remove the refresh interval setting.

# KNN

## [KNN sizing](https://opendistro.github.io/for-elasticsearch-docs/docs/knn/performance-tuning/#estimating-memory-usage)

Typically, in an Elasticsearch cluster, a certain portion of RAM is set aside
for the JVM heap. The k-NN plugin allocates graphs to a portion of the remaining
RAM. This portion’s size is determined by the circuit_breaker_limit cluster
setting. By default, the circuit breaker limit is set at 50%.

The memory required for graphs is estimated to be \`1.1 * (4 * dimension

- 8 * M)\` bytes/vector.

To get the `dimension` and `m` use the `/index` elasticsearch endpoint. To get
the number of vectors, use `/index/_count`. The number of vectors is the same as
the number of documents.

As an example, assume that we have 1 Million vectors with a dimension of 256 and
M of 16, and the memory required can be estimated as:

```
1.1 * (4 *256 + 8 * 16) * 1,000,000 ~= 1.26 GB
```

!!! note "Remember that having a replica will double the total number of
vectors."

I've seen some queries work with indices that required 120% of the available
memory for the KNN.

A good way to see if it fits, is [warming up the knn vectors](#knn-warmup). If
the process returns a timeout, you probably don't have enough memory.

## [KNN warmup](https://opendistro.github.io/for-elasticsearch-docs/docs/knn/api/#warmup-operation)

The Hierarchical Navigable Small World (HNSW) graphs that are used to perform an
approximate k-Nearest Neighbor (k-NN) search are stored as .hnsw files with
other Apache Lucene segment files. In order for you to perform a search on these
graphs using the k-NN plugin, these files need to be loaded into native memory.

If the plugin has not loaded the graphs into native memory, it loads them when
it receives a search request. This loading time can cause high latency during
initial queries. To avoid this situation, users often run random queries during
a warmup period. After this warmup period, the graphs are loaded into native
memory and their production workloads can begin. This loading process is
indirect and requires extra effort.

As an alternative, you can avoid this latency issue by running the k-NN plugin
warmup API operation on whatever indices you’re interested in searching. This
operation loads all the graphs for all of the shards (primaries and replicas) of
all the indices specified in the request into native memory.

After the process finishes, you can start searching against the indices with no
initial latency penalties. The warmup API operation is idempotent, so if a
segment’s graphs are already loaded into memory, this operation has no impact on
those graphs. It only loads graphs that aren’t currently in memory.

This request performs a warmup on three indices:

```
GET /_opendistro/_knn/warmup/index1,index2,index3?pretty
{
  "_shards" : {
    "total" : 6,
    "successful" : 6,
    "failed" : 0
  }
}
```

`total` indicates how many shards the k-NN plugin attempted to warm up. The
response also includes the number of shards the plugin succeeded and failed to
warm up.

The call does not return until the warmup operation is complete or the request
times out. If the request times out, the operation still continues on the
cluster. To monitor the warmup operation, use the Elasticsearch `_tasks` API:

```
GET /_tasks
```

# Troubleshooting

## Deal with the AWS service timeout

AWS' Elasticsearch service is exposed behind a load balancer that returns a
timeout after 300 seconds. If the query you're sending takes longer you won't be
able to retrieve the information.

You can consider using Asynchronous search which requires Elasticsearch 7.10 or
later. Asynchronous search lets you run search requests that run in the
background. You can monitor the progress of these searches and get back partial
results as they become available. After the search finishes, you can save the
results to examine at a later time.

If the query you're running is a KNN one, you can try:

- Using the [knn warmup api](#knn-warmup) before running initial queries.

- Scaling up the instances: Amazon ES uses half of an instance's RAM for the
  Java heap (up to a heap size of 32 GiB). By default, KNN uses up to 50% of the
  remaining half, so an instance type with 64 GiB of RAM can accommodate 16 GiB
  of graphs (64 * 0.5 * 0.5). Performance can suffer if graph memory usage
  exceeds this value.

- In a less recommended approach, you can make more percentage of memory
  available for KNN operations.

  Open Distro for Elasticsearch lets you modify all KNN settings using the
  `_cluster/settings` API. On Amazon ES, you can change all settings except
  `knn.memory.circuit_breaker.enabled` and `knn.circuit_breaker.triggered`.

  You can change the circuit breaker settings as:

  ```
  PUT /_cluster/settings
  {
    "persistent" : {
      "knn.memory.circuit_breaker.limit" : "<value%>"
    }
  }
  ```

You could also do
[performance tuning your KNN request](https://opendistro.github.io/for-elasticsearch-docs/docs/knn/performance-tuning/).

## Fix Circuit breakers triggers

The [`elasticsearch_exporter`](elasticsearch_exporter.md) has a
`elasticsearch_breakers_tripped` metric, which counts then number of Circuit
Breakers triggered of the different kinds. The Grafana dashboard paints a count
of all the triggers with a big red number, which may scare you at first.

Lets first understand what are Circuit Breakers. Elasticsearch is built with
Java and as such depends on the JVM heap for many operations and caching
purposes. By default in AWS, each data node is assigned half the RAM to be used
for heap for ES. In Elasticsearch the default Garbage Collector is
Concurrent-Mark and Sweep (CMS). When the JVM Memory Pressure reaches 75%, this
collector pauses some threads and attempts to reclaim some heap space. High heap
usage occurs when the garbage collection process cannot keep up. An indicator of
high heap usage is when the garbage collection is incapable of reducing the heap
usage to around 30%.

When a request reaches the ES nodes, circuit breakers estimate the amount of
memory needed to load the required data. The cluster then compares the estimated
size with the configured heap size limit. If the estimated size of your data is
greater than the available heap size, the query is terminated. As a result, a
CircuitBreakerException is thrown to prevent overloading the node.

In essence, these breakers are present to prevent a request overloading a data
node and consuming more heap space than that node can provide at that time. If
these breakers weren't present, then the request will use up all the heap that
the node can provide and this node will then restart due to OOM.

Lets assume a data node has 16GB heap configured, When the parent circuit
breaker is tripped, then a similar error is thrown:

```json
"error": {
        "root_cause": [
            {
                "type": "circuit_breaking_exception",
                "reason": "[parent] Data too large, data for [<HTTP_request>] would be [16355096754/15.2gb], which is larger than the limit of [16213167308/15gb], real usage: [15283269136/14.2gb], new bytes reserved: [1071827618/1022.1mb]",
               }
      ]
}
```

The parent circuit breaker (a circuit breaker type) is responsible for the
overall memory usage of your Elasticsearch cluster. When a parent circuit
breaker exception occurs, the total memory used across all circuit breakers has
exceeded the set limit. A parent breaker throws an exception when the cluster
exceeds 95% of 16 GB, which is 15.2 GB of heap (in above example).

A circuit breaking exception is generally caused by high JVM. When the JVM
Memory Pressure is high, it indicates that a large portion of one or more data
nodes configured heap is currently being used heavily, and as such, the
frequency of the circuit breakers being tripped increases as there is not enough
heap available at the time to process concurrent smaller or larger requests.

It is worth noting that that the error can also be thrown by a certain request
that would just consume all the available heap on a certain data node at the
time such as an intensive search query.

If you see numerous spikes to the high 90%, with occasionally spikes to 100%,
it's not uncommon for the parent circuit breaker to be tripped in response to
requests.

To troubleshoot circuit breakers, you'll then have to address the High JVM
issues, which can be caused by:

- Increase in the number of requests to the cluster. Check the IndexRate and
  SearchRate metrics in to determine your current load.
- Aggregation, wildcards, and using wide time ranges in your queries.
- Unbalanced shard allocation across nodes or too many shards in a cluster.
- Index mapping explosions.
- Using the fielddata data structure to query data. Fielddata can consume a
  large amount of heap space, and remains in the heap for the lifetime of a
  segment. As a result, JVM memory pressure remains high on the cluster when
  fielddata is used.

Here's what happens as JVM memory pressure increases in AWS:

- At 75%: Amazon ES triggers the Concurrent Mark Sweep (CMS) garbage collector.
  The CMS collector runs alongside other processes to keep pauses and
  disruptions to a minimum. The garbage collection is a CPU-intensive process.
  If JVM memory pressure stays at this percentage for a few minutes, then you
  could encounter ClusterBlockException, JVM OutOfMemoryError, or other cluster
  performance issues.
- Above 75%: If the CMS collector fails to reclaim enough memory and usage
  remains above 75%, Amazon ES triggers a different garbage collection
  algorithm. This algorithm tries to free up memory and prevent a JVM
  OutOfMemoryError (OOM) exception by slowing or stopping processes.
- Above 92% for 30 minutes: Amazon ES blocks all write operations.
- Around 95%: Amazon ES kills processes that try to allocate memory. If a
  critical process is killed, one or more cluster nodes might fail.
- At 100%: Amazon ES JVM is configured to exit and eventually restarts on
  OutOfMemory (OOM).

To resolve high JVM memory pressure, try the following tips:

- Reduce incoming traffic to your cluster, especially if you have a heavy
  workload.

- Consider scaling the cluster to obtain more JVM memory to support your
  workload. As mentioned above each data node gets half the RAM allocated to be
  used as Heap. Consider scaling to a data node type with more RAM and hence
  more Available Heap. Thereby increasing the parent circuit breaker limit.

- If cluster scaling isn't possible, try reducing the number of shards by
  deleting old or unused indices. Because shard metadata is stored in memory,
  reducing the number of shards can reduce overall memory usage.

- Enable slow logs to identify faulty requests. Note: Before enabling
  configuration changes, verify that JVM memory pressure is below 85%. This way,
  you can avoid additional overhead to existing resources.

- Optimize search and indexing requests, and choose the correct number of
  shards.

- Disable and avoid using fielddata. By default, fielddata is set to "false" on
  a text field unless it's explicitly defined as otherwise in index mappings.

  Field data is a potentially a huge consumer of JVM Heap space. This build up
  of field data occurs when aggregations are run on fields that are of type
  `text`. More on how you can periodically clear field data below.

- Change your index mapping type to a `keyword`, using reindex API. You can use
  the `keyword` type as an alternative for performing aggregations and sorting
  on text fields.

  As mentioned in above point, by aggregating on `keyword` type instead of
  `text`, no field data has to be built on demand and hence won't consume
  precious heap space. Look into the commonly aggregated fields in index
  mappings and ensure they are not of type `text`.

  If they are, you can consider changing them to `keyword`. You will have to
  create a new index with the desired mapping and then use the Reindex API to
  transfer over the documents from the source index to the new index. Once
  Re-index has completed then you can delete the old index.

- Avoid aggregating on text fields to prevent increases in field data. When you
  use more field data, more heap space is consumed. Use the cluster stats API
  operation to check your field data.

- Clear the fielddata cache with the following API call:

  ```
  POST /index_name/_cache/clear?fielddata=true (index-level cache)
  POST */_cache/clear?fielddata=true (cluster-level cache)
  ```

Generally speaking, if you notice your workload (search rate and index rate)
remaining consistent during these high spikes and non of the above optimizations
can be applied or if they have already been applied and the JVM is still high
during these workload times, then it is an indication that the cluster needs to
be scaled in terms of JVM resources to cope with this workload.

You can't reset the 'tripped' count. This is a Node level metric and thus will
be reset to `0` when the Elasticsearch Service is restarted on that Node. Since
in AWS it's a managed service, unfortunately you will not have access to the
underlaying EC2 instance to restart the ES Process.

However the ES Process can be restarted on your end (on all nodes) in the
following ways:

- Initiate a Configuration Change that causes a blue/green deployment : When you
  initiate a configuration change, a subsequent blue/green deployment process is
  launched in which we launch a new fleet that matches the desired
  configuration. The old fleet continues to run and serve requests.
  Simultaneously, data in the form of shards are then migrated from the old
  fleet to the new fleet. Once all this data has been migrated the old fleet is
  terminated and the new one takes over.

  During this process ES is restarted on the Nodes.

  Ensure that CPU Utilization and JVM Memory Pressure are below the recommended
  80% thresholds to prevent any issues with this process as it uses clusters
  resources to initiate and complete.

  You can scale the EBS Volumes attached to the data nodes by an arbitrary
  amount such as 1GB, wait for the blue/green to complete and then scale it
  back.

- Wait for a new service software release and update the service software of the
  Cluster.

  This will also cause a blue/green and hence ES process will be restarted on
  the nodes.

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
metric caused the node to go down. Check the
[Fix Circuit breaker triggers](#fix-circuit-breaker-triggers) section above to
see how to solve that case.

### Reallocate unassigned shards

Elasticsearch makes 5 attempts to assign the shard but if it fails to be
assigned after 5 attempts, the shards will remain unassigned. There is a
solution to this issue in order to bring the cluster to green state.

You can disable the replicas on the failing index and then enable replicas back.

- Disable Replica

  ```bash
  curl -X PUT "<ES_endpoint>/<index_name>/_settings" -H 'Content-Type: application/json' -d'
  {
      "index" : {
          "number_of_replicas" : 0
      }
  }'
  ```

- Enable the Replica back:

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
