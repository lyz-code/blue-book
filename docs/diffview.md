[Diffview](https://github.com/sindrets/diffview.nvim) is a single tabpage interface for easily cycling through diffs for all modified files for any git rev.

# Installation

## Using Lazyvim

```lua
return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },

    keys = {
      {
        "dv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview window",
      },
    },
  },
}
```
Which sets the next bindings:
- `dv`: [Toggle the opening and closing of the diffview windows](https://www.reddit.com/r/neovim/comments/15remc4/how_to_exit_all_the_tabs_in_diffviewnvim/?rdt=52076)

## Using NeoGit and Packer
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

## [Use diffview as merge tool](https://github.com/sindrets/diffview.nvim/issues/226)

Add to your `~/.gitconfig`:

```ini
[alias]
  mergetool = "!nvim -c DiffviewOpen"
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

## Resolve merge conflicts

If you call `:DiffviewOpen` during a merge or a rebase, the view will list the conflicted files in their own section. When opening a conflicted file, it will open in a 3-way diff allowing you to resolve the conflict with the context of the target branch's version (OURS, left), and the version from the branch which is being merged (THEIRS, right).

The conflicted file's entry in the file panel will show the remaining number of conflict markers (the number following the file name). If what follows the file name is instead an exclamation mark (`!`), this indicates that the file has not yet been opened, and the number of conflicts is unknown. If the sign is a check mark, this indicates that there are no more conflicts in the file.

You can interact with the merge tool with the next bindings:

- `]x` and `[x`: Jump between conflict markers. This works from the file panel as well. 
- `dp`: Put the contents on the other buffer
- `do`: Get the contents from the other buffer
- `2do`: to obtain the hunk from the OURS side of the diff 
- `3do` to obtain the hunk from the THEIRS side of the diff
- `1do` to obtain the hunk from the BASE in a 4-way diff

Additionally there are mappings for operating directly on the conflict
markers:

- `<leader>co`: Choose the OURS version of the conflict.
- `<leader>ct`: Choose the THEIRS version of the conflict.
- `<leader>cb`: Choose the BASE version of the conflict.
- `<leader>ca`: Choose all versions of the conflict (effectively
  just deletes the markers, leaving all the content).
- `dx`: Choose none of the versions of the conflict (delete the
  conflict region).

# Troubleshooting

## No valid VCS tool found

It may be because you have an outdated version of git. To fix it update to the latest one, if it's still not enough, [install it from the backports repo](linux_snippets.md#install-latest-version-of-package-from-backports)

# References

- [Source](https://github.com/sindrets/diffview.nvim)
