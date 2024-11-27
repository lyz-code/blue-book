

# Concealment

Some plugins allow the conceal of some text, for example in orgmode you will only see the text of the description of a link and not the content, making it more pleasant to read. To enable it set in your config:

```lua
-- Conceal links
-- https://github.com/nvim-orgmode/orgmode#links-are-not-concealed
-- Use visual mode to navigate through the hidden text
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
```

Where:

- `conceallevel`: Determine how text with the "conceal" syntax attribute is shown:

  - `0`: Text is shown normally
  - `1`: Each block of concealed text is replaced with one character. If the syntax item does not have a custom replacement character defined the character defined in 'listchars' is used (default is a space). It is highlighted with the "Conceal" highlight group.
  - `2`: Concealed text is completely hidden unless it has a custom replacement character defined.
  - `3`: Concealed text is completely hidden.

- `concealcursor`: Sets the modes in which text in the cursor line can also be concealed. When the current mode is listed then concealing happens just like in other lines.
  - `n`: Normal mode
  - `v`: Visual mode
  - `i`: Insert mode
  - `c`: Command line editing, for 'incsearch'

  A useful value is `nc`. So long as you are moving around text is concealed, but when starting to insert text or selecting a Visual area the concealed text is displayed, so that you can see what you are doing.
# Buffer and file management

In the past I used [ctrlp](https://github.com/ctrlpvim/ctrlp.vim) as a remaining of the
migration from vim to nvim. Today I've seen that there are `nvim` native plugins to do
the same. I'm going to start with
[`Telescope`](https://github.com/nvim-telescope/telescope.nvim), a popular plugin (8.4k
stars)

## Telescope

### Install

It is suggested to either use the latest release tag or their release branch (which will get consistent updates) 0.1.x. If you're  using `packer` you can add this to your `plugins.lua`:

```lua
use {
  'nvim-telescope/telescope.nvim', tag = '0.1.x',
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

You may need to have installed [`treesitter`](#treesitter) look for those instructions to install it.

`telescope` uses `ripgrep` to do `live-grep`. I've tried using `ag` instead with [this config](https://github.com/nvim-telescope/telescope.nvim/issues/2083#issuecomment-1216769324-permalink), but it didn't work.

```lua
require('telescope').setup{
  defaults = {
     vimgrep_arguments = {
        "ag",
        "--nocolor",
        "--noheading",
        "--numbers",
        "--column",
        "--smart-case",
        "--silent",
        "--follow",
        "--vimgrep",
    }
  }
}
```

It's a good idea also to have `fzf` fuzzy finder, to do that we need to install the [`telescope-fzf-native`](https://github.com/nvim-telescope/telescope-fzf-native.nvim) plugin. To do that add to your `plugins.lua` config file:

```lua
  use {
    'nvim-telescope/telescope-fzf-native.nvim', 
    run = 'make' 
  }
```

Run `:PackerInstall` and then configure it in your `init.lua`:

```lua
-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
```

It also needs [`fd`](https://github.com/sharkdp/fd#installation) for further features. You should be using it too for your terminal.

NOTE: If you want to [search exact words](https://github.com/nvim-telescope/telescope.nvim/issues/1083) you can start the search with `'` to search for exact matches.

To check that everything is fine run `:checkhealth telescope`.

### [Usage](https://github.com/nvim-telescope/telescope.nvim#usage)

`telescope` has different ways to find files:

* `find_files`: Uses `fd` to find a string in the file names.
* `live_grep`: Uses `rg` to find a string in the file's content.
* `buffers`: Searches strings in the buffer names.

You can configure each of these commands with the next bindings:

```lua
local builtin = require('telescope.builtin')
local key = vim.keymap
key.set('n', '<leader>f', builtin.find_files, {})
key.set('n', '<leader>a', builtin.live_grep, {})
key.set('n', '<leader>b', builtin.buffers, {})
```

By default it searches on all files. You can ignore some of them with:

```lua
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    file_ignore_patterns = {
      "%.svg",
      "%.bmp",
      "%.jpg",
      "%.jpeg",
      "%.gif",
      "%.png",
    },
  }
}
```

You can also replace some other default `vim` commands like history browsing, spell checker suggestions or searching in the current buffer with:

```lua
key.set('n', '<C-r>', builtin.command_history, {})
key.set('n', 'z=', builtin.spell_suggest, {})
key.set('n', '/', builtin.current_buffer_fuzzy_find, {})
```

### [Follow symbolic links](https://github.com/nvim-telescope/telescope.nvim/issues/394)

By default symbolic links are not followed either for files or directories, to enable it use

```lua
  require('telescope').setup {
    pickers = {
      find_files = {
        follow = true
      }
    }
  }
```

## [Heading navigation](https://github.com/crispgm/telescope-heading.nvim)

It's a `telescope` plugin to navigate through your markdown headers

### Installation

Install with your favorite package manager:

```lua
use('nvim-telescope/telescope.nvim')
use('crispgm/telescope-heading.nvim')
```

`telescope-heading` supports Tree-sitter for parsing documents and finding headings.

```lua
-- make sure you have already installed treesitter modules
require('nvim-treesitter.configs').setup({
    ensure_installed = {
        -- ..
        'markdown',
        'rst',
        -- ..
    },
})

-- enable treesitter parsing
local telescope = require('telescope')
telescope.setup({
    -- ...
    extensions = {
        heading = {
            treesitter = true,
        },
    },
})

-- `load_extension` must be after `telescope.setup`
telescope.load_extension('heading')

-- Set the key binding

local key = vim.keymap
key.set('n', '<leader>h', ':Telescope heading<cr>')
```

# [Keep foldings](https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save)

When running fixers usually the foldings go to hell. To keep the foldings add
the following snippet to your vimrc file

```Vim
augroup remember_folds
  autocmd!
  autocmd BufLeave * mkview
  autocmd BufEnter * silent! loadview
augroup END
```

## [Python folding done right](https://github.com/tmhedberg/SimpylFold)

Folding Python in Vim is not easy, the python-mode plugin doesn't do it for me
by default and after fighting with it for 2 hours...

SimpylFold does the trick just fine.


# [Delete a file inside vim](https://vim.fandom.com/wiki/Delete_files_with_a_Vim_command)

```vim
:call delete(expand('%')) | bdelete!
```

You can make a function so it's easier to remember

```vim
function! Rm()
  call delete(expand('%')) | bdelete!
endfunction
```

Now you need to run `:call Rm()`.
