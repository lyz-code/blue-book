---
title: Mkdocs
date: 20200409
author: Lyz
---

[MkDocs](https://www.mkdocs.org/) is a fast, simple and downright gorgeous
static site generator that's geared towards building project documentation.
Documentation source files are written in Markdown, and configured with a single
YAML configuration file.

Note: I've automated the creation of the mkdocs site in
[this cookiecutter template](https://github.com/lyz-code/cookiecutter-python-project).

# Installation

- Install the basic packages.

  ```bash
  pip install \
      mkdocs \
      mkdocs-material \
      mkdocs-autolink-plugin \
      mkdocs-minify-plugin \
      pymdown-extensions \
      mkdocs-git-revision-date-localized-plugin
  ```

- Create the `docs` repository.

  ```bash
  mkdocs new docs
  ```

- Although there are
  [several themes](https://www.mkdocs.org/user-guide/styling-your-docs/), I
  usually use the [material](https://squidfunk.github.io/mkdocs-material) one. I
  won't dive into the different options, just show a working template of the
  `mkdocs.yaml` file.

  ```yaml
  site_name: {{site_name: null}: null}
  site_author: {{your_name: null}: null}
  site_url: {{site_url: null}: null}
  nav:
    - Introduction: index.md
    - Basic Usage: basic_usage.md
    - Configuration: configuration.md
    - Update: update.md
    - Advanced Usage:
        - Projects: projects.md
        - Tags: tags.md

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
        emoji_generator: !%21python/name:pymdownx.emoji.to_svg
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
    custom_dir: theme
    logo: images/logo.png
    palette:
      primary: blue grey
      accent: light blue

  extra_css:
    - stylesheets/extra.css
    - stylesheets/links.css

  repo_name: {{repository_name: null}: null} # for example: 'lyz-code/pydo'
  repo_url: {{repository_url: null}: null} # for example: 'https://github.com/lyz-code/pydo'
  ```

- [Configure your logo](https://squidfunk.github.io/mkdocs-material/getting-started/#logo)
  by saving it into `docs/images/logo.png`.

- I like to show a small image above each link so you know where is it pointing
  to. To do so add the content of
  [this directory](https://github.com/lyz-code/pydo/tree/master/docs/theme) to
  `theme`. and
  [these](https://github.com/lyz-code/pydo/tree/master/docs/docs/stylesheets)
  files under `docs/stylesheets`.

- Initialize the git repository and create the first commit.

- Start the server to see everything is alright.

  ```bash
  mkdocs serve
  ```

## Material theme customizations

### [Color palette toggle](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/#color-palette-toggle)

Since 7.1.0, you can have a light-dark mode on the site using a toggle in the
upper bar.

To enable it add to your `mkdocs.yml`:

```yaml
theme:
  palette:

    # Light mode
    - media: '(prefers-color-scheme: light)'
      scheme: default
      primary: blue grey
      accent: light blue
      toggle:
        icon: material/toggle-switch-off-outline
        name: Switch to dark mode

    # Dark mode
    - media: '(prefers-color-scheme: dark)'
      scheme: slate
      primary: blue grey
      accent: light blue
      toggle:
        icon: material/toggle-switch
        name: Switch to light mode
```

Changing your desired colors for each mode

### [Back to top button](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/#back-to-top-button)

Since 7.1.0, a back-to-top button can be shown when the user, after scrolling
down, starts to scroll up again. It's rendered in the lower right corner of the
viewport. Add the following lines to mkdocs.yml:

```yaml
theme:
  features:
    - navigation.top
```

## Add a github pages hook.

- Save your `requirements.txt`.

  ```bash
  pip freeze > requirements.txt
  ```

- Create the `.github/workflows/gh-pages.yml` file with the following contents.

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
            architecture: x64

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

- Create an
  [SSH deploy key](https://github.com/peaceiris/actions-gh-pages#%EF%B8%8F-create-ssh-deploy-key)

- Activate `GitHub Pages` repository configuration with `gh-pages branch`.

- Make a new commit and push to check it's working.

## Create MermaidJS diagrams

Even though the Material theme
[supports mermaid diagrams](https://squidfunk.github.io/mkdocs-material/reference/diagrams/#fn:2)
it's only giving it for the paid users. The
[funding needs to reach 5000$](https://squidfunk.github.io/mkdocs-material/insiders/#funding)
so it's released to the general public.

The alternative is to use the
[mkdocs-mermaid2-plugin](https://github.com/fralau/mkdocs-mermaid2-plugin)
plugin, which can't be used with `mkdocs-minify-plugin` and doesn't adapt to
dark mode.

To [install it](https://github.com/fralau/mkdocs-mermaid2-plugin#installation):

- Download the package: `pip install mkdocs-mermaid2-plugin`.

- Enable the plugin in `mkdocs.yml`.

  ```yaml
  plugins:
    # Not compatible with mermaid2
    # - minify:
    #    minify_html: true
    - mermaid2:
        arguments:
          securityLevel: loose
  markdown_extensions:
    - pymdownx.superfences:
        # make exceptions to highlighting of code:
        custom_fences:
          - name: mermaid
            class: mermaid
            format: !%21python/name:mermaid2.fence_mermaid
  ```

Check the [MermaidJS](mermaidjs.md) article to see how to create the diagrams.

# [Plugin development](https://www.mkdocs.org/user-guide/plugins/)

Like MkDocs, plugins must be written in Python. It is expected that each plugin
would be distributed as a separate Python module. At a minimum, a MkDocs Plugin
must consist of a
[BasePlugin](https://www.mkdocs.org/user-guide/plugins/#baseplugin) subclass and
an [entry point](https://www.mkdocs.org/user-guide/plugins/#entry-point) which
points to it.

The BasePlugin class is meant to have `on_<event_name>` methods that run actions
on the MkDocs defined [events](#events).

The same object is called at the different events, so you can save objects from
one event to the other in the object attributes.

Keep in mind that the order of execution of the plugins follows the ordering of
the list of the `mkdocs.yml` file where they are defined.

## Interesting objects

### [Files](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L14)

`mkdocs.structure.files.Files` contains a list of [File](#file) objects under
the `._files` attribute and allows you to `append` files to the collection. As
well as extracting the different file types:

- `documentation_pages`: Iterable of markdown page file objects.
- `static_pages`: Iterable of static page file objects.
- `media_files`: Iterable of all files that are not documentation or static
  pages.
- `javascript_files`: Iterable of javascript files.
- `css_files`: Iterable of css files.

It is initialized with a list of [`File`](#file) objects.

### [File](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L92)

[`mkdocs.structure.files.File`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/files.py#L92)
objects points to the source and destination locations of a file. It has the
following interesting attributes:

- `name`: Name of the file without the extension.
- `src_path` or `abs_src_path`: Relative or absolute path to the original path,
  for example the markdown file.
- `dest_path` or `abs_dest_path`: Relative or absolute path to the destination
  path, for example the html file generated from the markdown one.
- `url`: Url where the file is going to be exposed.

It is initialized with the arguments:

- `path`: Must be a path that exists relative to `src_dir`.
- `src_dir`: Absolute path on the local file system to the directory where the
  docs are.
- `dest_dir`: Absolute path on the local file system to the directory where the
  site is going to be built.
- `use_directory_urls`: If `False`, a Markdown file is mapped to an HTML file of
  the same name (the file extension is changed to `.html`). If True, a Markdown
  file is mapped to an HTML index file (`index.html`) nested in a directory
  using the "name" of the file in `path`. The `use_directory_urls` argument has
  no effect on non-Markdown files. By default MkDocs uses `True`.

### [Navigation](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L11)

[`mkdocs.structure.nav.Navigation`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L11)
objects hold the information to build the navigation of the site. It has the
following interesting attributes:

- `items`: Nested List with full navigation of Sections, SectionPages, Pages,
  and Links.
- `pages`: Flat List of subset of Pages in nav, in order.

The `Navigation` object has no `__eq__` method, so when testing, instead of
trying to build a similar `Navigation` object and compare them, you need to
assert that the contents of the object are what you expect.

### [Page](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/pages.py#L18)

[`mkdocs.structure.pages.Page`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/pages.py#L18)
models each page of the site.

To initialize it you need the `title`, the [`File`](#file) object of the page,
and the MkDocs `config` object.

### [Section](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L32)

[`mkdocs.structure.nav.Section`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L32)
object models a section of the navigation of a MkDocs site.

To initialize it you need the `title` of the section and the `children` which
are the elements that belong to the section. If you don't yet know the children,
pass an empty list `[]`.

### [SectionPage](https://github.com/oprypin/mkdocs-section-index/blob/master/mkdocs_section_index/__init__.py#L11)

[`mkdocs_section_index.SectionPage`](https://github.com/oprypin/mkdocs-section-index/blob/master/mkdocs_section_index/__init__.py#L11)
, part of the
[mkdocs-section-index](https://github.com/oprypin/mkdocs-section-index/) plugin,
models [Section](#section) objects that have an associated [Page](#page),
allowing you to have nav sections that when clicked, load the Page and not only
opens the menu for the children elements.

To initialize it you need the `title` of the section, the [`File`](#file) object
of the page, , the MkDocs `config` object, and the `children` which are the
elements that belong to the section. If you don't yet know the children, pass an
empty list `[]`.

## [Events](https://www.mkdocs.org/user-guide/plugins/#events)

### [on_config](https://www.mkdocs.org/user-guide/plugins/#on_config)

The config event is the first event called on build and is run immediately after
the user configuration is loaded and validated. Any alterations to the config
should be made here.

Parameters:

- `config`: global configuration object

Returns:

- global configuration object

### [on_files](https://www.mkdocs.org/user-guide/plugins/#on_files)

The `files` event is called after the files collection is populated from the
`docs_dir`. Use this event to add, remove, or alter files in the collection.
Note that Page objects have not yet been associated with the file objects in the
collection. Use Page Events to manipulate page specific data.

Parameters:

- `files`: global [files collection](#files)
- `config`: global configuration object

Returns:

- global [files collection](#files)

### [on_nav](https://www.mkdocs.org/user-guide/plugins/#on_nav)

The `nav` event is called after the site navigation is created and can be used
to alter the site navigation.

Warning: Read the following section if you want to
[add new files](#adding-new-files).

Parameters:

- `nav`: global [navigation object](#navigation).
- `config`: global configuration object.
- `files`: global [files collection](#files).

Returns:

- global navigation object

## Adding new files

Note: "TL;DR: Add them in the `on_config` event."

To add new files to the repository you will need two phases:

- Create the markdown article pages.
- Add them to the navigation.

My first idea as a MkDocs user, and newborn plugin developer was to add the
navigation items to the `nav` key in the `config` object, as it's more easy to
add items to a dictionary I'm used to work with than to dive into the code and
understand how MkDocs creates the navigation. As I understood from the docs, the
files should be created in the `on_files` event. the problem with this approach
is that the only event that allows you to change the `config` is the `on_config`
event, which is before the `on_files` one, so you can't build the navigation
this way after you've created the files.

Next idea was to add the items in the `on_nav` event, that means creating
yourself the [`Section`](#section), [`Pages`](#page),
[`SectionPages`](#sectionpage) or `Link` objects and append them to the
`nav.items`. [The problem](https://github.com/mkdocs/mkdocs/issues/2324) is that
MkDocs initializes and processes the `Navigation` object in the
[`get_navigation`](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/structure/nav.py#L99)
function. If you want to add items with a plugin in the `on_nav` event, you need
to manually run all the post processing functions such as building the `pages`
attribute, by running the `_get_by_type`, ` _add_previous_and_next_links` or
` _add_parent_links` yourself. Additionally, when building the site you'll get
the
`The following pages exist in the docs directory, but are not included in the "nav" configuration`
error, because that check is done *before* all plugins change the navigation in
the `on_nav` object.

The last approach is to build the files and tweak the navigation in the
`on_config` event. This approach has the next advantages:

- You need less knowledge of how MkDocs works.
- You don't need to create the `File` or `Files` objects.
- You don't need to create the `Page`, `Section`, `SectionPage` objects.
- More robust as you rely on existent MkDocs functionality.

# Testing

I haven't found any official documentation on how to test MkDocs plugins, in the
[issues](https://github.com/mkdocs/mkdocs/issues/1528) they suggest you look at
how they test it in the
[search plugin](https://github.com/mkdocs/mkdocs/blob/master/mkdocs/tests/search_tests.py).
I've looked at other plugins such as
[mkdocs_blog](https://github.com/andyoakley/mkdocs-blog) and used the next way
to test [mkdocs-newsletter](https://github.com/lyz-code/mkdocs-newsletter).

I see the plugin definition as an entrypoint to the functionality of our
program, that's why I feel the definition should be in
`src/mkdocs_newsletter/entrypoints/mkdocs_plugin.py`. As any entrypoint, the
best way to test them are in end-to-end tests.

You need to have a
[working test site](https://github.com/lyz-code/mkdocs-newsletter/tree/master/tests/assets/test_data)
in `tests/assets/test_data`, with it's `mkdocs.yml` file that loads your plugin
and some fake articles.

To prepare the test we can define the next [fixture](pytest.md#fixtures) that
prepares the building of the site:

File: `tests/conftest.py`:

```python
import os
import shutil

from mkdocs import config
from mkdocs.config.base import Config


@pytest.fixture(name="config")
def config_(tmp_path: Path) -> Config:
    """Load the mkdocs configuration."""
    repo_path = tmp_path / "test_data"
    shutil.copytree("tests/assets/test_data", repo_path)
    mkdocs_config = config.load_config(os.path.join(repo_path, "mkdocs.yml"))
    mkdocs_config["site_dir"] = os.path.join(repo_path, "site")
    return mkdocs_config
```

It does the next steps:

- Copy the fake MkDocs site to a temporal directory
- Prepare the MkDocs `Config` object to build the site.

Now we can use it in the e2e tests:

File: `tests/e2e/test_plugin.py`:

```python
def test_plugin_builds_newsletters(full_repo: Repo, config: Config) -> None:
    build.build(config)  # act

    newsletter_path = f"{full_repo.working_dir}/site/newsletter/2021_02/index.html"
    with open(newsletter_path, "r") as newsletter_file:
        newsletter = newsletter_file.read()
    assert "<title>February of 2021 - The Blue Book</title>" in newsletter
```

That test is meant to ensure that our plugin works with the MkDocs ecosystem, so
the assertions should be done against the created html files.

If your functionality can't be covered by the happy path of the end-to-end test,
it's better to create unit tests to make sure that they work as you want.

You can see a full example
[here](https://github.com/lyz-code/mkdocs-newsletter/tree/master/tests).

# Issues

Once they are closed:

- [Mkdocs Deprecation warning](https://github.com/mkdocs/mkdocs/issues/2794),
  once it's solved remove the warning filter on mkdocs-newsletter
  `pyproject.toml`.
- [Mkdocs-Material Deprecation warning](https://github.com/squidfunk/mkdocs-material/issues/3695),
  once it's solved remove the warning filter on mkdocs-newsletter
  `pyproject.toml`.

# References

- [Git](https://github.com/mkdocs/mkdocs/)
- [Homepage](https://www.mkdocs.org/).
- [Material theme configuration guide](https://squidfunk.github.io/mkdocs-material/getting-started/)

## Plugin development

- [User guide](https://www.mkdocs.org/user-guide/plugins/)
- [List of events](https://www.mkdocs.org/user-guide/plugins/#events)
- [Plugin testing example](https://github.com/andyoakley/mkdocs-blog/tree/master/tests)
