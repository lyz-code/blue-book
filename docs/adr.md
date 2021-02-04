---
title: ADR
date: 20210204
author: Lyz
---

[ADR](https://github.com/joelparkerhenderson/architecture_decision_record) are
short text documents that captures an important architectural decision made
along with its context and consequences.

The whole document should be one or two pages long. Written as if it is
a conversation with a future developer. This requires good writing style, with
full sentences organized into paragraphs. Bullets are acceptable only for visual
style, not as an excuse for writing sentence fragments.

Pros:

* We have a clear log of the different decisions taken, which can help newcomers
    to understand past decisions.
* It can help in the discussion of such changes.
* Architecture decisions recorded in small modular readable documents.

Cons:

* More time is required for each change, as we need to document and discuss it.

# How to use them

We will keep a collection of architecturally significant decisions, those that
affect the structure, non-functional characteristics, dependencies, interfaces
or construction techniques.

There are [different
templates](https://github.com/joelparkerhenderson/architecture_decision_record#adr-example-templates)
you can start with, being the most popular [Michael Nygard's
one](https://github.com/joelparkerhenderson/architecture_decision_record/blob/master/adr_template_by_michael_nygard.md).

The documents are stored in the project repository under the `doc/arch`
directory, with a name convention of `adr-NNN.md`, where `NNN` is
a monotonically increasing number.

If a decision is reversed, we'll keep the old one around, but mark it as
superseded, as it's still relevant to know that it was a decision, but is no
longer.

## Michael Nygard's ADR template

We'll use a format with few parts, so each document is easy to digest and
maintain.

* **Title**: A short noun phrase that describes the change. For example, "ADR 1:
    Deployment on Ruby on Rails 3.0.10".
* **Context**: This section describes the forces at play, including
    technological, political, social, and project local. The language in this
    section is neutral, simply describing facts.
* **Decision**: This section describes our response to these forces. It is
    stated in full sentences, with active voice.
* **Status**: A decision may be "proposed" if we haven't agreed with it yet,
    or "accepted" once it's agreed. If a later ADR changes or reverses
    a decision, it may be marked as "deprecated" or "superseded" with
    a reference to its replacement.
* **Consequences**: This section describes the resulting context, after applying
    the decision. All consequences should be listed here, not just the positive
    ones.

## Tools

Although [adr-tools](https://github.com/npryce/adr-tools) exist, I feel it's an
overkill to create new documents and search on an existing codebase. We are now
used to using other tools for the similar purpose, like Vim or grep.

# References

* [Joel Parker guide on ADRs](https://github.com/joelparkerhenderson/architecture_decision_record)
* [Michael Nygard post on ARDs](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
