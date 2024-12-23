---
title: Vim
date: 20210318
author: Lyz
---

Vim is a lightweight keyboard driven editor. It's the road to **fly over the
keyboard** as it increases productivity and usability.

!!! note "If you doubt between learning emacs or vim, try first with emacs through spacemacs"
    I am a power vim user for more than 10 years, and seeing what my friends do
    with emacs, I suggest you to learn it while keeping the vim movement.

    Spacemacs is a preconfigured Emacs with those bindings and a lot of more
    stuff, but it's a good way to start.

    It's not for everyone though, I tried to change to emacs but failed big as I'm  already too used to the vim ecosystem. So take my advice lightly.

From now on whenever you read `vim` I'm actually refering to [neovim](https://neovim.io/) check [this](vim_vs_neovim.md).

# [Installation](https://github.com/neovim/neovim/releases)

The version of `nvim` released by Debian is too old, use the latest by downloading it
directly from the [releases](https://github.com/neovim/neovim/releases) page and
unpacking it somewhere in your home and doing a link to the `bin/nvim` file somewhere in your `$PATH`.

```bash
# Install the dependencies

sudo apt-get install gcc g++ npm libc6-dev ripgrep

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage ~/.local/bin/nvim
```

# Configuration

Configuring `vim` is a never ending life experience. As such, it deserves it's own [section](vim_config.md)

# Troubleshooting

When you run into problems run `:checkhealth` to see if it rings a bell. If that doesn't help you maybe [I've encountered your particular problem](vim_troubleshooting.md).

## [Disable autoformat for some buffers](https://www.lazyvim.org/configuration/tips#disable-autoformat-for-some-buffers)

If you want to disable autoformat for a certain buffer, then set `vim.b.autoformat = false` for that buffer.
```lua
-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua" },
  callback = function()
    vim.b.autoformat = false
  end,
})

```

If you change your mind you can do <leader>uf to enable autoformat anyway for that buffer.
## [<c-i> is not well mapped](https://github.com/neovim/neovim/issues/5916)
It's because `<c-i>` is a synonym of `<TAB>`.

# Debugging

## Debugging with prints

Add `echom` statements. For example:

```vim
function! himalaya#domain#email#list_with(account, folder, page, query) abort
  echom "Account: " . a:account
  echom "Folder: " . a:folder
  echom "Page: " . a:page
  echom "Query: " . a:query
  call himalaya#request#plain({
  \ 'cmd': 'envelope list --folder %s --account %s --max-width %d --page-size %d --page %d %s',
  \ 'args': [shellescape(a:folder), shellescape(a:account), s:bufwidth(), winheight(0) - 1, a:page, a:query],
  \ 'msg': printf('Fetching %s envelopes', a:folder),
  \ 'on_data': {data -> s:list_with(a:folder, a:page, data)}
  \})
endfunction

```
# Resources

- [Home](https://neovim.io/)
* [News](https://neovim.io/news/)
* [awesome-neovim](https://github.com/rockerBOO/awesome-neovim/blob/main/README.md)
* [awesome-vim](https://github.com/akrawchyk/awesome-vim)

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
