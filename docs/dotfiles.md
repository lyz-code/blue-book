---
title: Dotfiles
date: 20221231
author: Lyz
---

[User-specific application configuration is traditionally stored in so called dotfiles](https://wiki.archlinux.org/title/Dotfiles)
(files whose filename starts with a dot). It is common practice to track
dotfiles with a version control system such as Git to keep track of changes and
synchronize dotfiles across various hosts. There are various approaches to
managing your dotfiles (e.g. directly tracking dotfiles in the home directory
v.s. storing them in a subdirectory and symlinking/copying/generating files with
a shell script or a dedicated tool).

Note: this is not meant to configure files that are outside your home directory,
use Ansible for that use case.

# [Tracking dotfiles directly with Git](https://wiki.archlinux.org/title/Dotfiles#Tracking_dotfiles_directly_with_Git)

The benefit of tracking dotfiles directly with Git is that it only requires Git
and does not involve symlinks. The disadvantage is that host-specific
configuration generally requires merging changes into multiple branches.

```bash
$ git init --bare ~/.dotfiles
$ alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
$ config config status.showUntrackedFiles no
```

## [Host-specific configuration](https://wiki.archlinux.org/title/Dotfiles#Host-specific_configuration)

A common problem with synchronizing dotfiles across various machines is
host-specific configuration.

With Git this can be solved by maintaining a main branch for all shared
configuration, while each individual machine has a machine-specific branch
checked out. Host-specific configuration can be committed to the
machine-specific branch; when shared configuration is modified in the master
branch, the per-machine branches need to be rebased on top of the updated
master.

If you find rebasing Git branches too cumbersome, you may want to use a tool
that supports file grouping, or if even greater flexibility is desired, a
[tool](#tools) that does processing.

# Using Ansible to manage the dotfiles

Ansible gives you a lot of freedom on how to configure complex devices, and I've
use it for a while, creating my own roles for each application with tests, it
was beautiful to see.

It wasn't so pleasant to use or maintain because:

- Every time you update something you need to:

  - Change the files manually until you get the new state of the files
  - Copy the files to the ansible-playbook repo
  - Apply the changes

  Alternatively you can do the changes directly on the playbook repo, but then
  you'd need to run the `apply` many more times, and it's slow, so in the end
  you don't do it.

- If you want to try a new tool but you're not sure you want it either you add
  it to the playbook and then remove it (waste of time), or play with the tool
  and then once your finished add it to the playbook. This last approach didn't
  work for me. It's like writing the docs after you've finished coding, you just
  don't do it, you don't have energy left and go to the next thing.

- Most of the applications that use dotfiles are similarly configured, so
  ansible is an overkill for them. dotfiles tools are much better because you'd
  spend less time configuring it and the result is the same.

# [Tools](https://wiki.archlinux.org/title/Dotfiles#Tools)

| Name          | Written in | File grouping              | Processing           | Stars |
| ------------- | ---------- | -------------------------- | -------------------- | ----- |
| [chezmoi][1]  | Go         | directory-based            | Go templates         | 8.2k  |
| dot-templater | Rust       | directory-based            | custom syntax        |       |
| [dotdrop][2]  | Python     | configuration file         | Jinja2               | 1.5k  |
| [dotfiles][3] | Python     | No                         | No                   | 555   |
| [Dots][4]     | Python     | directory-based            | custom append points | 264   |
| [Mackup][5]   | Python     | automatic  per application | No                   | 12.8k |
| dotter        | Rust       | configuration file         | Handlebars           |       |
| dt-cli        | Rust       | configuration file         | Handlebars           |       |
| mir.qualia    | Python     | No                         | custom blocks        |       |

Where:

- File grouping: How configuration files can be grouped to configuration groups
  (also called profiles or packages).
- Processing: Some tools process configuration files to allow them to be
  customized depending on the host.

A quick look up shows that:

- [chezmoi][1] looks like the best option.
- [dotdrop][2] looks like the second best option.
- [dotfiles][3] is unmaintained.
- [dots][4]: is maintained but migrated to go
- [mackup][5]: Looks like it's built for the cloud and it needs to support your
  application?

I think I'll give `chezmoi` a try.

[1]: chezmoi.md
[2]: dotdrop.md
[3]: https://github.com/jbernard/dotfiles
[4]: https://github.com/EvanPurkhiser/dots
[5]: https://github.com/lra/mackup
