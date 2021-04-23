---
title: Python Logging
date: 20210423
author: Lyz
---

Logging information in your Python programs makes it possible to debug problems
when running.

For command line application that the user is going to run directly, the
`logging` module might be enough. For command line tools or APIs that are going
to be run by a server, it might fall short. `logging` will write exceptions and
breadcrumbs to a file, and unless you look at it directly most errors will pass
unnoticed.

To actively monitor and react to code exceptions use an application monitoring
platform like [sentry](https://sentry.io/welcome/). They gather de data on your
application and aggregate the errors in a user friendly way, such as:

* Showing the context of the error in a web interface.
* Gather both front and backend issues in one place.
* Show the trail of events that led to the exceptions with breadcrumbs.
* Show the probable commit that introduced the bug.
* Link problems with issue tracker issues.
* See the impact of each bug with the number of occurrences and users that are
    experiencing it.
* Visualize all the data in dashboards.
* Get notifications on the issues raised.

Check the [demo](https://try.sentry-demo.com/) to see its features.

You can [self-host sentry](https://develop.sentry.dev/self-hosted/), but it uses
a [docker-compose](https://github.com/getsentry/onpremise/blob/21.4.1/docker-compose.yml)
that depends on 12 services, including postgres, redis and kafka with a minimum
requirements of 4 cores and 8 GB of RAM.

So I've looked for a simple solution, and arrived to
[GlitchTip](https://glitchtip.com/), a similar solution that even uses the
sentry SDK, but has a smaller system footprint, and it's [open sourced, while
sentry is not anymore](https://blog.sentry.io/2019/11/06/relicensing-sentry).
Check it's [documentation](https://glitchtip.com/documentation) and [source
code](https://gitlab.com/glitchtip).
