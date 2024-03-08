This Postgres operator manages PostgreSQL clusters on Kubernetes (K8s):

- The operator watches additions, updates, and deletions of PostgreSQL cluster manifests and changes the running clusters accordingly. For example, when a user submits a new manifest, the operator fetches that manifest and spawns a new Postgres cluster along with all necessary entities such as K8s StatefulSets and Postgres roles. See [this Postgres cluster manifest](https://github.com/zalando/postgres-operator/blob/master/manifests/complete-postgres-manifest.yaml) for settings that a manifest may contain.
- The operator also watches updates to its own configuration and alters running Postgres clusters if necessary. For instance, if the Docker image in a pod is changed, the operator carries out the rolling update, which means it re-spawns pods of each managed StatefulSet one-by-one with the new Docker image.
- Finally, the operator periodically synchronizes the actual state of each Postgres cluster with the desired state defined in the cluster's manifest.
- The operator aims to be hands free as configuration works only via manifests. This enables easy integration in automated deploy pipelines with no access to K8s directly.

# Usage

## [Create a database](https://postgres-operator.readthedocs.io/en/latest/user/)

Make sure you have [set up the operator](#installation). Then you can create a new Postgres cluster by applying manifest like this minimal example:

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: acid-minimal-cluster
spec:
  teamId: "acid"
  volume:
    size: 1Gi
  numberOfInstances: 2
  users:
    # database owner
    zalando:
    - superuser
    - createdb

    # role for application foo
    foo_user: # or 'foo_user: []'

  #databases: name->owner
  databases:
    foo: zalando
  postgresql:
    version: "15"
    parameters:
      password_encryption: scram-sha-256
```

Make sure, the `spec` section of the manifest contains at least a `teamId`, the `numberOfInstances` and the `postgresql` object with the `version` specified. The minimum volume size to run the postgresql resource on Elastic Block Storage (EBS) is `1Gi`. The `password_encryption` option is set to use a better algorithm than the default `md5`.

Then check if the database pods are coming up. Use the label `application=spilo` to filter and list the label `spilo-role` to see when the master is promoted and replicas get their labels.

```bash
kubectl get pods -l application=spilo -L spilo-role -w
```

The operator also emits K8s events to the Postgresql CRD which can be inspected in the operator logs or with:

```bash
kubectl describe postgresql acid-minimal-cluster
```

Connect to PostgreSQL with a port-forward on one of the database pods (e.g. the master) from your machine. Use labels to filter for the master pod of our test cluster.

```bash
# get name of master pod of acid-minimal-cluster
export PGMASTER=$(kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=acid-minimal-cluster,spilo-role=master)

# set up port forward
kubectl port-forward $PGMASTER 6432:5432
```

Open another CLI and connect to the database using e.g. the `psql` client. When connecting with a manifest role like `foo_user` user, read its password from the K8s secret which was generated when creating `acid-minimal-cluster`. As non-encrypted connections are rejected by default set SSL mode to require:

```bash
export PGPASSWORD=$(kubectl get secret postgres.acid-minimal-cluster.credentials.postgresql.acid.zalan.do -o 'jsonpath={.data.password}' | base64 -d)
export PGSSLMODE=require
psql -U postgres -h localhost -p 6432
```
# Installation
## Backup configuration

The Spilo images that are deployed when using the Zalando Postgres Operator, can do backups and WAL archiving to S3 (compatible) storage using WAL-E or it’s successor WAL-G. 
### Use S3 backend for backups
Using the S3 backend for backups has the [nasty side effect](https://github.com/zalando/postgres-operator/issues/1209) that all the backups of all deployed Postgres live under the same S3 bucket. Unless you [use custom pod configs](https://postgres-operator.readthedocs.io/en/latest/administrator/#custom-pod-environment-variables). This is a potential security risk that you may need to accept if you want to follow this path and don't want to use custom pod configs. This means that if an attacker gains control of one of your Postgres pods it may be able to access all the backups of all your databases (yikes! `(¬º-°)¬`). 

### [Restore a backup from S3 or clone from S3](https://postgres-operator.readthedocs.io/en/latest/user/#clone-from-s3) 
#### [Restore from logical backups ](https://vitobotta.com/2020/02/05/postgres-kubernetes-zalando-operator/)
If you feel confused between wall-g and wall-e backups, don't worry you are not alone ([1](https://github.com/zalando/postgres-operator/issues/568), [2](https://github.com/zalando/postgres-operator/issues/630), [3](https://github.com/zalando/postgres-operator/issues/1072)). So far there is no way to restore automatically from a logical backup. If you want to automatically restore from a backup when the cluster is installed you need to use the wall-e backups.

However if you need to restore from logical backups you can run the next script from within the database pod.

```bash 
DUMP_URL=s3://..... (URL of the .sql.gz dump)

apt update
apt install -y python3-pip postgresql-client

pip3 install s3cmd

cat > ~/.pgpass <<EOF
postgres-cluster:5432:postgres:postgres:$PGPASSWORD_SUPERUSER
EOF

chmod 0600 /root/.pgpass
/usr/local/bin/s3cmd \
  --no-check-certificate \
  --access_key=$AWS_ACCESS_KEY_ID \
  --secret_key=$AWS_SECRET_ACCESS_KEY \
  --region=$AWS_REGION \
  get --no-progress ${DUMP_URL} - | gunzip | psql -U postgres 
```

#### Restore from WAL-E

Cloning from S3 has the advantage that there is no impact on your production database.

```yaml 
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: acid-minimal-cluster-clone
spec:
  clone:
    uid: "efd12e58-5786-11e8-b5a7-06148230260c"
    cluster: "acid-minimal-cluster"
    timestamp: "2017-12-19T12:40:33+01:00"
```

Where `cluster` is a name of a source cluster that is going to be cloned. A new cluster will be cloned from S3, using the latest backup before the `timestamp`. Note, a time zone is required for `timestamp` in the format of +00:00 (UTC).

If you don't want to clone but directly to restore, the `metadata.name` and `spec.clone.cluster` will be the same. This will create a new database cluster with the same name but different UID, whereas the database will be in the state it was at the specified time. The backups and WAL files for the original DB are retained under the original UID, making it possible retry restoring. However, it is probably better to create a temporary clone for experimenting or finding out to which point you should restore.

The operator will try to find the WAL location based on the configured `wal_[s3|gs]_bucket` or `wal_az_storage_account` and the specified `uid`. You can find the UID of the source cluster in its metadata:

```yaml
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: acid-minimal-cluster
  uid: effd12e58-5786-11e8-b5a7-06148230260c
```

If your source cluster uses a WAL location different from the global configuration you can specify the full path under `s3_wal_path`


## Monitorization

### Postgres exporter
The operator [doesn't yet have prometheus metrics](https://github.com/zalando/postgres-operator/issues/1189) even though there is an [open pull request since 2021](https://github.com/zalando/postgres-operator/pull/1529). The main dev suggests to directly use the [postgres-exporter](https://github.com/zalando/postgres-operator/pull/1529) as [a sidecar](https://github.com/zalando/postgres-operator/issues/264)  while others suggest to use [this helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-postgres-exporter) connected to the pooler-replica service.

## [WalG exporter](https://thedatabaseme.de/2023/05/07/get-me-those-metrics-use-prometheus-wal-g-backup-exporter/)
It looks maintained although it hasn't yet reached `1.0.0`

## [Patroni exporter](https://github.com/Showmax/patroni-exporter)

Some also suggest to monitor Patroni, I still have no idea of what this is and the exporter is archived, so until I need it I'm going to pass.
# References
- [Source](https://github.com/zalando/postgres-operator)
- [Docs](https://postgres-operator.readthedocs.io)
- [Chart source](https://github.com/zalando/postgres-operator/tree/master/charts/postgres-operator)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
