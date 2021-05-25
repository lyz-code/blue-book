---
title: Write neovim plugins
date: 20210525
author: Lyz
---

* [plugin example](https://github.com/jacobsimpson/nvim-example-python-plugin)
* [plugin repo](https://github.com/neovim/python-client)

The plugin repo has some examples in the tests directory

# Control an existing nvim instance

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

# Load buffer

```python
buffer = nvim.current.buffer # Get the current buffer
buffer[0] = 'replace first line'
buffer[:] = ['replace whole buffer']
```

# Get cursor position
```python
nvim.current.window.cursor
```
