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

# Usage

`sanoid` runs in the back with the `systemd` service, so there is nothing you need to do for it to run.

To check the logs use `journalctl -eu sanoid`.

To manage the snapshots look at the [`zfs`](zfs.md#restore-a-backup) article.

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

Which would pull-replicate the filesystem from the remote host to the local system over an SSH tunnel.

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
