---
title: Vim Automation
date: 20200513
author: Lyz
---

# [Abbreviations](https://davidxmoody.com/2014/better-vim-abbreviations/)

In order to reduce the amount of typing and fix common typos, I use the Vim
abbreviations support. Those are split into two files,
`~/.vim/abbreviations.vim` for abbreviations that can be used in every type of
format and `~/.vim/markdown-abbreviations.vim` for the ones that can interfere
with programming typing.

Those files are sourced in my `.vimrc`

```vim
" Abbreviations
source ~/.vim/abbreviations.vim
autocmd BufNewFile,BufReadPost *.md source ~/.vim/markdown-abbreviations.vim
```

To avoid getting worse in grammar, I don't add abbreviations for words that
I doubt their spelling or that I usually mistake. Instead I use it for common
typos such as `teh`.

The process has it's inconveniences:

* You need different abbreviations for the capitalized versions, so you'd need
    two abbreviations for `iab cant can't` and `iab Cant Can't`
* It's not user friendly to add new words, as you need to open a file.

The [Vim Abolish plugin](https://github.com/tpope/vim-abolish) solves that. For
example:

```vim
" Typing the following:
Abolish seperate separate

" Is equivalent to:
iabbrev seperate separate
iabbrev Seperate Separate
iabbrev SEPERATE SEPARATE
```

Or create more complex rules, were each `{}` gets captured and expanded with
different caps

```vim
:Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
```

With a bang (`:Abolish!`) the abbreviation is also appended to the file in
`g:abolish_save_file`. By default `after/plugin/abolish.vim` which is loaded by
default.

Typing `:Abolish! im I'm` will append the following to the end of this file:

```vim
Abolish im I'm
```

To make it quicker I've added a mapping for `<leader>s`.

```vim
nnoremap <leader>s :Abolish!<Space>
```

Check the
[README](https://github.com/tpope/vim-abolish/blob/master/doc/abolish.txt) for
more details.

## Troubleshooting

Abbreviations with dashes or if you only want the first letter in capital need
to be specified with the first letter in capital letters as stated in [this
issue](https://github.com/tpope/vim-abolish/issues/30).

```vim
Abolish knobas knowledge-based
Abolish w what
```

Will yield `KnowledgeBased` if invoked with `Knobas`, and `WHAT` if invoked with
`W`. Therefore the following definitions are preferred:

```vim
Abolish Knobas Knowledge-based
Abolish W What
```

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

Once I've made the commit I want to only retain one buffer.

Add the following snippet to do just that:

```
" Open commit message buffer in fullscreen with a vertical split, and close it with
" leader q
au BufNewFile,BufRead *COMMIT_EDITMSG call CommitMessage()

function CommitMessage()
  " Remap the saving mappings
  inoremap <silent> <leader>w <esc>:w<cr> \| :only<cr> \|:Sayonara<CR>
  nnoremap <silent> <leader>w <esc>:w<cr> \| :only<cr> \|:Sayonara<CR>
  " Close all other windows
  only
  " Create a vertical split
  vsplit
  " Go to the right split
  wincmd l
  " Go to the first change
  execute "normal! /^diff\<cr>5j"
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
