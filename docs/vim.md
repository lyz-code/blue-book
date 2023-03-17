---
title: Vim
date: 20210318
author: Lyz
---

Vim is a lightweight keyboard driven editor. It's the road to **fly over the
keyboard** as it increases productivity and usability.

!!! note "If you doubt between learning emacs or vim, go with emacs with spacemacs"
    I am a power vim user for more than 10 years, and seeing what my friends do
    with emacs, I suggest you to learn it while keeping the vim movement.

    Spacemacs is a preconfigured Emacs with those bindings and a lot of more
    stuff, but it's a good way to start.

# Vi vs Vim vs Neovim

!!! note "TL;DR: Use Neovim"

Small comparison:

* Vi
  * Follows the Single Unix Specification and POSIX.
  * Original code written by Bill Joy in 1976.
  * BSD license.
  * Doesn't even have a git repository `-.-`.

* Vim
  * Written by Bram Moolenaar in 1991.
  * Vim is free and open source software, license is compatible with the GNU General Public License.
  * C: 47.6 %, Vim Script: 44.8%, Roff 1.9%, Makefile 1.7%, C++ 1.2%
  * Commits: 7120, Branch: **1**, Releases: 5639, Contributor: **1**
  * Lines: 1.295.837

* Neovim
  * Written by the community from 2014
  * Published under the Apache 2.0 license
  * Commits: 7994, Branch **1**, Releases: 9, Contributors: 303
  * Vim script: 46.9%, C:38.9%, Lua 11.3%, Python 0.9%, C++ 0.6%
  * Lines: 937.508 (27.65% less code than vim)
  * Refactor: Simplify maintenance and encourage contributions
  * Easy update, just symlinks
  * Ahead of vim, new features inserted in Vim 8.0 (async)

