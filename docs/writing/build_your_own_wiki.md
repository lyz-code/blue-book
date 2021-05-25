---
title: Build your own wiki
date: 20200205
author: Lyz
---

!!! warning "This page is an early version of a WIP"

If you don't want to start from scratch, you can [fork the blue
book](forking_this_wiki.md) and start writing straight away.

# Enable clickable navigation sections

By default, mkdocs doesn't let you to have clickable sections that lead to an
index page. It has been long discussed in
[#2060](https://github.com/squidfunk/mkdocs-material/issues/2060),
[#1042](https://github.com/mkdocs/mkdocs/pull/1042),
[#1139](https://github.com/mkdocs/mkdocs/issues/1139) and
[#1975](https://github.com/mkdocs/mkdocs/issues/1975). Thankfully,
[oprypin](https://github.com/oprypin) has solved it with the
[mkdocs-section-index](https://github.com/oprypin/mkdocs-section-index) plugin.

Install the plugin with `pip install mkdocs-section-index` and configure your
`mkdocs.yml` as:

```yaml
nav:
  - Frob: index.md
  - Baz: baz.md
  - Borgs:
    - borgs/index.md
    - Bar: borgs/bar.md
    - Foo: borgs/foo.md

plugins:
  - section-index
```

# Unconnected thoughts

* Set up ci with pre-commit and [ALE](vim_plugins.md#ale).
* Create a [custom
    commitizen](https://commitizen-tools.github.io/commitizen/customization/)
    changelog configuration to generate the rss entries periodically and publish
    them as github releases.
* If some code needs to be in a file use:
    ~~~markdown
    !!! note "File ~/script.py"
        ```python
        print('hi')
        ```
    ~~~
* Define how to add links to newly created documents in the whole wiki.
* Deploy fast, deploy early
* Grab the ideas of todo
* Define a meaningful tag policy.
  * https://www.gwern.net/About#confidence-tags
  * https://www.gwern.net/About#importance-tags

* Decide a meaningful nav policy.
  * How to decide when to create a new section,
  * Add to the index nav once it's finished, not before
* Use the `tbd` tag to mark the articles that need attention.
* Avoid file hardcoding, use [mkdocs autolinks
    plugin](https://github.com/midnightprioriem/mkdocs-autolinks-plugin/), or
    [mkdocs-altlink-plugin](https://github.com/cmitu/mkdocs-altlink-plugin) if
    [#15](https://github.com/midnightprioriem/mkdocs-autolinks-plugin/issues/15)
    is not solved and you don't need to link images.
* Use underscores for the file names, so the autocompletion feature of your
  editor works.
* Add a link to the github pages site both in the git repository description and
  in the README.
* Use [Github Actions](https://github.com/peaceiris/actions-gh-pages) to build
  your blog.
* [Make redirections of refactored articles.](https://github.com/datarobot/mkdocs-redirects)
* The newsletter could be split in
  [years](https://wiki.nikitavoloboev.xyz/looking-back/2020/2020-january) with
  one summary once the [year has ended](https://www.gwern.net/newsletter/2019/13)
* I want an rss support for my newsletters, mkdocs [is not going to support
  it](https://github.com/mkdocs/mkdocs/issues/1844), so the solution is to use
  a [static
  template](https://www.mkdocs.org/user-guide/configuration/#static_templates)
  `rss.xml` that is manually generated each time you create a new newsletter
  article. I could develop
  a [plugin](https://www.mkdocs.org/user-guide/plugins/) so it creates it at
  build time.
* [Use of custom
    domains](https://www.mkdocs.org/user-guide/deploying-your-docs/#custom-domains)
* [Material guide to enable code blocks
    highlight](https://squidfunk.github.io/mkdocs-material/extensions/pymdown/):
    From what I've seen in some github issue, you should not use it with
    codehilite, although you still have their syntax.
* [User Guide: Writing your docs](https://www.mkdocs.org/user-guide/writing-your-docs/)
* [Example of markdown writing with Material theme](https://squidfunk.github.io/mkdocs-material/specimen/) and it's [source](https://raw.githubusercontent.com/squidfunk/mkdocs-material/master/docs/specimen.md)
* [Add revision date](https://squidfunk.github.io/mkdocs-material/plugins/revision-date/)
* [Add test for rotten
    links](https://github.com/manuzhang/mkdocs-htmlproofer-plugin), it seems
   that [htmltest](https://github.com/wjdp/htmltest) was meant to be faster.
* [Adds tooltips to preview the content of page links using
    tooltipster](https://github.com/midnightprioriem/mkdocs-tooltipster-links-plugin).
    I only managed to make it work with internal links and in an ugly way... So I'm
    not using it.
* [Plugin to generate Python Docstrings](https://github.com/pawamoy/mkdocstrings)
* [Add Mermaid graphs](https://github.com/pugong/mkdocs-mermaid-plugin)
* [Add Plantuml graphs](https://github.com/christo-ph/mkdocs_build_plantuml)
* [Analyze the text readability](https://github.com/shivam5992/textstat)

## About page

* [Nikita](https://wiki.nikitavoloboev.xyz/meta)
* [Gwern](https://www.gwern.net/About)

## [Create a local server to visualize the documentation](mkdocs.md)

```bash
mkdocs serve
```

## Links

* [Nikita's wiki workflow](https://wiki.nikitavoloboev.xyz/other/wiki-workflow)
