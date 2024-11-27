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

One downside though is that it's not able to [work with "big" files](https://github.com/neovim/neovim/issues/614) for me 110kb file broke it. Although after [some debugging](#Deal-with-big-files) it worked.
