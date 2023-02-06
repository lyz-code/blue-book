---
title: Velero
date: 20230104
author: Lyz
---

[Velero](https://velero.io/) is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

# Installation

## Client instalation

You interact with `velero` through a  client command line.

* Download the [latest release’s
  tarball](https://github.com/vmware-tanzu/velero/releases/latest) for your client platform.
* Extract the tarball:

  ```bash
  tar -xvf <RELEASE-TARBALL-NAME>.tar.gz
  ```
* Move the extracted velero binary to somewhere in your `$PATH`.

## Server configuration

Instead of configuring the server through the `velero` command line it's better to use the [vmware-tanzu/velero](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero) chart.

To configure backup policy use the `extraObjects` chart field. For example to backup everything with the next policy do:

* Hourly backups for a day.
* Daily backups for a month.
* Montly backups for a year.
* Yearly backups forever.

```yaml
extraObjects:
  - apiVersion: velero.io/v1
    kind: Schedule
    metadata:
      creationTimestamp: null
      name: backup-1h
      namespace: velero
    spec:
      schedule: '@every 1h'
      template:
        csiSnapshotTimeout: 0s
        hooks: {}
        includedNamespaces:
        - '*'
        metadata: {}
        ttl: 25h0m0s
      useOwnerReferencesInBackup: false
    status: {}
  - apiVersion: velero.io/v1
    kind: Schedule
    metadata:
      creationTimestamp: null
      name: backup-1d
      namespace: velero
    spec:
      schedule: '@every 24h'
      template:
        csiSnapshotTimeout: 0s
        hooks: {}
        includedNamespaces:
        - '*'
        metadata: {}
        ttl: 730h0m0s
      useOwnerReferencesInBackup: false
    status: {}
  - apiVersion: velero.io/v1
    kind: Schedule
    metadata:
      creationTimestamp: null
      name: backup-1m
      namespace: velero
    spec:
      schedule: '@every 730h'
      template:
        csiSnapshotTimeout: 0s
        hooks: {}
        includedNamespaces:
        - '*'
        metadata: {}
        ttl: 8760h0m0s
      useOwnerReferencesInBackup: false
    status: {}
  - apiVersion: velero.io/v1
    kind: Schedule
    metadata:
      creationTimestamp: null
      name: backup-1y
      namespace: velero
    spec:
      schedule: '@every 8760h'
      template:
        csiSnapshotTimeout: 0s
        hooks: {}
        includedNamespaces:
        - '*'
        metadata: {}
        ttl: 0s
      useOwnerReferencesInBackup: false
    status: {}
```

## Monitorization

Assuming you're using [prometheus](prometheus.md) you can add the next prometheus rules in the chart:

```yaml
# -------------------------------------------------------------
# --   Monitor the failures when doing backups or restores   --
# -------------------------------------------------------------
- alert: VeleroBackupPartialFailures
  annotations:
    message: Velero backup {{ $labels.schedule }} has {{ $value | humanizePercentage }} partialy failed backups.
  expr: increase(velero_backup_partial_failure_total{schedule!=""}[1h]) > 0
  for: 15m
  labels:
    severity: warning
- alert: VeleroBackupFailures
  annotations:
    message: Velero backup {{ $labels.schedule }} has {{ $value | humanizePercentage }} failed backups.
  expr: increase(velero_backup_failure_total{schedule!=""}[1h]) > 0
  for: 15m
  labels:
    severity: warning
- alert: VeleroBackupSnapshotFailures
  annotations:
    message: Velero backup {{ $labels.schedule }} has {{ $value | humanizePercentage }} failed snapshot backups.
  expr: increase(velero_volume_snapshot_failure_total{schedule!=""}[1h]) > 0
  for: 15m
  labels:
    severity: warning
- alert: VeleroRestorePartialFailures
  annotations:
    message: Velero restore {{ $labels.schedule }} has {{ $value | humanizePercentage }} partialy failed restores.
  expr: increase(velero_restore_partial_failure_total{schedule!=""}[1h]) > 0
  for: 15m
  labels:
    severity: warning
- alert: VeleroRestoreFailures
  annotations:
    message: Velero restore {{ $labels.schedule }} has {{ $value | humanizePercentage }} failed restores.
  expr: increase(velero_restore_failure_total{schedule!=""}[1h]) > 0
  for: 15m
  labels:
    severity: warning
    
# ------------------------------------------------
# --   Monitor the backup rate of each policy   --
# ------------------------------------------------
- alert: VeleroHourlyBackupFailure
  annotations:
    message: There are no new hourly velero backups in the last hour.
  expr: time() - velero_backup_last_successful_timestamp{schedule="backup-1h"} > 3600 
  for: 10m
  labels:
    severity: warning
- alert: VeleroDailyBackupFailure
  annotations:
    message: There are no new daily velero backups in the last day.
  expr: time() - velero_backup_last_successful_timestamp{schedule="backup-1d"} > 3600 * 24 
  for: 15m
  labels:
    severity: warning
- alert: VeleroMonthlyBackupFailure
  annotations:
    message: There are no new montly velero backups in the last month.
  expr: time() - velero_backup_last_successful_timestamp{schedule="backup-1m"} > 3600 * 24 * 30
  for: 15m
  labels:
    severity: warning
- alert: VeleroYearlyBackupFailure
  annotations:
    message: There are no new yearly velero backups in the last year.
  expr: time() - velero_backup_last_successful_timestamp{schedule="backup-1y"} > 3600 * 24 * 365
  for: 15m
  labels:
    severity: warning
    
# -------------------------------------
# --   Monitor the backup cleaning   --
# -------------------------------------
- alert: VeleroBackupCleaningFailure
  annotations:
    message: There are more backups than the expected, deletion policy may not be working well.
    # Desired backups:
    # - 25 hourlys
    # - 31 dailys
    # - 12 monthlys
    # - 10 yearlys
  expr: velero_backup_total > (25 + 31 + 12 + 10)
  for: 15m
  labels:
    severity: warning
```

# Usage

## Restore backups

To get the available backups you can use:

```bash
velero get backups
```

Imagine we want to restore the backup `backup-1h-20230109125511`.

We first need to update your backup storage location to read-only mode. This prevents backup objects from being created or deleted in the backup storage location during the restore process.

```bash
kubectl patch backupstoragelocation default \
    --namespace velero \
    --type merge \
    --patch '{"spec":{"accessMode":"ReadOnly"}}'
```

Where `default` is the only backup storage location I have, check what's the name of your's by running `kubectl get backupstoragelocation -n velero`.

You'd now run the `velero restore create` commands (we'll see more examples in next sections). For example:

* Create a restore with a default name `backup-1-<timestamp>` from backup `backup-1`.

  ```bash
  velero restore create --from-backup backup-1
  ```

* Create a restore with name `restore-1` from a backup called `backup-1` .

  ```bash
  velero restore create restore-1 --from-backup backup-1
  ```

* Create a restore from the latest successful backup triggered by schedule `schedule-1`.

  ```bash
  velero restore create --from-schedule schedule-1
  ```

When you run the command they'll will show you how to monitor the evolution of the restore with commands similar to:

```bash
velero restore describe backup-1h-20230109125511-20230110145314
velero restore logs backup-1h-20230109125511-20230110145314
```

Once they're done, remember to reset the ReadWrite permissions on the backup location.

```bash
kubectl patch backupstoragelocation default \
    --namespace velero \
    --type merge \
    --patch '{"spec":{"accessMode":"ReadWrite"}}'
```

### [Overwrite existing resources](https://velero.io/docs/main/restore-reference/#restore-existing-resource-policy)

The only way I've found to do this is by removing the namespace and then restore it with `velero`. If you want to try to do it in a cleaner way keep on reading (although for me it didn't work!).

