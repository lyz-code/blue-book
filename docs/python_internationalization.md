---
title: Python Internationalization
date: 20220513
author: Lyz
---

To make your code accessible to more people, you may want to support more than
one language. It's not as easy as it looks as it's not enough to translate it
but also it must look and feel local. The answer is internationalization.

Internationalization (numeronymed as i18n) can be defined as the design process
that ensures a program can be adapted to various languages and regions without
requiring engineering changes to the source code.

Common internationalization tasks include:

* Facilitating compliance with Unicode.
* Minimizing the use of concatenated strings.
* Accommodating support for double-byte languages (e.g. Japanese) and
    right-to-left languages (for example, Hebrew).
* Avoiding hard-coded text.
* Designing for independence from cultural conventions (e. g., date and time
    displays), limiting language, and character sets.

Localization (l10n) refers to the adaptation of your program, once
internationalized, to the local language and cultural habits. In theory it looks
simple to implement. In practice though, it takes time and effort to provide the
best Internationalization and Localization experience for your global audience.

In Python, there is a specific bundled module for that and it’s called
[gettext](gettext.md), which consists of a public API and a set of tools that
help extract and generate message catalogs from the source code.

# References

* [Phrase blog on Localizing with GNU gettext](https://phrase.com/blog/posts/translate-python-gnu-gettext/)
* [Phrase blog on internationalization](https://phrase.com/lp/i18n-manager/)
