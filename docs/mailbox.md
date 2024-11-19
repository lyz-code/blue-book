[`mailbox`](https://docs.python.org/3/library/mailbox.html) is a python library to work with MailDir and mbox local mailboxes.

It's part of the core python libraries, so you don't need to install anything.

# Usage

The docs are not very pleasant to read, so I got most of the usage knowledge from these sources:

- [pymowt docs](https://pymotw.com/2/mailbox/)
- [Cleanup maildir directories](https://cr-net.be/posts/maildir_cleanup_with_python/)
- [Parsing maildir directories](https://gist.github.com/tyndyll/6f6145f8b1e82d8b0ad8)

One thing to keep in mind is that an account can have many mailboxes (INBOX, Sent, ...), there is no "root mailbox" that contains all of the other

## initialise a mailbox

```python 
mbox = mailbox.Maildir('path/to/your/mailbox')
```

Where the `path/to/your/mailbox` is the directory that contains the `cur`, `new`, and `tmp` directories.

## Working with mailboxes

It's not very clear how to work with them, the Maildir mailbox contains the emails in iterators `[m for m in mbox]`, it acts kind of a dictionary, you can get the keys of the emails with `[k for k in mbox.iterkeys]`, and then you can `mbox[key]` to get an email, you cannot modify those emails (flags, subdir, ...) directly in the `mbox` object (for example `mbox[key].set_flags('P')` doesn't work). You need to `mail = mbox.pop(key)`, do the changes in the `mail` object and then `mbox.add(mail)` it again, with the downside that after you added it again, the `key` has changed! But it's the return value of the `add` method.

If the program gets interrupted between the `pop` and the `add` then you'll loose the email. The best way to work with it would be then:

- `mail = mbox.get(key)` the email 
- Do all the process you need to do with the email
- `mbox.pop(key)` and `key = mbox.add(mail)`

In theory `mbox` has an `update` method that does this, but I don't understand it and it doesn't work as expected :S.

## Moving emails around

You can't just move the files between directories like you'd do with python as each directory contains it's own identifiers.

### Moving a message between the maildir directories

The `Message` has a `set_subdir`

## [Creating folders](https://pymotw.com/2/mailbox/#maildir-folders)

Even though you can create folders with `mailbox` it creates them in a way that mbsync doesn't understand it. It's easier to manually create the `cur`, `tmp`, and `new` directories. I'm using the next function:

```python
if not (mailbox_dir / "cur").exists():
    for dir in ["cur", "tmp", "new"]:
        (mailbox_dir / dir).mkdir(parents=True)
    log.info(f"Initialized mailbox: {mailbox}")
else:
    log.debug(f"{mailbox} already exists")
```
# References
- [Reference Docs](https://docs.python.org/3/library/mailbox.html)
- [Non official useful docs](https://pymotw.com/2/mailbox/)