By default, Velero is configured to be non-destructive during a restore. This means that it will never overwrite data that already exists in your cluster. When Velero attempts to create a resource during a restore, the resource being restored is compared to the existing resources on the target cluster by the Kubernetes API Server. If the resource already exists in the target cluster, Velero skips restoring the current resource and moves onto the next resource to restore, without making any changes to the target cluster.

You can change this policy for a restore by using the `--existing-resource-policy` restore flag. The available options are `none` (default) and `update`. If you choose to update existing resources during a restore (`--existing-resource-policy=update`), Velero will attempt to update an existing resource to match the resource being restored:

* If the existing resource in the target cluster is the same as the resource Velero is attempting to restore, Velero will add a `velero.io/backup-name` label with the backup name and a `velero.io/restore-name` label with the restore name to the existing resource. If patching the labels fails, Velero adds a restore error and continues restoring the next resource.

* If the existing resource in the target cluster is different from the backup, Velero will first try to patch the existing resource to match the backup resource. If the patch is successful, Velero will add a `velero.io/backup-name` label with the backup name and a `velero.io/restore-name` label with the restore name to the existing resource. If the patch fails, Velero adds a restore warning and tries to add the `velero.io/backup-name` and `velero.io/restore-name` labels on the resource. If the labels patch also fails, then Velero logs a restore error and continues restoring the next resource.

Even with these flags the restore of PersistentVolumeClaim doesn't work.

### Restore only a namespace

```bash
velero restore create --include-namespaces monitoring
```

### Restore only a subsection of the backup

You can list the backed up resources with:

```bash
velero describe backups backup-1h-20230109125511
```

Then you can create a restore for only `persistentvolumeclaims` and `persistentvolumes` within a backup.

```bash
velero restore create --from-backup backup-2 --include-resources persistentvolumeclaims,persistentvolumes
```

### Restore from a snapshot not done by velero

If you want to use an EBS snapshot that is not managed by `velero` you need to:

