---
title: Aleph
date: 20221116
author: Lyz
---

[Aleph](https://github.com/alephdata/aleph) is a tool for indexing large amounts
of both documents (PDF, Word, HTML) and structured (CSV, XLS, SQL) data for easy
browsing and search. It is built with investigative reporting as a primary use
case. Aleph allows cross-referencing mentions of well-known entities (such as
people and companies) against watchlists, e.g. from prior research or public
datasets.

# [Install the development environment](https://docs.alephdata.org/developers/installation#getting-started)

As a first step, check out the source code of Aleph from GitHub:

```bash
git clone https://github.com/alephdata/aleph.git
cd aleph/
```

Also, please execute the following command to allow ElasticSearch to map its
memory:

```bash
sysctl -w vm.max_map_count=262144
```

Then enable
[the use of `pdb`](https://docs.alephdata.org/developers/installation#debugging)
by adding the next lines into the `docker-compose.dev.yml` file, under the `api`
service configuration.

```yaml
stdin_open: true
tty: true
```

With the settings in place, you can use `make all` to set everything up and
launch the web service. This is equivalent to the following steps:

- `make build` to build the docker images for the application and relevant
  services.
- `make upgrade` to run the latest database migrations and create/update the
  search index.
- `make web` to run the web-based API server and the user interface.
- In a separate shell, run `make worker` to start a worker. If you do not start
  a worker, background jobs (for example ingesting new documents) won’t be
  processed.

Open http://localhost:8080/ in your browser to visit the web frontend.

- Create a shell to do the operations with `make shell`.
- Create the main user within that shell running
  ```bash
  aleph createuser --name="demo" \
      --admin \
      --password=demo \
      demo@demo.com
  ```
- Load some sample data by running `aleph crawldir /aleph/contrib/testdata`

## Debugging the code

To debug the code, you can create `pdb` breakpoints in the code you cloned, and
run the actions that trigger the breakpoint. To be able to act on it, you need
to be attached to the api by running:

```bash
docker attach aleph_api_1
```

You don't need to reload the page for it to load the changes, it does it
dynamically.

## Operation

### [Upgrade Aleph](https://docs.alephdata.org/developers/technical-faq#how-do-i-upgrade-to-a-new-version-of-aleph)

Aleph does not perform updates and database migrations automatically. Once you
have the latest version, you can run the command bellow to upgrade the existing
installation (i.e. apply changes to the database model or the search index
format).

The first step is to add a notice in Aleph's banner section informing the users
that there's going to be a downtime.

Before you upgrade, check the  to make sure you understand the [latest
release](https://docs.alephdata.org/developers/changelog)
and know about new options and features that have been added.

In production mode, make sure you perform a backup of the main database and the
ElasticSearch index before running an upgrade.

Then, make sure you are using the latest `docker-compose.yml` file. You can do
this by checking out [the source repo](https://github.com/alephdata/aleph), but
really you just need that one file (and your config in aleph.env). There are
many `docker-compose.yml` files, we need to decide the one we want to take as
the source of truth.

```bash
# Pull changes
cd /data/config/aleph
docker-compose pull --parallel

# Stop services
service aleph stop

# Do database migrations
docker-compose up -d redis postgres elasticsearch
# Wait a minute or so while services boot up...
# Run upgrade:
docker-compose run --rm shell aleph upgrade

# Start the services
service aleph start
```

### [Create Aleph admins](https://docs.alephdata.org/developers/technical-faq#how-can-i-make-an-admin-user)

Creation of admins depends on how you create users, in our case that we're using
Oauth we need to update the database directly (ugly!). So go into the instance
you want to do the change and run:

```bash
# Create a terminal inside the aleph environment
docker-compose run --rm shell bash

# Connect to the postgres database
# It will ask you for the password, search it in the docker-compose.yaml file
psql postgresql://aleph@postgres/aleph

# Once there you can see which users do have the Admin rights with:
select * from role where is_admin = 't';

# If you want to make another user admin run the next command:
UPDATE role SET is_admin = true WHERE email = 'keng@pulitzercenter.org';
```

You may also need to run `aleph update` afterwards to refresh some cached information.

### Remove a group

There is currently no web interface that allows this operation, you need to interact with the database directly.

```bash
# Create a terminal inside the aleph environment
docker-compose run --rm shell bash

# Connect to the postgres database
# It will ask you for the password, search it in the docker-compose.yaml file
psql postgresql://aleph@postgres/aleph

# List the available groups
select * from role where type = 'group';

# Delete a group.
# Imagine that the id of the group we want to delete is 18
delete from role where id = 18;
```

#### Role permission error

You may encounter the next error:

```
ERROR:  update or delete on table "role" violates foreign key constraint "permission_role_id_fkey" on table "permission"
DETAIL:  Key (id)=(18) is still referenced from table "permission".
```

That means that the group is still used, to find who is using it use:

```sql
select * from permission where role_id = 18;
```

You can check the elements that have the permission by looking at the `collection_id` number, imagine it's `3`, then you can check `your.url.com/investigations/3`.

Once you're sure you can remove that permission, run:

```sql
delete from permission where role_id = 18;
delete from role where id = 18;
```

#### Role membership error

You may encounter the next error:

```
ERROR:  update or delete on table "role" violates foreign key constraint "role_membership_group_id_fkey" on table "role_membership"
DETAIL:  Key (id)=(8) is still referenced from table "role_membership".
```
That means that the group is still used, to find who is using it use:

```sql
select * from role_membership where group_id = 8;
```

If you agree to remove that user from the group use:

```sql
delete from role_membership where group_id = 8;
delete from role where id = 8;
```

## Troubleshooting

### Ingest gets stuck

It looks that Aleph doesn't yet give an easy way to debug it. It can be seen in the next webs:

- [Improve the UX for bulk uploading and processing of large number of files](https://github.com/alephdata/aleph/issues/2124)
- [Document ingestion gets stuck effectively at 100%](https://github.com/alephdata/aleph/issues/1839)
- [Display detailed ingestion status to see if everything is alright and when the collection is ready](https://github.com/alephdata/aleph/discussions/1525)

Some interesting ideas I've extracted while diving into these issues is that:

- You can also upload files using the [`alephclient` python command line tool](https://github.com/alephdata/alephclient)
- Some of the files might fail to be processed without leaving any hint to the uploader or the viewer.
  - This results in an incomplete dataset and the users don't get to know that the dataset is incomplete. This is problematic if the completeness of the dataset is crucial for an investigation.
  - There is no way to upload only the files that failed to be processed without re-uploading the entire set of documents or manually making a list of the failed documents and re-uploading them
  - There is no way for uploaders or Aleph admins to see an overview of processing errors to figure out why some files are failing to be processed without going through docker logs (which is not very user-friendly)
- There was an attempt to [improve the way ingest-files manages the pending tasks](https://github.com/alephdata/aleph/issues/2127), it's merged into the [release/4.0.0](https://github.com/alephdata/ingest-file/tree/release/4.0.0) branch, but it has [not yet arrived `main`](https://github.com/alephdata/ingest-file/pull/423).

There are some tickets that attempt to address these issues on the command line:

- [Allow users to upload/crawl new files only](https://github.com/alephdata/alephclient/issues/34)
- [Check if alephclient crawldir was 100% successful or not](https://github.com/alephdata/alephclient/issues/35)

I think it's interesting either to contribute to `alephclient` to solve those issues or if it's complicated create a small python script to detect which files were not uploaded and try to reindex them and/or open issues that will prevent future ingests to fail.

### Problems accessing redis locally

If you're with the VPN connected, turn it off.

### PDB behaves weird

Sometimes you have two traces at the same time, so each time you run a PDB
command it jumps from pdb trace. Quite confusing. Try to `c` the one you don't
want so that you're left with the one you want. Or put the `pdb` trace in a
conditional that only matches one of both threads.

# References

- [Source](https://github.com/alephdata/aleph)
- [Docs](http://docs.alephdata.org/)