[Neovim](https://neovim.io/doc/user/vim_diff.html#nvim-features) is a refactor
of Vim to make it viable for another 30 years of hacking.

Neovim very intentionally builds on the long history of Vim community
knowledge and user habits. That means “switching” from Vim to Neovim is just
an “upgrade”.

From the start, one of Neovim’s explicit goals has been simplify maintenance and
encourage contributions.  By building a codebase and community that enables
experimentation and low-cost trials of new features..

And there’s evidence of real progress towards that ambition. We’ve
successfully executed non-trivial “off-the-roadmap” patches: features which
are important to their authors, but not the highest priority for the project.

These patches were included because they:

* Fit into existing conventions/design.
* Included robust test coverage (enabled by an advanced test framework and CI).
* Received thoughtful review by other contributors.

One downside though is that it's not able to [work with "big" files](https://github.com/neovim/neovim/issues/614) for me 110kb file broke it. Although after [some debugging](#Deal-with-big-files) it worked.

# [Installation](https://github.com/neovim/neovim/releases)

The version of `nvim` released by debian is too old, use the latest by downloading it
directly from the [releases](https://github.com/neovim/neovim/releases) page and
unpacking it somewhere in your home and doing a link to the `bin/nvim` file somewhere in your `$PATH`.

# [Configuration](https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/)

Nvim moved away from vimscript and now needs to be configured in lua. You can access the
config file in `~/.config/nvim/init.lua`. It's not created by default so you need to do
it yourself.

To access the editor's setting we need to use the global variable `vim`. Okay, more than
a variable this thing is a module. It has an `opt` property to change the program
options.  This is the syntax you should follow.

```lua
vim.opt.option_name = value
```

Where `option_name` can be anything in [this list](https://neovim.io/doc/user/quickref.html#option-list). And value must be whatever that option expects. You can also see the list with `:help option-list`.

## Key bindings

We need to learn about `vim.keymap.set`. Here is a basic usage example.

```lua
vim.keymap.set('n', '<space>w', '<cmd>write<cr>', {desc = 'Save'})
```

After executing this, the sequence `Space + w` will call the `write` command. Basically, we can save changes made to a file with `Space + w`.

Let's dive into what does the  `vim.keymap.set` parameters mean.

```lua
vim.keymap.set({mode}, {lhs}, {rhs}, {opts})
```

* `{mode}`:  mode where the keybinding should execute. It can be a list of modes. We need to specify the mode's short name. Here are some of the most common.
  * `n`: Normal mode.
  * `i`: Insert mode.
  * `x`: Visual mode.
  * `s`: Selection mode.
  * `v`: Visual + Selection.
  * `t`: Terminal mode.
  * `o`: Operator-pending.
  * `''`: Yes, an empty string. Is the equivalent of `n + v + o`.

* `{lhs}`: is the key we want to bind.
* `{rhs}` is the action we want to execute. It can be a string with a command or an expression. You can also provide a lua function.
* `{opts}` this must be a lua table. If you don't know what is a "lua table" just think is a way of storing several values in one place. Anyway, it can have these properties.

  * `desc`: A string that describes what the keybinding does. You can write anything you want.
  * `remap`: A boolean that determines if our keybinding can be recursive. The default value is `false`. Recursive keybindings can cause some conflicts if used incorrectly. Don't enable it unless you know what you're doing.
  * `buffer`: It can be a boolean or a number. If we assign the boolean `true` it means the keybinding will only be effective in the current file. If we assign a number, it needs to be the "id" of an open buffer.
  * `silent`: A boolean. Determines whether or not the keybindings can show a message. The default value is `false`.
  * `expr`: A boolean. If enabled it gives the chance to use vimscript or lua to calculate the value of `{rhs}`. The default value is `false`.

### [The leader key](https://www.reddit.com/r/vim/wiki/the_leader_mechanism/)

When creating keybindings we can use the special sequence `<leader>` in the `{lhs}` parameter, it'll take the value of the global variable mapleader.

So mapleader is a global variable in vimscript that can be string. For example.

```lua
vim.g.mapleader = ' '
```

After defining it we can use it as a prefix in our keybindings.

```lua
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')
```

This will make `<space key>` + `w` save the current file.

There are different opinions on what key to use as the `<leader>` key. The `<space>` is the most comfortable as it's always close to your thumbs, and it works well with both hands. Nevertheless, you can only use it in normal mode, because in insert `<space><whatever>` will be triggered as you write. An alternative is to use `;` which is also comfortable (if you use the english key distribution) and you can use it in insert mode. 

If you [want to define more than one leader key](https://stackoverflow.com/questions/30467660/can-we-define-more-than-one-leader-key-in-vimrc) you can either:

* Change the `mapleader` many times in your file: As the value of `mapleader` is used at the moment the mapping is defined, you can indeed change that while plugins are loading. For that, you have to explicitly `:runtime` the plugins in your `~/.vimrc` (and count on the canonical include guard to prevent redefinition later):

  ```vim
  let mapleader = ','
  runtime! plugin/NERD_commenter.vim
  runtime! ...
  let mapleader = '\'
  runime! plugin/mark.vim
  ...
  ```
* Use the keys directly instead of using `<leader>` 
  
  ```vim
  " editing mappings
  nnoremap ,a <something>
  nnoremap ,k <something else>
  nnoremap ,d <and something else>

  " window management mappings
  nnoremap gw <something>
  nnoremap gb <something else>
  ```

Defining `mapleader` and/or using `<leader>` may be useful if you change your mind often on what key to use a leader but it won't be of any use if your mappings are stable.

## Spelling

```lua
set.spell = true
set.spelllang = 'en_us'
set.spellfile = '/home/your_user/.config/nvim/spell/my_dictionary.add'
```

## Testing

The [`vim-test`](https://github.com/vim-test/vim-test) alternatives for neovim are:

* [`neotest`](https://github.com/nvim-neotest/neotest)
* [`nvim-test`](https://github.com/klen/nvim-test)

The first one is the most popular so it's the first to try.

### [neotest](https://github.com/nvim-neotest/neotest)

#### Installation

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

# [Plugin managers](https://vonheikemen.github.io/devlog/tools/neovim-plugins-to-get-started/)

Neovim has builtin support for installing plugins. You can manually download the plugins
in any directory shown in `:set packpath?`, for example `~/.local/share/nvim/site`. In one of those directories we have to create a directory called `pack` and inside `pack` we must create a "package". A package is a directory that contains several plugins. It must have this structure.

```
package-directory
├── opt
│   ├── [plugin 1]
│   └── [plugin 2]
└── start
    ├── [plugin 3]
    └── [plugin 4]
```

In this example we are creating a directory with two other directory inside: opt and start. Plugins in opt will only be loaded if we execute the command packadd. The plugins in start will be loaded automatically during the startup process.

So to install a plugin like `lualine` and have it load automatically, we should place it for example here `~/.local/share/nvim/site/pack/github/start/lualine.nvim`

As I'm using [`chezmoi`](chezmoi.md) to handle the plugins of `zsh` and other stuff I tried to work with that. It was a little cumbersome to add the plugins but it did the job until I had to install `telescope` which needs to run a command after each install, and that was not easy with `chezmoi`. Then I analyzed the  most popular plugin managers in the Neovim ecosystem right now:

* [`packer`](https://github.com/wbthomason/packer.nvim)
* [`paq`](https://github.com/savq/paq-nvim)

If you prefer minimalism take a look at `paq`. If you want something full of features use `packer`. I went with `packer`.

## [Packer](https://github.com/wbthomason/packer.nvim)

### Installation

Create the `~/.config/nvim/lua/plugins.lua` file with the contents:

```lua
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Example of another plugin. Nice buffer closing 
  use 'moll/vim-bbye'

end)
```

And load the file in your `~/.config/nvim/init.lua`:

```lua
-- -------------------
-- --    Plugins    --
-- -------------------
require('plugins')
```

You can now run the `packer` commands.

### Usage

Whenever you make changes to your plugin configuration you need to:

* Regenerate the compiled loader file:

  ```
  :PackerCompile
  ```

* Remove any disabled or unused plugins

  ```
  :PackerClean
  ```

* Clean, then install missing plugins

  ```
  :PackerInstall
  ```

To update the packages to the latest version you can run:

```
:PackerUpdate
```

To show the list of installed plugins run:

```
:PackerStatus
```


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

# Git

There are many plugins to work with git in neovim the most interesting ones are:

* [vim-fugitive](https://github.com/tpope/vim-fugitive)
* [neogit](#neogit)
* [lazygit](https://github.com/jesseduffield/lazygit)
* [vgit](https://github.com/tanvirtin/vgit.nvim)

I've been using `vim-fugitive` for some years now and it works very well but is built for `vim`. Now that I'm refurbishing all the neovim configuration I want to try some neovim native plugins.

`neogit` looks interesting as it's a [magit](https://magit.vc/) clone for `neovim`. `lazygit` is the most popular one as it's a command line tool not specific to `neovim`. As such you'd need to launch a terminal inside neovim or use a plugin like [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim). I'm not able to understand how to use `vgit` by looking at their readme, there's not more documentation and there is no videos showing it's usage. It's also the least popular although it [looks active](https://github.com/tanvirtin/vgit.nvim/pulse).

At a first look `lazygit` is too much and `neogit` a little more verbose than `vim-fugitive` but it looks closer to my current workflow. I'm going to try `neogit` then.

## [Neogit](https://github.com/TimUntersberger/neogit)

### [Installation](https://github.com/TimUntersberger/neogit#installation)

```lua
use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
```

Now you have to add the following lines to your `init.lua`

```lua
local neogit = require('neogit')

neogit.setup()
```

That uses the default configuration, but there are [many options that can be set](https://github.com/TimUntersberger/neogit#configuration). For example to disable the commit confirmation use:

```lua
neogit.setup({
  disable_commit_confirmation = true
})

### Improve the commit message window






[create custom keymaps with lua](https://blog.devgenius.io/create-custom-keymaps-in-neovim-with-lua-d1167de0f2c2)
[create specific bindings for a file type](https://stackoverflow.com/questions/72984648/neovim-lua-how-to-use-different-mappings-depending-on-file-type)
https://neovim.discourse.group/t/how-to-create-an-auto-command-for-a-specific-filetype-in-neovim-0-7/2404
[create autocmd in neovim](https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42)
[autocmd events](https://neovim.io/doc/user/autocmd.html#autocmd-events)








# [Abbreviations](https://davidxmoody.com/2014/better-vim-abbreviations/)

In order to reduce the amount of typing and fix common typos, I use the Vim
abbreviations support. Those are split into two files,
`~/.vim/abbreviations.vim` for abbreviations that can be used in every type of
format and `~/.vim/markdown-abbreviations.vim` for the ones that can interfere
with programming typing.

Those files are sourced in my `.vimrc`

```vim
" Abbreviations
source ~/.vim/abbreviations.vim
autocmd BufNewFile,BufReadPost *.md source ~/.vim/markdown-abbreviations.vim
```

To avoid getting worse in grammar, I don't add abbreviations for words that
I doubt their spelling or that I usually mistake. Instead I use it for common
typos such as `teh`.

The process has it's inconveniences:

* You need different abbreviations for the capitalized versions, so you'd need
    two abbreviations for `iab cant can't` and `iab Cant Can't`
* It's not user friendly to add new words, as you need to open a file.

The [Vim Abolish plugin](https://github.com/tpope/vim-abolish) solves that. For
example:

```vim
" Typing the following:
Abolish seperate separate

" Is equivalent to:
iabbrev seperate separate
iabbrev Seperate Separate
iabbrev SEPERATE SEPARATE
```

Or create more complex rules, were each `{}` gets captured and expanded with
different caps

```vim
:Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
```

With a bang (`:Abolish!`) the abbreviation is also appended to the file in
`g:abolish_save_file`. By default `after/plugin/abolish.vim` which is loaded by
default.

Typing `:Abolish! im I'm` will append the following to the end of this file:

```vim
Abolish im I'm
```

To make it quicker I've added a mapping for `<leader>s`.

```vim
nnoremap <leader>s :Abolish!<Space>
```

Check the
[README](https://github.com/tpope/vim-abolish/blob/master/doc/abolish.txt) for
more details.

## Troubleshooting

Abbreviations with dashes or if you only want the first letter in capital need
to be specified with the first letter in capital letters as stated in [this
issue](https://github.com/tpope/vim-abolish/issues/30).

```vim
Abolish knobas knowledge-based
Abolish w what
```

Will yield `KnowledgeBased` if invoked with `Knobas`, and `WHAT` if invoked with
`W`. Therefore the following definitions are preferred:

```vim
Abolish Knobas Knowledge-based
Abolish W What
```

# Auto complete prose text

Tools like [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) allow you
to auto complete variables and functions. If you want the same functionality for
prose, you need to enable it for markdown and text, as it's disabled by default.

```vim
let g:ycm_filetype_blacklist = {
      \ 'tagbar' : 1,
      \ 'qf' : 1,
      \ 'notes' : 1,
      \ 'unite' : 1,
      \ 'vimwiki' : 1,
      \ 'pandoc' : 1,
      \ 'infolog' : 1
  \}
```

When writing prose you don't need all possible suggestions, as navigating the
options is slower than keep on typing. So I'm limiting the results just to one,
to avoid unnecessary distractions.

```vim
" Limit the results for markdown files to 1
au FileType markdown let g:ycm_max_num_candidates = 1
au FileType markdown let g:ycm_max_num_identifier_candidates = 1
```

# Find synonyms

Sometimes the prose linters tell you that a word is wordy or too complex, or you may be
repeating a word too much. The [thesaurus query
plugin](https://github.com/Ron89/thesaurus_query.vim) allows you to search
synonyms of the word under the cursor. Assuming you use Vundle, add the
following lines to your config.

!!! note "File: ~/.vimrc"

    ```vim
    Plugin 'ron89/thesaurus_query.vim'

    " Thesaurus
    let g:tq_enabled_backends=["mthesaur_txt"]
    let g:tq_mthesaur_file="~/.vim/thesaurus"
    nnoremap <leader>r :ThesaurusQueryReplaceCurrentWord<CR>
    inoremap <leader>r <esc>:ThesaurusQueryReplaceCurrentWord<CR>
    ```

Run `:PluginInstall` and download the thesaurus text from [gutenberg.org](http://www.gutenberg.org/files/3202/files/)

Next time you find a word like `therefore` you can press
`:ThesaurusQueryReplaceCurrentWord
` and you'll get a window with the following:

```
In line: ... therefore ...
Candidates for therefore, found by backend: mthesaur_txt
Synonyms: (0)accordingly (1)according to circumstances (2)and so (3)appropriately (4)as a consequence
          (5)as a result (6)as it is (7)as matters stand (8)at that rate (9)because of that (10)because of this
          (11)compliantly (12)conformably (13)consequently (14)equally (15)ergo (16)finally (17)for that
          (18)for that cause (19)for that reason (20)for this cause (21)for this reason (22)for which reason
          (23)hence (24)hereat (25)in that case (26)in that event (27)inconsequence (28)inevitably
          (29)it follows that (30)naturally (31)naturellement (32)necessarily (33)of course (34)of necessity
          (35)on that account (36)on that ground (37)on this account (38)propter hoc (39)suitably
          (40)that being so (41)then (42)thence (43)thereat (44)therefor (45)thus (46)thusly (47)thuswise
          (48)under the circumstances (49)whence (50)wherefore (51)wherefrom
Type number and <Enter> (empty cancels; 'n': use next backend; 'p' use previous backend):
```

If for example you type `45` and hit enter, it will change it for `thus`.

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

# Task management

Check the [`nvim-orgmode`](orgmode.md) file.

### References

* [Source](https://github.com/nvim-orgmode/orgmode#agenda)
* [Getting started guide](https://github.com/nvim-orgmode/orgmode/wiki/Getting-Started)
* [Docs](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md)

# Troubleshooting

## Deal with big files

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

# Tips

## Run lua snippets

Run lua snippet within neovim with `:lua <your snippet>`. Useful to test the commands before binding it to keys.

## Bind a lua function to a key binding

```lua
key.set({'n'}, 't', ":lua require('neotest').run.run()<cr>", {desc = 'Run the closest test'})
```

## [Use relativenumber](https://koenwoortman.com/vim-relative-line-numbers/)

If you enable the `relativenumber` configuration you'll see how to move around with `10j` or `10k`.

# Resources

* [Nvim news](https://neovim.io/news/)
* [spacevim](https://spacevim.org/)
* [awesome-neovim](https://github.com/rockerBOO/awesome-neovim/blob/main/README.md)
* [awesome-vim](https://github.com/akrawchyk/awesome-vim): a list of vim
      resources maintained by the community

## Vimrc tweaking

* [List of nvim configs](https://github.com/topics/neovim-config)
* [jessfraz vimrc](https://github.com/jessfraz/.vim/blob/master/vimrc)

## Learning

* [vim golf](https://www.vimgolf.com)
* [Vim game tutorial](https://vim-adventures.com/): very funny and challenging,
      buuuuut at lvl 3 you have to pay :(.
* [PacVim](https://www.ostechnix.com/pacvim-a-cli-game-to-learn-vim-commands/):
      Pacman like vim game to learn.
* [Vimgenius](http://www.vimgenius.com/): Increase your speed and improve your
      muscle memory with Vim Genius, a timed flashcard-style game designed to
      make you faster in Vim. It’s free and you don’t need to sign up. What are
      you waiting for?
* [Openvim](http://www.openvim.com/): Interactive tutorial for vim.
