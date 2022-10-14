---
title: vdirsyncer
date: 20221007
author: Lyz
---

[vdirsyncer](https://vdirsyncer.pimutils.org/en/stable/) is a Python
command-line tool for synchronizing calendars and addressbooks between a variety
of servers and the local filesystem. The most popular usecase is to synchronize
a server with a local folder and use a set of other programs such as
[`khal`](khal.md) to change the local events and contacts. Vdirsyncer can then
synchronize those changes back to the server.

However, `vdirsyncer` is not limited to synchronizing between clients and
servers. It can also be used to synchronize calendars and/or addressbooks
between two servers directly.

It aims to be for calendars and contacts what OfflineIMAP is for emails.

# [Installation](https://vdirsyncer.pimutils.org/en/stable/installation.html)

Although it's available in the major package managers, you can get a more
bleeding edge version with `pip`.

```bash
pipx install vdirsyncer
```

If you don't have [`pipx`](pipx.md) you can use `pip`.

You also need to install some dependencies for it to work:

```bash
sudo apt-get install libxml2 libxslt1.1 zlib1g
```

## [Configuration](https://vdirsyncer.pimutils.org/en/stable/tutorial.html)

In this example we set up contacts synchronization, but calendar sync works
almost the same. Just swap `type = "carddav"` for `type = "caldav"` and `fileext
= ".vcf"` for `fileext = ".ics"`.

By default, `vdirsyncer` looks for its configuration file in the following locations:

* The file pointed to by the `VDIRSYNCER_CONFIG` environment variable.
* `~/.vdirsyncer/config`.
* `$XDG_CONFIG_HOME/vdirsyncer/config`, which is normally
    `~/.config/vdirsyncer/config`.

You need to create the directory as it's not created by default and the [base
config file](https://github.com/pimutils/vdirsyncer/blob/main/config.example).

The config file should start with a general section, where the only required
parameter is status_path. The following is a minimal example:

```ini
[general]
status_path = "~/.vdirsyncer/status/"
```

After the `general` section, an arbitrary amount of pair and storage sections
might come.

In vdirsyncer, synchronization is always done between two storages. Such
storages are defined in storage sections, and which pairs of storages should
actually be synchronized is defined in pair section. This format is copied from
OfflineIMAP, where storages are called repositories and pairs are called
accounts.

### Syncing a calendar

To sync to a nextcloud calendar:

```ini
[pair my_calendars]
a = "my_calendars_local"
b = "my_calendars_remote"
collections = ["from a", "from b"]
metadata = ["color"]

[storage my_calendars_local]
type = "filesystem"
path = "~/.calendars/"
fileext = ".ics"

[storage my_calendars_remote]
type = "caldav"
#Can be obtained from nextcloud
url = "https://yournextcloud.example.lcl/remote.php/dav/calendars/USERNAME/personal/"
username = "<USERNAME>"
#Instead of inserting my plaintext password I fetch it using pass
password.fetch = ["command", "pass", "nextcloud"]
#SSL certificate fingerprint
verify_fingerprint = "FINGERPRINT"
#Verify ssl certificate. Set to false if it is self signed and not installed on local machine
verify = true
```

Read the [SSl and certificate validation](#ssl-and-certificate-validation)
section to see how to create the `verify_fingerprint`.

### Syncing an address book

The following example synchronizes ownCloud’s addressbooks to `~/.contacts/`:

```ini
[pair my_contacts]
a = "my_contacts_local"
b = "my_contacts_remote"
collections = ["from a", "from b"]

[storage my_contacts_local]
type = "filesystem"
path = "~/.contacts/"
fileext = ".vcf"

[storage my_contacts_remote]
type = "carddav"

# We can simplify this URL here as well. In theory it shouldn't matter.
url = "https://owncloud.example.com/remote.php/carddav/"
username = "bob"
password = "asdf"
```

!!! note
        Configuration for other servers can be found at
        [Servers](https://vdirsyncer.pimutils.org/en/stable/tutorials/index.html#supported-servers).

After running `vdirsyncer discover` and `vdirsyncer sync`, `~/.contacts/` will contain
subdirectories for each addressbook, which in turn will contain a bunch of
`.vcf` files which all contain a contact in VCARD format each. You can modify their
contents, add new ones and delete some, and your changes will be
synchronized to the CalDAV server after you run `vdirsyncer sync` again.

### [Conflict resolution](https://vdirsyncer.pimutils.org/en/stable/tutorial.html#conflict-resolution)

If the same item is changed on both sides `vdirsyncer` can manage the conflict in
three ways:

* Displaying an error message (the default).
* Choosing one alternative version over the other.
* Starts a command of your choice that is supposed to merge the two alternative
    versions.

Options 2 and 3 require adding a `conflict_resolution` parameter to the pair
section. Option 2 requires giving either `a wins` or `b wins` as value to the
parameter:

```ini
[pair my_contacts]
...
conflict_resolution = "b wins"
```

Earlier we wrote that `b = "my_contacts_remote"`, so when `vdirsyncer`
encounters the situation where an item changed on both sides, it will simply
overwrite the local item with the one from the server.

Option 3 requires specifying as value of `conflict_resolution` an array starting with `command` and containing paths and arguments to a command. For example:

```ini
[pair my_contacts]
...
conflict_resolution = ["command", "vimdiff"]
```

In this example, `vimdiff <a> <b>` will be called with `<a>` and `<b>` being two
temporary files containing the conflicting files. The files need to be exactly
the same when the command returns. More arguments can be passed to the command
by adding more elements to the array.

### [SSL and certificate validation](https://vdirsyncer.pimutils.org/en/stable/ssl-tutorial.html)

To pin the certificate by fingerprint:

```ini
[storage foo]
type = "caldav"
...
verify_fingerprint = "94:FD:7A:CB:50:75:A4:69:82:0A:F8:23:DF:07:FC:69:3E:CD:90:CA"
#verify = false  # Optional: Disable CA validation, useful for self-signed certs
```

SHA1-, SHA256- or MD5-Fingerprints can be used.

You can use the following command for obtaining a SHA-1 fingerprint:

```bash
echo -n | openssl s_client -connect unterwaditzer.net:443 | openssl x509 -noout -fingerprint
```

Note that `verify_fingerprint` doesn't suffice for `vdirsyncer` to work with
self-signed certificates (or certificates that are not in your trust store). You
most likely need to set `verify = false` as well. This disables verification of
the SSL certificate’s expiration time and the existence of it in your trust
store, all that’s verified now is the fingerprint.

However, please consider using Let’s Encrypt such that you can forget about all
of that. It is easier to deploy a free certificate from them than configuring
all of your clients to accept the self-signed certificate.

### [Storing passwords](https://vdirsyncer.pimutils.org/en/stable/keyring.html)

`vdirsyncer` can fetch passwords from several sources other than the config
file.

Say you have the following configuration:

```ini
[storage foo]
type = "caldav"
url = ...
username = "foo"
password = "bar"
```

But it bugs you that the password is stored in cleartext in the config file. You
can do this:

```ini
[storage foo]
type = "caldav"
url = ...
username = "foo"
password.fetch = ["command", "~/get-password.sh", "more", "args"]
```

You can fetch the username as well:

```ini
[storage foo]
type = "caldav"
url = ...
username.fetch = ["command", "~/get-username.sh"]
password.fetch = ["command", "~/get-password.sh"]
```

Or really any kind of parameter in a storage section.

With `pass` for example, you might find yourself writing something like this in
your configuration file:

```ini
password.fetch = ["command", "pass", "caldav"]
```

### [Google](https://vdirsyncer.pimutils.org/en/stable/config.html#google)

`vdirsyncer` supports synchronization with Google calendars with the restriction
that VTODO files are rejected by the server.

Synchronization with Google contacts is less reliable due to negligence of
Google’s CardDAV API. Google’s CardDAV implementation is allegedly a disaster in
terms of data safety. Always back up your data.

At first run you will be asked to authorize application for Google account access.

To use this storage type, you need to install some additional dependencies:

```bash
pip install vdirsyncer[google]
```

#### Official steps

!!! warning "As of 2022-10-13 these didn't work for me, see the next section"

Furthermore you need to register `vdirsyncer` as an application yourself to
obtain `client_id` and `client_secret`, as it is against Google’s Terms of Service to hardcode those into open source software:

* Go to the [Google API Manager](https://console.developers.google.com/) and
    create a new project under any name.
* Within that project, enable the `CalDAV` and `CardDAV` APIs (not the Calendar
    and Contacts APIs, those are different and won’t work). There should be
    a searchbox where you can just enter those terms.
* In the sidebar, select `Credentials` and create a new `OAuth Client ID`. The application type is `Other`.
* You’ll be prompted to create a OAuth consent screen first. Fill out that form
    however you like.
* Finally you should have a Client ID and a Client secret. Provide these in your
    storage config.

The `token_file` parameter should be a `filepath` where vdirsyncer can later
store authentication-related data. You do not need to create the file itself or
write anything to it.

```ini
[storage example_for_google_calendar]
type = "google_calendar"
token_file = "..."
client_id = "..."
client_secret = "..."
#start_date = null
#end_date = null
#item_types = []
```

#### [Use Nekr0z patch solution](https://github.com/pimutils/vdirsyncer/issues/975)

!!! note "look the previous section if you have doubts on any of the steps"

If the official steps failed for you, try these ones:

* Go to the [Google API Manager](https://console.developers.google.com/) and
    create a new project under any name.
* Selected the vdirsyncer project
* Went to Credentials -> Create Credentials -> OAuth Client ID
* Select "Web Application"
* Under "Authorised redirect URIs" added `http://127.0.0.1:8088` pressed "Create".
* Edit your `vdirsyncer` `config` [storage google] section to have the new
    client_id and client_secret ().
* Find the location of the `vdirsyncer/storage/google.py` in your environment
    (mine was in
    `~/.local/pipx/venvs/vdirsyncer/lib/python3.10/site-packages/vdirsyncer/storage`) and changed line 65 from

    ```python
    redirect_uri="urn:ietf:wg:oauth:2.0:oob",
    ```

    to

    ```python
    redirect_uri="http://127.0.0.1:8088",
    ```

* Run `vdirsyncer discover my_calendar`.
* Opened the link in my browser (on my desktop machine).
* Proceeded with Google authentication until "Firefox can not connect to 127.0.0.1:8088." was displayed.
    from the browser's address bar that looked like:

    http://127.0.0.1:8088/?state=SOMETHING&code=HERECOMESTHECODE&scope=https://www.googleapis.com/auth/calendar
* Copy the `HERECOMESTHECODE` part.
* Paste the code into the session where `vdirsyncer` was running

### See differences between syncs

If you create a git repository where you have your calendars you can do a `git
diff` and see the files that have changed. If you do a commit after each sync
you can have all the history.

# References

* [Docs](https://vdirsyncer.pimutils.org/en/stable/)
* [Git](https://github.com/pimutils/vdirsyncer)
