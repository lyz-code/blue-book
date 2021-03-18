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

Add the plugin and configure it so vim runs it each time you save.

!!! note "File `~/.vimrc`"
    ```vimrc
    Plugin 'psf/black'

    " Black
    autocmd BufWritePre *.py execute ':Black'
    ```

A configuration [issue](https://github.com/psf/black/issues/1293) exists for neovim. If you
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

# [ALE](https://github.com/dense-analysis/ale)

ALE (Asynchronous Lint Engine) is a plugin providing linting (syntax checking
and semantic errors) in NeoVim 0.2.0+ and Vim 8 while you edit your text files,
and acts as a Vim Language Server Protocol client.

ALE makes use of NeoVim and Vim 8 job control functions and timers to run
linters on the contents of text buffers and return errors as text changes in
Vim. This allows for displaying warnings and errors in files before they are
saved back to a filesystem.

In other words, this plugin allows you to lint while you type.

ALE offers support for fixing code with command line tools in a non-blocking
manner with the `:ALEFix` feature, [supporting tools in many languages](https://github.com/dense-analysis/ale/blob/master/supported-tools.md), like
prettier, eslint, autopep8, and more.

## [Installation](https://github.com/dense-analysis/ale#installation)

Install with Vundle:

```vimrc
Plugin 'dense-analysis/ale'
```

## [Configuration](https://github.com/dense-analysis/ale/blob/master/doc/ale.txt)

```vim
let g:ale_sign_error                  = '✘'
let g:ale_sign_warning                = '⚠'
highlight ALEErrorSign ctermbg        =NONE ctermfg=red
highlight ALEWarningSign ctermbg      =NONE ctermfg=yellow
let g:ale_linters_explicit            = 1
let g:ale_lint_on_text_changed        = 'normal'
" let g:ale_lint_on_text_changed        = 'never'
let g:ale_lint_on_enter               = 0
let g:ale_lint_on_save                = 1
let g:ale_fix_on_save                 = 1

let g:ale_linters = {
\  'markdown': ['markdownlint', 'writegood', 'alex', 'proselint'],
\  'json': ['jsonlint'],
\  'python': ['flake8', 'mypy', 'pylint', 'alex'],
\  'yaml': ['yamllint', 'alex'],
\   '*': ['alex', 'writegood'],
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'json': ['jq'],
\   'python': ['isort']
\   'terraform': ['terraform'],
\}
inoremap <leader>e <esc>:ALENext<cr>
nnoremap <leader>e :ALENext<cr>
inoremap <leader>p <esc>:ALEPrevious<cr>
nnoremap <leader>p :ALEPrevious<cr>
```

Where:

* `let g:ale_linters_explicit`: Prevent ALE load only the selected linters.
* use `<leader>e` and `<leader>p` to navigate through the warnings.

If you feel that it's too heavy, use `ale_lint_on_enter` or increase the
`ale_lint_delay`.

Use `:ALEInfo` to see the ALE configuration for the specific buffer.

### Flakehell

[Flakehell](flakehell.md) is not [supported
yet](https://github.com/dense-analysis/ale/issues/3295). Until that issue is
closed we need the following configuration:

```
let g:ale_python_flake8_executable = flake8helled
let g:ale_python_flake8_use_global = 1
```

### Toggle fixers on save

There are cases when you don't want to run the fixers in your code.

Ale [doesn't have an option to do
it](https://github.com/dense-analysis/ale/issues/1353), but zArubaru showed how
to do it. If you add to your configuration

```
command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"
```

You can then use `:ALEToggleFixer` to activate an deactivate them.

# Issues

## Vim-Abolish

* [Error adding elipsis instead of three
    dots](https://github.com/tpope/vim-abolish/issues/99): Pope said that it's
    not possible :(.

# References

* [ALE supported tools](https://github.com/dense-analysis/ale/blob/master/supported-tools.md)
