---
title: Mkdocs
date: 20200409
author: Lyz
---

[MkDocs](https://www.mkdocs.org/) is a fast, simple and downright gorgeous
static site generator that's geared towards building project documentation.
Documentation source files are written in Markdown, and configured with a single
YAML configuration file.

# Installation

* Install the basic packages.

    ```bash
    pip install \
        mkdocs \
        mkdocs-material \
        mkdocs-autolink-plugin \
        mkdocs-minify-plugin \
        pymdown-extensions \
        mkdocs-git-revision-date-localized-plugin
    ```
* Create the `docs` repository.

    ```bash
    mkdocs new docs
    ```

* Although there are [several
    themes](https://www.mkdocs.org/user-guide/styling-your-docs/), I usually use
    the [material](https://squidfunk.github.io/mkdocs-material) one. I won't
    dive into the different options, just show a working template of the
    `mkdocs.yaml` file.

    ```yaml
    site_name: {{ site_name }}
    site_author: {{ your_name }}
    site_url: {{ site_url }}
    nav:
      - Introduction: 'index.md'
      - Basic Usage: 'basic_usage.md'
      - Configuration: 'configuration.md'
      - Update: 'update.md'
      - Advanced Usage:
        - Projects: "projects.md"
        - Tags: "tags.md"

    plugins:
      - search
      - autolinks
      - git-revision-date-localized:
          type: timeago
      - minify:
          minify_html: true

    markdown_extensions:
      - admonition
      - meta
      - toc:
          permalink: true
          baselevel: 2
      - pymdownx.arithmatex
      - pymdownx.betterem:
          smart_enable: all
      - pymdownx.caret
      - pymdownx.critic
      - pymdownx.details
      - pymdownx.emoji:
          emoji_generator: !!python/name:pymdownx.emoji.to_svg
      - pymdownx.inlinehilite
      - pymdownx.magiclink
      - pymdownx.mark
      - pymdownx.smartsymbols
      - pymdownx.superfences
      - pymdownx.tasklist:
          custom_checkbox: true
      - pymdownx.tilde

    theme:
      name: material
      custom_dir: "theme"
      logo: "images/logo.png"
      palette:
        primary: 'blue grey'
        accent: 'light blue'

    extra_css:
      - 'stylesheets/extra.css'
      - 'stylesheets/links.css'

    repo_name: {{ repository_name }} # for example: 'lyz-code/pydo'
    repo_url: {{ repository_url }} # for example: 'https://github.com/lyz-code/pydo'
    ```

* [Configure your
    logo](https://squidfunk.github.io/mkdocs-material/getting-started/#logo) by
    saving it into `docs/images/logo.png`.

* I like to show a small image above each link so you know where is it pointing
    to. To do so add the content of [this
    directory](https://github.com/lyz-code/pydo/tree/master/docs/theme) to
    `theme`. and
    [these](https://github.com/lyz-code/pydo/tree/master/docs/docs/stylesheets)
    files under `docs/stylesheets`.
* Initialize the git repository and create the first commit.
* Start the server to see everything is alright.

    ```bash
    mkdocs serve
    ```

## Add a github pages hook.


# Links

* [Homepage](https://www.mkdocs.org/).
* [Material theme configuration guide](https://squidfunk.github.io/mkdocs-material/getting-started/)
