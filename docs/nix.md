[Nix](https://nixos.org) is a tool that takes a unique approach to package management and system configuration. Some of their features are:

- *Reproducible*: Nix builds packages in isolation from each other. This ensures that they are reproducible and don't have undeclared dependencies, so if a package works on one machine, it will also work on another.
- *Declarative*: Nix makes it trivial to share development and build environments for your projects, regardless of what programming languages and tools you’re using.
- *Reliable*: Nix ensures that installing or upgrading one package cannot break other packages. It allows you to roll back to previous versions, and ensures that no package is in an inconsistent state during an upgrade. 

# [Installation](https://nixos.org/download)
Install Nix via the recommended multi-user installation:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
````

We recommend the multi-user install if you are on Linux running systemd, with SELinux disabled and you can authenticate with sudo. 

They have a nice installer that guides you step by step.
# References:

- [Home](https://nixos.org)
- [homelab nix configuration](https://github.com/badele/nix-homelab)
