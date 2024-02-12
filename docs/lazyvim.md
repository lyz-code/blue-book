
# Package manager usage

## [Adding plugins configuration](https://www.lazyvim.org/configuration/plugins)

Configuring LazyVim plugins is exactly the same as using `lazy.nvim` to build a config from scratch.

For the full plugin spec documentation please check the [lazy.nvim readme](https://github.com/folke/lazy.nvim).

LazyVim comes with a list of preconfigured plugins, check them [here](https://www.lazyvim.org/configuration/plugins) before diving on your own.

### Adding a plugin

Adding a plugin is as simple as adding the plugin spec to one of the files under `lua/plugins/*.lua``. You can create as many files there as you want.

You can structure your `lua/plugins`` folder with a file per plugin, or a separate file containing all the plugin specs for some functionality. For example: `lua/plugins/lsp.lua`

```lua
return {
  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    opts = {
      -- add your options that should be passed to the setup() function here
      position = "right",
    },
  },
}
```
### Customizing plugin specs

Defaults merging rules:

- cmd: the list of commands will be extended with your custom commands
- event: the list of events will be extended with your custom events
- ft: the list of filetypes will be extended with your custom filetypes
- keys: the list of keymaps will be extended with your custom keymaps
- opts: your custom opts will be merged with the default opts
- dependencies: the list of dependencies will be extended with your custom dependencies
- any other property will override the defaults

For ft, event, keys, cmd and opts you can instead also specify a values function that can make changes to the default values, or return new values to be used instead.

```lua
-- change trouble config
{
  "folke/trouble.nvim",
  -- opts will be merged with the parent spec
  opts = { use_diagnostic_signs = true },
}

-- add cmp-emoji
{
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emoji" })
  end,
}
```

### Defining the plugin keymaps

Adding `keys=` follows the rules as explained above. You don't have to specify a mode for `normal` mode keymaps.

You can also disable a default keymap by setting it to `false`. To override a keymap, simply add one with the same `lhs` and a new `rhs`. For example `lua/plugins/telescope.lua`

```lua
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- disable the keymap to grep files
    {"<leader>/", false},
    -- change a keymap
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    -- add a keymap to browse plugin files
    {
      "<leader>fp",
      function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
      desc = "Find Plugin File",
    },
  },
},
```

Make sure to use the exact same mode as the keymap you want to disable. 

```lua
return {
  "folke/flash.nvim",
  keys = {
    -- disable the default flash keymap
    { "s", mode = { "n", "x", "o" }, false },
  },
}
```
You can also return a whole new set of keymaps to be used instead. Or return `{}` to disable all keymaps for a plugin.
 
```lua
return {
  "nvim-telescope/telescope.nvim",
  -- replace all Telescope keymaps with only one mapping
  keys = function()
    return {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    }
  end,
},
```

## [Auto update plugins](https://github.com/folke/lazy.nvim/issues/702)

Add this to `~/.config/nvim/lua/config/autocomds.lua`

```lua
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("autoupdate"),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false })
    end
  end
})
```

## [Disabling plugins](https://www.lazyvim.org/configuration/plugins#-disabling-plugins)
In order to disable a plugin, add a spec with enabled=false
lua/plugins/disabled.lua

```lua
return {
  -- disable trouble
  { "folke/trouble.nvim", enabled = false },
}
```
# References

- [Source](https://github.com/LazyVim/LazyVim)
- [Docs](https://lazyvim.github.io/)
- [Home](https://lazyvim.github.io/)
