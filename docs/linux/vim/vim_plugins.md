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
