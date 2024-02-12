---
title: Write neovim plugins
date: 20210525
author: Lyz
---

# Developing a new Neovim plugin

* [plugin example](https://github.com/jacobsimpson/nvim-example-python-plugin)
* [plugin repo](https://github.com/neovim/python-client)

The plugin repo has some examples in the tests directory.

[Miguel Crespo has created a nice tutorial too](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua)
# [The anatomy of a Neovim plugin](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua) 

Let’s start by seeing how the architecture of a common neovim plugin looks like, usually a neovim plugin is structured in the following way:

```code
.
├── LICENSE
├── plugin
│  └── plugin-file.lua
├── lua
│  └── main-file.lua
└── README.md

```

The plugin and lua folder are special cases and have the following meanings:

- `plugin` directory: All files in this directory will get executed as soon as Neovim starts, this is useful if you want to set keymaps or autocommands regardless of the user requiring the plugin or not.

- `lua` directory: Here is where your plugin’s code lives, this code will only be executed when the user explicitly requires your plugin.

The naming of the files is important and will usually be the same as the plugin, there are two ways to do it:

- Having a single lua file named after the plugin, e.g: `scratch-buffer.lua`
- Having a folder named after the plugin with an init.lua inside of it, e.g `lua/scratch-buffer/init.lua`.

# Vim plugin development snippets

## Control an existing nvim instance

A number of different transports are supported, but the simplest way to get
started is with the python REPL. First, start Nvim with a known address (or use
the `$NVIM_LISTEN_ADDRESS` of a running instance):

```sh
$ NVIM_LISTEN_ADDRESS=/tmp/nvim nvim
```

In another terminal, connect a python REPL to Nvim (note that the API is similar
to the one exposed by the [python-vim
bridge](http://vimdoc.sourceforge.net/htmldoc/if_pyth.html#python-vim):

```python
>>> from neovim import attach
# Create a python API session attached to unix domain socket created above:
>>> nvim = attach('socket', path='/tmp/nvim')
# Now do some work.
>>> buffer = nvim.current.buffer # Get the current buffer
>>> buffer[0] = 'replace first line'
>>> buffer[:] = ['replace whole buffer']
>>> nvim.command('vsplit')
>>> nvim.windows[1].width = 10
>>> nvim.vars['global_var'] = [1, 2, 3]
>>> nvim.eval('g:global_var')
[1, 2, 3]
```

## Load buffer

```python
buffer = nvim.current.buffer # Get the current buffer
buffer[0] = 'replace first line'
buffer[:] = ['replace whole buffer']
```

## Get cursor position
```python
nvim.current.window.cursor
```
# Neovim plugin debug

If you use [packer](#packer) your plugins will be installed in `~/.local/share/nvim/site/pack/packer/start/`. You can manually edit those files to develop new feature or fix issues on the plugins.

To debug a plugin read it's source code and try to load in a lua shell the relevant code. If you are in a vim window you can run lua code with `:lua your code here`, for example `:lua Files = require('orgmode.parser.files')`, you can then do stuff with the `Files` object.

## Debugging with prints

Remember that if you need to print the contents of a table [you can use `vim.inspect`](lua.md#inspect-contents-of-Lua-table-in-Neovim).

Another useful tip for Lua newbies (like me) can be to use `print` statements to debug the state of the variables. If it doesn't show up in vim use `error` instead, although that will break the execution with an error.

To see the messages you can use `:messages`. 

## [Debugging with DAP](https://github.com/nanotee/nvim-lua-guide#debugging-lua-code)

You can debug Lua code running in a separate Neovim instance with [jbyuki/one-small-step-for-vimkind](vim_dap.md#one-small-step-for-vimkind).

The plugin uses the [Debug Adapter Protocol](vim_dap.md#debug-adapter-protocol). Connecting to a debug adapter requires a DAP client like [mfussenegger/nvim-dap](vim_dap.md#nvim-dap). Check how to configure [here](vim_dap.md#one-small-step-for-vimkind)

Once you have all set up and assuming you're using the next keybindings for `nvim-dap`:

```lua
vim.api.nvim_set_keymap('n', '<leader>b', [[:lua require"dap".toggle_breakpoint()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>c', [[:lua require"dap".continue()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>n', [[:lua require"dap".step_over()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>N', [[:lua require"dap".step_into()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<F5>', [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>B', [[:lua require"dapui".toggle()<CR>]], { noremap = true })
```

You will debug the plugin by:

- Launch the server in the debuggee using `F5`.
- Open another Neovim instance with the source file (the debugger).
- Place breakpoint with `<leader>b`.
- On the debugger connect to the DAP client with `<leader>c`.
- Optionally open the `nvim-dap-ui` with `<leader>B` in the debugger.
- Run your script/plugin in the debuggee
- Interact in the debugger using `<leader>n` to step to the next step, and `<leader>N` to step into. Then use the dap console to inspect and change the values of the state.

# References
- [Miguel Crespo tutorial](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua)

