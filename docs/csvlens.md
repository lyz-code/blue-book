`csvlens` is a command line CSV file viewer. It is like less but made for CSV.

# Usage

Run `csvlens` by providing the CSV filename:

```
csvlens <filename>
```

Pipe CSV data directly to `csvlens`:

```
<your commands producing some csv data> | csvlens
```

## Key bindings

Key | Action
--- | ---
`hjkl` (or `← ↓ ↑→ `) | Scroll one row or column in the given direction
`Ctrl + f` (or `Page Down`) | Scroll one window down
`Ctrl + b` (or `Page Up`) | Scroll one window up
`Ctrl + d` (or `d`) | Scroll half a window down
`Ctrl + u` (or `u`) | Scroll half a window up
`Ctrl + h` | Scroll one window left
`Ctrl + l` | Scroll one window right
`Ctrl + ←` | Scroll left to first column
`Ctrl + →` | Scroll right to last column
`G` (or `End`) | Go to bottom
`g` (or `Home`) | Go to top
`<n>G` | Go to line `n`
`/<regex>` | Find content matching regex and highlight matches
`n` (in Find mode) | Jump to next result
`N` (in Find mode) | Jump to previous result
`&<regex>` | Filter rows using regex (show only matches)
`*<regex>` | Filter columns using regex (show only matches)
`TAB` | Toggle between row, column or cell selection modes
`>` | Increase selected column's width
`<` | Decrease selected column's width
`Shift + ↓` (or `Shift + j`) | Sort rows or toggle sort direction by the selected column
`#` (in Cell mode) | Find and highlight rows like the selected cell
`@` (in Cell mode) | Filter rows like the selected cell
`y` (in Cell Mode) | Copy the selected cell to clipboard
`Enter` (in Cell mode) | Print the selected cell to stdout and exit
`-S` | Toggle line wrapping
`-W` | Toggle line wrapping by words
`r` | Reset to default view (clear all filters and custom column widths)
`H` (or `?`) | Display help
`q` | Exit

# Installation

Download the binary directly from the [releases](https://github.com/YS-L/csvlens/releases) or if you have cargo installed do:

```bash
cargo install csvlens
```
# References
- [Source](https://github.com/YS-L/csvlens)
