---
title: TDD
date: 20200702
author: Lyz
---

[Test-driven development](https://en.wikipedia.org/wiki/Test-driven_development)
(TDD) is a software development process that relies on the repetition of a very
short development cycle: requirements are turned into very specific test cases,
then the code is improved so that the tests pass. This is opposed to software
development that allows code to be added that is not proven to meet
requirements.

# [Abstractions in testing](https://www.cosmicpython.com/book/chapter_03_abstractions.html)

Writing tests that couple our high-level code with low-level details will make
your life hard, because as the scenarios we consider get more complex, our tests
will get more unwieldy.

To avoid it, abstract the low-level code from the high-level one, unit test it
and edge-to-edge test the high-level code.

Edge-to-edge testing involves writing end-to-end tests, substituting the low
level code for fakes that behave in the same way. The advantage of this approach
is that our tests act on the exact same function that's used by our production
code. The disadvantage is that we have to make our stateful components explicit
and pass them around.

## Fakes vs Mocks

*Mocks* are used to verify *how* something gets used. *Fakes* are working
implementations of the things they're replacing, but they're designed for use
only in tests. They wouldn't work in the real life but they can be used to make
assertions about the end state of a system rather than the behaviours along the
way.

Using fakes instead of mocks have these advantages:

* Overuse of mocks leads to complicated test suites that fail to explain the
    code
* Patching out the dependency you're using makes it possible to unit test the
    code, but it does nothing to improve the design. Faking makes you identify
    the responsibilities of your codebase, and to separate those
    responsibilities into small, focused objects that are easy to replace.
* Tests that use mocks tend to be more coupled to the implementation details
    of the codebase. That's because mock tests verify the interactions between
    things. This coupling between code and test tends to make tests more
    brittle.

Using the right abstractions is tricky, but here are a few questions that may
help you:

* Can I choose a familiar Python data structure to represent the state of the
    messy system and then try to imagine a single function that can return that
    state?
* Where can I draw a line between my systems, where can I carve out a seam to
    stick that abstraction in?
* What is a sensible way of dividing things into components with different
    responsibilities? What implicit concepts can I make explicit?
* What are the dependencies, and what is the core business logic?


# [TDD in High Gear and Low Gear](https://www.cosmicpython.com/book/chapter_05_high_gear_low_gear.html)

Tests are supposed to help us change our system fearlessly, but often we write
too many tests against the domain model. This causes problems when we want to
change our codebase and find that we need to update tens or even hundreds of
unit tests.

Every line of code that we put in a test is like a blob of glue, holding the
system in a particular shape. The more low-level tests we have, the harder it
will be to change things.

Tests can be written at the different levels of abstraction, high level tests
gives us low feedback, low barrier to change and a high system coverage, while
low level tests gives us high feedback, high barrier to change and focused
coverage.

A test for an HTTP API tells us nothing about the fine grained design of our
objects, because it sits at a much higher level of abstraction. On the other
hand, we can rewrite our entire application and, so long as we don't change the
URLs or request formats, our HTTP tests will continue to pass. This gives us
confidence that large-scale changes, like changing the database schema, haven't
broken our code.

At the other end of the spectrum, tests in the domain model  help us to
understand the objects we need. These tests guide us to a design that makes
sense and reads in the domain language. When our tests read in the domain
language, we feel comfortable that our code matches our intuition about the
problem we're trying to solve.

We often sketch new behaviours by writing tests at this level to see how the
code might look. When we want to improve the design of the code, though, we will
need to replace or delete these tests, because they are tightly coupled to
a particular implementation.

Most of the time, when we are adding a new feature or fixing a bug, we don't
need to make extensive changes to the domain model. In these cases, we prefer to
write tests against services because of the lower coupling and higher coverage.

When starting a new project or when hitting a particularly difficult problem, we
will drop back down to writing tests against the domain model so we get better
feedback and executable documentation of our intent.

!!! note Test writing level metaphor
    When starting a journey, the bicycle needs to be in a low gear so that it
    can overcome inertia. Once we're off and running, we can go faster and more
    efficiently by changing into a high gear; but if we suddenly encounter
    a steep hill or are forced to slow down by a hazard, we again drop down to
    a low gear until we can pick up speed again.


# References

* [Architecture Patterns with
    Python](https://www.cosmicpython.com/book/preface.html) by
    Harry J.W. Percival and Bob Gregory.

# Further reading

* [Martin Fowler o Mocks aren't stubs](https://martinfowler.com/articles/mocksArentStubs.html)
