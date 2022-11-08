---
Title: Git
Author: Lyz
Date: 20161202
Keywords: git
Tags: publish
---

[Git](https://en.wikipedia.org/wiki/Git) is a software for tracking changes in
any set of files, usually used for coordinating work among programmers
collaboratively developing source code during software development. Its goals
include speed, data integrity, and support for distributed, non-linear workflows
(thousands of parallel branches running on different systems).

# Learning git

Git is a tough nut to crack, no matter how experience you are you'll frequently
get surprised. Sadly it's one of the main tools to develop your code, so you
must master it as soon as possible.

Depending on how you like to learn I've found these options:

* Written courses: [W3 git course](https://www.w3schools.com/git/default.asp)
* Interactive tutorials: [Learngitbranching interactive
    tutorial](https://learngitbranching.js.org/)
* Written article: [Freecode camp article](https://www.freecodecamp.org/news/learn-the-basics-of-git-in-under-10-minutes-da548267cc91/)
* Video courses: [Code academy](https://www.codecademy.com/learn/learn-git) and [Udemy](https://www.udemy.com/course/learngit/)

# [Pull Request Process](https://raw.githubusercontent.com/kubernetes/community/master/contributors/devel/pull-requests.md)

This part of the doc is shamefully edited from the source. It was for the k8s
project but they are good practices that work for all the projects. It explains
the process and best practices for submitting a PR It should serve as
a reference for all contributors, and be useful especially to new and infrequent
submitters.

## Before You Submit a PR

This guide is for contributors who already have a PR to submit. If you're
looking for information on setting up your developer environment and creating
code to contribute to the project, search the development guide.

**Make sure your PR adheres to the projects best practices. These include
following project conventions, making small PRs, and commenting thoroughly.**

## Run Local Verifications

You can run the tests in local before you submit your PR to predict the
pass or fail of continuous integration.

## Why is my PR not getting reviewed?

A few factors affect how long your PR might wait for review.

If it's the last few weeks of a milestone, we need to reduce churn and stabilize.

Or, it could be related to best practices. One common issue is that the PR is
too big to review. Let's say you've touched 39 files and have 8657 insertions.
When your would-be reviewers pull up the diffs, they run away - this PR is going
to take 4 hours to review and they don't have 4 hours right now. They'll get to
it later, just as soon as they have more free time (ha!).

There is a detailed rundown of best practices, including how to avoid
too-lengthy PRs, in the next section.

But, if you've already followed the best practices and you still aren't getting
any PR love, here are some
things you can do to move the process along:

* Make sure that your PR has an assigned reviewer (assignee in GitHub). If not,
  reply to the PR comment stream asking for a reviewer to be assigned.

* Ping the assignee (@username) on the PR comment stream, and ask for an
  estimate of when they can get to the review.

* Ping the assignee by email (many of us have publicly available email
  addresses).

* If you're a member of the organization ping the team (via @team-name) that
  works in the area you're submitting code.

* If you have fixed all the issues from a review, and you haven't heard back,
  you should ping the assignee on the comment stream with a "please take another
  look" (`PTAL`) or similar comment indicating that you are ready for another
  review.

Read on to learn more about how to get faster reviews by following best practices.

## Best Practices for Faster Reviews

You've just had a brilliant idea on how to make a project better. Let's call
that idea Feature-X. Feature-X is not even that complicated. You have a pretty
good idea of how to implement it. You jump in and implement it, fixing a bunch
of stuff along the way. You send your PR - this is awesome! And it sits. And
sits. A week goes by and nobody reviews it. Finally, someone offers a few
comments, which you fix up and wait for more review. And you wait. Another week
or two go by. This is horrible.

Let's talk about best practices so your PR gets reviewed quickly.

### Familiarize yourself with project conventions

* Search for the Development guide
* Search for the Coding conventions
* Search for the API conventions

### Is the feature wanted? Make a Design Doc or Sketch PR

Are you sure Feature-X is something the project team wants or will accept? Is
it implemented to fit with other changes in flight? Are you willing to bet a few
days or weeks of work on it?

It's better to get confirmation beforehand. There are two ways to do this:

- Make a proposal doc (in docs/proposals; for example [the QoS
  proposal](http://prs.k8s.io/11713)), or reach out to the affected special
  interest group (SIG). Some projects have that
- Coordinate your effort with SIG Docs ahead of time
- Make a sketch PR (e.g., just the API or Go interface). Write or code up just
  enough to express the idea and the design and why you made those choices

Or, do all of the above.

Be clear about what type of feedback you are asking for when you submit
a proposal doc or sketch PR.

Now, if we ask you to change the design, you won't have to re-write it all.

### Smaller Is Better: Small Commits, Small PRs

Small commits and small PRs get reviewed faster and are more likely to be
correct than big ones.

Attention is a scarce resource. If your PR takes 60 minutes to review, the
reviewer's eye for detail is not as keen in the last 30 minutes as it was in the
first. It might not get reviewed at all if it requires a large continuous block
of time from the reviewer.

**Breaking up commits**

Break up your PR into multiple commits, at logical break points.

Making a series of discrete commits is a powerful way to express the evolution
of an idea or the different ideas that make up a single feature. Strive to group
logically distinct ideas into separate commits.

For example, if you found that Feature-X needed some prefactoring to fit in,
make a commit that JUST does that prefactoring. Then make a new commit for
Feature-X.

Strike a balance with the number of commits. A PR with 25 commits is still very
cumbersome to review, so use judgment.

**Breaking up PRs**

Or, going back to our prefactoring example, you could also fork a new branch, do
the prefactoring there and send a PR for that. If you can extract whole ideas
from your PR and send those as PRs of their own, you can avoid the painful
problem of continually rebasing.

Multiple small PRs are often better than multiple commits. Don't worry about
flooding us with PRs. We'd rather have 100 small, obvious PRs than 10
unreviewable monoliths.

We want every PR to be useful on its own, so use your best judgment on what
should be a PR vs. a commit.

As a rule of thumb, if your PR is directly related to Feature-X and nothing
else, it should probably be part of the Feature-X PR. If you can explain why you
are doing seemingly no-op work ("it makes the Feature-X change easier,
I promise") we'll probably be OK with it. If you can imagine someone finding
value independently of Feature-X, try it as a PR. (Do not link pull requests by
`#` in a commit description, because GitHub creates lots of spam. Instead,
reference other PRs via the PR your commit is in.)

### Open a Different PR for Fixes and Generic Features

**Put changes that are unrelated to your feature into a different PR.**

Often, as you are implementing Feature-X, you will find bad comments, poorly
named functions, bad structure, weak type-safety, etc.

You absolutely should fix those things (or at least file issues, please) - but
not in the same PR as your feature. Otherwise, your diff will have way too many
changes, and your reviewer won't see the forest for the trees.

**Look for opportunities to pull out generic features.**

For example, if you find yourself touching a lot of modules, think about the
dependencies you are introducing between packages. Can some of what you're doing
be made more generic and moved up and out of the Feature-X package? Do you need
to use a function or type from an otherwise unrelated package? If so, promote!
We have places for hosting more generic code.

Likewise, if Feature-X is similar in form to Feature-W which was checked in last
month, and you're duplicating some tricky stuff from Feature-W, consider
prefactoring the core logic out and using it in both Feature-W and Feature-X.
(Do that in its own commit or PR, please.)

### Comments Matter

In your code, if someone might not understand why you did something (or you
won't remember why later), comment it. Many code-review comments are about this
exact issue.

If you think there's something pretty obvious that we could follow up on, add
a TODO.

### Test

Nothing is more frustrating than starting a review, only to find that the tests
are inadequate or absent. Very few PRs can touch code and NOT touch tests.

If you don't know how to test Feature-X, please ask!  We'll be happy to help you
design things for easy testing or to suggest appropriate test cases.

### Squashing and Commit Titles

Your reviewer has finally sent you feedback on Feature-X.

Make the fixups, and don't squash yet. Put them in a new commit, and re-push.
That way your reviewer can look at the new commit on its own, which is much
faster than starting over.

We might still ask you to clean up your commits at the very end for the sake of
a more readable history, but don't do this until asked: typically at the point
where the PR would otherwise be tagged `LGTM`.

Each commit should have a good title line (`<70` characters) and include an
additional description paragraph describing in more detail the change intended.

**General squashing guidelines:**

* Sausage => squash

 Do squash when there are several commits to fix bugs in the original commit(s),
 address reviewer feedback, etc. Really we only want to see the end state and
 commit message for the whole PR.

* Layers => don't squash

 Don't squash when there are independent changes layered to achieve a single
 goal. For instance, writing a code munger could be one commit, applying it
 could be another, and adding a precommit check could be a third. One could
 argue they should be separate PRs, but there's really no way to test/review the
 munger without seeing it applied, and there needs to be a precommit check to
 ensure the munged output doesn't immediately get out of date.

A commit, as much as possible, should be a single logical change.

### KISS, YAGNI, MVP, etc.

Sometimes we need to remind each other of core tenets of software design - Keep
It Simple, You Aren't Gonna Need It, Minimum Viable Product, and so on. Adding
a feature "because we might need it later" is antithetical to software that
ships. Add the things you need NOW and (ideally) leave room for things you might
need later - but don't implement them now.

### It's OK to Push Back

Sometimes reviewers make mistakes. It's OK to push back on changes your reviewer
requested. If you have a good reason for doing something a certain way, you are
absolutely allowed to debate the merits of a requested change. Both the reviewer
and reviewee should strive to discuss these issues in a polite and respectful
manner.

You might be overruled, but you might also prevail. We're pretty reasonable
people. Mostly.

Another phenomenon of open-source projects (where anyone can comment on any
issue) is the dog-pile - your PR gets so many comments from so many people it
becomes hard to follow. In this situation, you can ask the primary reviewer
(assignee) whether they want you to fork a new PR to clear out all the comments.
You don't HAVE to fix every issue raised by every person who feels like
commenting, but you should answer reasonable comments with an explanation.

### Common Sense and Courtesy

No document can take the place of common sense and good taste. Use your best
judgment, while you put a bit of thought into how your work can be made easier
to review. If you do these things your PRs will get merged with less friction.

# [Split long PR into smaller ones](https://brewing-bits.com/blog/splitting-big-merges/)

* Start a new branch from where you want to merge.
* Start an interactive rebase on HEAD:
    ```bash
    git rebase -i HEAD
    ```

* Get the commits you want: Now comes the clever part, we are going to pick out
    all the commits we care about from 112-new-feature-branch using the
    following command:

    ```bash
    git log --oneline --reverse HEAD..112-new-feature-branch -- app/models/ spec/models
    ```

    Woah thats quite the line! Let’s dissect it first:

    * `git log` shows a log of what you have done in your project.
    * `--online` formats the output from a few lines (including author and time of
      commit), to just “[sha-hash-of-commit] [description-of-commit]”
    * `--reverse` reverses the log output chronologically (so oldest commit first,
      newest last).
    * `112-new-feature-branch..HEAD` shows the difference in commits from your
      current branch (HEAD) and the branch you are interested in
      112-new-feature-branch.
    * `-- app/models/ spec/models` Only show commits that changed files in
      app/models/ or spec/models So that we confine the changes to our model and its
      tests.

    Now if you are using vim (or vi or neovim) you can put the results of this
    command directly into your rebase-todo (which was opened when starting the
    rebase) using the :r command like so:

    ```vim
    :r !git log --oneline --reverse HEAD..112-new-feature-branch -- app/models/
    ```

* Review the commits you want: Now you have a chance to go though your todo once
    again. First you should remove the noop from above, since you actually do
    something now. Second you should check the diffs of the sha-hashes.

    Note: If you are using vim, you might already have the fugitive plug-in. If you
    haven’t changed the standard configuration, you can just move your cursor over
    the sha-hashes and press K (note that its capitalized) to see the diff of that
    commit.

    If you don’t have fugitive or don’t use vim, you can check the diff using git
    show SHA-HASH (for example `git show c4f74d0`), which shows the commits data.

    Now you can prepend and even rearrange the commits (Be careful
    rearranging or leaving out commits, you might have to fix conflicts later).

* Execute the rebase: Now you can save and exit the editor and git will try to
    execute the rebase. If you have conflicts you can fix them just like you do
    with merges and then continue using git rebase --continue.

    If you feel like something is going terribly wrong (for example you have a bunch
    of conflicts in just a few commits), you can abort the rebase using git rebase
    --abort and it will be like nothing ever happened.

# Git workflow

There are many ways of using git, one of the most popular is [git
flow](https://nvie.com/posts/a-successful-git-branching-model/), please read
[this article](https://nvie.com/posts/a-successful-git-branching-model/) to
understand it before going on.

Unless you are part of a big team that delivers software that needs to maintain
many versions, it's not worth using git flow as it's too complex and cumbersome.
Instead I suggest a variation of the Github workflow.

To carry out a reliable continuous delivery we must work to comply with the
following list of best practices:

* Everything must be in the git server: source code, tests, pipelines, scripts,
  templates and documentation.
* There is only a main branch (main) whose key is that everything is in this
  branch must be always stable and deployable into production at any time.
* New branches are created from main in order to develop new features that
  should be merged into main branch in short development cycles.
* It is highly recommended to do small commits to have more control over what is
  being done and to avoid discarding many lines of code if a rollback has to be
  done.
* A commit message policy should be set so that they are clear and conform the
  same pattern, for example [semantic versioning](semantic_versioning.md).
* `main` is blocked to reject direct pushes as well as to protect it of
  catastrophic deletion. Only pre-validated merge requests are accepted.
* When a feature is ready, we will open a merge request to merge changes into
  `main` branch.
* Use webhooks to automate the execution of tests and validation tasks in the CI
  server before/after adding changes in main.
* It is not needed to discard a merge request if any of the validation tasks
  failed. We check the code and when the changes are pushed, the CI server will
  relaunch the validation tasks.
* If all validation tasks pass, we will assign the merge request to two team
  developers to review the feature code.
* After both reviewers validate the code, the merge request can be accepted and
  the feature branch may be deleted.
* A clear versioning policy must be adopted for all generated artifacts.
* Each artifact must be generated once and be promoted to the different
  environments in different stages.

When a developer wants to add code to main should proceed as follows:

* Wait until the pipeline execution ends if it exists. If that process fails,
  then the developer must help to other team members to fix the issue before
  requesting a new merge request.
* Pull the changes from main and resolve the conflicts locally before pushing
  the code to the new feature branch.
* Run a local script that compiles and executes the tests before committing
  changes. This task can be done executing it manually by the developer or using
  a git precommit.
* Open a new merge request setting the feature branch as source branch and
  main as target branch.
* The CI server is notified of the new merge request and executes the pipeline
  which compiles the source code, executes the tests, deploys the artifact, etc.
* If there are errors in the previous step, the developer must fix the code and
  push it to the git server as soon as possible so that the CI server validate
  once again the merge request.
* If no errors, the CI server will mark the merge request as OK and the
  developer can assign it to two other team members to review the feature code.
* At this point, the developer can start with other task.

Considerations

The build process and the execution of the tests have to be pretty fast. It
should not exceed about 10 minutes.

Unit tests must be guarantee that they are completely unitary; they must be
executed without starting the context of the application, they must not access
to the DDBB, external systems, file system, etc.

## Naming conventions

The best idea is to use [Semantic Versioning](semantic_versioning.md) to define the names of the
branches, for example: `feat/add-command-line-support` or
`fix/correct-security-issue`, and also [for the commit
messages](semantic_versioning.md#commit-message-guidelines).

## Tag versioning policy

We will also adopt [semantic versioning](semantic_versioning.md) policy on
version management.

## Versioning control

When a branch is merged into main, the CI server launches a job which generates
a new artifact release as follow:

* The new version number is calculated taken into account the above
  considerations.
* Generates a new artifact named as appname-major.minor.patch.build
* Upload the previous artifact to the artifact repository manager.
* Create a git tag on the repository with the same version identifier,
  major.minor.patch.build
* Automatically deploy the artifact on the desired environment (dev, pre, etc)

## Hotfixing

Hotfix should be developed and fixed using one of the next cases, which has been
defined by preference order:

### Case 1

In this case, we have pushed new code to "main" branch since the last deploy
on production and we want to deploy the new code with the fix code.

We have to follow the next steps:

* Create a branch "Hotfix" from commit/tag of the last deploy
* Fix the bug in "hotfix" branch
* Merge the new branch to "main"
* Deploy main branch

### Case 2

In this case, we have pushed new code to "main" branch since the last deploy
on production but we  don't want to deploy the new code with the fix code.

We have to follow the next steps:

* Create a branch "Hotfix" from commit/tag of the last deploy
* Fix the bug in "hotfix" branch
* Deploy main branch
* Merge the new branch to "main.

### Case 3

In this case, we have pushed new code to "main" branch since the last deploy
on production but we don't want to deploy the new code with the fix code.

We have to follow the next steps:

* Create a branch "Hotfix" from commit/tag of the last deploy
* Fix the bug in "hotfix" branch
* Deploy main branch
* Merge the new branch to "main.

# Git housekeeping

The best option is to:

```bash
git fetch --prune
git-sweep cleanup
```

To [remove the local branches](https://github.com/arc90/git-sweep#deleting-local-branches) you can:

```bash
cd myrepo
git remote add local $(pwd)
git-sweep cleanup --origin=local
```

* [git-sweep](https://github.com/arc90/git-sweep): For local branches
* [archaeologit](https://github.com/peterjaric/archaeologit): Tool to search
  strings in the history of a github user
* [jessfraz made a tool ghb0t](https://github.com/jessfraz/ghb0t): For github

# Submodules

Shamefully edited from the
[docs](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

It often happens that while working on one project, you need to use another
project from within it. Perhaps it’s a library that a third party developed or
that you’re developing separately and using in multiple parent projects.
A common issue arises in these scenarios: you want to be able to treat the two
projects as separate yet still be able to use one from within the other.

Here’s an example. Suppose you’re developing a website and creating Atom feeds.
Instead of writing your own Atom-generating code, you decide to use a library.
You’re likely to have to either include this code from a shared library like
a CPAN install or Ruby gem, or copy the source code into your own project tree.
The issue with including the library is that it’s difficult to customize the
library in any way and often more difficult to deploy it, because you need to
make sure every client has that library available. The issue with copying the
code into your own project is that any custom changes you make are difficult to
merge when upstream changes become available.

Git addresses this issue using submodules. Submodules allow you to keep a Git
repository as a subdirectory of another Git repository. This lets you clone
another repository into your project and keep your commits separate.

It often happens that while working on one project, you need to use another
project from within it. Perhaps it’s a library that a third party developed or
that you’re developing separately and using in multiple parent projects.
A common issue arises in these scenarios: you want to be able to treat the two
projects as separate yet still be able to use one from within the other.

Here’s an example. Suppose you’re developing a website and creating Atom feeds.
Instead of writing your own Atom-generating code, you decide to use a library.
You’re likely to have to either include this code from a shared library like
a CPAN install or Ruby gem, or copy the source code into your own project tree.
The issue with including the library is that it’s difficult to customize the
library in any way and often more difficult to deploy it, because you need to
make sure every client has that library available. The issue with copying the
code into your own project is that any custom changes you make are difficult to
merge when upstream changes become available.

Git addresses this issue using submodules. Submodules allow you to keep a Git
repository as a subdirectory of another Git repository. This lets you clone
another repository into your project and keep your commits separate.

## Submodule tips

### Submodule Foreach

There is a foreach submodule command to run some arbitrary command in each
submodule. This can be really helpful if you have a number of submodules in the
same project.

For example, let’s say we want to start a new feature or do a bugfix and we have
work going on in several submodules. We can easily stash all the work in all our
submodules.

```bash
git submodule foreach 'git stash'
```

Then we can create a new branch and switch to it in all our submodules.

```bash
git submodule foreach 'git checkout -b featureA'
```

You get the idea. One really useful thing you can do is produce a nice unified
diff of what is changed in your main project and all your subprojects as well.

```bash
git diff; git submodule foreach 'git diff'
```

### Useful Aliases

You may want to set up some aliases for some of these commands as they can be
quite long and you can’t set configuration options for most of them to make them
defaults. We covered setting up Git aliases in Git Aliases, but here is an
example of what you may want to set up if you plan on working with submodules in
Git a lot.

```bash
git config alias.sdiff '!'"git diff && git submodule foreach 'git diff'"
git config alias.spush 'push --recurse-submodules=on-demand'
git config alias.supdate 'submodule update --remote --merge'
```

This way you can simply run git supdate when you want to update your submodules, or git spush to push with submodule dependency checking.


# Encrypt sensitive information

Use [git-crypt](https://github.com/AGWA/git-crypt).

# Use different git configs

Include in your `~/.gitconfig`

```
[includeIf "gitdir:~/company_A/"]
  path = ~/.config/git/company_A.config
```

Every repository you create under that directory it will append the other
configuration

# [Renaming from master to main](https://sfconservancy.org/news/2020/jun/23/gitbranchname/)

There's been a movement to migrate from `master` to `main`, the reason behind it
is that the initial branch name, `master`, is offensive to some people and we
empathize with those hurt by the use of that term.

Existing versions of Git are capable of working with any branch name; there's
nothing special about `master` except that it has historically been the name
used for the first branch when creating a new repository from scratch (with the
`git init` command). Thus many projects use it to represent the primary line of
development. We support and encourage projects to switch to branch names that
are meaningful and inclusive.

To [configure `git` to use `main` by default](https://stackoverflow.com/questions/42871542/how-can-i-create-a-git-repository-with-the-default-branch-name-other-than-maste) run:

```bash
git config --global init.defaultBranch main
```

It only works on since git version 2.28.0, so you're stuck with manually
changing it if you have an earlier version.

## Change's Controversy

The change is not free of controversy, for example in the [PDM
project](https://github.com/pdm-project/pdm/pull/1064) some people are not sure
that it's needed for many reasons. Let's see each of them:

* *The reason people are implementing the change is because other people are
    doing it*: After a quick search I found that the first one to do the change
    was [the software freedom conservancy with the Git
    project](https://sfconservancy.org/news/2020/jun/23/gitbranchname/). You can
    also see [Python](https://github.com/python/cpython/issues/78786),
    [Django](https://github.com/django/django/pull/2692),
    [Redis](https://github.com/redis/redis/issues/3185),
    [Drupal](https://www.drupal.org/node/2275877),
    [CouchDB](https://issues.apache.org/jira/browse/COUCHDB-2248) and
    [Github](https://www.theserverside.com/feature/Why-GitHub-renamed-its-master-branch-to-main)'s
    statements.

    As we're not part of the deciding organisms of the collectives
    doing the changes, all we can use are their statements and discussions to
    guess what are the reasons behind their support of the change. Despite that
    some of them do use the argument that other communities do support the
    change to emphasize the need of the change, all of them mention that the
    main reason is that the term is offensive to some people.

* *I don't see an issue using the term master*: If you relate to this statement
    it can be because you're not part of the communities that suffer the
    oppression tied to the term, and that makes you blind to the issue. It's
    a lesson I learned on my own skin throughout the years. There are thousand
    of situations, gestures, double meaning words and sentences that went
    unnoticed by me until I started discussing it with the people that are
    suffering them (women, racialized people, LGTBQI+, ...). Throughout my
    experience I've seen that the more privileged you are, the blinder you
    become. You can read more on privileged blindness
    [here](https://iveybusinessjournal.com/fighting-privilege-blindness/),
    [here](https://dojustice.crcna.org/article/becoming-aware-my-privilege) or
    [here](https://www.mindful.org/the-research-on-white-privilege-blindness/)
    (I've skimmed through the articles, and are the first articles I've found,
    there are probably better references).

    I'm not saying that privileged people are not aware of the issues or that
    they can even raise them. We can do so and more we read, discuss and train
    ourselves, the better we'll detect them. All I'm saying is that a non
    privileged person will always detect more because they suffer them daily.

    I understand that for you there is no issue using the word *master*, there
    wasn't an issue for me either until I saw these projects doing the change,
    again I was blinded to the issue as I'm not suffering it. That's because
    change is not meant for us, as we're not triggered by it. The change is
    targeted to the people that do perceive that `master` is an offensive term.
    What we can do is empathize with them and follow this tiny tiny tiny
    gesture. It's the least we can do.

    Think of a term that triggers you, such as *heil hitler*, imagine that those
    words were being used to define the main branch of your code, and that
    everyday you sit in front of your computer you see them. You'll probably be
    reminded of the historic events, concepts, feelings that are tied to that
    term each time you see it, and being them quite negative it can slowly mine
    you. Therefore it's legit that you wouldn't want to be exposed to that
    negative effects.

* *I don't see who will benefit from this change*: Probably the people that
    belongs to communities that are and have been under constant oppression for
    a very long time, in this case, specially the racialized ones which have
    suffered slavery.

    Sadly you will probably won't see many the affected people speak in these
    discussions, first because there are not that many, sadly the IT world is
    dominated by middle aged, economically comfortable, white, cis, hetero,
    males. Small changes like this are meant to foster diversity in the
    community by allowing them being more comfortable. Secondly because when
    they see these debates they move on as they are so fed up on teaching
    privileged people of their privileges. They not only have to suffer the
    oppression, we also put the burden on their shoulders to teach us.

As and ending thought, if you see yourself being specially troubled by the
change, having a discomfort feeling and strong reactions. In my experience these
signs are characteristic of privileged people that feel that their privileges
are being threatened, I've felt them myself countless times. When I feel it,
I usually do two things, fight them as strong as I can, or embrace them, analyze
them, and go to the root of them. Depending on how much energy I have I go with
the easy or the hard one. I'm not saying that it's you're case, but it could
be.

# References

* [FAQ](https://github.com/k88hudson/git-flight-rules)
* [Funny FAQ](http://ohshitgit.com/)
* [Nvie post on branching model](http://nvie.com/posts/a-successful-git-branching-model/)

## Courses

* [W3 git course](https://www.w3schools.com/git/default.asp)
* [Learngitbranching interactive tutorial](https://learngitbranching.js.org/)
* [katakoda](https://www.katacoda.com/courses/git)
* [Code academy](https://www.codecademy.com/learn/learn-git)
* [Udemy](https://www.udemy.com/course/learngit/)
* [Freecode camp article](https://www.freecodecamp.org/news/learn-the-basics-of-git-in-under-10-minutes-da548267cc91/)

## Tools

* [git-extras](https://github.com/tj/git-extras/blob/master/Commands.md)
