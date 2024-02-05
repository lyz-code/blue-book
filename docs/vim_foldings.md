One way to easily work with folds is by using the [fold-cycle](https://github.com/jghauser/fold-cycle.nvim?tab=readme-ov-file) plugin to be able to press `<tab>` or `<enter>` to toggle a fold.

If you're using [lazyvim](lazyvim.md) you can use the next configuration:

```lua
return {
  {
    "jghauser/fold-cycle.nvim",
    config = function()
      require("fold-cycle").setup()
    end,
    keys = {
      {
        "<tab>",
        function()
          return require("fold-cycle").open()
        end,
        desc = "Fold-cycle: open folds",
        silent = true,
      },
      {
        "<cr>",
        function()
          return require("fold-cycle").open()
        end,
        desc = "Fold-cycle: open folds",
        silent = true,
      },
      {
        "<s-tab>",
        function()
          return require("fold-cycle").close()
        end,
        desc = "Fold-cycle: close folds",
        silent = true,
      },
      {
        "zC",
        function()
          return require("fold-cycle").close_all()
        end,
        remap = true,
        silent = true,
        desc = "Fold-cycle: close all folds",
      },
    },
  },
}
```
