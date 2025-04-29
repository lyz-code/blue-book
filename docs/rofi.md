DEPRECATED: [Use fzf instead](https://medium.com/njiuko/using-fzf-instead-of-dmenu-2780d184753f)

[Rofi](https://github.com/davatorium/rofi?tab=readme-ov-file) is a window switcher, application launcher and dmenu replacement.

# [Installation](https://github.com/davatorium/rofi/blob/next/INSTALL.md)

```bash
sudo apt-get install rofi
```

# [Usage](https://github.com/davatorium/rofi?tab=readme-ov-file#usage)
To launch rofi directly in a certain mode, specify a mode with `rofi -show <mode>`. To show the run dialog:

```bash
rofi -show run
```

Or get the options from a script:

```bash
~/my_script.sh | rofi -dmenu
```

Specify an ordered, comma-separated list of modes to enable. Enabled modes can be changed at runtime. Default key is Ctrl+Tab. If no modes are specified, all configured modes will be enabled. To only show the run and ssh launcher:

```bash
rofi -modes "run,ssh" -show run
```

The modes to combine in combi mode. For syntax to `-combi-modes` , see `-modes`. To get one merge view, of window,run, and ssh:

```bash
rofi -show combi -combi-modes "window,run,ssh" -modes combi
```

# [Configuration](https://github.com/davatorium/rofi/blob/next/CONFIG.md)

The configuration lives at `~/.config/rofi/config.rasi` to create this file with the default conf run:

```bash
rofi -dump-config > ~/.config/rofi/config.rasi
```

## [Use fzf to do the matching]()

To run once:

```bash
rofi -show run -sorting-method fzf -matching fuzzy
```

To persist them change those same values in the configuration.
## Theme changing
To change the theme:
- Choose the one you like most looking [here](https://davatorium.github.io/rofi/themes/themes/)
- Run `rofi-theme-selector` to select it
- Accept it with `Alt + a`

## [Keybindings change](https://davatorium.github.io/rofi/current/rofi-keys.5/)

# [Plugins](https://github.com/davatorium/rofi/wiki/User-scripts)
You can write your custom plugins. If you're on python using [`python-rofi`](https://github.com/bcbnz/python-rofi) seems to be the best option although it looks unmaintained.

Some interesting examples are:

- [Python based plugin](https://framagit.org/Daguhh/naivecalendar/-/tree/master?ref_type=heads)
- [Creation of nice menus](https://gitlab.com/vahnrr/rofi-menus/-/tree/master?ref_type=heads)
- [Nice collection of possibilities](https://github.com/adi1090x/rofi/tree/master)
- [Date picker](https://github.com/DMBuce/i3b/blob/master/bin/pickdate)
- [Orgmode capture](https://github.com/wakatara/rofi-org-todo/blob/master/rofi-org-todo.py)

Other interesting references are:

- [List of key bindings](https://davatorium.github.io/rofi/current/rofi-keys.5/)
- [Theme guide](https://davatorium.github.io/rofi/current/rofi-theme.5/#examples)
# References
- [Source](https://github.com/davatorium/rofi?tab=readme-ov-file)
- [Docs](https://davatorium.github.io/rofi/)
- [Plugins](https://github.com/davatorium/rofi/wiki/User-scripts)
