# Tips

## [How to exclude some files from the search](https://github.com/junegunn/fzf.vim/issues/453)

If anyone else comes here in the future and have the following setup

- Using `fd` as default command: `export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow'`
- Using `:Rg` to grep in files

And want to exclude a specific path in a git project say `path/to/exclude` (but that should not be included in `.gitignore`) from both `fd` and `rg` as used by `fzf.vim`, then the easiest way I found to solve to create ignore files for the respective tool then ignore this file in the local git clone (as they are only used by me)

```bash
cd git_proj/
echo "path/to/exclude" > .rgignore
echo "path/to/exclude" > .fdignore
printf ".rgignore\n.fdignore" >> .git/info/exclude
```
