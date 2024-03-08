# Operations

## [Restore a dump](https://www.postgresql.org/docs/current/backup-dump.html#BACKUP-DUMP-RESTORE)
Text files created by `pg_dump` are intended to be read in by the `psql` program. The general command form to restore a dump is

```bash
psql dbname < dumpfile
```

Where `dumpfile` is the file output by the `pg_dump` command. The database `dbname` will not be created by this command, so you must create it yourself from `template0` before executing `psql` (e.g., with `createdb -T template0 dbname`). `psql` supports options similar to `pg_dump` for specifying the database server to connect to and the user name to use. See [the `psql` reference page](https://www.postgresql.org/docs/current/app-psql.html) for more information. Non-text file dumps are restored using the `pg_restore` utility.

# Troubleshooting
## [Fix pg_dump version mismatch](https://stackoverflow.com/questions/12836312/postgresql-9-2-pg-dump-version-mismatch) 
If you need to use a `pg_dump` version different from the one you have at your system you could either [use nix](nix.md) or use docker

```bash
docker run postgres:9.2 pg_dump books > books.out
```

Or if you need to enter the password

```bash
docker run -v /path/to/dump:/dump -it postgres:12 bash
pg_dump books > /dump/books.out
```
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
