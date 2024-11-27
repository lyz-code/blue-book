# Prepare environment to write the commit message

When I write the commit message I like to review what changes I'm commiting. To
do it I find useful to close all windows and do a vertical split with the
changes so I can write the commit message in one of the window while I scroll
down in the other. As the changes are usually no the at the top of the file,
I scroll the window of the right to the first change and then switch back to the
left one in insert mode to start writing.

I've also made some movement remappings:

* `<C-s>` to save the commit.
* `q` to quit without saving.
* `jj`, `kk`, `<C-d>` and `<C-u>` in insert mode will insert normal mode and go
    to the window in the right to continue seeing the changes.
* `i`, `a`, `o`, `O`: if you are in the changes window it will go to the commit message window
    in insert mode.

Once I've made the commit I want to only retain one buffer.

Add the following snippet to `lua/config/autocmds.lua` if you're using [`lazyvim`](lazyvim.md):

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  group = augroup("gitcommit"),
  callback = function()
    local keymap = vim.keymap

    -- Close the diffview window if its open
    if next(require("diffview.lib").views) ~= nil then
      vim.cmd("DiffviewClose")
    end
    -- Close all other windows
    vim.cmd("only")
    -- Create a vertical nplit
    vim.cmd("vsplit")
    -- " Go to the right split
    vim.cmd("wincmd l")
    -- " Go to the first change
    vim.cmd('execute "normal! /^diff<cr>8j"')
    -- " Clear the search highlights
    vim.cmd("nohl")
    -- " Open buffers
    -- set foldlevel=999
    -- " Go back to the left split
    vim.cmd("wincmd h")
    -- " Enter insert mode
    vim.cmd('execute "startinsert"')

    -- Saving keymaps
    keymap.set({ "i", "n" }, "<c-s>", function()
      -- Close all other windows
      vim.cmd("only")
      -- Save the buffer
      vim.cmd("w")
      -- Close the buffer
      vim.cmd("bd")
    end, { desc = "Save the current buffer and exit" })

    keymap.set("n", "q", function()
      -- Close all other windows
      vim.cmd("only")
      -- Close the buffer
      vim.cmd("bd!")
    end, { desc = "Close the current buffer and exit without saving" })

    -- Movement keymaps
    keymap.set("i", "jj", "<esc>:wincmd l<cr>j", { desc = "Go to normal, changes window and down" })
    keymap.set("i", "kk", "<esc>:wincmd l<cr>k", { desc = "Go to normal, changes window and up" })
    keymap.set("i", "<c-d>", "<esc>:wincmd l<cr><c-d>", { desc = "Go to normal, changes window and down a bunch" })
    keymap.set("i", "<c-u>", "<esc>:wincmd l<cr><c-u>", { desc = "Go to normal, changes window and up a bunch" })

    -- Editor keymaps
    keymap.set("n", "i", ":wincmd h<cr>i", { desc = "Insert in the commit message window" })
    keymap.set("n", "a", ":wincmd h<cr>a", { desc = "Append in the commit message window" })
    keymap.set("n", "o", ":wincmd h<cr>o", { desc = "Open below in the commit message window" })
    keymap.set("n", "O", ":wincmd h<cr>O", { desc = "Open above in the commit message window" })
  end,
})
```

I'm assuming that you save with `<leader>w` and that you're using Sayonara to
close your buffers.

# Vim git plugin comparison

There are many plugins to work with git in neovim the most interesting ones are:

* [diffview](diffview.md)
* [vim-fugitive](https://github.com/tpope/vim-fugitive)
* [neogit](#neogit)
* [lazygit](https://github.com/jesseduffield/lazygit)
* [vgit](https://github.com/tanvirtin/vgit.nvim)

I've been using `vim-fugitive` for some years now and it works very well but is built for `vim`. Now that I'm refurbishing all the neovim configuration I want to try some neovim native plugins.

`neogit` looks interesting as it's a [magit](https://magit.vc/) clone for `neovim`. `lazygit` is the most popular one as it's a command line tool not specific to `neovim`. As such you'd need to launch a terminal inside neovim or use a plugin like [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim). I'm not able to understand how to use `vgit` by looking at their readme, there's not more documentation and there is no videos showing it's usage. It's also the least popular although it [looks active](https://github.com/tanvirtin/vgit.nvim/pulse).

At a first look `lazygit` is too much and `neogit` a little more verbose than `vim-fugitive` but it looks closer to my current workflow. I also tried `neogit` but didn't like it in the end. Finally I'm using [`diffview`](diffview.md)

## [vim-fugitive](https://github.com/tpope/vim-fugitive)

### Installation

If you're using [lazyvim](lazyvim.md):
```lua
return {
  {
    "tpope/vim-fugitive",
  },
}
```
### [Add portions of file to the index](http://vimcasts.org/episodes/fugitive-vim-working-with-the-git-index/)

To stage only part of the file to a commit, open it and launch `:Gdiff`. With
`diffput` and `diffobtain` Vim's functionality you move to the index file (the
one in the left) the changes you want to stage.

## [Git push sets the upstream by default](https://github.com/tpope/vim-fugitive/issues/1272)

Add to your config:

```vim
nnoremap <leader>gp :Git -c push.default=current push<CR>
```

If you want to see the [output of the push
command](https://github.com/tpope/vim-fugitive/issues/951), use `:copen` after
the successful push.


## [Neogit](https://github.com/Neogit/neogit)

### [Installation](https://github.com/TimUntersberger/neogit#installation)

```lua
use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
```

Now you have to add the following lines to your `init.lua`

```lua
local neogit = require('neogit')

neogit.setup()
```

That uses the default configuration, but there are [many options that can be set](https://github.com/TimUntersberger/neogit#configuration). For example to disable the commit confirmation use:

```lua
neogit.setup({
  disable_commit_confirmation = true
})
```

## Improve the commit message window

[create custom keymaps with lua](https://blog.devgenius.io/create-custom-keymaps-in-neovim-with-lua-d1167de0f2c2)
[create specific bindings for a file type](https://stackoverflow.com/questions/72984648/neovim-lua-how-to-use-different-mappings-depending-on-file-type)
https://neovim.discourse.group/t/how-to-create-an-auto-command-for-a-specific-filetype-in-neovim-0-7/2404
[create autocmd in neovim](https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42)
[autocmd events](https://neovim.io/doc/user/autocmd.html#autocmd-events)


