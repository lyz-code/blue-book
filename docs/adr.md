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
Date: `date +%Y-%m-%d`

# Status
<!-- What is the status? Draft, Proposed, Accepted, Rejected, Deprecated or Superseded?
-->
$1

# Context
<!-- What is the issue that we're seeing that is motivating this decision or change? -->
$0

# Proposals
<!-- What are the possible solutions to the problem described in the context -->

# Decision
<!-- What is the change that we're proposing and/or doing? -->

# Consequences
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
* Use the problem definition of `001` and draft the phases of the solution at `002`.
* Create another ADR for each of the phases, getting a level closer to the final
    implementation.

* Use `00X` for the early drafts. Once you give it a number try not to change
    the file name, or you'll need to manually update the references you make.

As the project starts to grow, the relationships between the ADRs will get more
complex, it's useful to create an ADR landing page, where the user can follow
the logic between them. [MermaidJS](mermaidjs.md) can be used to create a nice
diagram that shows this information.

In the [mkdocs-newsletter](https://lyz-code.github.io/mkdocs-newsletter/adr/adr)
I've used the next structure:

```
graph TD
    001[001: High level analysis]
    002[002: Initial MkDocs plugin design]
    003[003: Selected changes to record]
    004[004: Article newsletter structure]
    005[005: Article newsletter creation]

    001 -- Extended --> 002
    002 -- Extended --> 003
    002 -- Extended --> 004
    002 -- Extended --> 005
    003 -- Extended --> 004
    004 -- Extended --> 005

    click 001 "https://lyz-code.github.io/mkdocs-newsletter/adr/001-initial_approach" _blank
    click 002 "https://lyz-code.github.io/mkdocs-newsletter/adr/002-initial_plugin_design" _blank
    click 003 "https://lyz-code.github.io/mkdocs-newsletter/adr/003-select_the_changes_to_record" _blank
    click 004 "https://lyz-code.github.io/mkdocs-newsletter/adr/004-article_newsletter_structure" _blank
    click 005 "https://lyz-code.github.io/mkdocs-newsletter/adr/005-create_the_newsletter_articles" _blank

    001:::accepted
    002:::accepted
    003:::accepted
    004:::accepted
    005:::accepted

    classDef draft fill:#CDBFEA;
    classDef proposed fill:#B1CCE8;
    classDef accepted fill:#B1E8BA;
    classDef rejected fill:#E8B1B1;
    classDef deprecated fill:#E8B1B1;
    classDef superseeded fill:#E8E5B1;
```

Where we define:

* The nodes with their title.
* The relationship between the ADRs.
* The link to the ADR article so it can be clicked.
* The state of the ADR.

## Tools

Although [adr-tools](https://github.com/npryce/adr-tools) exist, I feel it's an
overkill to create new documents and search on an existing codebase. We are now
used to using other tools for the similar purpose, like Vim or grep.

# References

* [Joel Parker guide on ADRs](https://github.com/joelparkerhenderson/architecture_decision_record)
* [Michael Nygard post on ARDs](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
