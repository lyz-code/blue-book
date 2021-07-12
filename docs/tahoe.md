---
title: Tahoe-LAFS
date: 20210701
author: Lyz
---

[Tahoe-LAFS](https://en.wikipedia.org/wiki/Tahoe-LAFS) is a free and open,
secure, decentralized, fault-tolerant, distributed data store and distributed
file system.

Tahoe-LAFS is a system that helps you to store files. You run a client program
on your computer, which talks to one or more storage servers on other computers.
When you tell your client to store a file, it will encrypt that file, encode it
into multiple pieces, then spread those pieces out among multiple servers. The
pieces are all encrypted and protected against modifications. Later, when you
ask your client to retrieve the file, it will find the necessary pieces, make
sure they haven’t been corrupted, reassemble them, and decrypt the result.

The client creates more pieces (or “shares”) than it will eventually need, so
even if some of the servers fail, you can still get your data back. Corrupt
shares are detected and ignored, so the system can tolerate server-side
hard-drive errors. All files are encrypted (with a unique key) before uploading,
so even a malicious server operator cannot read your data. The only thing you
ask of the servers is that they can (usually) provide the shares when you ask
for them: you aren’t relying upon them for confidentiality, integrity, or
absolute availability.

Tahoe [does not provide locking of mutable files and
directories](https://tahoe-lafs.readthedocs.io/en/latest/write_coordination.html).
If there is more than one simultaneous attempt to change a mutable file or
directory, then an `UncoordinatedWriteError` may result. This might, in rare
cases, cause the file or directory contents to be accidentally deleted. The user
is expected to ensure that there is at most one outstanding write or update
request for a given file or directory at a time. One convenient way to
accomplish this is to make a different file or directory for each person or
process that wants to write.

If mutable parts of a file store are accessed via sshfs, only a single sshfs
mount should be used. There may be data loss if mutable files or directories are
accessed via two sshfs mounts, or written both via sshfs and from other
clients.

# Installation

```bash
apt-get install tahoe-lafs
```

Or if you want the latest version

```bash
pip install tahoe-lafs
```

If you plan to connect to servers protected through Tor, use `pip install
tahoe-lafs[tor]` instead.

# Troubleshooting

## pkg_resources.DistributionNotFound: The idna  distribution was not found and is required by Twisted

```bash
apt-get install python-idna
```

# References

* [Git](https://github.com/tahoe-lafs/tahoe-lafs)
* [Docs](https://tahoe-lafs.readthedocs.io/en/latest/)
* [Issues](https://tahoe-lafs.org/trac/tahoe-lafs)
