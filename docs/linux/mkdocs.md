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

* Save your `requirements.txt`.
    ```bash
    pip freeze > requirements.txt
    ```

* Create the `.github/workflows/gh-pages.yml` file with the following contents.
    ```yaml
    name: Github pages

    on:
      push:
        branches:
          - master

    jobs:
      deploy:
        runs-on: ubuntu-18.04
        steps:
          - uses: actions/checkout@v2
            with:
              # Number of commits to fetch. 0 indicates all history.
              # Default: 1
              fetch-depth: 0

          - name: Setup Python
            uses: actions/setup-python@v1
            with:
              python-version: '3.7'
              architecture: 'x64'

          - name: Cache dependencies
            uses: actions/cache@v1
            with:
              path: ~/.cache/pip
              key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
              restore-keys: |
                ${{ runner.os }}-pip-

          - name: Install dependencies
            run: |
              python3 -m pip install --upgrade pip
              python3 -m pip install -r ./requirements.txt

          - run: |
              cd docs
              mkdocs build

          - name: Deploy
            uses: peaceiris/actions-gh-pages@v3
            with:
              deploy_key: ${{ secrets.ACTIONS_DEPLOY_KEY }}
              publish_dir: ./docs/site
    ```
* Create an [SSH deploy key](https://github.com/peaceiris/actions-gh-pages#%EF%B8%8F-create-ssh-deploy-key)
* Activate `GitHub Pages` repository configuration with `gh-pages branch`.
* Make a new commit and push to check it's working.

# Links

* [Homepage](https://www.mkdocs.org/).
* [Material theme configuration guide](https://squidfunk.github.io/mkdocs-material/getting-started/)
