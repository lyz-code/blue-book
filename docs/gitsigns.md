[Gitsigns](https://github.com/lewis6991/gitsigns.nvim) is a neovim plugin to create git decorations similar to the vim plugin [gitgutter](https://github.com/airblade/vim-gitgutter) but written purely in Lua.

# [Installation](https://github.com/lewis6991/gitsigns.nvim)

Add to your `plugins.lua` file:

```lua
  use {'lewis6991/gitsigns.nvim'}
```

Install it with `:PackerInstall`.

Configure it in your `init.lua` with:

```lua
-- Configure gitsigns
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map('n', '<leader>gs', gs.stage_hunk)
    map('n', '<leader>gr', gs.reset_hunk)
    map('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>gS', gs.stage_buffer)
    map('n', '<leader>gu', gs.undo_stage_hunk)
    map('n', '<leader>gR', gs.reset_buffer)
    map('n', '<leader>gp', gs.preview_hunk)
    map('n', '<leader>gb', function() gs.blame_line{full=true} end)
    map('n', '<leader>gb', gs.toggle_current_line_blame)
    map('n', '<leader>gd', gs.diffthis)
    map('n', '<leader>gD', function() gs.diffthis('~') end)
    map('n', '<leader>ge', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})
```

# Usage

Some interesting bindings:

- `]c`: Go to next diff chunk
- `[c`: Go to previous diff chunk
- `<leader>gs`: Stage chunk, it works both in normal and visual mode
- `<leader>gr`: Restore chunk from index, it works both in normal and visual mode
- `<leader>gp`: Preview diff, you can use it with `]c` and `[c` to see all the chunk diffs
- `<leader>gb`: Show the git blame of the line as a shadowed comment

# References

- [Source](https://github.com/lewis6991/gitsigns.nvim)

