---
title: Frontend Development
date: 20220422
author: Lyz
---

I've recently started learning how to make web frontends, two years ago
I learned a bit of [HTML](html.md), [CSS](css.md),
[Javascript](javascript.md) and [React](react.md), but it didn't stick that
much.

This time I'm full in with [Vue](vuejs.md) which in my opinion is by far
prettier than React.

# Newbie tips

I feel completely lost xD, I don't know even how to search well what I need,
it's like going back to programming 101. Funnily though, it's bringing me closer to the people
I mentor on [Python](python.md), I'm getting frustrated with similar things that
they do, those things that you don't see when you already are proficient in
a language, so here are some tips.

## Don't resize your browser window

As I use i3wm, I've caught myself resizing the browser by adding terminals above
and besides the browser to see how does the site react to different screen
sizes. I needed the facepalm of a work colleague, which kindly suggested to
spawn the Developer Tools and move that around. If you need to resize in the
other direction, change the position of the Developer tools and grow it in that
direction.

A better feature yet is to use the  Responsive Design mode, which lets you
select screen sizes of existent devices, and it's easy to resize the screen.

## Your frontend probably doesn't talk to your backend

If you're using [Vue](vuejs.md) or a similar framework, your frontend is just
a webserver (like nginx) that has some html, js and css static files whose only
purpose is to serve those static files to the user. It is the user's browser the
one that does all the queries, even to the backend.

Imagine that we have a frontend application that uses a backend API behind the
scenes. In the front application you'll do the queries on `/api` and depending
on the environment two different things will happen:

* In your development environment, when you run the development server to
    manually interact with it with the browser, you configure it so that
    whatever request you do to `/api` is redirected to the backend endpoint,
    which usually is listening on another port on `localhost`.

    If you are doing unit or integration tests, you'll probably use your test
    runner to intercept those calls and mock the result.

    If you are doing E2E tests, your test runner will probably understand your
    development configuration and forward the requests to the backend service.

* In production you'll have an SSL proxy, for example linuxserver's
    [swag](https://docs.linuxserver.io/general/swag), that will forward `/api`
    to the backend and the rest to the frontend.

# UX design

The most popular tool out there is `Figma` but it's closed sourced, the
alternative (quite popular in github) is [`penpot`](https://penpot.app/).

# Testing

## [Write testable code](https://docs.cypress.io/guides/references/best-practices#Selecting-Elements)

Every test you write will include selectors for elements. To save yourself a lot
of headaches, you should write selectors that are resilient to changes.

Oftentimes we see users run into problems targeting their elements because:

* Your application may use dynamic classes or ID's that change.
* Your selectors break from development changes to CSS styles or JS behavior.

Luckily, it is possible to avoid both of these problems.

* Don't target elements based on CSS attributes such as: id, class, tag.
* Don't target elements that may change their `textContent`.
* Add `data-*` attributes to make it easier to target elements.

Given a button that we want to interact with:

```html
<button
  id="main"
  class="btn btn-large"
  name="submission"
  role="button"
  data-cy="submit"
>
  Submit
</button>
```

Let's investigate how we could target it:
| Selector                         | Recommended | Notes                                              |
| cy.get('button').click()         | Never       | Worst - too generic, no context.                   |
| cy.get('.btn.btn-large').click() | Never       | Bad. Coupled to styling.
Highly subject to change. |
| cy.get('#main').click() |	Sparingly |	Better. But still coupled to styling or
JS event listeners. |
| cy.get('[name=submission]').click() |	Sparingly |	Coupled to the name
attribute which has HTML semantics. |
| cy.contains('Submit').click() |	Depends |	Much better. But still coupled
to text content that may change. |
| cy.get('[data-cy=submit]').click() |	Always |	Best. Isolated from all
changes. |

## [Conditional testing](https://docs.cypress.io/guides/core-concepts/conditional-testing)

Conditional testing refers to the common programming pattern:

```
If X, then Y, else Z
```

Here are some examples:

* How do I do something different whether an element does or doesn't exist?
* My application does A/B testing, how do I account for that?
* My users receive a "welcome wizard", but existing ones don't. Can I always
    close the wizard in case it's shown, and ignore it when it's not?
* I want to automatically find all <a> elements and based on which ones I find, I want to check that each link works.

The problem is - while first appearing simple, writing tests in this fashion
often leads to flaky tests, random failures, and difficult to track down edge
cases.

Some interesting cases and their solutions:

* [Welcome wizard](https://docs.cypress.io/guides/core-concepts/conditional-testing#Use-your-server-or-database)
* [A/B Campaign](https://docs.cypress.io/guides/core-concepts/conditional-testing#A-B-campaign)
