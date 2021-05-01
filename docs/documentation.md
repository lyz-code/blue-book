---
title: Write good documentation
date: 20210501
author: Lyz
---

It doesn't matter how good your program is, because if its documentation is not
good enough, people will not use it. Even if they have to use it because they
have no choice, without good documentation, they won’t use it effectively or the
way you’d like them to.

People working with software need different kinds of documentation at different
times, in different circumstances, so good software documentation needs them
all.

They first need to get started and see how to solve specific problems. Then they
need a way to search the software possibilities in a reference. Finally when
they hit a road block, they need to understand how everything works so they can
solve it.

Each of these sections must be clearly differenced and the writing style must
be adapted. The five types of documentation are:

* [Introduction](#introduction): A short description with optional pictures or screen casts,
    that catches the user's attention and makes them want to use it. Like
    the advertisement of your program.
* [Get started](#get-started): Lessons that allows the newcomer learn how to
    start using the software. Like teaching a small child how to cook.
* [How-to guides](#how-to-guides): Series of steps that show how to solve a specific problem. Like
    a recipe in a cookery book.
* [Technical reference](#technical-reference): Searchable and organized dry
    description of the software's machinery. Like a reference encyclopedia
    article.
* [Background information](#background-information): Discursive explanations
    that makes the user understand how the software works and how has it
    evolved. Like an article on culinary social history.

This division makes it obvious to both author and reader what material, and what
kind of material, goes where. It tells the author how to write, what to
write, and where to write it.

## Introduction

The introduction is the first gateway for the users to your program, as such, it
needs to be eye-catching, otherwise they will walk pass it to one of the other
thousand programs or libraries out there.

It needs to start with a short phrase that defines the whole project in a way
that catches the user's attention.

If the short phrase doesn't give enough context, you can add a small paragraph
with further information. But don't make it too long, human's attention is weak.

It's also a good idea to add a screenshot or screencast showing the usage of the
program.

Optionally, you can also add a list of features that differentiate your solution
from the rest.

## Get started

Made of tutorials that take the reader by the hand through a series of steps
to complete a meaningful project achievable for a complete beginner. They are
what your project needs in order to show a beginner that they can achieve
something with it.

Tutorials are what will turn your learners into users. A bad or missing tutorial
will prevent your project from acquiring new users.

They need to be useful for the beginner, easy to follow, meaningful,
extremely robust, and kept up-to-date. You might well find that writing and
maintaining your tutorials can occupy as much time and energy as the other
four parts put together.

### How to write good tutorials

#### Allow the user to learn by doing

Your learner needs to do things. The different things that they do while
following your tutorial need to cover a wide range of tools and operations,
building up from the simplest ones at the start to more complex ones.

#### Get the user started

It’s perfectly acceptable if your beginner’s first steps are hand-held baby
steps. It’s also good if what you get the beginner to do is not the way an
experienced person would, or even if it’s not the ‘correct’ way.

The point of a tutorial is to get your learner started on their journey, not to
get them to a final destination.

#### Make sure that your tutorial works

One of your jobs as a tutor is to inspire the beginner’s confidence: in the
software, in the tutorial, in the tutor, and in their own ability to
achieve what’s being asked of them.

There are many things that contribute to this. A friendly tone helps, as does
consistent use of language, and a logical progression through the material. But
the single most important thing is that what you ask the beginner to do must
work.

If the learner’s actions produce an error or unexpected results, your tutorial
has failed. When your students are there with you,
you can rescue them; if they’re reading your documentation on their own you
can’t. So you have to prevent that from happening in advance.

One way of achieving this is by adding the snippets in your documentation to the
test suite.

#### Ensure the user sees results immediately

Everything the learner does should accomplish something comprehensible, however
small. If your student has to do strange and incomprehensible things for two
pages before they even see a result, that’s much too long. The effect of every
action should be visible and evident as soon as possible, and the connection to
the action should be clear.

The conclusion of each section of a tutorial, or the tutorial as a whole, must
be a meaningful accomplishment.

#### Focus on concrete steps, not abstract concepts

Tutorials need to be concrete, built around specific, particular actions and
outcomes.

The temptation to introduce abstraction is huge; it is after all how most
computing derives its power. But all learning proceeds from the particular and
concrete to the general and abstract, and asking the learner to appreciate
levels of abstraction before they have even had a chance to grasp the concrete
is poor teaching.

#### Provide the minimum necessary explanation

Don’t explain anything the learner doesn’t need to know in order to complete the
tutorial. Extended discussion is important, just not in a tutorial. In
a tutorial, it is an obstruction and a distraction. Only the bare minimum is
appropriate. Instead, link to explanations elsewhere in the documentation.

#### Focus only on the steps the user needs to take

Your tutorial needs to be focused on the task in hand. Maybe the command you’re
introducing has many other options, or maybe there are different ways to access
a certain API. It doesn’t matter: right now, your learner does not need to know
about those in order to make progress.

## How-to guides

## Technical reference

## Background information

# References

* [divio's documentation wiki](https://documentation.divio.com/introduction/)
* [Vue's guidelines](https://v3.vuejs.org/guide/contributing/writing-guide.html#principles)
* [FastAPI awesome docs](https://fastapi.tiangolo.com/tutorial/)