* Locate a `velero` backup which has done a backup of the resources you want to restore. Imagine it's `backup-1`. 
* Go to the `backup-1` directory in the S3 bucket where velero stores the data.
* Download and decompress the `backup-1-volumesnapshots.json.gz` file.
* Edit the result `json` and restore the `snap-.*` strings of the `pvc` that you want to restore for the ones that are not managed by velero.
* Compress the file and upload it to the S3 bucket.
* Restore the backup

Keep in mind that if you are trying to restore a backup created by an EBS lifecycle hook you'll receive an error when restoring because these snapshots have a tag that starts with `aws:` which is reserved for AWS only. The solution is to copy the snapshot into a new one, assign a tag, for example `Name`, and use that snapshot instead. If you don't define any tag you'll get another error :/.


# [Overview of Velero](https://velero.io/docs/main/how-velero-works/)

Each Velero operation – on-demand backup, scheduled backup, restore – is a custom resource, defined with a Kubernetes Custom Resource Definition (CRD) and stored in etcd. Velero also includes controllers that process the custom resources to perform backups, restores, and all related operations.

You can back up or restore all objects in your cluster, or you can filter objects by type, namespace, and/or label.

## Backups

### [On demand backups](https://velero.io/docs/main/how-velero-works/#on-demand-backups)

The backup operation:

* Uploads a tarball of copied Kubernetes objects into cloud object storage.
* Calls the cloud provider API to make disk snapshots of persistent volumes, if specified.

You can optionally specify backup hooks to be executed during the backup. For example, you might need to tell a database to flush its in-memory buffers to disk before taking a snapshot. 

Note that cluster backups are not strictly atomic. If Kubernetes objects are being created or edited at the time of backup, they might not be included in the backup. The odds of capturing inconsistent information are low, but it is possible.

### [Scheduled backups](https://velero.io/docs/main/how-velero-works/#scheduled-backups)

The schedule operation allows you to back up your data at recurring intervals. You can create a scheduled backup at any time, and the first backup is then performed at the schedule’s specified interval. These intervals are specified by a Cron expression.

Velero saves backups created from a schedule with the name `<SCHEDULE NAME>-<TIMESTAMP>`, where `<TIMESTAMP>` is formatted as `YYYYMMDDhhmmss`.

### [Backup workflow](https://velero.io/docs/main/how-velero-works/#backup-workflow)

When you run `velero backup create test-backup`:

* The Velero client makes a call to the Kubernetes API server to create a `Backup` object.
* The `BackupController` notices the new `Backup` object and performs validation.
* The `BackupController` begins the backup process. It collects the data to back up by querying the API server for resources.
* The `BackupController` makes a call to the object storage service – for example, AWS S3 – to upload the backup file.

### [Set expiration date of a backup](https://velero.io/docs/main/how-velero-works/#set-a-backup-to-expire)

When you create a backup, you can specify a TTL (time to live) by adding the flag `--ttl <DURATION>`. If Velero sees that an existing backup resource is expired, it removes:

* The backup resource
* The backup file from cloud object storage
* All `PersistentVolume` snapshots
* All associated Restores

The TTL flag allows the user to specify the backup retention period with the value specified in hours, minutes and seconds in the form `--ttl 24h0m0s`. If not specified, a default TTL value of 30 days will be applied.

If backup fails to delete, a label `velero.io/gc-failure=<Reason>` will be added to the backup custom resource.

You can use this label to filter and select backups that failed to delete.

## [Restores](https://velero.io/docs/main/how-velero-works/#restores)
    
The restore operation allows you to restore all of the objects and persistent volumes from a previously created backup. You can also restore only a filtered subset of objects and persistent volumes. 

By default, backup storage locations are created in read-write mode. However, during a restore, you can configure a backup storage location to be in read-only mode, which disables backup creation and deletion for the storage location. This is useful to ensure that no backups are inadvertently created or deleted during a restore scenario.

A restored object includes a label with key velero.io/restore-name and value <RESTORE NAME>.

You can optionally specify restore hooks to be executed during a restore or after resources are restored. For example, you might need to perform a custom database restore operation before the database application containers start.

### Restore workflow

When you run `velero restore create`:

* The Velero client makes a call to the Kubernetes API server to create a `Restore` object.
* The `RestoreController` notices the new `Restore` object and performs validation.
* The `RestoreController` fetches the backup information from the object storage service. It then runs some preprocessing on the backed up resources to make sure the resources will work on the new cluster. For example, using the backed-up API versions to verify that the restore resource will work on the target cluster.
* The `RestoreController` starts the restore process, restoring each eligible resource one at a time.

By default, Velero performs a non-destructive restore, meaning that it won’t delete any data on the target cluster. If a resource in the backup already exists in the target cluster, Velero will skip that resource. You can configure Velero to use an update policy instead using the `--existing-resource-policy` restore flag. When this flag is set to update, Velero will attempt to update an existing resource in the target cluster to match the resource from the backup.

# References

* [Docs](https://velero.io/docs/main/)
* [Source](https://github.com/vmware-tanzu/velero)
* [Home](https://velero.io/)
