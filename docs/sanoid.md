[Sanoid](https://github.com/jimsalterjrs/sanoid/) is the most popular tool right now, with it you can create, automatically thin, and monitor snapshots and pool health from a single eminently human-readable TOML config file at `/etc/sanoid/sanoid.conf`. Sanoid also requires a "defaults" file located at /etc/sanoid/sanoid.defaults.conf, which is not user-editable. A typical Sanoid system would have a single cron job:

```cron
* * * * * TZ=UTC /usr/local/bin/sanoid --cron
```
Note: Using UTC as timezone is recommend to prevent problems with daylight saving times

And its `/etc/sanoid/sanoid.conf` might look something like this:

```toml
[data/home]
	use_template = production
[data/images]
	use_template = production
	recursive = yes
	process_children_only = yes
[data/images/win7]
	hourly = 4

#############################
# templates below this line #
#############################

[template_production]
        frequently = 0
        hourly = 36
        daily = 30
        monthly = 3
        yearly = 0
        autosnap = yes
        autoprune = yes
```

Which would be enough to tell `sanoid` to take and keep 36 hourly snapshots, 30 dailies, 3 monthlies, and no yearlies for all datasets under `data/images` (but not `data/images` itself, since `process_children_only` is set). Except in the case of `data/images/win7`, which follows the same template (since it's a child of `data/images`) but only keeps 4 hourlies for whatever reason.

For more full details on sanoid.conf settings see their [wiki page](https://github.com/jimsalterjrs/sanoid/wiki/Sanoid#options)

The monitorization is designed to be done with Nagios, although there is some work in progress to add [Prometheus metrics](https://github.com/jimsalterjrs/sanoid/issues/675) and there is an [exporter](https://gitlab.com/aaron-w/sanoid_prometheus)

What I like of `sanoid`:

* It's popular
* It has hooks to run your scripts at various stages in the lifecycle of a snapshot.
* It also handles the process of sending the backups to other locations with `syncoid`
* It lets you search on all changes of a given file (or folder) over all available snapshots. This is useful in case you need to recover a file or folder but don't want to rollback an entire snapshot. with `findoid` (although when I used it it gave me an error :/)
* It's in the official repos

What I don't like:

* Last release is almost 2 years ago.
* The last commit to `master` is done a year ago.
* It's made in Perl

# Installation

The tool is in the official repositories so:

```bash
sudo apt-get install sanoid
```

You can find the example config file at `/usr/share/doc/sanoid/examples/sanoid.conf` and can copy it to `/etc/sanoid/sanoid.conf`

```bash
mkdir /etc/sanoid/
cp /usr/share/doc/sanoid/examples/sanoid.conf /etc/sanoid/sanoid.conf
cp /usr/share/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf
```

Edit `/etc/sanoid/sanoid.conf` to suit your needs. The `/etc/sanoid/sanoid.defaults.conf` file contains the default values and should not be touched, use it only for reference.

An example of a configuration can be:

```toml
######################
# Filesystem Backups #
######################

[main/backup]
  use_template = daily
  recursive = yes
[main/lyz]
  use_template = frequent

#############
# Templates #
#############

[template_daily]
  daily = 30
  monthly = 6

[template_frequent]
  frequently = 4
  hourly = 25
  daily = 30
  monthly = 6
```

During installation from the Debian repositories, the `systemd` timer unit `sanoid.timer` is created which is set to run `sanoid` every 15 minutes. Therefore there is no need to create an entry in crontab. Having a crontab entry in addition to the `sanoid.timer` will result in errors similar to `cannot create snapshot '<pool>/<dataset>@<snapshot>': dataset already exists`.

By default, the `sanoid.timer` timer unit runs the `sanoid-prune` service followed by the `sanoid` service. To edit any of the command-line options, you can edit these service files (`/lib/systemd/system/sanoid.timer`).

Also `recursive` is not set by default, so the dataset's children won't be backed up unless you set this option.

# Usage

`sanoid` runs in the back with the `systemd` service, so there is nothing you need to do for it to run.

To check the logs use `journalctl -eu sanoid`.

To manage the snapshots look at the [`zfs`](zfs.md#restore-a-backup) article.

## Prune snapshots

If you want to manually prune the snapshots after you tweaked `sanoid.conf` you can run:

```bash
sanoid --prune-snapshots
```

# [Syncoid](https://github.com/jimsalterjrs/sanoid/wiki/Syncoid)

`Sanoid` also includes a replication tool, `syncoid`, which facilitates the asynchronous incremental replication of ZFS filesystems. A typical `syncoid` command might look like this:

```bash
syncoid data/images/vm backup/images/vm
```

Which would replicate the specified ZFS filesystem (aka dataset) from the data pool to the backup pool on the local system, or

```bash
syncoid data/images/vm root@remotehost:backup/images/vm
```

Which would push-replicate the specified ZFS filesystem from the local host to remotehost over an SSH tunnel, or

```bash
syncoid root@remotehost:data/images/vm backup/images/vm
```

Which would pull-replicate the filesystem from the remote host to the local system over an SSH tunnel. In case of doubt [using the pull strategy is always desired](https://github.com/jimsalterjrs/sanoid/issues/666)

`Syncoid` supports recursive replication (replication of a dataset and all its child datasets) and uses mbuffer buffering, lzop compression, and pv progress bars if the utilities are available on the systems used. If ZFS supports resumeable send/receive streams on both the source and target those will be enabled as default. It also automatically supports and enables resume of interrupted replication when both source and target support this feature.

## Configuration

### [Syncoid configuration caveats](https://ithero.eu/documentation/filesystems/zfs/sanoid-syncoid/)

One key point is that pruning is not done by `syncoid` but only and always by `sanoid`. This means `sanoid` has to be run on the backup datasets as well, but without creating snapshots, only pruning (as set in the template).

Also, the template is called `template_something` and only `something` must be use with `use_template`.

```toml
[SAN200/projects]
        use_template = production
        recursive = yes
        process_children_only = yes

[BACKUP/SAN200/projects]
        use_template = backup
        recursive = yes
        process_children_only = yes
```
Also note that `post_snapshot_script` cannot be used with `syncoid` especially with `recursive = yes`. This is because there cannot be two zfs send and receive at the same time on the same dataset.

`sanoid` does not wait for the script completion before continuing. This mean that should the `syncoid` process take a bit too much time, a new one will be spawned. And for reasons unknown to me yet, a new syncoid process will cancel the previous one (instead of just leaving). As some of the spawned `syncoid` will produce errors, the entire `sanoid` process will fail.

So this approach does not work and has to be done independently, it seems. The good news is that the SystemD service of `Type= oneshot` can have several `Execstart=` lines.

## Send encrypted backups to a encrypted dataset

`syncoid`'s default behaviour is to create the destination dataset without encryption so the snapshots are transferred and can be read without encryption. You can check this with the `zfs get encryption,keylocation,keyformat` command both on source and destination.

To prevent this from happening you have to [pass the `--sendoptions='w'](https://github.com/jimsalterjrs/sanoid/issues/548) to `syncoid` so that it tells zfs to send a raw stream. If you do so, you also need to [transfer the key file](https://github.com/jimsalterjrs/sanoid/issues/648) to the destination server so that it can do a `zfs loadkey` and then mount the dataset. For example:

```bash
server-host:$ sudo zfs list -t filesystem
NAME                    USED  AVAIL     REFER  MOUNTPOINT
server_data             232M  38.1G      230M  /var/server_data
server_data/log         111K  38.1G      111K  /var/server_data/log
server_data/mail        111K  38.1G      111K  /var/server_data/mail
server_data/nextcloud   111K  38.1G      111K  /var/server_data/nextcloud
server_data/postgres    111K  38.1G      111K  /var/server_data/postgres

server-host:$ sudo zfs get keylocation server_data/nextcloud
NAME                   PROPERTY     VALUE                                    SOURCE
server_data/nextcloud  keylocation  file:///root/zfs_dataset_nextcloud_pass  local

server-host:$ sudo syncoid --recursive --skip-parent --sendoptions=w server_data root@192.168.122.94:backup_pool
INFO: Sending oldest full snapshot server_data/log@autosnap_2021-06-18_18:33:42_yearly (~ 49 KB) to new target filesystem:
17.0KiB 0:00:00 [1.79MiB/s] [=================================================>                                                                                                  ] 34%            
INFO: Updating new target filesystem with incremental server_data/log@autosnap_2021-06-18_18:33:42_yearly ... syncoid_caedrium.com_2021-06-22:10:12:55 (~ 15 KB):
41.2KiB 0:00:00 [78.4KiB/s] [===================================================================================================================================================] 270%            
INFO: Sending oldest full snapshot server_data/mail@autosnap_2021-06-18_18:33:42_yearly (~ 49 KB) to new target filesystem:
17.0KiB 0:00:00 [ 921KiB/s] [=================================================>                                                                                                  ] 34%            
INFO: Updating new target filesystem with incremental server_data/mail@autosnap_2021-06-18_18:33:42_yearly ... syncoid_caedrium.com_2021-06-22:10:13:14 (~ 15 KB):
41.2KiB 0:00:00 [49.4KiB/s] [===================================================================================================================================================] 270%            
INFO: Sending oldest full snapshot server_data/nextcloud@autosnap_2021-06-18_18:33:42_yearly (~ 49 KB) to new target filesystem:
17.0KiB 0:00:00 [ 870KiB/s] [=================================================>                                                                                                  ] 34%            
INFO: Updating new target filesystem with incremental server_data/nextcloud@autosnap_2021-06-18_18:33:42_yearly ... syncoid_caedrium.com_2021-06-22:10:13:42 (~ 15 KB):
41.2KiB 0:00:00 [50.4KiB/s] [===================================================================================================================================================] 270%            
INFO: Sending oldest full snapshot server_data/postgres@autosnap_2021-06-18_18:33:42_yearly (~ 50 KB) to new target filesystem:
17.0KiB 0:00:00 [1.36MiB/s] [===============================================>                                                                                                    ] 33%            
INFO: Updating new target filesystem with incremental server_data/postgres@autosnap_2021-06-18_18:33:42_yearly ... syncoid_caedrium.com_2021-06-22:10:14:11 (~ 15 KB):
41.2KiB 0:00:00 [48.9KiB/s] [===================================================================================================================================================] 270%  

server-host:$ sudo scp /root/zfs_dataset_nextcloud_pass 192.168.122.94:
```

```bash
backup-host:$ sudo zfs set keylocation=file:///root/zfs_dataset_nextcloud_pass  backup_pool/nextcloud
backup-host:$ sudo zfs load-key backup_pool/nextcloud
backup-host:$ sudo zfs mount backup_pool/nextcloud
```

If you also want to keep the `encryptionroot` you need to [let zfs take care of the recursion instead of syncoid](https://github.com/jimsalterjrs/sanoid/issues/614). In this case you can't use syncoid's stuff like `--exclude` from the manpage of zfs:

```
-R, --replicate
   Generate a replication stream package, which will replicate the specified file system, and all descendent file systems, up to the named snapshot.  When received, all properties, snap‐
   shots, descendent file systems, and clones are preserved.

   If the -i or -I flags are used in conjunction with the -R flag, an incremental replication stream is generated.  The current values of properties, and current snapshot and file system
   names are set when the stream is received.  If the -F flag is specified when this stream is received, snapshots and file systems that do not exist on the sending side are destroyed.
   If the -R flag is used to send encrypted datasets, then -w must also be specified.
```

In this case this should work:

```bash
/sbin/syncoid --recursive --force-delete --sendoptions="Rw" zpool/backups zfs-recv@10.29.3.27:zpool/backups
```

# Troubleshooting

## [Syncoid no tty present and no askpass program specified](https://sidhion.com/blog/posts/zfs-syncoid-slow/)

If you try to just sync a ZFS dataset between two machines, something like `syncoid pool/dataset user@remote:pool/dataset`, you’ll eventually see `syncoid` throwing a sudo error: `sudo: no tty present and no askpass program specified`. That’s because it’s trying to run a sudo command on the remote, and sudo doesn’t have a way to ask for a password with the way `syncoid`’s running commands in the remote.

Searching online, many people just saying to enable SSH as root, which might be fine on a local network, but not the best solution. Instead, you can enable passwordless `sudo` for `zfs` commands on a unprivileged user. Getting this done was very simple:

```bash
sudo visudo /etc/sudoers.d/zfs_receive_for_syncoid
```

And then fill it with the following:

```
<your user> ALL=NOPASSWD: /usr/sbin/zfs *
```

If you really want to put in the effort, you can even take a look at which `zfs` commands that `syncoid` is actually invoking, and then restrict passwordless sudo only for those commands. It’s important that you do this for all commands that `syncoid` uses. Syncoid runs a few `zfs` commands with sudo to list snapshots and get some other information on the remote machine before doing the transfer.

# References

* [Source](https://github.com/jimsalterjrs/sanoid/)
* [Docs](https://github.com/jimsalterjrs/sanoid/wiki)
