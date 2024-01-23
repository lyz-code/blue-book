[journald](https://www.freedesktop.org/software/systemd/man/latest/systemd-journald.service.html) is a system service that collects and stores logging data. It creates and maintains structured, indexed journals based on logging information that is received from a variety of sources:

- Kernel log messages, via kmsg
- Simple system log messages, via the `libc syslog` call
- Structured system log messages via the native Journal API.
- Standard output and standard error of service units.
- Audit records, originating from the kernel audit subsystem.

The daemon will implicitly collect numerous metadata fields for each log messages in a secure and unfakeable way.

Journald provides a good out-of-the-box logging experience for systemd. The trade-off is, journald is a bit of a monolith, having everything from log storage and rotation, to log transport and search. Some would argue that syslog is more UNIX-y: more lenient, easier to integrate with other tools. Which was its main criticism to begin with. When the change was made [not everyone agreed with the migration from syslog](https://rainer.gerhards.net/2013/05/rsyslog-vs-systemd-journal.html) or the general approach systemd took with journald. But by now, systemd is adopted by most Linux distributions, and it includes journald as well. journald happily coexists with syslog daemons, as:

- Some syslog daemons can both read from and write to the journal
- journald exposes the syslog API

It provides lots of features, most importantly:

- Indexing. journald uses a binary storage for logs, where data is indexed. Lookups are much faster than with plain text files.
- Structured logging. Though it’s possible with syslog, too, it’s enforced here. Combined with indexing, it means you can easily filter specific logs (e.g. with a set priority, in a set timeframe).
- Access control. By default, storage files are split by user, with different permissions to each. As a regular user, you won’t see everything root sees, but you’ll see your own logs.
- Automatic log rotation. You can configure journald to keep logs only up to a space limit, or based on free space.

# References

- [Sematext post on journald](https://sematext.com/blog/journald-logging-tutorial/#journald-vs-syslog)
