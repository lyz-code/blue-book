---
title: Vim
date: 20210318
author: Lyz
---

Vim is a lightweight keyboard driven editor. It's the road to **fly over the
keyboard** as it increases productivity and usability.

!!! note "If you doubt between learning emacs or vim, go with emacs with spacemacs"
    I am a power vim user for more than 10 years, and seeing what my friends do
    with emacs, I suggest you to learn it while keeping the vim movement.

    Spacemacs is a preconfigured Emacs with those bindings and a lot of more
    stuff, but it's a good way to start.

# Vi vs Vim vs Neovim

!!! note "TL;DR: Use Neovim"

Small comparison:

* Vi
  * Follows the Single Unix Specification and POSIX.
  * Original code written by Bill Joy in 1976.
  * BSD license.
  * Doesn't even have a git repository `-.-`.

* Vim
  * Written by Bram Moolenaar in 1991.
  * Vim is free and open source software, license is compatible with the GNU General Public License.
  * C: 47.6 %, Vim Script: 44.8%, Roff 1.9%, Makefile 1.7%, C++ 1.2%
  * Commits: 7120, Branch: **1**, Releases: 5639, Contributor: **1**
  * Lines: 1.295.837

* Neovim
  * Written by the community from 2014
  * Published under the Apache 2.0 license
  * Commits: 7994, Branch **1**, Releases: 9, Contributors: 303
  * Vim script: 46.9%, C:38.9%, Lua 11.3%, Python 0.9%, C++ 0.6%
  * Lines: 937.508 (27.65% less code than vim)
  * Refactor: Simplify maintenance and encourage contributions
  * Easy update, just symlinks
  * Ahead of vim, new features inserted in Vim 8.0 (async)

[Neovim](https://neovim.io/doc/user/vim_diff.html#nvim-features) is a refactor
of Vim to make it viable for another 30 years of hacking.

Neovim very intentionally builds on the long history of Vim community
knowledge and user habits. That means “switching” from Vim to Neovim is just
an “upgrade”.

From the start, one of Neovim’s explicit goals has been simplify maintenance and
encourage contributions.  By building a codebase and community that enables
experimentation and low-cost trials of new features..

And there’s evidence of real progress towards that ambition. We’ve
successfully executed non-trivial “off-the-roadmap” patches: features which
are important to their authors, but not the highest priority for the project.

These patches were included because they:

* Fit into existing conventions/design.
* Included robust test coverage (enabled by an advanced test framework and CI).
* Received thoughtful review by other contributors.

# Write neovim plugins

* [plugin example](https://github.com/jacobsimpson/nvim-example-python-plugin)
* [plugin repo](https://github.com/neovim/python-client)

The plugin repo has some examples in the tests directory

## Control an existing nvim instance

A number of different transports are supported, but the simplest way to get
started is with the python REPL. First, start Nvim with a known address (or use
the `$NVIM_LISTEN_ADDRESS` of a running instance):

```sh
$ NVIM_LISTEN_ADDRESS=/tmp/nvim nvim
```

In another terminal, connect a python REPL to Nvim (note that the API is similar
to the one exposed by the [python-vim
bridge](http://vimdoc.sourceforge.net/htmldoc/if_pyth.html#python-vim):

```python
>>> from neovim import attach
# Create a python API session attached to unix domain socket created above:
>>> nvim = attach('socket', path='/tmp/nvim')
# Now do some work.
>>> buffer = nvim.current.buffer # Get the current buffer
>>> buffer[0] = 'replace first line'
>>> buffer[:] = ['replace whole buffer']
>>> nvim.command('vsplit')
>>> nvim.windows[1].width = 10
>>> nvim.vars['global_var'] = [1, 2, 3]
>>> nvim.eval('g:global_var')
[1, 2, 3]
```

## Load buffer

```python
buffer = nvim.current.buffer # Get the current buffer
buffer[0] = 'replace first line'
buffer[:] = ['replace whole buffer']
```

## Get cursor position
```python
nvim.current.window.cursor
```

# Resources

* [Nvim news](https://neovim.io/news/)
* [spacevim](https://spacevim.org/)
* [awesome-vim](https://github.com/akrawchyk/awesome-vim): a list of vim
      resources maintained by the community

## Vimrc tweaking

* [jessfraz vimrc](https://github.com/jessfraz/.vim/blob/master/vimrc)

## Learning

* [vim golf](https://www.vimgolf.com)
* [Vim game tutorial](https://vim-adventures.com/): very funny and challenging,
      buuuuut at lvl 3 you have to pay :(.
* [PacVim](https://www.ostechnix.com/pacvim-a-cli-game-to-learn-vim-commands/):
      Pacman like vim game to learn.
* [Vimgenius](http://www.vimgenius.com/): Increase your speed and improve your
      muscle memory with Vim Genius, a timed flashcard-style game designed to
      make you faster in Vim. It’s free and you don’t need to sign up. What are
      you waiting for?
* [Openvim](http://www.openvim.com/): Interactive tutorial for vim.
