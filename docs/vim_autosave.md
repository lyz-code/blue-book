To automatically save your changes in NeoVim you can use the [auto-save](https://github.com/okuuva/auto-save.nvim?tab=readme-ov-file#%EF%B8%8F-configuration) plugin.

It has some nice features

- Automatically save your changes so the world doesn't collapse
- Highly customizable:
  - Conditionals to assert whether to save or not
  - Execution message (it can be dimmed and personalized)
  - Events that trigger auto-save
- Debounce the save with a delay
- Hook into the lifecycle with autocommands
- Automatically clean the message area

# [Installation ](https://github.com/okuuva/auto-save.nvim?tab=readme-ov-file#-installation) 
```lua 
{
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {
    -- your config goes here
    -- https://github.com/okuuva/auto-save.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
    execution_message = {
      enabled = false,
    },
  },
},
```

## [Disable for specific filetypes](https://github.com/okuuva/auto-save.nvim?tab=readme-ov-file#condition)

The `condition` field of the configuration allows the user to exclude **auto-save** from saving specific buffers. This can be useful for example if you have a broken LSP that is making editing the markdown files an absolute hell.

Here is an example that disables auto-save for specified file types:

```lua
{
  condition = function(buf)
    local filetype = vim.fn.getbufvar(buf, "&filetype")

    -- don't save for `sql` file types
    if vim.list_contains({ "markdown" }, filetype) then
      return false
    end
    return true
  end
}
```

You may also exclude `special-buffers` see (`:h buftype` and `:h special-buffers`):

```lua
{
  condition = function(buf)
    -- don't save for special-buffers
    if vim.fn.getbufvar(buf, "&buftype") ~= '' then
      return false
    end
    return true
  end
}
```

Buffers that are `nomodifiable` are not saved by default.

# Usage


Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

# References

- [Source](https://github.com/okuuva/auto-save.nvim)
