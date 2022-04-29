---
title: Program versioning
date: 20211215
author: Lyz
---

The Don't Repeat Yourself principle encourages developers to abstract code into
a separate components and reuse them rather than write it over and over again.
If this happens across the system, the best practice is to put it inside
a package that lives on its own (a library) and then pull it in from the
applications when required.

!!! note "This article is **heavily** based on the posts in the
[references](#references) sections, the main credit goes to them, I've just
refactored all together under my personal opinion."

As most of us can’t think of every feature that the library might offer or what
bugs it might contain, these packages tend to evolve. Therefore, we need some
mechanism to encode these evolutions of the library, so that downstream users
can understand how big the change is. Most commonly, developers use three
methods:

* A version number.
* [A changelog](changelog.md).
* The git history.

The version change is used as a concise way for the project to communicate this
evolution, and it's what we're going to analyze in this article. However,
encoding all the information of a change into a number switch [has proven to be
far from perfect](semantic_versioning.md#semantic-versioning-system-problems).

That's why keeping a [good and detailed changelog](changelog.md) makes a lot of
sense, as it will better transmit that intent, and what will be the impact of
upgrading. Once again, this falls into the same problem as before, while a change
log is more descriptive, it still only tells you what changes (or breakages)
a project intended to make, it doesn’t go into any detail about unintended
consequences of changes made. Ultimately, a change log’s accuracy is no
different than that of the version itself, it's just (hopefully!) more
detailed.

Fundamentally, any indicator of change that isn’t a full diff is just a lossy
encoding of that change. You can't expect though to read all the diffs of the
libraries that you use, that's why version numbers and changelogs make a lot of
sense. We just need to be aware of the limits of each system.

That being said, you'll use version numbers in two ways:

* As a producer of applications and libraries where you’ll have to decide what
    versioning system to use.

* As a consumer of dependencies, you’ll have to express what versions of a given library your
    application/library is compatible.

# Deciding what version system to use for your programs

The two most popular versioning systems are:

* [Semantic Versioning](semantic_versioning.md): A way to define your program's
    version based on the type of changes you've introduced.

* [Calendar Versioning](calendar_versioning.md): A versioning convention based
    on your project's release calendar, instead of arbitrary numbers.

Each has it's advantages and disadvantages. From a consumer perspective, I think
that projects should generally default to SemVer-ish, following the spirit of
the documentation rather than the letter of the specification because:

* Your version number becomes a means of communicating your changes *intents* to
    your end users.
* If you use the semantic versioning [commit message
    guidelines](semantic_versioning.md#commit-message-guidelines), you are more
    likely to have a useful git history and can automatically maintain the
    project's [changelog](changelog.md).

There are however, corner cases where [CalVer](calendar_versioning.md) makes
more sense:

* You’re tracking something that is already versioned using dates or for which
    the version number can only really be described as a point in time release.
    The `pytz` is a good example of both of these cases, the Olson TZ database is
    versioned using a date based scheme and the information that it is providing
    is best represented as a snapshot of the state of what timezones were like
    at a particular point in time.

* Your project is going to be breaking compatibility in every release and you do
    not want to make any promises of compatibility. You should still document
    this fact in your README, but if there’s no promise of compatibility between
    releases, then there’s no information to be communicated in the version
    number.

* Your project is never going to intentionally breaking compatibility in
    a release, and you strive to always maintain compatibility. Projects can
    always just use the latest version of your software. Your changes will
    only ever be additive, and if you need to change your API, you’ll do
    something like leave the old API intact, and add a new API with the new
    semantics. An example of this case would be the Ubuntu versions.

## How to evolve your code version

Assuming you're using Semantic Versioning you can improve your code evolution
by:

* [Avoid becoming a ZeroVer package](#avoid-becoming-a-zerover-package).
* [Use Warnings to avoid major changes](#use-warnings-to-avoid-major-changes)

### Avoid becoming a ZeroVer package

Once your project reach it's first level of maturity you should release `1.0.0`
to avoid falling into [ZeroVer](semantic_versioning.md#using-zerover). For
example you can use one of the next indicators:

* If you're frequently using it and haven't done any breaking change in 3 months.
* If 30 users are depending on it. For example counting the project stars.

### [Use Warnings to avoid major changes](use_warnings.md)

Semantic versioning uses the major version to defend against breaking changes,
and at the same offers maintainers the freedom to evolve the library without
breaking users. Nevertheless, this does [not seem to work that
well](semantic_versioning.md#semantic-versioning-system-problems).

So it's better to [use Warnings to avoid major changes](use_warnings.md).

### Communicate with your users

You should warn your users not to blindly trust that any version change is not
going to break their code and that you assume that they are [actively testing
the package updates](#automatically-upgrade-and-test-your-dependencies).

### Keep the `Requires-Python` metadata updated

It's important not to [upper cap the Python
version](#pinning-the-python-version-is-special) and to maintain the
`Requires-Python` package metadata updated. [Dependency
solvers](python_package_management.md#solver) will use this information to fetch
the correct versions of the packages for the users.

# Deciding how to manage the versions of your dependencies

As a consumer of other dependencies, you need to specify in your package what
versions does your code support. The traditional way to do it is by pinning
those versions in your package definition. For example in python it lives either
in the `setup.py` or in the `pyproject.toml`.

## Lower version pinning

When you're developing a program that uses a dependency, you usually don't know if
a previous version of that dependency is compatible with your code, so in theory
it makes sense to specify that you don't support any version smaller than the
actual with something like `>=1.2`. If you follow this train of thought, each
time you update your dependencies, you should update your lower pins, because
you're only running your test suite on those versions. If the libraries didn't
do [upper version pinning](#it-conflicts-with-tight-lower-bounds), then there would be no
problem as you wouldn't be risking to get into [version
conflicts](#version-conflicts).

A more relaxed approach would be not to update the pins when you update, in that
case, you should run your tests both against the oldest possible values and the
newest to ensure that everything works as expected. This way you'll be more kind
to your users as you'll reduce possible version conflicts, but it'll add work to
the maintainers.

The most relaxed approach would be not to use pins at all, it will suppress most
of the version conflicts but you won't be sure that the dependencies that your
users are using are compatible with your code.

Think about how much work you want to invest in maintaining your package and how
much stability you want to offer before you choose one or the other method. Once
you've made your choice, it would be nice if you communicate it to your users
through your documentation.

## Upper version pinning

Program maintainers often rely on upper version pinning to guarantee that their
code is not going to be broken due to a dependency update.

We’ll cover the [valid use cases for
capping](#when-is-it-ok-to-set-an-upper-limit) after this section. But, just to
be clear, if you know you do not support a new release of a library, then
absolutely, go ahead and cap it as soon as you know this to be true. If
something does not work, you should cap (or maybe restrict a single version if
the upstream library has a temporary bug rather than a design direction that’s
causing the failure). You should also do as much as you can to quickly remove
the cap, as all the downsides of capping in the next sections still apply.

The following will assume you are capping before knowing that something does not
work, but just out of general principle, like Poetry recommends and defaults to
with `poetry add`. In most cases, the answer will be *don’t*. For simplicity,
I will also assume you are being tempted to cap to major releases (`^1.0.0` in
Poetry or `~=1.0` in all other tooling that follows Python standards via PEP
440) following the false security that only `major` changes can to break your
code. If you cap to minor versions `~=1.0.0`, this is much worse, and the
arguments below apply even more strongly.

#### [Version limits break code too](https://iscinumpy.dev/post/bound-version-constraints/#version-limits-break-code-too)

Following this path will effectively *opt you out of bug fixes and security
updates*, as most of the projects only maintain the [latest version of their
program](semantic_versioning.md#maintaining-different-versions) and what worse,
you'll be *preventing everyone using your library not to use the latest version
of those libraries*. All in exchange to defend yourself against a change that in
practice will rarely impact you. Sure, you can move on to the next version of
each of your pins each time they increase a major via something like `Click>=8,
<9`. However, this involves manual intervention on their code, and you might not
have the time to do this for every one of your projects.

If we add the fact that not only major but any other version change may break
your code due to [unintended changes](semantic_versioning.md#unintended-changes)
and the [difference in the change
categorization](semantic_versioning.md#difference-in-change-categorization),
then you can treat all changes equally, so it makes no sense on pinning the
major version either.

This is specially useless when you add dependencies that follow
[CalVer](calendar_versioning.md). `poetry add` packaging will still do `^21` for
the version it adds. You shouldn’t be capping versions, but you really shouldn’t
be capping CalVer.

#### [SemVer never promises to break your code](https://iscinumpy.dev/post/bound-version-constraints/#version-limits-break-code-too)

A really easy but incorrect generalization of the SemVer rules is “a major
version will break my code”. Even if the library follows true SemVer perfectly,
a *major version bump* does not promise to *break downstream code*. It promises that
*some* downstream code *may* break. If you use `pytest` to test your code, for
example, the next major version will be very unlikely to break. If you write
a `pytest` extension, however, then the chances of something breaking are much
higher (but not 100%, maybe not even 50%). Quite ironically, the better
a package follows SemVer, the smaller the change will trigger a major version,
and therefore the less likely a major version will break a particular downstream
code.

As a general rule, if you have a reasonably stable dependency, and you only use
the documented API, especially if your usage is pretty light/general, then
a major update is extremely unlikely to break your code. It’s quite rare for
light usage of a library to break on a major update. It *can* happen, of course,
but is unlikely. If you are using something very heavily, if you are working on
a framework extension, or if you use internals that are not publicly documented,
then your chances of breaking on a major release are much higher. Python has
a culture of producing `FutureWarnings`, `DeprecationWarnings`, or
`PendingDeprecationWarnings` (make sure they are on in your testing, and
[turn into errors](pytest.md#capture-deprecation-warnings)), good libraries will
use them.

#### [Version conflicts](https://bernat.tech/posts/version-numbers/#version-conflicts)

And then there’s another aspect version pinning will introduce: version
conflicts.

An application or library will have a set of libraries it depends on directly.
These are libraries you’re directly importing within the application/library
you’re maintaining, but then the libraries themselves may rely on other
libraries. This is known as a transitive dependency. Very soon, you’ll get to
a point where two different components use the same library, and both of them
might express version constraints on it.

For example, consider the case of `tenacity`: a general-purpose retrying library.
Imagine you were using this in your application, and being a religious follower
of semantic versioning, you’ve pinned it to the version that was out when you
created the app in early 2018: `4.11`. The constraint would specify version
`4.11` or later, but less than the next major version `5`.

At the same time, you also connect to an HTTP service. This connection is
handled by another library, and the maintainer of that decided to also use
`tenacity` to offer automatic retry functionality. They pinned it similarly
following the semantic versioning convention. Back in 2018, this caused no
issues. But then August comes, and version `5.0` is released.

The service and its library maintainers have a lot more time on their hands
(perhaps because they are paid to do so), so they quickly move to version `5.0`.
Or perhaps they want to use a feature from the new major version. Now they
introduce the pin greater than five but less than six on tenacity. Their public
interface does not change at all at this point, so they do not bump their major
version. It’s just a patch release.

Python can only have one version of a library installed at a given time. At this
point, there is a version conflict. You’re requesting a version between four and
five, while the service library is requesting a version between five and six.
Both constraints cannot be satisfied.

If you use a version of pip older than `20.2` (the release in which it added
a [dependency
resolver](python_package_management.md#solver)) it will
just install a version matching the first constraint it finds and ignore any
subsequent constraints. Versions of pip after `20.2` would fail with an error
indicating that the constraint cannot be satisfied.

Either way, your application no longer works. The only way to make it work is to
either pin the service library down to the last working patch number, or upgrade
your version pinning of `tenacity`. This is generating extra work for you with
minimal benefit. Often it might not be even possible to use two conflicting
libraries until one of them relaxes their requirements. It also means you must
support a wide version range; ironically. If you update to requiring `tenacity
>5`, your update can’t be installed with another library still on `4.11`. So
you have to support `tenacity>=4.11,<6` for a while until most libraries have
similarly updated.

And for those who might think this doesn’t happen often, let me say that
`tenacity` released another major version a year later in November 2019. Thus, the
cycle starts all over again. In both cases, your code most likely did not need
to change at all, as just a small part of their public API changed. In my
experience, this happens **a lot more often** than when a major version bump
breaks you. I've found myself investing most of my project maintenance time
opening issues in third party dependencies to update their pins.

#### [It doesn’t scale](https://iscinumpy.dev/post/bound-version-constraints/#it-doesnt-scale)

If you have a single library that doesn’t play well, then you probably will get
a working solve easily (this is one reason that this practice doesn’t seem so
bad at first). If more packages start following this tight capping, however, you
end up with a situation where things simply cannot solve. A moderately sized
application can have a hundred or more dependencies when expanded, so such
issues in my experience start to appear every few months. You need only 5-6 of
such cases for every 100 libraries for this issue to pop up every two months on
your plate. And potentially for a multiple of your applications.

The entire point of packaging is to allow you to get lots of packages that each
do some job for you. We should be trying to make it easy to be able to add
dependencies, not harder.

The implication of this is you should be very careful when you see tight
requirements in packages and you have any upper bound caps anywhere in the
dependency chain. If something caps dependencies, there’s a very good chance
adding two such packages will break your solve, so you should pick just one, or
just avoid them altogether, so you can add one in the future. This is a good
rule, actually: *Never add a library to your dependencies that has excessive
upper bound capping*. When I have failed to follow this rule for a larger
package, I have usually come to regret it.

If you are doing the capping and are providing a library, you now have
a commitment to quickly release an update, ideally right *before* any capped
dependency comes out with a new version. Though if you cap, how to you install
development versions or even know when a major version is released? This makes
it harder for downstream packages to update, because they have to wait for all
the caps to be moved for all upstream.

#### [It conflicts with tight lower bounds](https://iscinumpy.dev/post/bound-version-constraints/#it-conflicts-with-tight-lower-bounds)

A tight lower bound is only bad if packages cap upper bounds. If you can avoid
upper-cap packages, you can accept tight lower bound packages, which are much
better; better features, better security, better compatibility with new hardware
and OS’s. A good packaging system should allow you to require modern packages;
why develop for really old versions of things if the packaging system can
upgrade them? But a upper bound cap breaks this. Hopefully anyone who is writing
software and pushing versions will agree that tight lower limits are much better
than tight upper limits, so if one has to go, it’s the upper limits.

It is also rather rare that packages solve for lower bounds in CI (I would love
to see such a solver become an option, by the way!), so setting a tight lower
bound is one way to avoid rare errors when old packages are cached that you
don’t actually support. CI almost never has a cache of old packages, but users
do.

#### [Capping dependencies hides incompatibilities](https://iscinumpy.dev/post/bound-version-constraints/#capping-dependencies-hides-incompatibilities)

Another serious side effect of capping dependencies is that you are not notified
properly of incoming incompatibilities, and you have to be extra proactive in
monitoring your dependencies for updates. If you don’t cap your dependencies,
you are immediately notified when a dependency releases a new version, probably
by your CI, the first time you build with that new version. If you are running
your CI with the `--dev` flag on your `pip install` (uncommon, but probably a good
idea), then you might even catch and fix the issue before a release is even
made. If you don’t do this, however, then you don’t know about the
incompatibility until (much) later.

If you are not following all of your dependencies, you might not notice that you
are out of date until it’s both a serious problem for users and it’s really hard
for you to tell what change broke your usage because several versions have been
released. While I’m not a huge fan of Google’s live-at-head philosophy
(primarily because it has heavy requirements not applicable for most open-source
projects), I appreciate and love catching a dependency incompatibility as soon
as you possibly can; the smaller the change set, the easier it is to identify
and fix the issue.

#### [Capping all dependencies hides real incompatibilities](https://iscinumpy.dev/post/bound-version-constraints/#capping-all-dependencies-hides-eal-incompatibilities)

If you see `X>=1.1`, that tells you that the package is using features from `1.1` and do
not support `1.0`. If you see `X<1.2`, this should tell you that there’s a problem
with `1.2` and the current software, specifically something they know the
dependency will not fix/revert. Not that you just capped all your dependencies
and have no idea if that will or won’t work at all. A cap should be like a TODO;
it’s a known issue that needs to be worked on soon. As in yesterday.

#### [Pinning the Python version is special](https://iscinumpy.dev/post/bound-version-constraints/#pinning-the-python-version-is-special)

Another practice pushed by Poetry is adding an upper cap to the Python version.
This is misusing a feature designed to help with dropping old Python versions to
instead stop new Python versions from being used. “Scrolling back” through older
releases to find the newest version that does not restrict the version of Python
being used is exactly the wrong behavior for an upper cap, and that is what the
purpose of this field is. Current versions of pip do seem to fail when this is
capped, rather than scrolling back to find an older uncapped version, but
I haven’t found many libraries that have “added” this after releasing to be sure
of that.

To be clear, this is very different from a library: specifically, you can’t
downgrade your Python version if this is capped to something below your current
version. You can only fail. So this does not “fix” something by getting an
older, working version, it only causes hard failures if it works the way you
might hope it does. This means instead of seeing the real failure and possibly
helping to fix it, users just see a `Python doesn’t match` error. And, most of
the time, it’s not even a real error; if you support Python `3.x` without
warnings, you should support Python `3.x+1` (and `3.x+2`, too).

Capping to `<4` (something like `^3.6` in Poetry) is also directly in conflict
with the Python developer’s own statements; they promise the `3->4` transition
will be more like the `1->2` transition than the `2->3` transition. When Python
4 does come out, it will be really hard to even run your CI on 4 until all your
dependencies uncap. And you won’t actually see the real failures, you’ll just
see incompatibility errors, so you won’t even know what to report to those
libraries. And this practice makes it hard to test development versions of
Python.

And, if you use Poetry, as soon as someone caps the Python version, every Poetry
project that uses it must also cap, even if you believe it is a detestable
practice and confusing to users. It is also wrong unless you fully pin the
dependency that forced the cap. If the dependency drops it in a patch release
or something else you support, you no longer would need the cap.

#### [Applications are slightly different](https://iscinumpy.dev/post/bound-version-constraints/#applications-are-slightly-different)

If you have a true application (that is, if you are not intending your package
to be used as a library), upper version constraints are much less problematic,
and some of the reasons above don't apply. This due to two reasons.

First, if you are writing a library, your “users” are specifying your package in
their dependencies; if an update breaks them, they can always add the necessary
exclusion or cap for you to help end users. It’s a leaky abstraction, they
shouldn’t have to care about what your dependencies are, but when capping
interferes with what they can use, that’s also a leaky and unfixable
abstraction. For an application, the “users” are more likely to be installing
your package directly, where the users are generally other developers adding to
requirements for libraries.

Second, for an app that is installed from PyPI, you are less likely to have to
worry about what else is installed (the other issues are still true). Many
(most?) users will not be using `pipx` or a fresh virtual environment each time,
so in practice, you’ll still run into problems with tight constraints, but there
is a workaround (use `pipx`, for example). You still are still affected by most of
the arguments above, though, so personally I’d still not recommend adding
untested caps.

#### [When is it ok to set an upper limit?](https://iscinumpy.dev/post/bound-version-constraints/#when-is-it-ok-to-set-an-upper-limit)

Valid reasons to add an upper limit are:

* If a dependency is known to be broken, block out the broken version. Try very
    hard to fix this problem quickly, then remove the block if it’s fixable on
    your end. If the fix happens upstream, excluding *just the broken version* is
    fine (or they can “yank” the bad release to help everyone).

* If you know upstream is about to make a major change that is very likely to
    break your usage, you can cap. But try to fix this as quickly as possible so
    you can remove the cap by the time they release. Possibly add development
    branch/release testing until this is resolved.

* If upstream asks users to cap, then I still don’t like it, but it is okay if
    you want to follow the upstream recommendation. You should ask yourself: do
    you want to use a library that may intentionally break you and require
    changes on your part without help via deprecation periods? A one-time major
    rewrite might be an acceptable reason. Also, if you are upstream, it is very
    un-Pythonic to break users without deprecation warnings first. Don’t do it
    if possible.

* If you are writing an extension for an ecosystem/framework (pytest extension,
    Sphinx extension, Jupyter extension, etc), then capping on the major version
    of that library is acceptable. Note this happens once - you have a single
    library that can be capped. You must release as soon as you possibly can
    after a new major release, and you should be closely following upstream
    - probably using development releases for testing, etc. But doing this for
    one library is probably manageable.

* You are releasing two or more libraries in sync with each other. You control
    the release cadence for both libraries. This is likely the “best” reason to
    cap. Some of the above issues don’t apply in this case - since you control
    the release cadence and can keep them in sync.

* You depend on private internal details of a library. You should also rethink
    your choices - this can be broken in a minor or patch release, and often is.

If you cap in these situations, I wouldn’t complain, but I wouldn’t really recommend it either:

* If you have a heavy dependency on a library, maybe cap. A really large API
    surface is more likely to be hit by the possible breakage.

* If a library is very new, say on version 1 or a ZeroVer library, and has very
    few users, maybe cap if it seems rather unstable. See if the library authors
    recommend capping - they might plan to make a large change if it’s early in
    development. This is not blanket permission to cap ZeroVer libraries!

* If a library looks really unstable, such as having a history of making big
    changes, then cap. Or use a different library. Even better, contact the
    authors, and make sure that your usage is safe for the near future.

#### Summary

No more than 1-2 of your dependencies should fall into the categories of
acceptable upper pinning. In every other case, do not cap your dependences,
specially if you are writing a library! You could probably summarize it like
this: if there’s a high chance (say `75%+`) that a dependency will break for you
when it updates, you can add a cap. But if there’s no reason to believe it will
break, do not add the cap; you will cause more severe (unfixable) pain than the
breakage would.

If you have an app instead of a library, you can be cautiously more relaxed, but
not much. Apps do not have to live in shared environments, though they might.

Notice many of the above instances are due to very close/special interaction
with a small number of libraries (either a plugin for a framework, synchronized
releases, or very heavy usage). Most libraries you use do not fall into this
category. Remember, library authors don’t want to break users who follow their
public API and documentation. If they do, it’s for a special and good reason (or
it is a bad library to depend on). They will probably have a deprecation period,
produce warnings, etc.

If you do version cap anything, you are promising to closely follow that
dependency, update the cap as soon as possible, follow beta or RC releases or
the development branch, etc. When a new version of a library comes out, end
users should be able to start trying it out. If they can’t, your library’s
dependencies are a leaky abstraction (users shouldn’t have to care about what
dependencies libraries use).

## Automatically upgrade and test your dependencies

Now that you have minimized the [upper bound pins](#upper-version-pinning) and
defined the [lower bound pins](#lower-version-pinning) you need to ensure that
your code works with the latest version of your dependencies.

One way to do it is running a periodic cronjob (daily probably) that updates
your requirements lock, [optionally your lower
bounds](#lower-version-pinning), and checks that the tests keep on passing.

## Monitor your dependencies evolution

You rely on your dependencies to fulfill critical parts of your package,
therefore it makes sense to know how they are changing in order to:

* Change your package to use new features.
* Be aware of the new possibilities to solve future problems.
* Get an idea of the dependency stability and future.

Depending on how much you rely on the dependency, different levels of
monitorization can be used, ordered from least to most you could check:

* *Release messages*: Some projects post them in their blogs, you can use
    their RSS feed to keep updated. If the project uses Github to create the
    release messages, you can get notifications on just those release messages.

    If the project uses [Semantic Versioning](semantic_versioning.md), it can
    help you dismiss all changes that are `micro`, review without urgency the
    `minor` and prioritize the `major` ones. If all you're given is a CalVer
    style version then you're forced to dedicate the same time to each of the
    changes.

* *Changelog*: if you get a notification of a new release, head to the changelog
    to get a better detail of what has changed.

* *Pull requests*: Depending on the project release workflow, it may
    take some time from a change to be accepted until it's published under a new
    release, if you monitor the pull requests, you get an early idea of what
    will be included in the new version.

* *Issues*: Most of changes introduced in a project are created from the outcome
    of a repository issue, where a user expresses their desire to introduce the
    change. If you monitor them you'll get the idea of how the project will
    evolve in the future.

## [Summary](https://bernat.tech/posts/version-numbers/#summary)

Is semantic versioning irrevocably broken? Should it never be used? I don’t
think so. It still makes a lot of sense where there are ample resources to
maintain multiple versions in parallel. A great example of this is Django.
However, it feels less practical for projects that have just a few maintainers.

In this case, it often leads to opting people out of bug fixes and security
updates. It also encourages version conflicts in environments that can’t have
multiple versions of the same library, as is the case with Python. Furthermore,
it makes it a lot harder for developers to learn from their mistakes and evolve
the API to a better place. Rotten old design decisions will pull down the
library for years to come.

A better solution at hand can be using CalVer and a time-window based warning
system to evolve the API and remove old interfaces. Does it solve all problems?
Absolutely not.

One thing it makes harder is library rewrites. For example, consider
virtualenv's recent rewrite. Version 20 introduced a completely new API and
changed some behaviours to new defaults. For such use cases in a CalVer world,
you would likely need to release the rewritten project under a new name, such as
virtualenv2. Then again, such complete rewrites are extremely rare (in the case
of virtualenv, it involved twelve years passing).

No version scheme will allow you to predict with any certainty how compatible
your software will be with potential future versions of your dependencies. The
only reasonable choices are for libraries to choose minimum versions/excluded
versions only, never maximum versions. For applications, do the same thing, but
also add in a lock file of known, good versions with exact pins (this is the
fundamental difference between install_requires and requirements.txt).

## [This doesn't necessarily apply to other ecosystems](https://snarky.ca/why-i-dont-like-semver/)

All of  this advice coming from me does not necessarily apply to all other
packaging ecosystems. Python's flat dependency management has its pros and cons,
hence why some other ecosystems do things differently.

# References

* [Bernat post on versioning](https://bernat.tech/posts/version-numbers/)
* [Should You Use Upper Bound Version Constraints? by Henry Schreiner](https://iscinumpy.dev/post/bound-version-constraints/)
* [Why I don't like SemVer anymore by Snarky](https://snarky.ca/why-i-dont-like-semver/)
* [Versioning Software by donald stufft](https://caremad.io/posts/2016/02/versioning-software/)
