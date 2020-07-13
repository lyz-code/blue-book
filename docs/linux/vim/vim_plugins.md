---
title: Vim plugins
date: 20200702
author: Lyz
---

# [Black](https://black.readthedocs.io/en/stable/)

To install Black you first need `python3-venv`.

```bash
sudo apt-get install python3-venv
```

Add the plugin and configure it to be executed each time you save.

!!! note "File `~/.vimrc`"
    ```vimrc
    Plugin 'psf/black'

    " Black
    autocmd BufWritePre *.py execute ':Black'
    ```

There is an [issue](https://github.com/psf/black/issues/1293) for neovim. If you
encounter the error `AttributeError: module 'black' has no attribute
'find_pyproject_toml'`, do the following:

```bash
cd ~/.vim/bundle/black
git checkout 19.10b0
```

As the default line length is 88 (ugly number by the way), we need to change the
indent, python-mode configuration as well

```vimrc

"" python indent
autocmd BufNewFile,BufRead *.py setlocal foldmethod=indent tabstop=4 softtabstop=4 shiftwidth=4 textwidth=88 smarttab expandtab

" python-mode
let g:pymode_options_max_line_length = 88
let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}
```

