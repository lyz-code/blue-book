---
title: YAML
date: 20200617
author: Lyz
---

[YAML](https://en.wikipedia.org/wiki/YAML) (a recursive acronym for "YAML Ain't
Markup Language") is a human-readable data-serialization language. It is
commonly used for configuration files and in applications where data is being
stored or transmitted. YAML targets many of the same communications applications
as Extensible Markup Language (XML) but has a minimal syntax which intentionally
differs from SGML. It uses both Python-style indentation to indicate nesting,
and a more compact format that uses [...] for lists and {...} for maps making
YAML 1.2 a superset of JSON.

## [Break long lines](https://stackoverflow.com/a/21699210)

* Use `>` most of the time: interior line breaks are stripped out, although you
    get one at the end:

    ```yaml
    key: >
      Your long
      string here.
    ```

* Use `|` if you want those line breaks to be preserved as `\n` (for instance,
    embedded markdown with paragraphs):

    ```yaml
    key: |
      ### Heading

      * Bullet
      * Points
    ```

* Use `>-` or `|-` instead if you don't want a line break appended at the end.

* Use `"..."` if you need to split lines in the middle of words or want to
    literally type line breaks as `\n`:

    ```yaml
    key: "Antidisestab\
     lishmentarianism.\n\nGet on it."
    ```

* YAML is crazy.
