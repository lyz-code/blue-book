---
title: MDFormat
date: 20221110
author: Lyz
---

[MDFormat](https://mdformat.readthedocs.io/en/stable/) is an opinionated
Markdown formatter that can be used to enforce a consistent style in Markdown
files. Mdformat is a Unix-style command-line tool as well as a Python library.

The features/opinions of the formatter include:

- Consistent indentation and whitespace across the board
- Always use ATX style headings
- Move all link references to the bottom of the document (sorted by label)
- Reformat indented code blocks as fenced code blocks
- Use 1. as the ordered list marker if possible, also for noninitial list items.

It's based on the
[`markdown-it-py`](https://markdown-it-py.readthedocs.io/en/latest/index.html)
Markdown parser, which is a Python implementation of
[`markdown-it`](https://github.com/markdown-it/markdown-it).

# [Installation](https://mdformat.readthedocs.io/en/stable/users/installation_and_usage.html)

By default it uses CommonMark support:

```bash
pip install mdformat
```

This won't
[support task lists](https://github.com/executablebooks/mdformat/issues/300), if
you want them use the github flavoured parser instead:

```bash
pip install mdformat-gfm
```

You may want to also install some interesting plugins:

- [`mdformat-beautysh`](https://github.com/hukkin/mdformat-beautysh): format
  `bash` and `sh` code blocks.
- [`mdformat-black`](https://github.com/hukkin/mdformat-black): format `python`
  code blocks.
- [`mdformat-config`](https://github.com/hukkin/mdformat-config): format `json`,
  `toml` and `yaml` code blocks.
- [`mdformat-web`](https://github.com/hukkin/mdformat-web): format `javascript`,
  `css`, `html` and `xml` code blocks.
- [`mdformat-tables`](https://github.com/executablebooks/mdformat-tables): Adds
  support for Github Flavored Markdown style tables.
- [`mdformat-frontmatter`](https://github.com/butler54/mdformat-frontmatter):
  Adds support for the yaml header with metadata of the file.

To install them with `pipx` you can run:

```bash
pipx install --include-deps mdformat-gfm
pipx inject mdformat-gfm mdformat-beautysh mdformat-black mdformat-config \
    mdformat-web mdformat-tables mdformat-frontmatter
```

# Desires

These are the functionalities I miss when writing markdown that can be currently
fixed with `mdformat`:

- Long lines are wrapped.
- Long lines in lists are wrapped and the indentation is respected.
- Add correct blank lines between sections.

I haven't found yet a way to achieve:

- Links are sent to the bottom of the document.
- Do
  [typographic replacements](https://markdown-it-py.readthedocs.io/en/latest/using.html#typographic-components)
- End paragraphs with a dot.

# [Developing mdformat plugins](https://mdformat.readthedocs.io/en/stable/contributors/contributing.html#developing-code-formatter-plugins)

There are two kinds of plugins:

- Formatters: They change the output of the text. For example
  [`mdformatormat-black`](https://github.com/hukkin/mdformat-black).
- Parsers: They are extensions to the base CommonMark parser.

You can see some plugin examples
[here](https://mdformat.readthedocs.io/en/stable/users/plugins.html).

# Issues

- It doesn't yet
  [support admonitions](https://github.com/executablebooks/mdformat/issues/309)
- You can't
  [ignore some files](https://github.com/executablebooks/mdformat/issues/359),
  nor
  [some part of the file](https://github.com/executablebooks/mdformat/issues/53)

# References

- [Docs](https://mdformat.readthedocs.io/en/stable/)
- [Source](https://github.com/executablebooks/mdformat)
