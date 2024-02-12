# Vim custom keymaps
I'm assuming you control the next concepts, otherwise read those sections first:

- [Setting keymaps in lua](#setting-keymaps-in-lua)
- [Using the leader key](#the-leader-key)

LazyVim comes with some sane default keybindings, you can see them [here](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua). You don't need to remember them all, it also comes with [which-key](https://github.com/folke/which-key.nvim) to help you remember your keymaps. Just press any key like <space> and you'll see a popup with all possible keymaps starting with <space>.

- default `<leader>` is `<space>`
- default `<localleader>` is `\`

## General editor bindings

- Save file: `<C-s>`
- Quit all: `<leader>qq`
- Open a floating terminal: `<C-/>`

## Movement keybindings

- Split the windows:
  - Vertically: `<C-|`
  - Horizontally: `<C--`
- Delete window: `<leader>wd`
- To move around the windows you can use: <C-h>, <C-j>, <C-k>, <C-l>.
- To resize the windows use: <C-Up>, <C-Down>, <C-Left>, <C-Right>
- To move between buffers: 
  - Next and previous with <S-h>, <S-l>
  - Switch to the previously opened buffer: `<leader>bb`

## Coding keybindings

### Diagnostics 

- `<leader>cd>`: Shows you the diagnostics message of the current line in a floating window
- `]d` and `[d`: iterates over all diagnostics
- `]e` and `[e`: iterates over all error diagnostics
- `]w` and `[w`: iterates over all warning diagnostics
# Setting keymaps in lua

If you need to set keymaps in lua you can use `vim.keymap.set`. For example:

```lua
vim.keymap.set('n', '<space>w', '<cmd>write<cr>', {desc = 'Save'})
```

After executing this, the sequence `Space + w` will call the `write` command. Basically, we can save changes made to a file with `Space + w`.

Let's dive into what does the  `vim.keymap.set` parameters mean.

```lua
vim.keymap.set({mode}, {lhs}, {rhs}, {opts})
```

* `{mode}`:  mode where the keybinding should execute. It can be a list of modes. We need to specify the mode's short name. Here are some of the most common.
  * `n`: Normal mode.
  * `i`: Insert mode.
  * `x`: Visual mode.
  * `s`: Selection mode.
  * `v`: Visual + Selection.
  * `t`: Terminal mode.
  * `o`: Operator-pending.
  * `''`: Yes, an empty string. Is the equivalent of `n + v + o`.

* `{lhs}`: is the key we want to bind.
* `{rhs}` is the action we want to execute. It can be a string with a command or an expression. You can also provide a lua function.
* `{opts}` this must be a lua table. If you don't know what is a "lua table" just think is a way of storing several values in one place. Anyway, it can have these properties.

  * `desc`: A string that describes what the keybinding does. You can write anything you want.
  * `remap`: A boolean that determines if our keybinding can be recursive. The default value is `false`. Recursive keybindings can cause some conflicts if used incorrectly. Don't enable it unless you know what you're doing.
  * `buffer`: It can be a boolean or a number. If we assign the boolean `true` it means the keybinding will only be effective in the current file. If we assign a number, it needs to be the "id" of an open buffer.
  * `silent`: A boolean. Determines whether or not the keybindings can show a message. The default value is `false`.
  * `expr`: A boolean. If enabled it gives the chance to use vimscript or lua to calculate the value of `{rhs}`. The default value is `false`.


# [The leader key](https://www.reddit.com/r/vim/wiki/the_leader_mechanism/)

When creating keybindings we can use the special sequence `<leader>` in the `{lhs}` parameter, it'll take the value of the global variable `mapleader`.

So `mapleader` is a global variable in vimscript that can be string. For example.

```lua
vim.g.mapleader = ' '
```

After defining it we can use it as a prefix in our keybindings.

```lua
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')
```

This will make `<space key>` + `w` save the current file.

There are different opinions on what key to use as the `<leader>` key. The `<space>` is the most comfortable as it's always close to your thumbs, and it works well with both hands. Nevertheless, you can only use it in normal mode, because in insert `<space><whatever>` will be triggered as you write. An alternative is to use `;` which is also comfortable (if you use the english key distribution) and you can use it in insert mode. 

If you [want to define more than one leader key](https://stackoverflow.com/questions/30467660/can-we-define-more-than-one-leader-key-in-vimrc) you can either:

* Change the `mapleader` many times in your file: As the value of `mapleader` is used at the moment the mapping is defined, you can indeed change that while plugins are loading. For that, you have to explicitly `:runtime` the plugins in your `~/.vimrc` (and count on the canonical include guard to prevent redefinition later):

  ```vim
  let mapleader = ','
  runtime! plugin/NERD_commenter.vim
  runtime! ...
  let mapleader = '\'
  runime! plugin/mark.vim
  ...
  ```
* Use the keys directly instead of using `<leader>` 
  
  ```vim
  " editing mappings
  nnoremap ,a <something>
  nnoremap ,k <something else>
  nnoremap ,d <and something else>

  " window management mappings
  nnoremap gw <something>
  nnoremap gb <something else>
  ```

Defining `mapleader` and/or using `<leader>` may be useful if you change your mind often on what key to use a leader but it won't be of any use if your mappings are stable.

# Tips

## Tell the user not to use the keymap
If you're moving away from a keymap or set of keymaps you can show a notice:

```lua
-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ";", ":")
keymap.set({ "n", "x" }, ":", function()
  vim.notify("Use ; instead")
end)
```
## [Set custom keymaps on specific filetypes](https://github.com/folke/which-key.nvim/issues/135)

Use autocomands on the `FileType` pattern. For example to add a keymap to the `gitcommit` filetype:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  group = augroup("gitcommit"),
  callback = function()
    local keymap = vim.keymap

    keymap.set("i", "jj", "<esc>:wincmd l<cr>j", { desc = "Go to normal, changes window and down", silent = true, buffer = true })
})
```

It's important to set the `buffer = true` if you don't want the bindings to be permanent for all buffers once it's been loaded.
