[`python_systemd`](https://github.com/systemd/python_systemd) is a Python module for native access to the `systemd` facilities. Functionality is separated into a number of modules:

- `systemd.journal` supports sending of structured messages to the journal and reading journal files.
- `systemd.daemon` wraps parts of `libsystemd` useful for writing daemons and socket activation.
- `systemd.id128` provides functions for querying machine and boot identifiers and a lists of message identifiers provided by systemd.
- `systemd.login` wraps parts of `libsystemd` used to query logged in users and available seats and machines.

# [Installation](https://github.com/systemd/python_systemd?tab=readme-ov-file#installation)

```bash
sudo apt install python3-systemd
```

# References
- [Source](https://github.com/systemd/python_systemd)
\n\n[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
