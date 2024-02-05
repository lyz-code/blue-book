
When you run into problems run `:checkhealth` to see if it rings a bell.

# Deal with big files

Sometimes `neovim` freezes when opening big files, one way to deal with it is to [disable some functionality when loading them](https://www.reddit.com/r/neovim/comments/z85s1l/disable_lsp_for_very_large_files/)

```lua
local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  callback = function()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
    if ok and stats and (stats.size > 100000) then
      vim.b.large_buf = true
      -- vim.cmd("syntax off") I don't yet need to turn the syntax off
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      set.foldexpr = 'nvim_treesitter#foldexpr()' -- Disable fold expression with treesitter, it freezes the loading of files
    else
      vim.b.large_buf = false
    end
  end,
  group = aug,
  pattern = "*",
})
```

When it opens a file it will decide if it's a big file. If it is, it will unset the `foldexpr` which made it break for me.

[Telescope's](#telescope) preview also froze the terminal. To deal with it I had to disable treesitter for the preview

```lua
require('telescope').setup{
  defaults = {
    preview = {
      enable = true,
      treesitter = false,
    },
  ...
```


# Telescope changes working directory when opening a file

In my case was due to a snippet I have to remember the folds:

```
vim.cmd[[
  augroup remember_folds
    autocmd!
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
  augroup END
]]
```

It looks that it had saved a view with the other working directory so when a file was loaded the `cwd` changed. To solve it I created a new `mkview` in the correct directory.
