---
title: Writing
date: 20200205
author: Lyz
---

Writing is difficult, at least for me. Even more if you aren't using your native
tongue.

# Principles

## Make it pleasant to the reader

[Writing](https://en.wikipedia.org/wiki/Writing) is a medium of communication, so avoid
introducing elements that push away the reader, such as:

* Spelling mistakes.
* Gender favoring, polarizing, race related, religion inconsiderate, or other unequal
    phrasing.
* Ugly environment: Present your texts through a pleasant medium such as
    a [mkdocs](mkdocs.md) webpage.
* Write like you talk: Ask yourself, *[is this the way I'd say this if I were talking to
    a friend?](http://www.paulgraham.com/talk.html)*. If it isn't, imagine what you would
    say, and use that instead.
* Format errors: If you're writing in markdown, make sure that the result has no display
    bugs.
* Write short articles: Even though I love [Gwern
    site](https://www.gwern.net/About#long-content), I find it daunting most of times.
    Instead of a big post, I'd rather use multiple well connected articles.

## [Saying more with less](https://wiki.nikitavoloboev.xyz/writing#saying-more-with-less)

Never use a long word where a short one will do. Replace words like `really
like` with `love` or other more appropriate words that save space writing and
are more meaningful.

Don't use filler words like *really*.

## [Be aware of pacing](https://wiki.nikitavoloboev.xyz/writing#be-aware-of-pacing)

Be aware of pacing between words and sentences. The sentences ideally should
flow into one another. Breaks in form of commas and full steps are important, as
they allow for the reader to take a break and absorb the point that you tried to
deliver. Try to use less tan 30 words per sentence.

For example, change *Due to the fact that* to *because*.

## [One purpose](https://github.com/mnielsen/notes-on-writing/blob/master/notes_on_writing.md)

A good piece of writing has a single, sharp, overriding purpose. Every part of
the writing, even the digressions, should serve that purpose. Put another
way, clarity of the general purpose is an absolute requirement in a good piece of
writing.

This observation matters because it's often tempting to let your purpose
expand and become vague. Writing a piece about gardens? Hey, why not include
that important related thought you had about rainforests? Now you have
a piece that's sort of about gardens and sort of about rainforests, and not
really about anything. The reader can no longer bond to it.

A complicating factor is that sometimes you need to explore beyond the
boundaries of your current purpose. You're writing for purpose A, but your
instinct says that you need to explore subject B. Unfortunately, you're not
yet sure how subject B fits in. If that's the case then you must take time
to explore, and to understand how, if at all, subject B fits in, and whether
you need to revise your purpose. This is emotionally difficult. It creates
uncertainty, and you may feel as though your work on subject B is wasted
effort. These doubts must be resisted.

## Avoid using clichés

[Clichés prevent readers from
visualization](https://writingcooperative.com/the-real-reason-you-shouldnt-use-clich%C3%A9s-3f4793899c7f),
making them an obstacle to creating memorable writing.

## Citing the sources

* If it's a small phrase or a refactor, link the source inside the phrase or at
    the header of the section.
* If it's a big refactor, add it to a [references](#references) section.
* If it's a big block without editing use admonition quotes



## Take all the guidelines as suggestions

All the sections above are guidelines, not rules to follow blindly, I try to
adhere to them as much as possible, but if I feel it doesn't apply I ignore
them.

## Unconnected thoughts

* Replace adjectives with data. *Nearly all of* -> *84% of*.
* Remove [weasel words](https://en.wikipedia.org/wiki/Weasel_word).
* Most adverbs are superfluous. When you say "generally" or
  "usually" you're probably undermining your point and the use of "very" or
  "extremely" are hyperbolic and breathless and make it easier to regard what
  you're writing as not serious.
* Examine every word: a surprising number don't serve any purpose.
* While wrapping your content into a story you may find yourself talking about
  your achievements more than giving actionable advice. If that happens, try to
  get to the bottom of how you achieved these achievements and break this process
  down, then focus on the process more than on your personal achievement.
* Set up a system that prompts people to review the material.
* Don't be egocentric, limit the use of `I`, use the implied subject instead:
    *It's where I go to* -> *It's the place to go.*
    *I take different actions* -> *Taking different actions*.
* Don't be possessive, use `the` instead of `my`.
* If you don't know how to express something use services like
    [deepl](deepl.com).
* Use synonyms instead of repeating the same word over and over.
* Think who are you writing to.
* Use *active voice*: Active voice ensures that the actors are identified and it
  generally leaves less open questions. The exception is if you want to
  emphasize the object of the sentence.

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

* Try to use less tan 30 words per sentence.
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
