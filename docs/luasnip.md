[LuaSnip](https://github.com/L3MON4D3/LuaSnip) is a snippet Engine for Neovim written in Lua.

# Installation

It comes preinstalled with [lazyvim](lazyvim.md). You can see the [default configuration here](https://www.lazyvim.org/plugins/coding#luasnip). 

## [Add your custom snippets](https://github.com/LazyVim/LazyVim/discussions/2253)

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({ paths = "./lua/snippets" })
      end,
    },
  },
}
```

And store your snippets in `./lua/snippets`. You can write snippets in [You have two main choices to write snippets](https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#getting-started): use SnipMate/VS Code snippets (easier) or write snippets in Lua (more complex but also more feature-rich).

If you want to learn to write lua snippets check [these resources for new users](https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#resources-for-new-users).


# Usage

Lazyvim comes with the [`friendly-snippets`](https://github.com/rafamadriz/friendly-snippets/tree/main/snippets) installed by default. It's good to have it cloned locally to browse the available ones.

## [Transform selected text](https://github.com/L3MON4D3/LuaSnip/discussions/884) 

It can only be used on snippets that use `TM_SELECTED_TEXT`:

You'd have to

- Select some text in visual mode
- Hit whatever you set as `store_selection_keys`.
- Expand that snippet.

It looks like [the default binding for `store_selection_keys` is `<Tab>`](https://github.com/L3MON4D3/LuaSnip/blob/master/doc/luasnip.txt#LL2304). If it's not you can [configure it with](https://github.com/L3MON4D3/LuaSnip/issues/646). 

```lua 
require("luasnip").config.setup({store_selection_keys="<Tab>"})
```
# Reference
- [Source](https://github.com/L3MON4D3/LuaSnip)
