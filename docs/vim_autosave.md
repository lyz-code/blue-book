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

# Usage


Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

# References

- [Source](https://github.com/okuuva/auto-save.nvim)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
