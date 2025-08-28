[WezTerm](https://github.com/wez/wezterm) is a powerful cross-platform terminal emulator and multiplexer implemented in Rust.

# [Installation](https://wezfurlong.org/wezterm/install/linux.html)

You can configure your system to use that APT repo by following these steps:

```bash
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
```

Update your dependencies:

```bash
sudo apt update
```

Now you can install wezterm:

```bash
sudo apt install wezterm
```

or to install a nightly build (which I recommend as the stable is very old):

```bash
sudo apt install wezterm-nightly
```

# [Configuration](https://wezterm.org/config/files.html)

Create a file named `~/.config/wezterm/wezterm.lua` in your home directory, with the following contents:

```lua
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 10
config.color_scheme = 'AdventureTime'

-- Finally, return the configuration to wezterm:
return config
```

`wezterm` will watch the config file that it loads; if/when it changes, the configuration will be automatically reloaded and the majority of options will take effect immediately. You may also use the `CTRL+SHIFT+R` keyboard shortcut to force the configuration to be reloaded.

## [Colorscheme](https://wezterm.org/config/appearance.html#color-scheme)

WezTerm ships with over 700 color schemes. You can find a list of available color schemes and screenshots in [The Color Schemes Section](https://wezterm.org/colorschemes/index.html).

### [Switch between dark and light mode](https://wezterm.org/config/lua/wezterm.gui/get_appearance.html)

wezterm is able to detect when the appearance has changed and will reload the configuration when that happens.

```lua
This example configuration shows how you can have your color scheme automatically adjust to the current appearance:

local wezterm = require 'wezterm'

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Builtin Solarized Dark'
  else
    return 'Builtin Solarized Light'
  end
end

return {
  color_scheme = scheme_for_appearance(get_appearance()),
}
```

you can change between dark and light mode (if you're using GTK) by running:

```bash
alias dark="gsettings set org.gnome.desktop.interface color-scheme prefer-dark"
alias light="gsettings set org.gnome.desktop.interface color-scheme prefer-light"
```

You may want to also [configure the switch in nvim](vim.md#automatically-change-the-colorscheme-between-light-and-dark).

## Disable the padding

If you don't want it:

```lua
config.window_padding = {
	left = "0cell",
	right = "0cell",
	top = "0cell",
	bottom = "0cell",
}
```

## [Disable the tab bar](https://wezterm.org/config/appearance.html#tab-bar-appearance-colors)

I'm going to start without the tab bar as I prefer i3 to manage the tabs

```lua
config.hide_tab_bar_if_only_one_tab = true
```

## [Fonts](https://wezterm.org/config/fonts.html)

You can ask wezterm to including a listing of all of the fonts on the system in a form that can be copied and pasted into the configuration file:

```bash
wezterm ls-fonts --list-system
```

WezTerm bundles JetBrains Mono, Nerd Font Symbols and Noto Color Emoji fonts and uses those for the default font configuration.

If you wish to use a different font face, then you can use the wezterm.font function to specify it:

```lua
config.font = wezterm.font 'Fira Code'
```

## Key bindings

### Change copy mode

To enter in copy mode with less keys use:

```lua
config.keys = {
	{
		key = "x",
		mods = "CTRL",
		action = wezterm.action.ActivateCopyMode,
	},
}
```

## Set the terminal bell

The next snippet will make the window that raised the bell blink so that you can see it in i3wm even if you're at another workspace

```lua
-- Bell
wezterm.on("bell", function(window, _)
	-- Get the currently active window
	local _, prev_window, _ = wezterm.run_child_process({ "xdotool", "getactivewindow" })

	-- Focus the bell window
	window:focus()
	local _, bell_window, _ = wezterm.run_child_process({ "xdotool", "getactivewindow" })
	wezterm.log_info("the bell was rung in window " .. bell_window .. " while focus was on " .. prev_window)

	-- Set the X11 terminal bell and switch back to where we were if the window where the bell
	-- was triggered is not the active window.
	if bell_window ~= prev_window then
		wezterm.log_info("Ringing the bell")
		wezterm.run_child_process({
			"bash",
			"-c",
			"i3-msg workspace back_and_forth; xdotool set_window --urgency 1 " .. bell_window,
		})
	end
end)
wezterm.on("bell", function(window, _)
	-- Focus the bell window
	window:focus()
	-- Switch back to the previously focused window and set the urgency
	wezterm.background_child_process({
		"bash",
		"-c",
		"BELL_WINDOW=$(xdotool getactivewindow); i3-msg workspace back_and_forth; xdotool set_window --urgency 1 $BELL_WINDOW",
	})
end)
```

# Usage

## [Launching a different program as a one off via the CLI](https://wezterm.org/config/launch.html#launching-a-different-program-as-a-one-off-via-the-cli)

If you want to make a shortcut for your desktop environment that will, for example, open an editor in wezterm you can use the start subcommand to launch it. This example opens up a new terminal window running vim to edit your wezterm configuration:

```bash
wezterm start -- vim ~/.wezterm.lua
```

If you'd like wezterm to start running a program in a specific working directory you can do so with the `--cwd` flag.

## Using the [scrollbar and search](https://wezterm.org/scrollback.html#searching-the-scrollback)

By default, `CTRL-SHIFT-F` and `CMD-F` (F for Find) will activate the search overlay in the current tab:

- `Enter`, `UpArrow` and `CTRL-P` will cause the selection to move to any prior matching text.
- `CTRL-N` and `DownArrow` will cause the selection to move to any next matching text.
- `CTRL-U` will clear the search pattern so you can start over.
- `CTRL-R` will cycle through the pattern matching mode; the initial mode is case-sensitive text matching, the next will match ignoring case and the last will match using the regular expression syntax described here. The matching mode is indicated in the search bar.

The scrollbar works with SHIFT+PageUp and PageDown, but I find it simpler to enter in copy  mode and use vim bindings

### Search and copy the urls in your history

Use `ctrl+shift+u` to highlight the urls and `ctrl+y` to copy the selected one.
```lua
	{ key = "u", mods = "CTRL|SHIFT", action = act.Search({ Regex = "\\w+://\\S+" }) },
	{
		key = "y",
		mods = "CTRL",
		action = act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			{ Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
		}),
	},
```

# Troubleshooting

## [Install in Debian 12 error](https://github.com/wez/wezterm/issues/3973)

Install from nightly.

# References

- [Code](https://github.com/wez/wezterm)
- [Docs](https://wezterm.org/)
- [Home](https://wezfurlong.org/wezterm/index.html)
- [Awesome wezterm](https://github.com/michaelbrusegard/awesome-wezterm)
