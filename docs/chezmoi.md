---
title: Chezmoi
date: 20221231
author: Lyz
---

[Chezmoi](https://www.chezmoi.io/) stores the desired state of your dotfiles in
the directory `~/.local/share/chezmoi`. When you run `chezmoi apply`, `chezmoi`
calculates the desired contents for each of your dotfiles and then makes the
minimum changes required to make your dotfiles match your desired state.

What I like:

- Supports `pass` to retrieve credentials.
- Popular
- Can remove directories on `apply`
- It has a `diff`
- [It can include dotfiles from an URL](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)
- [Encrypt files with gpg](https://www.chezmoi.io/user-guide/encryption/gpg/)
- [There's a vim plugin](https://github.com/alker0/chezmoi.vim)
- Actively maintained
- Good documentation

What I don't like:

- Go templates, although
  [it supports autotemplating](https://www.chezmoi.io/user-guide/templating/#creating-a-template-file)
  and it's
  [well explained](https://www.chezmoi.io/user-guide/templating/#template-variables)
- Written in Go

# Installation

I've added some useful aliases:

```bash
alias ce='chezmoi edit'
alias ca='chezmoi add'
alias cdiff='chezmoi diff'
alias cdata='chezmoi edit-config'
alias capply='chezmoi apply'
alias cexternal='nvim ~/.local/share/chezmoi/.chezmoiexternal.yaml'
```

# [Basic Usage](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine)

Assuming that you have already installed `chezmoi`, initialize `chezmoi` with:

```bash
$ chezmoi init
```

This will create a new git local repository in `~/.local/share/chezmoi` where
`chezmoi` will store its source state. By default, `chezmoi` only modifies files
in the working copy.

Manage your first file with chezmoi:

```bash
$ chezmoi add ~/.bashrc
```

This will copy `~/.bashrc` to `~/.local/share/chezmoi/dot_bashrc`.

Edit the source state:

```bash
$ chezmoi edit ~/.bashrc
```

This will open `~/.local/share/chezmoi/dot_bashrc` in your `$EDITOR`. Make some
changes and save the file.

See what changes chezmoi would make:

```bash
$ chezmoi diff
```

Apply the changes:

```bash
$ chezmoi -v apply
```

All `chezmoi` commands accept the `-v` (verbose) flag to print out exactly what
changes they will make to the file system, and the `-n` (dry run) flag to not
make any actual changes. The combination `-n -v` is very useful if you want to
see exactly what changes would be made.

Next, open a shell in the source directory, to commit your changes:

```bash
$ chezmoi cd
$ git add .
$ git commit -m "Initial commit"
```

Create a new repository on your desired git server called `dotfiles` and then
push your repo:

```bash
$ git remote add origin https://your_git_server.com/$GIT_USERNAME/dotfiles.git
$ git branch -M main
$ git push -u origin main
```

Hint: `chezmoi` can be configured to automatically add, commit, and push changes
to your repo.

Finally, exit the shell in the source directory to return to where you were:

```bash
$ exit
```

## [Install a binary from an external url](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/#extract-a-single-file-from-an-archive)

Sometimes you may want to install some binaries from external urls, for example
[`velero`](velero.md) a backup tool for kubernetes. And you may want to be able to
define what version you want to have and be able to update it at will. 

To do that we can define the version in the configuration with `chezmoi edit-config`

```yaml
data:
  velero_version: 1.9.5
```

All the variables you define under the `data` field are globally available on all your
templates.

Then we can set the external configuration of chezmoi by editing the file
`~/.config/chezmoi/.chezmoiexternal.yaml` and add the next snippet:

```yaml
.local/bin/velero:
  type: "file"
  url: https://github.com/vmware-tanzu/velero/releases/download/v{{ .velero_version }}/velero-v{{ .velero_version }}-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz
  executable: true
  refreshPeriod: 168h
  filter:
    command: tar
    args:
      - --extract
      - --file
      - /dev/stdin
      - --gzip
      - --to-stdout
      - velero-v{{ .velero_version }}-{{ .chezmoi.os }}-{{ .chezmoi.arch }}/velero
```

This will download the binary of version `1.9.5` from the source, unpack it and extract
the `velero` binary and save it to `~/.local/bin/velero`.

# References

- [Home](https://www.chezmoi.io/)
