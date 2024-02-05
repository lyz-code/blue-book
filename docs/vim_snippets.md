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
