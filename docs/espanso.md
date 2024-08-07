[Espanso](https://github.com/espanso/espanso) is a cross-platform Text Expander written in Rust.

A text expander is a program that detects when you type a specific keyword and replaces it with something else. This is useful in many ways:

- Save a lot of typing, expanding common sentences or fixing common typos.
- Create system-wide code snippets.
- Execute custom scripts
- Use emojis like a pro.

# [Installation](https://espanso.org/docs/install/linux/)
Espanso ships with a .deb package, making the installation convenient on Debian-based systems.

Start by downloading the package by running the following command inside a terminal:

```bash
wget https://github.com/federico-terzi/espanso/releases/download/v2.2.1/espanso-debian-x11-amd64.deb
```

You can now install the package using:

```bash
sudo apt install ./espanso-debian-x11-amd64.deb
```

From now on, you should have the `espanso` command available in the terminal (you can verify by running `espanso --version`).

At this point, you are ready to use `espanso` by registering it first as a Systemd service and then starting it with:

```bash
espanso service register
```

Start espanso

```bash
espanso start
```

Espanso ships with very few built-in matches to give you the maximum flexibility, but you can expand its capabilities in two ways: creating your own custom matches or [installing packages](#using-packages).
# [Configuration](https://espanso.org/docs/get-started/#configuration)

Your configuration lives at `~/.config/espanso`. A quick way to find the path of your configuration folder is by using the following command `espanso path`.

- The files contained in the `match` directory define what Espanso should do. In other words, this is where you should specify all the custom snippets and actions (aka Matches). The `match/base.yml` file is where you might want to start adding your matches.
- The files contained in the `config` directory define how Espanso should perform its expansions. In other words, this is were you should specify all Espanso's parameters and options. The `config/default.yml` file defines the options that will be applied to all applications by default, unless an app-specific configuration is present for the current app. 

## [Using packages](https://espanso.org/docs/get-started/#understanding-packages)
Custom matches are great, but sometimes it can be tedious to define them for every common operation, especially when you want to share them with other people.

Espanso offers an easy way to share and reuse matches with other people, packages. In fact, they are so important that Espanso includes a built-in package manager and a store, the [Espanso Hub](https://hub.espanso.org/).

### [Installing a package](https://espanso.org/docs/get-started/#installing-a-package)
Get the id of the package from the [Espanso Hub](https://hub.espanso.org/) and then run `espanso install <<package_name>>`.

### Interesting packages

Of all the packages, I've found the next ones the most useful:

- [typofixer-en](https://hub.espanso.org/typofixer-en)
- [typofixer-es](https://hub.espanso.org/typofixer-es)
- [misspell-en-uk](https://hub.espanso.org/misspell-en-uk)

### Overwriting the snippets of a package

For example the `typofixer-en` replaces `si` to `is`, although `si` is a valid spanish word. To override the fix you can create your own file on `~/.config/espanso/match/typofix_overwrite.yml` with the next content:

```yaml
# This file overwrites typo fixes by https://github.com/Mte90/espanso-typofixer which conflict between languages
matches:
  # Simple text replacement
  - trigger: "si"
    replace: "si"
```
### [Creating a package](https://espanso.org/docs/packages/creating-a-package/)
## Auto-restart on config changes

Set `auto_restart: true` on `~/.config/espanso/config/default.yml`.

## [Changing the search bar shortcut](https://espanso.org/docs/configuration/options/#customizing-the-search-bar)
If the default search bar shortcut conflicts with your i3 configuration set it with:

```yaml
search_shortcut: CTRL+SHIFT+e
```

## [Hiding the notifications](https://espanso.org/docs/configuration/options/#hiding-the-notifications)
You can hide the notifications by adding the following option to your `$CONFIG/config/default.yml` config:

```yaml
show_notifications: false
```
# Usage
Just type and you'll see the text expanded. 

You can use the search bar if you don't remember your snippets.
# Helpers
## Desktop application to add words easily

Going into the espanso config files to add words is cumbersome, to make things easier you can use the `espansadd` Python script.

I'm going to assume that you have the following prerequisites:

- A Linux distribution with i3 window manager installed.
- Python 3 installed.
- Espanso installed and configured.
- `ruyaml` and `tkinter` Python libraries installed.
- `notify-send` installed.
- Basic knowledge of editing configuration files in i3.

### Installation

Create a new Python script named `espansadd.py` with the following content:

```python
import tkinter as tk
from tkinter import simpledialog
import traceback
import subprocess
import os
import sys

from ruyaml import YAML
from ruyaml.scanner import ScannerError

# Define the YAML file path
file_path = os.path.expanduser("~/.config/espanso/match/typofixer_overwrite.yml")


def append_to_yaml(file_path: str, trigger: str, replace: str) -> None:
    """Appends a new entry to the YAML file.

    Args:ath
        file_path (str): The file to append the new entry.
        trigger (str): The trigger string to be added.
        replace (str): The replacement string to be added.
    """

    # Define the new snippet
    new_entry = {
        "trigger": trigger,
        "replace": replace,
        "propagate_case": True,
        "word": True,
    }

    # Load existing data or initialize an empty list
    try:
        with open(os.path.expanduser(file_path), "r") as f:
            try:
                data = YAML().load(f)
            except ScannerError as e:
                send_notification(
                    f"Error parsing yaml of configuration file {file_path}",
                    f"{e.problem_mark}: {e.problem}",
                    "critical",
                )
                sys.exit(1)
    except FileNotFoundError:
        send_notification(
            f"Error opening the espanso file {file_path}", urgency="critical"
        )
        sys.exit(1)

    data["matches"].append(new_entry)

    # Write the updated data back to the file
    with open(os.path.expanduser(file_path), "w+") as f:
        yaml = YAML()
        yaml.default_flow_style = False
        yaml.dump(data, f)


def send_notification(title: str, message: str = "", urgency: str = "normal") -> None:
    """Send a desktop notification using notify-send.

    Args:
        title (str): The title of the notification.
        message (str): The message body of the notification. Defaults to an empty string.
        urgency (str): The urgency level of the notification. Can be 'low', 'normal', or 'critical'. Defaults to 'normal'.
    """
    subprocess.run(["notify-send", "-u", urgency, title, message])


def main() -> None:
    """Main function to prompt user for input and append to the YAML file."""
    # Create the main Tkinter window (it won't be shown)
    window = tk.Tk()
    window.withdraw()  # Hide the main window

    # Prompt the user for input
    trigger = simpledialog.askstring("Espanso add input", "Enter trigger:")
    replace = simpledialog.askstring("Espanso add input", "Enter replace:")

    # Check if both inputs were provided
    try:
        if trigger and replace:
            append_to_yaml(file_path, trigger, replace)
            send_notification("Espanso snippet added successfully")
        else:
            send_notification(
                "Both trigger and replace are required", urgency="critical"
            )
    except Exception as error:
        error_message = "".join(
            traceback.format_exception(None, error, error.__traceback__)
        )
        send_notification(
            "There was an unknown error adding the espanso entry",
            error_message,
            urgency="critical",
        )


if __name__ == "__main__":
    main()
```

Ensure the script has executable permissions. Run the following command:

```bash
chmod +x espansadd.py
```

To make the `espansadd` script easily accessible, we can configure a key binding in i3 to run the script. Open your i3 configuration file, typically located at `~/.config/i3/config` or `~/.i3/config`, and add the following lines:

```bash
# Bind Mod+Shift+E to run the espansadd script
bindsym $mod+Shift+e exec --no-startup-id /path/to/your/espansadd.py
```

Replace `/path/to/your/espansadd.py` with the actual path to your script.

If you also want the popup windows to be in floating mode add

```bash
for_window [title="Espanso add input"] floating enable
```

After editing the configuration file, reload i3 to apply the changes. You can do this by pressing `Mod` + `Shift` + `R` (where `Mod` is typically the `Super` or `Windows` key) or by running the following command:

```bash
i3-msg reload
```

### Usage

Now that everything is set up, you can use the `espansadd` script by pressing `Mod` + `Shift` + `E`. This will open a dialog where you can enter the trigger and replacement text for the new Espanso snippet. After entering the information and pressing Enter, a notification will appear confirming the snippet has been added, or showing an error message if something went wrong.

# References
- [Code](https://github.com/espanso/espanso)
- [Docs](https://espanso.org/docs/get-started/)
