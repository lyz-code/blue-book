
# [Actions](https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/doc/neo-tree.txt)

General keymaps:

- `<cr>`: Open the file in the current buffer
- `<s>`: Open in a vertical split
- `<S>`: Open in an horizontal split
- `<bs>`: Navigate one directory up (even if it's the root of the `cwd`)

File and directory management:

- `a`: Create a new file or directory. Add a `/` to the end of the name to make a directory.
- `d`: Delete the selected file or directory
- `r`: Rename the selected file or directory
- `y`: Mark file to be copied (supports visual selection)
- `x`: Mark file to be cut (supports visual selection)
- `m`: Move the selected file or directory
- `c`: Copy the selected file or directory

# Configuration

## [Show hidden files](https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/353)

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          '.git',
        },
        never_show = {},
      },
    }
  }
}
```

## [Autoclose on open file](https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#auto-close-on-open-file)
This example uses the file_open event to close the Neo-tree window when a file is opened. This applies to all windows and all sources at once.

```lua
require("neo-tree").setup({
  event_handlers = {

    {
      event = "file_opened",
      handler = function(file_path)
        -- auto close
        -- vimc.cmd("Neotree close")
        -- OR
        require("neo-tree.command").execute({ action = "close" })
      end
    },

  }
})
```

## [Configuring vim folds](https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#emulating-vims-fold-commands)

Copy the code under [implementation](https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#emulating-vims-fold-commands) in your config file.

# Troubleshooting

## Can't copy file/directory to itself

If you want to copy a directory you need to assume that the prompt is done from within the directory. So if you want to copy it to a new name at the same level you need to use `../new-name` instead of `new-name`.

# References

- [Docs](https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/doc/neo-tree.txt)
- [Wiki](https://github.com/nvim-neo-tree/neo-tree.nvim/wiki)
- [Wiki Recipes](https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes)
