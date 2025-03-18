---
title: Write neovim plugins
date: 20210525
author: Lyz
---

# Developing a new Neovim plugin

* [plugin example](https://github.com/jacobsimpson/nvim-example-python-plugin)
* [plugin repo](https://github.com/neovim/python-client)

The plugin repo has some examples in the tests directory.

Check [org-checkbox](https://github.com/massix/org-checkbox.nvim/blob/trunk/lua/orgcheckbox/init.lua) to see a simple one
)
[Miguel Crespo has created a nice tutorial too](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua)
## [The anatomy of a Neovim plugin](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua) 

For the repository name, plugins usually finish with the `.nvim` extension. I'm going to call mine `org-misc.nvim`.

Let’s start by seeing how the architecture of a common neovim plugin looks like, usually a neovim plugin is structured in the following way:

```code
.
├── LICENSE
├── plugin
│  └── ...
├── lua
│   └── org-misc
│       └── init.lua
└── README.md

```

The plugin and lua folder are special cases and have the following meanings:

- `plugin` directory: All files in this directory will get executed as soon as Neovim starts, this is useful if you want to set keymaps or autocommands regardless of the user requiring the plugin or not.

- `lua` directory: Here is where your plugin’s code lives, this code will only be executed when the user explicitly requires your plugin.

The naming of the files is important and will usually be the same as the plugin, there are two ways to do it:

- Having a single lua file named after the plugin, e.g: `scratch-buffer.lua`
- Having a folder named after the plugin with an init.lua inside of it, e.g `lua/scratch-buffer/init.lua`.

Let's go with the second, add to your `init.lua` the next code:

```lua
print("Hello from our plugin")
```
## [How to load our extension](https://www.youtube.com/watch?v=VGid4aN25iI)

We can have the code of our extension wherever we want in our filesystem, but we need to tell Neovim where our plugin’s code is, so it can load the files correctly. Since I use lazy.nvim this is the way to load a plugin from a local folder:

```lua
{
  dir = "~/projects/org-misc", -- Your path
}
```

Now if you restart your neovim you won't see anything until you load it with `:lua require "org-misc"` you'll see the message `Hello from our plugin` in the command line.


To automatically load the plugin when you open nvim, use the next lazy config:

```lua
{
  dir = "~/projects/org-misc", -- Your path
  config = function()
    require "org-misc"
  end
}
```

## [The plugin file structure](https://www.youtube.com/watch?v=VGid4aN25iI)

Usually `init.lua` starts with:

```lua
local M = {}

M.setup = function ()
  -- nothing yet
end

return M
```

Where:
- `M` stands for module, and we'll start adding it methods.
- `M.setup` will be the method we use to configure the plugin.

Let's start with a basic functionality to print some slides:

```lua
local M = {}

M.setup = function()
	-- nothing yet
end

---@class present.Slides
---@fields slides string[]: The slides of the file

--- Takes some lines and parses them
--- @param lines string
--- @return present.Slides
local parse_slides = function(lines)
	local slides = { slides = {} }
	for _, line in ipairs(lines) do
		print(line)
	end
	return slides
end

print(parse_slides({
	"# Hello",
	"this is something else",
	"# world",
	"this is something else",
}))

return M
```

You [can run the code in the current buffer](https://vi.stackexchange.com/questions/44902/how-can-i-execute-lua-code-from-a-buffer) with `:%lua`. For quick access, I've defined the next binding:

```lua
keymap.set("n", "<leader>X", ":%lua<cr>", {desc = "Run the lua code in the current buffer"})
```

The `print(parse_slides..` part it's temporal code so that you can debug your code easily. Once it's ready you'll remove them

# Vim plugin development snippets

## Call a method of a module

To run the method of a module: 

```lua
local M = {}

M.setup = function()
	-- nothing yet
end

return M
```

You can do `require('org-misc').setup()`

## Set keymaps

### Inside the code of the plugin

You can set keymaps into your plugins by using:

```lua
vim.keymap.set("n", "n", function()
  -- code
end)
```

The problem is that it will override the `n` key everywhere which is not a good idea, that's why we normally limit it to the current buffer.

You can get the current buffer with `buffer = true`

```lua
vim.keymap.set("n", "n", function()
  -- code
end, 
  {
    buffer = true
  }
)
```
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

If you use [packer](#packer) your plugins will be installed in `~/.local/share/nvim/site/pack/packer/start/`. 
If you use `lazy` your plugins will be installed in `~/.local/share/nvim/lazy/pack/packer/start/`. 

You can manually edit those files to develop new feature or fix issues on the plugins. Or if you're developing them in a directory you can specify the `dir` directive in the lazy loading.

To debug a plugin read it's source code and try to load in a lua shell the relevant code. If you are in a vim window you can run lua code with `:lua your code here`, for example `:lua Files = require('orgmode.parser.files')`, you can then do stuff with the `Files` object.

## [Debugging using Snacks](https://github.com/folke/snacks.nvim/blob/main/docs/debug.md)
Utility functions you can use in your code.

Personally, I have the code below at the top of my `init.lua`:

```lua
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
vim.print = _G.dd
```

What this does:

- Add a global `dd(...)` you can use anywhere to quickly show a
  notification with a pretty printed dump of the object(s)
  with lua treesitter highlighting
- Add a global `bt()` to show a notification with a pretty
  backtrace.
- Override Neovim's `vim.print`, which is also used by `:= {something = 123}`

You can't use `debug` instead of `dd` because nvim fails  to start :( 

![image](https://github.com/user-attachments/assets/0517aed7-fbd0-42ee-8058-c213410d80a7)
## Debugging with prints

Remember that if you need to print the contents of a table [you can use `vim.inspect`](lua.md#inspect-contents-of-Lua-table-in-Neovim).

Another useful tip for Lua newbies (like me) can be to use `print` statements to debug the state of the variables. If it doesn't show up in vim use `error` instead, although that will break the execution with an error.

To see the messages you can use `:messages`. 

## [Debugging with DAP](https://github.com/nanotee/nvim-lua-guide#debugging-lua-code)

You can debug Lua code running in a separate Neovim instance with [jbyuki/one-small-step-for-vimkind](vim_dap.md#one-small-step-for-vimkind).

The plugin uses the [Debug Adapter Protocol](vim_dap.md#debug-adapter-protocol). Connecting to a debug adapter requires a DAP client like [mfussenegger/nvim-dap](vim_dap.md#nvim-dap). Check how to configure [here](vim_dap.md#one-small-step-for-vimkind)

Once you have all set up and assuming you're using the lazyvim keybindings for `nvim-dap`:

```lua
vim.api.nvim_set_keymap('n', '<leader>ds', [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dq', [[:lua require"osv".stop()<CR>]], { noremap = true })
```

You will debug the plugin by:

- Launch the server in the nvim instance where you're going to run the actions using `<leader>ds`.
- Open another Neovim instance with the source file (the debugger).
- Place breakpoint with `<leader>db`.
- On the debugger connect to the DAP client with `<leader>dc`.
- Optionally open the `nvim-dap-ui` with `<leader>B` in the debugger.
- Run your script/plugin in the debuggee

Now you can interact with the debugger in the window below the code. You have the next commands:

- `help`: Show all commands
- `<enter>`: run the same action as the previous one. For example if you do `.n` and then `<enter>` it will run `.n` again.
- `.n` or `.next`: next step
- `.b` or `.back`: previous step (if the debugger supports it)
- `.c` or `.continue`: Continue to the next breakpoint.

### Continue till the end
If you want to stop capturing the traffic flow and go to the end ignoring all breakpoints, remove all breakpoints and do `.c`

### [Reload the plugin without exiting nvim](https://www.reddit.com/r/neovim/comments/170jkzh/how_to_reload_plugin_when_developing_them/)
If you are using lazy.nvim, there is a feature that lazy.nvim provides for this purpose: 

```lua
Lazy reload your_plugin your_plugin2
```
# Neovim plugin testing

We're going to test it with `plenary`. We'll add a `tests` directory at the root of our repository.

Each of the test files need to end in `_spec.lua`, so if we want to test a `parse_lines` it will be called `parse_lines_spec.lua`.

Each test file has the following structure

```lua
local clockin = require('org-misc').clockin

describe("org-misc.clockin", function()
	it("should do clockin", function()
		assert.is.True(clock_in())
	end)
end)
```
These are all the tests for the `clockin` method, 

Now you can run the test with `:PlenaryBustedFile %`

## Configuring neotest to run the tests

Using `:PlenaryBustedFile %` is not comfortable, that's why we're going to use [`neotest`](https://github.com/nvim-neotest/neotest?tab=readme-ov-file)

Configure it with:

```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-plenary"),
        },
      })
    end,
  },
}
```

Now you can do:

- `<leader>tT` to run all test files
- `<leader>tt` to run the whole file
- `<leader>tl` to run the last test
- `<leader>to` to show the output
- `<leader>tr` to run the nearest
- `<leader>ts` to show the summary


## [Remove the Undefined global describe linter warnings](https://www.reddit.com/r/neovim/comments/18pe4f4/plenarynvim_undefined_global_describe_it_etc_not/)

Add to the root of your repository a `.luarc.json` file with [the next contents](https://github.com/nvim-orgmode/orgmode/blob/master/.luarc.json)

```json
{
  "$schema": "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
  "diagnostics": {
    "globals": ["vim"]
  },
  "hint": {
    "enable": true
  },
  "runtime": {
    "path": ["?.lua", "?/init.lua"],
    "pathStrict": true,
    "version": "LuaJIT"
  },
  "telemetry": {
    "enable": false
  },
  "workspace": {
    "checkThirdParty": "Disable",
    "ignoreDir": [".git"],
    "library": [
      "./lua",
      "$VIMRUNTIME/lua",
      "${3rd}/luv/library",
      "./tests/.deps/plugins/plenary"
    ]
  }
}
```

## Testing internal functions

If you have a function `parse_lines` in your module that you want to test, you can export it as an internal method

```lua
local parse_lines = function ()
  -- code
end

M._parse_lines = parse_lines
```
# References
- [Simple plugin example](https://github.com/massix/org-checkbox.nvim/blob/trunk/lua/orgcheckbox/init.lua)
- [Miguel Crespo tutorial](https://miguelcrespo.co/posts/how-to-write-a-neovim-plugin-in-lua)

