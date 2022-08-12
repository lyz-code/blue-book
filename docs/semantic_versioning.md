---
title: Semantic Versioning
date: 20211215
author: Lyz
---

[Semantic Versioning](https://semver.org/) is a way to define your program's
version based on the type of changes you've introduced. It's defined as
a three-number string (separated with a period) in the format of
`MAJOR.MINOR.PATCH`.

Usually, it starts with 0.0.0. Then depending on the type of change you make to
the library, you increment one of these and set subsequent numbers to zero:

* `MAJOR` version if you make backward-incompatible changes.
* `MINOR` version if you add a new feature.
* `PATCH` version if you fix bugs.

The version number in this context is used as a contract between the library
developer and the systems pulling it in about how freely they can upgrade. For
example, if you wrote your web server against `Django 3`, you should be good to
go with all `Django 3` releases that are at least as new as your current one.
This allows you to express your Django dependency in the format of `Django >=
3.0.2, <4`.

In addition, we have to take into account the following considerations:

* A normal version number MUST take the form X.Y.Z where X, Y, and Z are
  non-negative integers, and MUST NOT contain leading zeroes.
* Once a versioned package has been released, the contents of that version MUST
  NOT be modified. Any modifications MUST be released as a new version.
* Major version zero (0.y.z) is for initial development. Anything may change at
  any time. The public API should not be considered stable. But don't fall into
  using [ZeroVer](#using-zerover) instead.
* Releasing the version 1.0.0 is a declaration of intentions to your users that
    the code is to be considered stable.
* Patch version Z (x.y.Z | x > 0) MUST be incremented if only backwards
  compatible bug fixes are introduced. A bug fix is defined as an internal
  change that fixes incorrect behavior.
* Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards
  compatible functionality is introduced to the public API. It MUST be
  incremented if any public API functionality is marked as deprecated. It MAY be
  incremented if substantial new functionality or improvements are introduced
  within the private code. It MAY include patch level changes. Patch version
  MUST be reset to 0 when minor version is incremented.
* Major version X (X.y.z | X > 0) MUST be incremented if any backwards
  incompatible changes are introduced to the public API. It MAY include minor
  and patch level changes. Patch and minor version MUST be reset to 0 when major
  version is incremented.

!!! note "Encoding this information in the version is just an extremely lossy, but very
fast to parse and interpret, which may lead into
[issues](#semantic-versioning-system-problems.)

By using this format whenever you rebuild your application, you’ll automatically
pull in any new feature/bugfix/security releases of Django, enabling you to use
the latest and best version that still [in
theory](#semantic-versioning-system-problems.) guarantees to works with your
project.

This is great because:

* You enable automatic, compatible security fixes.
* It automatically pulls in bug fixes on the library side.
* Your application will keep building and working in the future as it did today
    because the significant version pin protects you from pulling in versions
    whose API would not match.

# [Commit message guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)

If you like the idea behind Semantic Versioning, it makes sense to follow the
Angular commit convention to automate the [changelog maintenance](changelog.md)
and the program version bumping.

Each commit message consists of a header, a body and a footer. The header has
a defined format that includes a type, a scope and a subject:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The *header* is mandatory and the *scope* of the header is optional.

Any line of the commit message cannot be longer 100 characters.

The *footer* could contain a [closing reference to an
issue](https://help.github.com/articles/closing-issues-via-commit-messages/).

Samples:

```
docs(changelog): update changelog to beta.5

fix(release): need to depend on latest rxjs and zone.js

The version in our package.json gets copied to the one we publish, and users need the latest of these.

docs(router): fix typo 'containa' to 'contains' (#36764)

Closes #36763

PR Close #36764
```

## Change types

Must be one of the following:

* `feat`: A new feature.
* `fix`: A bug fix.
* `test`: Adding missing tests or correcting existing tests.
* `docs`: Documentation changes.
* `chore`: A package maintenance change such as updating the requirements.
* `bump`: A commit to mark the increase of the version number.
* `style`: Changes that do not affect the meaning of the code (white-space,
    formatting, missing semi-colons, etc).
* `ci`: Changes to our CI configuration files and scripts.
* `perf`: A code change that improves performance.
* `refactor`: A code change that neither fixes a bug nor adds a feature.
* `build`: Changes that affect the build system or external dependencies.

## Subject

The subject contains a succinct description of the change:

* Use the imperative, present tense: "change" not "changed" nor "changes".
* Don't capitalize the first letter.
* No dot (.) at the end.

## Body

Same as in the subject, use the imperative present tense. The body should
include the motivation for the change and contrast this with previous behavior.

## Footer

The footer should contain any information about Breaking Changes and is also the
place to reference issues that this commit Closes.

Breaking Changes should start with the word `BREAKING CHANGE:` with a space or
two newlines. The rest of the commit message is then used for this.

## Revert

If the commit reverts a previous commit, it should begin with `revert:` , followed
by the header of the reverted commit. In the body it should say: `This reverts
commit <hash>.`, where the hash is the SHA of the commit to revert.

## Helpers

### Use tool to bump your program version

You can use the [commitizen](https://github.com/commitizen-tools/commitizen)
tool to:

* Automatically detect which type of change you're introducing and decide
    which should be the next version number.
* [Update the changelog](changelog.md)

By running `cz bump --changelog --no-verify`.

The `--no-verify` part is required [if you use pre-commit
hooks](https://github.com/commitizen-tools/commitizen/issues/164).

Whenever you want to release `1.0.0`, use `cz bump --changelog --no-verify
--increment MAJOR`. If you are on a version `0.X.Y`, and you introduced
a breaking change but don't want to upgrade to `1.0.0`, use the `--increment
MINOR` flag.

### Use tool to create the commit messages

To get used to make correct commit messages, you can use the
[commitizen](https://commitizen-tools.github.io/commitizen/) tool, that guides
you through the steps of making a good commit message. Once you're used to the
system though, it makes more sense to ditch the tool and write the messages
yourself.

In Vim, if you're using Vim fugitive you can [change the
configuration](https://vi.stackexchange.com/questions/3670/how-to-enter-insert-mode-when-entering-neovim-terminal-pane)
to:

```vimrc
nnoremap <leader>gc :terminal cz c<CR>
nnoremap <leader>gr :terminal cz c --retry<CR>

" Open terminal mode in insert mode
if has('nvim')
    autocmd TermOpen term://* startinsert
endif
autocmd BufLeave term://* stopinsert
```

If some pre-commit hook fails, make the changes and then use `<leader>gr` to
repeat the same commit message.

### Pre-commit

To ensure that your project follows these guidelines, add the following
to your [pre-commit configuration](ci.md):

!!! note "File: .pre-commit-config.yaml"
    ```yaml
    - repo: https://github.com/commitizen-tools/commitizen
      rev: master
      hooks:
        - id: commitizen
          stages: [commit-msg]
    ```

# When to do a major release

Following the Semantic Versioning idea of a major update is problematic because:

* You can quickly get into the [high version number](#high-version-numbers) problem.
* The fact that [any change may break the users
    code](#unintended-changes) makes the definition of [when a change should be major
    blurry](#difference-in-change-categorization).
* Often the change that triggered the major change only affects a low percentage
    of your users (usually those using that one feature you changed in an
    incompatible fashion).

Does dropping Python 2 require a major release? Many (most) packages did this,
but the general answer is ironically no, it is not an addition or a breaking
change, the version solver will ensure the correct version is used (unless the
`Requires-Python` metadata slot is empty or not updated).

If you mark a feature as deprecated (almost always in a minor release), you can
remove that feature in a future minor release. You have to define in your
library documentation what the deprecation period is. For example, NumPy and
Python use three minor releases. Sometimes is useful to implement deprecations
based on a period of time. SemVer purists argue that this makes minor releases
into major releases, but as we've seen it’s not that simple. The deprecation
period ensures the “next” version works, which is really useful, and usually
gives you time to adjust before the removal happens. It’s a great balance for
projects that are well kept up using libraries that move forward at a reasonable
pace. If you make sure you can see deprecations, you will almost always work
with the next several versions.

# [Semantic versioning system problems](https://bernat.tech/posts/version-numbers/#whats-the-problem-with-semantic-versioning)

On paper, semantic versioning seems to be addressing all we need to encode the
evolution and state of our library. When implementation time comes some issues
are raised though.

!!! note "The pitfalls mentioned below don't invalidate the Semantic Versioning system,
you just need to be aware of them."

## Maintaining different versions

Version numbers are just a mapping of a sequence of digits to our branching
strategy in source control. For instance, if you are doing SemVer then your
`X.Y.Z` version maps a branch to `X.Y` branch where you're doing your current
feature work, an `X.Y.Z+1` branch for any bugfixes, and potentially an `X+1.0.0`
branch where you doing some crazy new stuff. So you got your next branch, main
branch, and bugfix branch. And all three of those branches are alive and
receiving updates.

For projects that have those 3 kinds of branches going, the concept of SemVer
makes much more sense, but how many projects are doing that? You have to be
a pretty substantial project typically to have the throughput to justify that
much project overhead.

There are a lot more projects that have a single `bugfix` branch and
a `main` branch which has all feature work, whether it be massively
backwards-incompatible or not. In that case why carry around two version
numbers? This is how you end up with [ZeroVer](#using-zerover). If you're doing
that why not just drop a digit and have your version be `X.Y`? PEP 440 supports
it, and it would more truthfully represent your branching strategy appropriately
in your version number. However, most library maintainers/developers out there
don’t have enough resources to maintain even two branches.

Maintaining a library is very time-consuming, and most libraries have just a few
active maintainers available that maintain other many libraries. To complicate
matters even further, for most maintainers this is not a full-time job, but
something on the side, part of their free time.

Given the scarce human resources to maintain a library, in practice, there’s
a single supported version for any library at any given point in time: *the
latest one*. Any version before that (be that major, minor, patch) is in essence
abandoned:

* If you want security updates, you need to move to the latest version.
* If you want a bug to be fixed, you need to move to the newest version.
* If you want a new feature, it is only going to be available in the latest
    version.

If the only maintained version is the latest, you really just have an `X` version
number that is monotonically increasing. Once again PEP 440 supports it, so why
not! It still communicates your branch strategy of there being only a single
branch at any one time. Now I know this is a bit too unconventional for some
people, and you may get into the [high version number
problem](#high-version-numbers), then maybe it makes sense to use [calendar
versioning](calendar_versioning.md) to use the version number to indicate the
release date to signify just how old of a version you’re using, but if stuff is
working does that really matter?

## [High version numbers](https://caremad.io/posts/2016/02/versioning-software/)

Another major argument is that people inherently judge a project based on what
it’s version number is. They’ll implicitly assume that `foo 2.0` is better than
`bar 1.0` (and `frob 3.0` is better still) because the version numbers are higher.
However, there is a limit to this, if you go too high too quickly, people assume
your project is unstable and shouldn’t really be used, even if the reason that
your project is so high is because you removed some tiny edge cases that nobody
actually used and didn’t actually impact many people, if any, at all.

These are two different expressions of the same thing. The first is that people
will look down on a project for not having a high enough version compared to its
competitors. While it’s true that some people will do this, it's not
a significant reason to throw away the communication benefits of your version
number. Ultimately, no matter what you do, people who judge a project as
inferior because of something as shallow as “smaller version number” will find
some other, equally shallow, reason to pick between projects.

The other side of this is a bit different. When you have a large major version,
like `42.0.0`, people assume that your library is not stable and that you
regularly break compatibility and if you follow SemVer strictly, it does
actually mean that you regularly break compatibility.

There are two general cases:

* The *true positives*: where a project that does routinely break it’s public API in meaningful ways.
* The *false positives*: Projects that strictly follow semantic versioning were
    each change which is not backwards compatible requires bumping a major
    version. This means that if you remove some function that nobody actually
    uses you need to increase your major version. Do it again and you need to
    increase your major version again. Do this enough times, for even very small
    changes and you can quickly get into a large version number `6`. This case
    is a false positive for the “stability” test, because the reality is that
    your project is actually quite stable.

## [Difference in change categorization](https://snarky.ca/why-i-dont-like-semver/)

Here's a thought experiment: you need to add a new warning to your Python
package that tries to follow SemVer. Would that single change cause you to
increase the major, minor, or patch version number? You might think a patch
number bump since it isn't a new feature or breaking anything. You might think
it's a minor version bump because it isn't exactly a bugfix. And you might think
it's a major version bump because if you ran your Python code with `-W` error you
suddenly introduced a new exception which could break people's code. [Brett
Cannon did
a poll](https://twitter.com/brettsky/status/1262077534797041665?ref_src=twsrc%5Etfw),
answered by 231 people with the results:

* *Patch/Bugfix*: 47.2%
* *Minor/enhancement*: 44.2%
* *Major/breaking*: 8.7%

That speaks volumes to why SemVer does not inherently work: someone's bugfix may
be someone else's breaking change. Because in Python we can't statically define
what an API change is there will always be a disagreement between you and your
dependencies as to what a "feature" or "bugfix" truly is.

That builds one of the arguments for [CalVer](calendar_versioning.md). Because
SemVer is imperfect at describing if a particular change will break someone
upgrading the software, that we should instead throw it out and replace it with
something that doesn’t purport to tell us that information.

## [Unintended changes](https://bernat.tech/posts/version-numbers/#will-a-major-version-bump-always-break-you)

A major version bump must happen not only when you rewrite an entire library
with its complete API, but also when you’re just renaming a single rarely used
function (which some may erroneously view as a minor change). Or even worse,
it’s not always clear what’s part of the public API and what’s not.

You have a library with some incidental, undocumented, and unspecified behavior
that you consider to be obviously not part of the public interface. You change
it to solve what seems like a bug to you, and make a patch release, only to find
that you have angry hordes at the gate who, thanks to [Hyrum’s
Law](https://www.hyrumslaw.com/), depend on the old behavior.

> With a sufficient number of users of an API, it does not matter what you
> promise in the contract. All observable behaviors of your system will be
> depended on by somebody.

Which has been represented perfectly by the people behind
[xkcd](https://imgs.xkcd.com/comics/workflow.png).

![ ](xkcd-workflow.png)

While every maintainer would like to believe they’ve thought of every use case
up-front and created the best API for everything. In practice it's impossible to
think on every impact your changes will make.

Even if you were very diligent/broad with your interpretation to avoid
accidentally breaking people with a bugfix release, bugs can still happen in
a bugfix release. It obviously isn't intentional, but it does happen which means
SemVer can't protect you from having to test your code to see if a patch version
is compatible with your code.

This makes “true” SemVer pointless. Minor releases are impossible, and patch
releases are nearly impossible. If you fix a bug, someone could be depending on
the buggy behaviour.

## [Using ZeroVer](https://0ver.org/)

ZeroVer is a joke versioning system similar to Semantic Versioning with the sole
difference that `MAJOR` is always `0`. From the specification, as long as you
are in the `0.X.Y` versions, you can introduce incompatible changes at any
point. It intended to make fun of people who use “semantic versioning” but never
make a `1.0` release, thus defeating the purpose of semver.

This one of the consequences of trying to strictly follow Semantic Versioning,
because once you give the leap to `1.0` you need to increase the `major` on each
change quickly leading to the problem of [high version
numbers](#high-version-numbers). The best way to fight this behaviour is to remember the often
overlooked [SemVer 2.0 FAQ
guideline](https://semver.org/#how-do-i-know-when-to-release-100):

> If your software is being used in production, it should probably already be
> 1.0.0. If you have a stable API on which users have come to depend, you should
> be 1.0.0. If you’re worrying a lot about backwards compatibility, you should
> probably already be 1.0.0.

# When to use it

Check the [Deciding what version system to use for your
programs](versioning.md#deciding-what-version-system-to-use-for-your-programs)
article section.

# References

* [Home](https://semver.org/)

* [Bernat post on versioning](https://bernat.tech/posts/version-numbers/)
* [Why I don't like SemVer anymore by Snarky](https://snarky.ca/why-i-dont-like-semver/)
* [Versioning Software by donald stufft](https://caremad.io/posts/2016/02/versioning-software/)

## Libraries

These libraries can be used to interact with a git history of commits that
follow the semantic versioning [commit guidelines](#commit-message-guidelines).

* [python-semantic-release](https://python-semantic-release.readthedocs.io)
