---
title: kitty
date: 20211007
author: Lyz
---

[kitty](https://sw.kovidgoyal.net/) is a fast, feature-rich, GPU based terminal
emulator written in C and Python with nice features for the keyboard driven
humans like me.

# [Installation](https://sw.kovidgoyal.net/kitty/binary/)

Although it's in the official repos, the version of Debian is quite old, instead
you can install it for the current user with:

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

You'll need to add the next alias too to your `.zshrc` or `.bashrc`

```bash
alias kitty="~/.local/kitty.app/bin/kitty"
```

# [Configuration](https://sw.kovidgoyal.net/kitty/overview/#configuring-kitty)

It's configuration is a simple, human editable, single file for easy
reproducibility stored at `~/.config/kitty/kitty.conf`

## [Print images in the terminal](https://paul-nameless.com/mastering-kitty.html)

Create an alias in your `.zshrc`:

```bash
alias icat="kitty +kitten icat"
```

![ ](https://paul-nameless.com/gif/icat.gif)


## [Colors](https://sw.kovidgoyal.net/kitty/kittens/themes/)

The themes kitten allows you to easily change color themes, from a collection of
almost two hundred pre-built themes available at kitty-themes. To use it run:

```bash
kitty +kitten themes
```

The kitten allows you to pick a theme, with live previews of the colors. You can
choose between light and dark themes and search by theme name by just typing
a few characters from the name.

If you want to tweak some colors once you select a theme, you can use [terminal
sexy](https://terminal.sexy/).

## [Make the background transparent](https://sw.kovidgoyal.net/kitty/conf/?highlight=opacity#opt-kitty.background_opacity)

!!! note "File: `~/.config/kitty/kitty.conf`"

    ```
    background_opacity 0.85
    ```

A number between 0 and 1, where 1 is opaque and 0 is fully transparent. This
will only work if supported by the OS (for instance, when using a compositor
under X11).

If you're using i3wm you need to configure [compton](https://www.reddit.com/r/i3wm/comments/2yytvs/make_terminals_transparent/)

Install it with `sudo apt-get install compton`, and configure i3 to start it in
the background adding `exec --no-startup-id compton` to your i3 config.

## [Terminal bell](https://sw.kovidgoyal.net/kitty/conf/?highlight=opacity#terminal-bell)

I hate the auditive terminal bell, disable it with:

```
enable_audio_bell no
```

## Movement

By default the movement is not vim friendly because if you use the same
keystrokes, they will be captured by kitty and not forwarded to the application.
The closest I got is:

```
# Movement

map ctrl+shift+k scroll_line_up
map ctrl+shift+j scroll_line_down
map ctrl+shift+u scroll_page_up
map ctrl+shift+d scroll_page_down
```

If you need more fine grained movement, use the [scrollback
buffer](#the-scrollback-buffer).

## [The scrollback buffer](https://sw.kovidgoyal.net/kitty/overview/#the-scrollback-buffer)

`kitty` supports scrolling back to view history, just like most terminals. You can
use either keyboard shortcuts or the mouse scroll wheel to do so. However, kitty
has an extra, neat feature. Sometimes you need to explore the scrollback buffer
in more detail, maybe search for some text or refer to it side-by-side while
typing in a follow-up command. kitty allows you to do this by pressing the
`ctrl+shift+h` key-combination, which will open the scrollback buffer in your
favorite pager program (which is less by default). Colors and text formatting
are preserved. You can explore the scrollback buffer comfortably within the
pager.

To use `nvim` as the pager follow [this
discussion](https://github.com/kovidgoyal/kitty/issues/719), the latest working
snippet was:

```
# Scrollback buffer
# https://sw.kovidgoyal.net/kitty/overview/#the-scrollback-buffer
# `bash -c '...'` Run everything in a shell taking the scrollback content on stdin
# `-u NORC` Load plugins but not initialization files
# `-c "map q :qa!<CR>"` Close with `q` key
# `-c "autocmd TermOpen * normal G"` On opening of the embedded terminal go to last line
# `-c "terminal cat /proc/$$/fd/0 -"` Open the embedded terminal and read stdin of the shell
# `-c "set clipboard+=unnamedplus"` Always use clipboard to yank/put instead of having to specify +
scrollback_pager bash -c 'nvim </dev/null -u NORC -c "map q :qa!<CR>" -c "autocmd TermOpen * normal G" -c "terminal cat /proc/$$/fd/0 -" -c "set clipboard+=unnamedplus" -c "call cursor(CURSOR_LINE, CURSOR_COLUMN)"'
```

To make the history scrollback infinite add the next lines:

```
scrollback_lines -1
scrollback_pager_history_size 0
```

## Clipboard management

```
# Clipboard
map ctrl+v        paste_from_clipboard
```

# Troubleshooting

## [Scrollback when ssh into a machine doesn't work](https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-when-sshing-into-a-different-computer)


This happens because the kitty terminfo files are not available on the server.
You can ssh in using the following command which will automatically copy the
terminfo files to the server:

```bash
kitty +kitten ssh myserver
```

This ssh kitten takes all the same command line arguments as ssh, you can alias
it to ssh in your shell’s rc files to avoid having to type it each time:

```bash
alias ssh="kitty +kitten ssh"
```

# Reasons to migrate from urxvt to kitty

* It doesn't fuck up your terminal colors.
* You can use [peek](peek.md) to record your screen.
* Easier to extend.

# References

* [Homepage](https://sw.kovidgoyal.net/)
