[Diffview](https://github.com/sindrets/diffview.nvim) is a single tabpage interface for easily cycling through diffs for all modified files for any git rev.

# Installation

If you're using it with NeoGit and Packer use:

```lua
  use {
    'NeogitOrg/neogit',
    requires = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-tree/nvim-web-devicons'
    }
  }
```

# Usage

## [DiffviewOpen](https://github.com/sindrets/diffview.nvim#diffviewopen-git-rev-options-----paths)

Calling `:DiffviewOpen` with no args opens a new `Diffview` that compares against the current index. You can also provide any valid git rev to view only changes for that rev.

Examples:

- `:DiffviewOpen`
- `:DiffviewOpen HEAD~2`
- `:DiffviewOpen HEAD~4..HEAD~2`
- `:DiffviewOpen d4a7b0d`
- `:DiffviewOpen d4a7b0d^!`
- `:DiffviewOpen d4a7b0d..519b30e`
- `:DiffviewOpen origin/main...HEAD`

You can also provide additional paths to narrow down what files are shown `:DiffviewOpen HEAD~2 -- lua/diffview plugin`.

Additional commands for convenience:

- `:DiffviewClose`: Close the current diffview. You can also use `:tabclose`.
- `:DiffviewToggleFiles`: Toggle the file panel.
- `:DiffviewFocusFiles`: Bring focus to the file panel.
- `:DiffviewRefresh`: Update stats and entries in the file list of the current Diffview.

With a Diffview open and the default key bindings, you can:

- Cycle through changed files with `<tab>` and `<s-tab>`
- You can stage changes with `-`
- Restore a file with `X`
- Refresh the diffs with `R`
- Go to the file panel with `<leader>e`

# Tips

## [Use the same binding to open and close the diffview windows](https://www.reddit.com/r/neovim/comments/15remc4/how_to_exit_all_the_tabs_in_diffviewnvim/?rdt=52076)

```lua
vim.keymap.set('n', 'dv', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd('DiffviewOpen')
  else
    vim.cmd('DiffviewClose')
  end
end)
```

# Troubleshooting

## No valid VCS tool found

It may be because you have an outdated version of git. To fix it update to the latest one, if it's still not enough, [install it from the backports repo](linux_snippets.md#install-latest-version-of-package-from-backports)

# References

- [Source](https://github.com/sindrets/diffview.nvim)
