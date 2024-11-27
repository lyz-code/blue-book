# Troubleshooting

## [Undefined global `vim` warning](https://github.com/neovim/nvim-lspconfig/issues/2743)

Added to my lua/plugins directory:

```lua
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
      },
    },
  },
```
