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
directory, with a name convention of `NNN-title_with_underscores.md`, where
`NNN` is a monotonically increasing number.

If a decision is reversed, we'll keep the old one around, but mark it as
superseded, as it's still relevant to know that it was a decision, but is no
longer.

## ADR template

Using Michael Nygard's template as a starting point, I'm going to use these
sections:

* **Title**: A short noun phrase that describes the change. For example, "ADR 1:
    Deployment on Ruby on Rails 3.0.10".
* **Date**: Creation date of the document.
* **Status**: The ADRs go through the following phases:
    * *Draft*: We are using the ADR to build the idea, so everything can change.
    * *Proposed*: We have a solid proposal on the Decision to solve the Context.
    * *Accepted*: We have agreed on the proposal, from now on the document can't
        be changed!
    * *Rejected*: We have agreed not to solve the Context.
    * *Deprecated*: The Context no longer applies, so the solution is no longer
        needed.
    * *Superseded*: We have found another ADR that better solves the Context.
* **Context**: This section describes the situation we're trying to solve,
    including technological, political, social, and project local aspects. The
    language in this section is neutral, simply describing facts.
* **Proposals**: Analysis of the different solutions for the situation defined
    in the Context.
* **Decision**: Clear summary of the selected proposal. It is stated in full
    sentences, with active voice.
* **Consequences**: Description of the resulting context, after applying
    the decision. All consequences should be listed here, not just the positive
    ones.

I'm using the following [Ultisnip](https://github.com/SirVer/ultisnips) vim
snippet:

```vim
snippet adr "ADR"
# ${1:Title}

Date: `date +%Y-%m-%d`

## Status
<!-- What is the status? Draft, Proposed, Accepted, Rejected, Deprecated or Superseded?
-->
$2

## Context
<!-- What is the issue that we're seeing that is motivating this decision or change? -->
$0

## Proposals
<!-- What are the possible solutions to the problem described in the context -->

## Decision
<!-- What is the change that we're proposing and/or doing? -->

## Consequences
<!-- What becomes easier or more difficult to do because of this change? -->
endsnippet
```

## Usage in a project

When starting a project, I'll do it by the ADRs, that way you evaluate the
problem, structure the idea and leave a record of your initial train of thought.

I found useful to:

* Define the general problem at high level in
    `001-high_level_problem_analysis.md`.

    * Describe the problem you want to solve in the Context.
    * Reflect the key points to solve the problem at the start of the Proposals
        section. Go one by one analyzing possible outcomes trying not to dive deep
        into details and having at least two proposals for each key point (hard!).
    * Build an initial proposal in the Decision section by reviewing that all
        the Context points have been addressed and summarizing each of the
        Proposal key points' outcomes.
    * Review the positive and negative Consequences for each actor involved with
        the solution, such as:
        * The final user that is going to consume the outcome.
        * The middle user that is going to host and maintain the solution.
        * Ourselves as developers.

## Tools

Although [adr-tools](https://github.com/npryce/adr-tools) exist, I feel it's an
overkill to create new documents and search on an existing codebase. We are now
used to using other tools for the similar purpose, like Vim or grep.

# References

* [Joel Parker guide on ADRs](https://github.com/joelparkerhenderson/architecture_decision_record)
* [Michael Nygard post on ARDs](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
