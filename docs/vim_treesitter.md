

## [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

`treesitter` it's a neovim parser generator tool and an incremental parsing library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited. With it you can do nice things like:

* [Highlight code](#highlight-code)
* [Incremental selection of the code](#incremental-selection)
* [Indentation](#indentation)
* [Folding](#folding)

### Installation

Add these lines to your `plugins.lua` file:

```lua
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
  }
```

Install it with `:PackerInstall`.

The base configuration is:

```lua
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'beancount',
    'dockerfile',
    'make',
    'terraform',
    'toml',
    'vue',
    'lua',
    'markdown',
    'python',
    'css',
    'html',
    'javascript',
    'json',
    'yaml',
  },
})
```

Select the languages you want to install from the [available ones](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages), close and reopen the vim window to install them.

To do so you need to run:

```vim
:TSInstall <language>
```

To update the parsers run

```vim
:TSUpdate
```

### Usage

By default it doesn't enable any feature, you need to enable them yourself.

#### [Highlight code](https://github.com/nvim-treesitter/nvim-treesitter#highlight)

Enable the feature with:

```lua
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
  },
})
```

Improves the default syntax for the supported languages.

#### [Incremental selection](https://github.com/nvim-treesitter/nvim-treesitter#incremental-selection)

It lets you select pieces of your code by the function they serve. For example imagine that we have the next snippet:

```python
def function():
  if bool is True:
    print('this is a Test')
```

And your cursor is in the `T` of the `print` statement. If you were to press the `Enter` key it will enter in visual mode selecting the `Test` word, if you were to press `Enter` key again it will increment the scope of the search, so it will select all the contents of the print statement `'this is a Test'`, if you press `Enter` again it will increase the scope. 

If you went too far, you can use the `Return` key to reduce the scope. For these keybindings to work you need to set:

```lua
require('nvim-treesitter.configs').setup({
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<cr>", -- set to `false` to disable one of the mappings
      node_incremental = "<cr>",
      node_decremental = "<bs>",
      -- scope_incremental = "grc",
    },
  },
})
```

#### [Indentation](https://github.com/nvim-treesitter/nvim-treesitter#indentation)

```lua
require'nvim-treesitter.configs'.setup {
  indent = {
    enable = true
  }
}
```

#### [Folding](https://github.com/nvim-treesitter/nvim-treesitter#folding)

Tree-sitter based folding

```lua
set.foldmethod = 'expr'
set.foldexpr = 'nvim_treesitter#foldexpr()'
set.foldenable = true                   
set.foldminlines = 3
```

It won't fold code sections that have have less than 3 lines.

If you add files through `telescope` you may see an `E490: No fold found` error when trying to access the folds, [there's an open issue](https://github.com/nvim-telescope/telescope.nvim/issues/559) that tracks this, the workaround for me was to add this snippet in the `telescope` configuration::

```lua
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = function()
                    vim.cmd [[:stopinsert]]
                    vim.cmd [[call feedkeys("\<CR>")]]
                end
            }
        }
    }
}
```

To save the foldings when you save a file [use the next snippet](https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save). Sorry but I don't know how to translate that into lua.

```lua
vim.cmd[[
  augroup remember_folds
    autocmd!
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
  augroup END
]]
```
