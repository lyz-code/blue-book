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

## Troubleshooting

### Problems accessing redis locally

If you're with the VPN connected, turn it off.

### PDB behaves weird

Sometimes you have two traces at the same time, so each time you run a PDB
command it jumps from pdb trace. Quite confusing. Try to `c` the one you don't
want so that you're left with the one you want. Or put the `pdb` trace in a
conditional that only matches one of both threads.

# References

- [Docs](http://docs.alephdata.org/)
- [Git](https://github.com/alephdata/aleph)
