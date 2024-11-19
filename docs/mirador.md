
DEPRECATED: as of 2024-11-15 the tool has many errors ([1](https://github.com/pimalaya/mirador/issues/4), [2](https://github.com/pimalaya/mirador/issues/3)), few stars (4) and few commits (8). use [watchdog](watchdog_python.md) instead and build your own solution.

[mirador](https://github.com/pimalaya/mirador) is a CLI to watch mailbox changes made by the maintaner of [himalaya](himalaya.md).

Features:

- Watches and executes actions on mailbox changes
- Interactive configuration via **wizard** (requires `wizard` feature)
- Supported events: **on message added**.
- Supported actions: **send system notification**, **execute shell command**.
- Supports **IMAP** mailboxes (requires `imap` feature)
- Supports **Maildir** folders (requires `maildir` feature)
- Supports global system **keyring** to manage secrets (requires `keyring` feature)
- Supports **OAuth 2.0** (requires `oauth2` feature)

*Mirador CLI is written in [Rust](https://www.rust-lang.org/), and relies on [cargo features](https://doc.rust-lang.org/cargo/reference/features.html) to enable or disable functionalities. Default features can be found in the `features` section of the [`Cargo.toml`](https://github.com/pimalaya/mirador/blob/master/Cargo.toml#L18).*

# [Installation](https://github.com/pimalaya/mirador)

*The `v1.0.0` is currently being tested on the `master` branch, and is the preferred version to use. Previous versions (including GitHub beta releases and repositories published versions) are not recommended.*

## Cargo (git)

Mirador CLI `v1.0.0` can also be installed with [cargo](https://doc.rust-lang.org/cargo/):

```bash
$ cargo install --frozen --force --git https://github.com/pimalaya/mirador.git
```

## Pre-built binary

Mirador CLI `v1.0.0` can be installed with a pre-built binary. Find the latest [`pre-release`](https://github.com/pimalaya/mirador/actions/workflows/pre-release.yml) GitHub workflow and look for the *Artifacts* section. You should find a pre-built binary matching your OS.

# Configuration

Just run `mirador`, the wizard will help you to configure your default account.

You can also manually edit your own configuration, from scratch:

- Copy the content of the documented [`./config.sample.toml`](https://github.com/pimalaya/mirador/blob/master/config.sample.toml)
- Paste it in a new file `~/.config/mirador/config.toml`
- Edit, then comment or uncomment the options you want

# Usage

# References
- [Source](https://github.com/pimalaya/mirador)
