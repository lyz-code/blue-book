# [Create quickmarks across files](https://stackoverflow.com/questions/1581505/vim-create-marks-across-files)

Use capital letters for the mark.

http://vim.wikia.com/wiki/Using_marks

Marks can span across files. To use such marks one has to use upper-case registers i.e. A-Z. Lower-case registers are used only within files and do not span files. That's to say, if you were to set a mark in a file foo.c in register "a" and then move to another file and hit 'a, the cursor will not jump back to the previous location. If you want a mark which will take you to a different file then you will need to use an upper-case register. For example, use mA instead of ma.

# [Search for different strings in the same search query](https://neovim.io/doc/user/pattern.html#_2.-the-definition-of-a-pattern)

```
* DONE\|* REJECTED\|* DUPLICATED
```

# [Get the name of the file shown](https://stackoverflow.com/questions/4111696/display-name-of-the-current-file-in-vim)

`:f` (`:file`) will do same as `<C-G>`. `:f!` will give a untruncated version, if applicable.

# [Run a command when opening vim](https://vi.stackexchange.com/questions/846/how-can-i-start-vim-and-then-execute-a-particular-command-that-includes-a-fro)

```bash
nvim -c ':DiffViewOpen'
```

# Run lua snippets

Run lua snippet within neovim with `:lua <your snippet>`. Useful to test the commands before binding it to keys.

# Bind a lua function to a key binding

```lua
key.set({'n'}, 't', ":lua require('neotest').run.run()<cr>", {desc = 'Run the closest test'})
```

# [Use relativenumber](https://koenwoortman.com/vim-relative-line-numbers/)

If you enable the `relativenumber` configuration you'll see how to move around with `10j` or `10k`.
