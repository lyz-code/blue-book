# Tips

## [Inspect contents of Lua table in Neovim](https://doriankarter.com/inspect-contents-of-lua-table-in-neovim/)

When using Lua inside of Neovim you may need to view the contents of Lua tables, which are a first class data structure in Lua world. Tables in Lua can represent ordinary arrays, lists, symbol tables, sets, records, graphs, trees, etc.

If you try to just print a table directly, you will get the reference address for that table instead of the content, which is not very useful for most debugging purposes:

```lua
:lua print(vim.api.nvim_get_mode())
" table: 0x7f5b93e5ff88
```

To solve this, Neovim provides the `vim.inspect` function as part of its API. It serializes the content of any Lua object into a human readable string.

For example you can get information about the current mode like so:

```lua
:lua print(vim.inspect(vim.api.nvim_get_mode()))
" {  blocking = false,  mode = "n"}
```
