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
`g:abolish_save_file`. So add in `~/.vim/abbreviations.vim` the following
snippet.

```vim
" `expand('<sfile>:p')` gets the absolute path of the
" current file that this is being executed from
let g:abolish_save_file = expand('<sfile>:p')

if !exists(":Abolish")
  finish
endif
```

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
