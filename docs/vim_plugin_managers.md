
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

To get started, first clone this repository to somewhere on your packpath, e.g.:

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

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

  This will install the plugins in `~/.local/share/nvim/site/pack/packer/start/`, you can manually edit those files to develop new feature or fix issues on the plugins.

* Update the packages to the latest version you can run:

  ```
  :PackerUpdate
  ```

* Show the list of installed plugins run:

  ```
  :PackerStatus
  ```
