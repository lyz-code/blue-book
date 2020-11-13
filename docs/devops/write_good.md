---
title: Write Good
date: 20201113
author: Lyz
---

[write-good](https://github.com/btford/write-good) is a naive linter for English
prose.

# Installation

```bash
npm install -g write-good
```

There is no way to configure it through a configuration file, but it accepts
command line arguments.

The [ALE vim](vim_plugins.md#ale) implementation supports the specification of
such flags with the `ale_writegood_options` variable:

```vim
let g:ale_writegood_options = "--no-passive"
```

Use `write-good --help` to see the available flags.

As of 2020-07-14, there is no pre-commit available. So I'm going to use it as
a soft linter.

# References

* [Git](https://github.com/btford/write-good)
