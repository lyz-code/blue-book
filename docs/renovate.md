---
title: Renovate
date: 20221012
author: Lyz
---

[Renovate](https://docs.renovatebot.com/) is a program that does automated
dependency updates. Multi-platform and multi-language.

Why use Renovate?

* Get pull requests to update your dependencies and lock files.
* Reduce noise by scheduling when Renovate creates PRs.
* Renovate finds relevant package files automatically, including in monorepos.
* You can customize the bot's behavior with configuration files.
* Share your configuration with ESLint-like config presets.
* Get replacement PRs to migrate from a deprecated dependency to the community
    suggested replacement (npm packages only).
* Open source.
* Popular (more than 9.7k stars and 1.3k forks)
* Beautifully integrate with main Git web applications (Gitea, Gitlab, Github).
* It supports most important languages: Python, Docker, Kubernetes, Terraform,
    Ansible, Node, ...

# Behind the scenes

## How Renovate updates a package file

Renovate:

* Scans your repositories to detect package files and their dependencies.
* Checks if any newer versions exist.
* Raises Pull Requests for available updates.

The Pull Requests patch the package files directly, and include Release Notes
for the newer versions (if they are available).

By default:

* You'll get separate Pull Requests for each dependency.
* Major updates are kept separate from non-major updates.

# References

* [Docs](https://docs.renovatebot.com/)
