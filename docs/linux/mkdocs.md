---
title: Mkdocs
date: 20200409
author: Lyz
---

[MkDocs](https://www.mkdocs.org/) is a fast, simple and downright gorgeous
static site generator that's geared towards building project documentation.
Documentation source files are written in Markdown, and configured with a single
YAML configuration file.

!!! note ""
    I've automated the creation of the mkdocs site in [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project).

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

# [Plugin development](https://www.mkdocs.org/user-guide/plugins/)

Like MkDocs, plugins must be written in Python. It is expected that
each plugin would be distributed as a separate Python module. At a minimum,
a MkDocs Plugin must consist of
a [BasePlugin](https://www.mkdocs.org/user-guide/plugins/#baseplugin) subclass
and an [entry point](https://www.mkdocs.org/user-guide/plugins/#entry-point) which
points to it.

The BasePlugin class is meant to have `on_<event_name>` methods that run actions
on the MkDocs defined
[events](#events).

The same object is called at the different events, so you can save objects from
one event to the other in the object attributes.

Keep in mind that the order of execution of the plugins follows the ordering of
the list of the `mkdocs.yml` file where they are defined.

## Interesting objects

### [Files](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L14)

`mkdocs.structure.files.Files` contains a list of [File](#file) objects under
the `._files` attribute and allows you to `append` files to the collection. As
well as extracting the different file types:

* `documentation_pages`: Iterable of markdown page file objects.
* `static_pages`: Iterable of static page file objects.
* `media_files`: Iterable of all files that are not documentation or static pages.
* `javascript_files`: Iterable of javascript files.
* `css_files`: Iterable of css files.

It is initialized with a list of [`File`](#file) objects.

### [File](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L92)

[`mkdocs.structure.files.File`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L92)
objects points to the source and destination locations of a file. It has the
following interesting attributes:

* `name`: Name of the file without the extension.
* `src_path` or `abs_src_path`: Relative or absolute path to the original path,
    for example the markdown file.
* `dest_path` or `abs_dest_path`: Relative or absolute path to the destination path,
    for example the html file generated from the markdown one.
* `url`: Url where the file is going to be exposed.

It is initialized with the arguments:

* `path`: Must be a path that exists relative to `src_dir`.
* `src_dir` and `dest_dir`: Which must be absolute paths on the local file
    system.
* `use_directory_urls`: If `False`, a Markdown file is mapped to an HTML file of
    the same name (the file extension is changed to `.html`). If True,
    a Markdown file is mapped to an HTML index file (`index.html`) nested in
    a directory using the "name" of the file in `path`. The `use_directory_urls`
    argument has no effect on non-Markdown files.

### [Navigation](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L11)

[`mkdocs.structure.nav.Navigation`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L11)
objects hold the information to build the navigation of the site. It has the
following interesting attributes:

* `items`: Nested List with full navigation of Sections, SectionPages, Pages, and Links.
* `pages`: Flat List of subset of Pages in nav, in order.

### [Page](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/pages.py#L18)

[`mkdocs.structure.pages.Page`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/pages.py#L18)
models each page of the site.

To initialize it you need the `title`, the [`File`](#file) object of the page,
and the MkDocs `config` object.

### [Section](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L32)

[`mkdocs.structure.nav.Section`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L32)
object models a section of the navigation of a MkDocs site.

To initialize it you need the `title` of the section and the `children` which are
the elements that belong to the section. If you don't yet know the children,
pass an empty list `[]`.

### [SectionPage](https://github.com/oprypin/mkdocs-section-index/blob/master/mkdocs_section_index/__init__.py#L11)
[`mkdocs_section_index.SectionPage`](https://github.com/oprypin/mkdocs-section-index/blob/master/mkdocs_section_index/__init__.py#L11)
, part of the
[mkdocs-section-index](https://github.com/oprypin/mkdocs-section-index/) plugin,
models [Section](#section) objects that have an associated [Page](#page),
allowing you to have nav sections that when clicked, load the Page and not only
opens the menu for the children elements.

To initialize it you need the `title` of the section, the [`File`](#file) object of the page,
, the MkDocs `config` object, and the `children` which are the elements that
belong to the section. If you don't yet know the children, pass an empty list
`[]`.

## [Events](https://www.mkdocs.org/user-guide/plugins/#events)

### [on_files](https://www.mkdocs.org/user-guide/plugins/#on_files)

The `files` event is called after the files collection is populated from the
`docs_dir`. Use this event to add, remove, or alter files in the collection.
Note that Page objects have not yet been associated with the file objects in the
collection. Use Page Events to manipulate page specific data.

Parameters:

* `files`: global [files collection](#files)
* `config`: global configuration object

Returns:

* global [files collection](#files)

### [on_nav](https://www.mkdocs.org/user-guide/plugins/#on_nav)

The `nav` event is called after the site navigation is created and can be used
to alter the site navigation.

If you want to append items, you would need to create the Section, Pages, SectionPages
or Link objects and append them to the `nav.items`.

Even though it seems more easy to create the nav structure in the
[`on_files`](#on_files) event, by editing the `nav` dictionary of the `config`
object, there is no way of returning the `config` object in that event, so we're
forced to do it in this event.

Parameters:

* `nav`: global [navigation object](#navigation).
* `config`: global configuration object.
* `files`: global [files collection](#files).

Returns:

* global navigation object

# References

* [Git](https://github.com/mkdocs/mkdocs/)
* [Homepage](https://www.mkdocs.org/).
* [Material theme configuration guide](https://squidfunk.github.io/mkdocs-material/getting-started/)

## Plugin development

* [User guide](https://www.mkdocs.org/user-guide/plugins/)
* [List of events](https://www.mkdocs.org/user-guide/plugins/#events)
* [Plugin testing
    example](https://github.com/andyoakley/mkdocs-blog/tree/master/tests)
