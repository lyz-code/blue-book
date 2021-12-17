---
title: Changelog
date: 20211216
author: Lyz
---

A changelog is a file which contains a curated, chronologically ordered list of
notable changes for each version of a project.

It's purpose is to make it easier for users and contributors to see precisely
what notable changes have been made between each release (or version) of the
project.

# [Types of changes](https://keepachangelog.com/en/1.0.0/#how)

* *Added* for new features.
* *Changed* for changes in existing functionality.
* *Deprecated* for soon-to-be removed features.
* *Removed* for now removed features.
* *Fixed* for any bug fixes.
* *Security* in case of vulnerabilities.


# Changelog Guidelines

[Good changelogs](https://keepachangelog.com/en/1.0.0/#how) follow the next
principles:

* Changelogs are for humans, not machines.
* There should be an entry for every single version.
* The same types of changes should be grouped.
* Versions and sections should be linkable.
* The latest version comes first.
* The release date of each version is displayed.
* Mention your [versioning strategy](versioning.md).
* [Call it
    `CHANGELOG.md`](https://keepachangelog.com/en/1.0.0/#frequently-asked-questions).

Some examples of [bad
changelogs](https://keepachangelog.com/en/1.0.0/#bad-practices) are:

* *Commit log diffs*: The purpose of a changelog entry is to document the
    noteworthy difference, often across multiple commits, to communicate them
    clearly to end users. If someone wants to see the commit log diffs they can
    access it through the `git` command.

* *Ignoring Deprecations*: When people upgrade from one version to another, it
    should be painfully clear when something will break. It should be possible
    to upgrade to a version that lists deprecations, remove what's deprecated,
    then upgrade to the version where the deprecations become removals.

* *Confusing Dates*: Regional date formats vary throughout the world and it's
    often difficult to find a human-friendly date format that feels intuitive to
    everyone. The advantage of dates formatted like 2017-07-17 is that they
    follow the order of largest to smallest units: year, month, and day. This
    format also doesn't overlap in ambiguous ways with other date formats,
    unlike some regional formats that switch the position of month and day
    numbers. These reasons, and the fact this date format is an ISO standard,
    are why it is the recommended date format for changelog entries.

# How to reduce the effort required to maintain a changelog

There are two ways to ease the burden of maintaining a changelog:

## Build it automatically

If you use [Semantic Versioning](semantic_versioning.md) you can use the
[commitizen](https://github.com/commitizen-tools/commitizen) tool to
automatically generate the changelog each time you cut a new release by running
`cz bump --changelog --no-verify`.

The `--no-verify` part is required [if you use pre-commit
hooks](https://github.com/commitizen-tools/commitizen/issues/164).

## [Use the `Unreleased` section](https://keepachangelog.com/en/1.0.0/#effort)

Keep an Unreleased section at the top to track upcoming changes.

This serves two purposes:

* People can see what changes they might expect in upcoming releases.
* At release time, you can move the Unreleased section changes into a new
    release version section.

# References

* [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
