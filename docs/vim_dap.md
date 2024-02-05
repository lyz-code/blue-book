# [Debug Adapter Protocol](https://davelage.com/posts/nvim-dap-getting-started/)

## [`nvim-dap`](https://github.com/mfussenegger/nvim-dap)
[`nvim-dap`](https://github.com/mfussenegger/nvim-dap) implements a client for the [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/overview). This allows a client to control a debugger over a documented API. That allows us to control the debugger from inside neovim, being able to set breakpoints, evaluate runtime values of variables, and much more.

`nvim-dap` is not configured for any language by default. You will need to set up a configuration for each language. For the configurations you will need adapters to run.

I would suggest starting with 2 actions. Setting breakpoints and “running” the debugger. The debugger allows us to stop execution and look at the current state of the program. Setting breakpoints will allow us to stop execution and see what the current state is.

```lua
vim.api.nvim_set_keymap('n', '<leader>b', [[:lua require"dap".toggle_breakpoint()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>c', [[:lua require"dap".continue()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>n', [[:lua require"dap".step_over()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>N', [[:lua require"dap".step_into()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<F5>', [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true })
```

Go to a line where a conditional or value is set and toggle a breakpoint. Then, we’ll start the debugger. If done correctly, you’ll see an arrow next to your line of code you set a breakpoint at.

There is no UI with dap by default. You have a few options for UI [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

In the `dap` repl you can [use the next operations](https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt):

- `.exit`: Closes the REPL
- `.c` or `.continue`: Same as |`dap.continue`|
- `.n` or `.next`: Same as |`dap.step_over`|
- `.into`: Same as |`dap.step_into`|
- `.into_target`: Same as |`dap.step_into{askForTargets=true}`|
- `.out`: Same as |`dap.step_out`|
- `.up`: Same as |`dap.up`|
- `.down`: Same as |`dap.down`|
- `.goto`: Same as |`dap.goto_`|
- `.scopes`: Prints the variables in the current s`cope`s
- `.threads`: Prints all t`hread`s
- `.frames`: Print the stack f`rame`s
- `.capabilities`: Print the capabilities of the debug a`dapte`r
- `.b` or `.back`: Same as |`dap.step_back`|
- `.rc` or `.reverse-continue`: Same as |`dap.reverse_continue`|

## [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

Install with packer:

```lua
use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
```

It is highly recommended to use [`neodev.nvim`](https://github.com/folke/neodev.nvim) to enable type checking for `nvim-dap-ui` to get type checking, documentation and autocompletion for all API functions.

```lua
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
  ...
})
```
`nvim-dap-ui` is built on the idea of "elements". These elements are windows which provide different features.

Elements are grouped into layouts which can be placed on any side of the screen. There can be any number of layouts, containing whichever elements desired.

Elements can also be displayed temporarily in a floating window.

Each element has a set of mappings for element-specific possible actions, detailed below for each element. The total set of actions/mappings and their default shortcuts are:

- edit: `e`
- expand: `<CR>` or left click
- open: `o`
- remove: `d`
- repl: `r`
- toggle: `t`

See `:h dapui.setup()` for configuration options and defaults.

To get started simply call the setup method on startup, optionally providing custom settings.

```lua
require("dapui").setup()
```

You can open, close and toggle the windows with corresponding functions:

```lua
require("dapui").open()
require("dapui").close()
require("dapui").toggle()
```

## [one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)

`one-small-step-for-vimkind` is an adapter for the Neovim lua language. It allows you to debug any lua code running in a Neovim instance.

Install it with Packer:

```lua
use 'mfussenegger/nvim-dap'
```
After installing one-small-step-for-vimkind, you will also need a DAP plugin which will allow you to interact with the adapter. Check the install instructions [here](#nvim-dap).

Then add these lines to your config:

```lua
local dap = require"dap"
dap.configurations.lua = { 
  { 
    type = 'nlua', 
    request = 'attach',
    name = "Attach to running Neovim instance",
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
end
```
