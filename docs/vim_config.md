Neovim configuration is a **complex** thing to do, both to start and to maintain. The configurations are endless, the plugins are too. Be ready to spend a lot of energy on it and to get lost reading a lot. 

If I'm scaring you, you are right to be scared! xD. Once you manage to get it configured to your liking you'll think that in the end it doesn't even matter spending all that time. However if you're searching for something that is plug and play try [vscodium](vscodium.md).

To make things worse, the configuration [is done in lua](#configuration-done-in-Lua), so you may need  a [small refreshment](lua.md) to understand what are you doing.

# [Vim distributions](https://lazyman.dev/posts/Configuration-Distributions/)

One way to make vim's configuration more bearable is to use vim distributions. These are projects that maintain configurations with sane defaults and that work with the whole ecosystem of plugins.

Using them is the best way to:

- Have something usable fast
- Minimize the maintenance efforts as others are doing it for you (plugin changes, breaking changes, ..)
- Keep updated with the neovim ecosystem, as you can see what is the community adding to the default config.

However, there are so many good Neovim configuration distributions that it becomes difficult for a Neovim user to decide which distribution to use and how to tailor it for their use case.

By far, the top 5 Neovim configuration distributions are [AstroNvim](https://github.com/AstroNvim/AstroNvim), [kickstart](https://github.com/nvim-lua/kickstart.nvim), [LazyVim](https://github.com/LazyVim/LazyVim), [LunarVim](https://github.com/LunarVim/LunarVim), and [NvChad](https://github.com/NvChad/NvChad). That is not to say these are the “best” configuration distributions, simply that they are the most popular.

Each of these configuration distributions has value. They all provide excellent starting points for crafting your own custom configuration, they are all extensible and fairly easy to learn, and they all provide an out-of-the-box setup that can be used effectively without modification.

Distinguishing features of the top Neovim configuration distributions are:

- AstroNvim:

    - An excellent community repository
    - Fully featured out-of-the-box
    - Good documentation

- kickstart

    - Minimal out-of-the-box setup
    - Easy to extend and widely used as a starting point
    - A good choice if your goal is hand-crafting your own config

- LazyVim

    - Very well maintained by the author of lazy.nvim
    - Nice architecture, it’s a plugin with which you can import preconfigured plugins
    - Good documentation

- LunarVim

    - Well maintained and mature
    - Custom installation processs installs LunarVim in an isolated location
    - Been around a while, large community, widespread presence on the web

- NvChad

    - Really great base46 plugin enables easy theme/colorscheme management
    - Includes an impressive mappings cheatsheet
    - ui plugin and nvim-colorizer

Personally I tried LunarVim and finally ended up with LazyVim because:

- It's more popular
- I like the file structure
- It's being maintained by [folke](https://github.com/folke) one of the best developers of neovim plugins.


# [Starting your configuration with LazyVim](https://www.lazyvim.org/)

## [Installing the requirements](https://www.lazyvim.org/)

LazyVim needs the next tools to be able to work:

- Neovim >= 0.9.0 (needs to be built with LuaJIT). Follow [these instructions](vim.md#installation)
- Git >= 2.19.0 (for partial clones support). `sudo apt-get install git`.
- a [Nerd Font(v3.0 or greater)](https://www.nerdfonts.com/) (optional, but strongly suggested as they rae needed to display some icons). Follow [these instructions if you're using kitty](kitty.md#fonts).
- lazygit (optional and I didn't like it)
- a C compiler for nvim-treesitter. `apt-get install gcc`
- for telescope.nvim (optional)
  - live grep: `ripgrep`
  - find files: `fd`
- a terminal that support true color and undercurl:
  - [kitty (Linux & Macos)](kitty.md)
  - wezterm (Linux, Macos & Windows)
  - alacritty (Linux, Macos & Windows)
  - iterm2 (Macos)

## [Install the starter](https://www.lazyvim.org/installation)

- Make a backup of your current Neovim files:
    ```bash
    # required
    mv ~/.config/nvim{,.old}

    # optional but recommended
    mv ~/.local/share/nvim{,.old}
    mv ~/.local/state/nvim{,.old}
    mv ~/.cache/nvim{,.old}
    ```
- Clone the starter

    ```bash
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    ```

- Remove the `.git` folder, so you can add it to your own repo later

    ```bash
    rm -rf ~/.config/nvim/.git
    ```

- Start Neovim!

    ```bash
    nvim
    ```
- It is recommended to run `:LazyHealth` after installation. This will load all plugins and check if everything is working correctly.

## [Understanding the file structure](https://www.lazyvim.org/configuration)

The files under `config` will be automatically loaded at the appropriate time, so you don't need to require those files manually. 

You can add your custom plugin specs under `lua/plugins/`. All files there will be automatically loaded by lazy.nvim. 

```
~/.config/nvim
├── lua
│   ├── config
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   └── options.lua
│   └── plugins
│       ├── spec1.lua
│       ├── **
│       └── spec2.lua
└── init.toml
```
The files `autocmds.lua`, `keymaps.lua`, `lazy.lua` and `options.lua` under `lua/config` will be automatically loaded at the appropriate time, so you don't need to require those files manually. LazyVim comes with a set of default config files that will be loaded before your own.

You can continue your config by [adding plugins](lazyvim.md).

# [Configuration done in Lua](https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/)

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

# References

* [List of nvim configs](https://github.com/topics/neovim-config)
* [jessfraz vimrc](https://github.com/jessfraz/.vim/blob/master/vimrc)
