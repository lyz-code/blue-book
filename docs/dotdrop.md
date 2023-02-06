---
title: Dotdrop
date: 20221231
author: Lyz
---

The main idea of [Dotdrop](https://deadc0de.re/dotdrop/)is to have the ability
to store each dotfile only once and deploy them with a different content on
different hosts/setups. To achieve this, it uses a templating engine that allows
to specify, during the dotfile installation with dotdrop, based on a selected
profile, how (with what content) each dotfile will be installed.

What I like:

- Popular
- Actively maintained
- Written in Python
- Uses jinja2
- Has a nice to read config file

What I don't like:

- [Updating dotfiles doesn't look as smooth as with chezmoi](https://dotdrop.readthedocs.io/en/latest/usage/#update-dotfiles)
- Uses `{{@@ @@}}` instead of `{{ }}` :S
- Doesn't support `pass`.
- Not easy way to edit the files.

# References

- [Source](https://github.com/deadc0de6/dotdrop)
- [Docs](https://dotdrop.readthedocs.io/en/latest/)
- [Blog post](https://deadc0de.re/articles/dotfiles.html)
