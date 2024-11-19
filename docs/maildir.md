The [Maildir](https://en.wikipedia.org/wiki/Maildir) e-mail format is a common way of storing email messages on a file system, rather than in a database. Each message is assigned a file with a unique name, and each mail folder is a file system directory containing these files.

A Maildir directory (often named Maildir) usually has three subdirectories named `tmp`, `new`, and `cur`.

- The `tmp` subdirectory temporarily stores e-mail messages that are in the process of being delivered. This subdirectory may also store other kinds of temporary files.
- The `new` subdirectory stores messages that have been delivered, but have not yet been seen by any mail application.
- The `cur` subdirectory stores messages that have already been seen by mail applications.
# References
- [Wikipedia](https://en.wikipedia.org/wiki/Maildir)
