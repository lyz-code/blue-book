# Markdown specific plugins

- [mkdnflow](https://github.com/jakewvincent/mkdnflow.nvim) looks awesome.

# Enable folds

If you have set the `foldmethod` to `indent` by default you won't be able to use folds in markdown.

To fix this you can create the next autocommand (in `lua/config/autocmds.lua` if you're using [lazyvim](lazyvim.md)).

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
```

# Aligning tables in markdown

In the past I used [Tabular](https://github.com/godlygeek/tabular) but it doesn't work with the latest neovim and the project didn't have any update in the last 5 years.

A good way to achieve this [without installing any plugin is to](https://heitorpb.github.io/bla/format-tables-in-vim/):

- select the table, including the header and footer lines (with shift V, for example).
- Prettify the table with `:!column -t -s '|' -o '|'`

If you don't want to remember that command you can bind it to a key:

```lua
vim.keymap.set("v", "<leader>tf", "!column -t -s '|' -o '|'<cr>", { desc = "Format table" })
```

How the hell this works?

- `shift V` switches to Visual mode linewise. This is to select all the lines of the table.
- `:` switches to Command line mode, to type commands.
- `!` specifies a filter command. This means we will send data to a command to modify it (or to filter) and replace the original lines. In this case we are in Visual mode, we defined the input text (the selected lines) and we will use an external command to modify the data.
- `column` is the filter command we are using, from the `util-linux` package. column’s purpose is to “columnate”. The `-t` flag tells column to use the Table mode. The `-s` flag specifies the delimiters in the input data (the default is whitespace). And the `-o` flag is to specify the output delimiter to use (we need that because the default is two whitespaces).
