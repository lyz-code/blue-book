
# Testing

The [`vim-test`](https://github.com/vim-test/vim-test) alternatives for neovim are:

* [`neotest`](https://github.com/nvim-neotest/neotest)
* [`nvim-test`](https://github.com/klen/nvim-test)

The first one is the most popular so it's the first to try.

## [neotest](https://github.com/nvim-neotest/neotest)

### Installation

Add to your [`packer`](#packer) configuration:

```lua
use {
  "nvim-neotest/neotest",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim"
  }
}
```

To get started you will also need to install an adapter for your test runner. For example [for python](https://github.com/nvim-neotest/neotest-python) add also:

```lua
use  "nvim-neotest/neotest-python"
```

Then configure the plugin with:

```lua
require("neotest").setup({ -- https://github.com/nvim-neotest/neotest
  adapters = {
    require("neotest-python")({ -- https://github.com/nvim-neotest/neotest-python
      dap = { justMyCode = false },
    }),
  }
})
```

It also needs a font that supports icons. If you don't see them [install one of these](https://github.com/ryanoasis/nerd-fonts).

