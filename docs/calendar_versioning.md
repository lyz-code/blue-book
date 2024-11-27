---
title: Calendar Versioning
date: 20211215
author: Lyz
---

[Calendar Versioning](https://calver.org/) is a versioning convention based on
your project's release calendar, instead of arbitrary numbers.

CalVer suggests version number to be in format of: `YEAR.MONTH.sequence`. For
example, `20.1` indicates a release in 2020 January, while `20.5.2` indicates
a release that occurred in 2020 May, while the `2` indicates this is the third
release of the month.

You can see it looks similar to [semantic versioning](semantic_versioning.md)
and has the benefit that a later release qualifies as bigger than an earlier one
within the semantic versioning world (which mandates that a version number must
grow monotonically). This makes it easy to use in all places where semantic
versioning can be used.

The idea here is that if the only maintained version is the latest, then we
might as well use the version number to indicate the release date to signify
just how old of a version you’re using. You also have the added benefit that you
can make calendar-based promises. For example, Ubuntu offers five years of
support, therefore given version `20.04` you can quickly determine that it will be
supported up to April 2025.

# [When to use CalVer](https://calver.org/#when-to-use-calver)

Check the [Deciding what version system to use for your
programs](versioning.md#deciding-what-version-system-to-use-for-your-programs)
article section.

# References

* [Home](https://calver.org/)
