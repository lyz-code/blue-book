---
title: Writing
date: 20200205
author: Lyz
---

Writing is difficult, at least for me. Even more if you aren't using your native
tongue. I'm focusing my efforts in improving my [grammar and
orthography](orthography.md) and [writing style](writing_style.md).

# Tests

Using automatic tools that highlight the violations of the previous principles
may help you to internalize all the measures, even more with the new ones.

Configure your editor to:

* Run a spell checker that you can check as you write.
* Alert you on new [orthography](orthography.md) rules you want to adopt.
* Use [linters](ci.md#linters) to raise your awareness on the rest of issues.
    * [alex](alex.md) to find gender favoring, polarizing, race related, religion
        inconsiderate, or other unequal phrasing in text.
    * [markdownlint](markdownlint.md): style checker and lint tool for
        Markdown/CommonMark files.
    * [proselint](proselint.md): Is another linter for prose.
    * [write-good](write_good.md) is a naive linter for English
        prose.
* Use [formatters](ci.md#formatters) to make your writing experience more
    pleasant.
    * [mdformat](https://github.com/executablebooks/mdformat): I haven't tested it yet,
        but looks promising.

There are some checks that I wasn't able to adopt:

* Try to use less than 30 words per sentence.
* Check that every sentence is ended with a dot.
* Be consistent across document structures, use *References* instead of *Links*, or
    *Installation* instead of *Install*.
* [gwern markdown-lint.sh](https://www.gwern.net/About#markdown-checker) [script
    file](https://www.gwern.net/markdown-lint.sh).
* Avoid the use of [here](link), use descriptive link text.
* Rotten links: use [linkchecker](https://github.com/linkchecker/linkchecker) (I think
  there was a mkdocs plugin to do this). Also read [how to archive
  urls](https://www.gwern.net/Archiving-URLs).
* check for use of the word "significant"/"significance" and insert
  "[statistically]" as appropriate (to disambiguate between effect sizes and
  statistical significance; this common confusion is one reason for
  ["statistical-significance considered harmful"](http://lesswrong.com/lw/g13/against_nhst/))

# Vim enhancements

* [vim-pencil](https://github.com/reedes/vim-pencil) looks promising but it's
[still not ready](issues.md)
* [mdnav](https://github.com/chmp/mdnav) opens links to urls or files when
    pressing `enter` in normal mode over a markdown link, similar to `gx` but
    more powerful. I specially like the ability of following `[self referencing
    link][]` links, that allows storing the links at the bottom.

# Writing workflow

* Start with a template.
* Use synoptical reading to gather ideas in an *unconnected thoughts* section.
* Once you've got several refactor them in sections with markdown headers.
* Ideally you'll want to wrap your whole blog post into a story or timeline.
* Add an abstract so the reader may decide if she wants to read it.

## Publication

* Think how to publicize:
  * Hacker News
  * Reddit
  * LessWrong (and further sites as appropriate)

# References

Awesome:

* [Nikita's writing notes](https://wiki.nikitavoloboev.xyz/writing)
* [Gwern's writing checklist](https://www.gwern.net/About#writing-checklist)

Good:

* [Long Naomi pen post with some key
  ideas](https://medium.com/@naomi_pen/a-blog-post-about-blog-posts-4bb6a6ce0772)

## Doing

* https://github.com/mnielsen/notes-on-writing/blob/master/notes_on_writing.md#readme

## Todo

* https://www.scottadamssays.com/2015/08/22/the-day-you-became-a-better-writer-2nd-look/
* https://blog.stephsmith.io/learning-to-write-with-confidence/
* https://styleguide.mailchimp.com/tldr/
* https://content-guide.18f.gov/inclusive-language/
* https://performancejs.com/post/31b361c/13-Tips-for-Writing-a-Technical-Book
* https://github.com/RacheltheEditor/ProductionGuide#readme
* https://mkaz.blog/misc/notes-on-technical-writing/
* https://www.swyx.io/writing/cfp-advice/
* https://sivers.org/d22
* https://homes.cs.washington.edu/~mernst/advice/write-technical-paper.html
* Investigate on readability tests:
  * [Definition](https://en.wikipedia.org/wiki/Readability_test)
  * [Introduction on Readability](https://en.wikipedia.org/wiki/Readability)
  * [List of readability tests and formulas](https://en.wikipedia.org/wiki/List_of_readability_tests_and_formulas)
  * [An example of a formula](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests)

### Vim plugins

* [Vim-lexical](https://github.com/reedes/vim-lexical)
* [Vim-textobj-quote](https://github.com/reedes/vim-textobj-quote)
* [Vim-textobj-sentence](https://github.com/reedes/vim-textobj-sentence)
* [Vim-ditto](https://github.com/dbmrq/vim-ditto)
* [Vim-exchange](https://github.com/tommcdo/vim-exchange)

### Books

* https://www.amazon.de/dp/0060891548/ref=as_li_tl?ie=UTF8&linkCode=gs2&linkId=39f2ab8ab47769b2a106e9667149df30&creativeASIN=0060891548&tag=gregdoesit03-21&creative=9325&camp=1789
* https://www.amazon.de/dp/0143127799/ref=as_li_tl?ie=UTF8&linkCode=gs2&linkId=ff9322c17ca288b1d9d6b5fb8d6df619&creativeASIN=0143127799&tag=gregdoesit03-21&creative=9325&camp=1789
