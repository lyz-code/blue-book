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
\   'python': ['isort'],
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

Use `:ALEInfo` to see the ALE configuration and any errors when running
`:ALEFix` for the specific buffer.

### Flakehell

[Flakehell](flakeheaven.md) is not [supported
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

# [vim-easymotion](https://github.com/easymotion/vim-easymotion)

EasyMotion provides a much simpler way to use some motions in vim. It takes the
`<number>` out of `<number>w` or `<number>f{char}` by highlighting all possible
choices and allowing you to press one key to jump directly to the target.

When one of the available motions is triggered, all visible text preceding or
following the cursor is faded, and motion targets are highlighted.

## [Installation](https://github.com/easymotion/vim-easymotion#installation)

Add to Vundle `Plugin 'easymotion/vim-easymotion'`

The configuration can be quite complex, but I'm starting with the basics:

```vim
" Easymotion
let g:EasyMotion_do_mapping = 0 " Disable default mappings
let g:EasyMotion_keys='asdfghjkl'

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
```

It's awesome to move between windows with `s`.

# Vim Fugitive

## [Add portions of file to the index](http://vimcasts.org/episodes/fugitive-vim-working-with-the-git-index/)

To stage only part of the file to a commit, open it and launch `:Gdiff`. With
`diffput` and `diffobtain` Vim's functionality you move to the index file (the
one in the left) the changes you want to stage.

## Prepare environment to write the commit message

When I write the commit message I like to review what changes I'm commiting. To
do it I find useful to close all windows and do a vertical split with the
changes so I can write the commit message in one of the window while I scroll
down in the other. As the changes are usually no the at the top of the file,
I scroll the window of the right to the first change and then switch back to the
left one in insert mode to start writing.

I've also made some movement remappings:

* `jj`, `kk`, `<C-d>` and `<C-u>` in insert mode will insert normal mode and go
    to the window in the right to continue seeing the changes.
* `i`, `a`, `o`, `O`: if you are in the changes window it will go to the commit message window
    in insert mode.

Once I've made the commit I want to only retain one buffer.

Add the following snippet to do just that:

```
" Open commit message buffer in fullscreen with a vertical split, and close it with
" leader q
au BufNewFile,BufRead *COMMIT_EDITMSG call CommitMessage()

function! RestoreBindings()
  inoremap jj <esc>j
  inoremap kk <esc>k
  inoremap <C-d> <C-d>
  inoremap <C-u> <C-u>
  nnoremap i i
  nnoremap a a
  nnoremap o o
  nnoremap O O
endfunction

function! CommitMessage()
  " Remap the saving mappings
  " Close buffer when saving
  inoremap <silent> <leader>q <esc>:w<cr> \| :only<cr> \| :call RestoreBindings()<cr> \|:Sayonara<CR>
  nnoremap <silent> <leader>q <esc>:w<cr> \| :only<cr> \| :call RestoreBindings()<cr> \|:Sayonara<CR>

  inoremap jj <esc>:wincmd l<cr>j
  inoremap kk <esc>:wincmd l<cr>k
  inoremap <C-d> <esc>:wincmd l<cr><C-d>
  inoremap <C-u> <esc>:wincmd l<cr><C-u>
  nnoremap i :wincmd h<cr>i
  nnoremap a :wincmd h<cr>a
  nnoremap o :wincmd h<cr>o
  nnoremap O :wincmd h<cr>O

  " Remove bad habits
  inoremap jk <nop>
  inoremap ZZ <nop>
  nnoremap ZZ <nop>
  " Close all other windows
  only
  " Create a vertical split
  vsplit
  " Go to the right split
  wincmd l
  " Go to the first change
  execute "normal! /^diff\<cr>8j"
  " Clear the search highlights
  nohl
  " Go back to the left split
  wincmd h
  " Enter insert mode
  execute "startinsert"
endfunction
```

I'm assuming that you save with `<leader>w` and that you're using Sayonara to
close your buffers.

## [Git push sets the upstream by default](https://github.com/tpope/vim-fugitive/issues/1272)

Add to your config:

```vim
nnoremap <leader>gp :Git -c push.default=current push<CR>
```

If you want to see the [output of the push
command](https://github.com/tpope/vim-fugitive/issues/951), use `:copen` after
the successful push.


# [Vim-test](https://github.com/janko-m/vim-test)

A Vim wrapper for running tests on different granularities.

Currently the following testing frameworks are supported:

| Language       | Frameworks                                            | Identifiers                                                       |
| :------------: | ----------------------------------------------------- | ----------------------------------------------------------------- |
| **C#**         | .NET                                                  | `dotnettest`                                                      |
| **Clojure**    | Fireplace.vim                                         | `fireplacetest`                                                   |
| **Crystal**    | Crystal                                               | `crystalspec`                                                     |
| **Elixir**     | ESpec, ExUnit                                         | `espec`, `exunit`                                                 |
| **Erlang**     | CommonTest                                            | `commontest`                                                      |
| **Go**         | Ginkgo, Go                                            | `ginkgo`, `gotest`                                                |
| **Java**       | Maven                                                 | `maventest`                                                       |
| **JavaScript** | Intern, Jasmine, Jest, Karma, Lab, Mocha, TAP,        | `intern`, `jasmine`, `jest`, `karma`, `lab`, `mocha`, `tap`       |
| **Lua**        | Busted                                                | `busted`                                                          |
| **PHP**        | Behat, Codeception, Kahlan, Peridot, PHPUnit, PHPSpec | `behat`, `codeception`, `kahlan`, `peridot`, `phpunit`, `phpspec` |
| **Perl**       | Prove                                                 | `prove`                                                           |
| **Python**     | Django, Nose, Nose2, PyTest, PyUnit                   | `djangotest`, `djangonose` `nose`, `nose2`, `pytest`, `pyunit`    |
| **Racket**     | RackUnit                                              | `rackunit`                                                        |
| **Ruby**       | Cucumber, [M], [Minitest][minitest], Rails, RSpec     | `cucumber`, `m`, `minitest`, `rails`, `rspec`                     |
| **Rust**       | Cargo                                                 | `cargotest`                                                       |
| **Shell**      | Bats                                                  | `bats`                                                            |
| **VimScript**  | Vader.vim, VSpec                                      | `vader`, `vspec`                                                  |

## Features

* Zero dependencies
* Zero configuration required (it Does the Right Thing™, see
  [**Philosophy**](https://github.com/janko-m/vim-test/wiki))
* Wide range of test runners which are automagically detected
* **Polyfills** for nearest tests (by [constructing regexes](#commands))
* Wide range of execution environments ("[strategies](#strategies)")
* Fully customized CLI options configuration
* Extendable with new runners and strategies

Test.vim consists of a core which provides an abstraction over running any kind
of tests from the command-line. Concrete test runners are then simply plugged
in, so they all work in the same unified way.

# Issues

## Vim-Abolish

* [Error adding elipsis instead of three
    dots](https://github.com/tpope/vim-abolish/issues/99): Pope said that it's
    not possible :(.

# References

* [ALE supported tools](https://github.com/dense-analysis/ale/blob/master/supported-tools.md)
