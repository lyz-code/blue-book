---
title: Python Prompt Toolkit
date: 20200827
author: Lyz
---

[Python Prompt Toolkit](https://python-prompt-toolkit.readthedocs.io/en/master/)
is a library for building powerful interactive command line and terminal
applications in Python.

# [Installation](https://python-prompt-toolkit.readthedocs.io/en/master/pages/getting_started.html#installation)

```bash
pip install prompt_toolkit
```

# Usage

## [A simple prompt](https://python-prompt-toolkit.readthedocs.io/en/master/pages/getting_started.html#a-simple-prompt)

The following snippet is the most simple example, it uses the `prompt()` function
to asks the user for input and returns the text. Just like `(raw_)input`.

```python
from prompt_toolkit import prompt

text = prompt('Give me some input: ')
print('You said: %s' % text)
```

# Testing

Testing prompt_toolkit or any [text-based user
interface](https://en.wikipedia.org/wiki/Text-based_user_interface) (TUI) with
python is not well documented. Some of the main developers suggest [mocking
it](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/477) while
[others](https://github.com/copier-org/copier/pull/260/files#diff-4e8715c7a425ee52e74b7df4d34efd32e8c92f3e60bd51bc2e1ad5943b82032e)
use [pexpect](pexpect.md).

With the first approach you can test python functions and methods internally but
it can lead you to the over mocking problem. The second will limit you to test
functionality exposed through your program's command line, as it will spawn
a process and interact it externally.

Given that the TUIs are entrypoints to your program, it makes sense to test them
in end-to-end tests, so I'm going to follow the second option. On the other
hand, you may want to test a small part of your TUI in a unit test, if you
want to follow this other path, I'd start with
[monkeypatch](https://stackoverflow.com/questions/38723140/i-want-to-use-stdin-in-a-pytest-test),
although I didn't have good results with it.

```python
def test_method(monkeypatch):
    monkeypatch.setattr('sys.stdin', io.StringIO('my input'))
```

## [Using pexpect](https://github.com/copier-org/copier/pull/260/files)

This method is useful to test end to end functions as you need to all the
program as a command line. You can't use it to tests python functions
internally.

!!! note "File: source.py"
    ```python
    from prompt_toolkit import prompt

    text = prompt("Give me some input: ")
    with open("/tmp/tui.txt", "w") as f:
        f.write(text)
    ```

!!! note "File: test_source.py"
    ```python
    import pexpect


    def test_tui() -> None:
        tui = pexpect.spawn("python source.py", timeout=5)
        tui.expect("Give me .*")
        tui.sendline("HI")
        tui.expect_exact(pexpect.EOF)

        with open("/tmp/tui.txt", "r") as f:
            assert f.read() == "HI"
   ```

Where:

* The `tui.expect_exact(pexpect.EOF)` line is required so that the tests aren't
    run before the process has ended, otherwise the file might not exist yet.
* The `timeout=5` is required in case that the `pexpect` interaction is not well
    defined, so that the test is not hung forever.

!!! note "Thank you [Jairo Llopis](https://github.com/Yajo) for this solution."
    I've deduced the solution from his
    [#260](https://github.com/copier-org/copier/pull/260/files) PR into
    [copier](https://github.com/copier-org/copier), and the comments of
    [#1243](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1243)

# [Full screen
applications](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html)

`prompt_toolkit` can be used to create complex full screen terminal applications.
Typically, an application consists of a layout (to describe the graphical part)
and a set of key bindings.

Every prompt_toolkit application is an instance of an `Application` object.

```python
from prompt_toolkit import Application

app = Application(full_screen=True)
app.run()
```

When `run()` is called, the event loop will run until the application is done.
An application will quit when exit() is called. The event loop is
basically a while-true loop that waits for user input, and when it receives
something (like a key press), it will send that to the appropriate handler,
like for instance, a key binding.

An application consists of several components. The most important are:

* I/O objects: the input and output device.
* The layout: this defines the graphical structure of the application. For
    instance, a text box on the left side, and a button on the right side. You
    can also think of the layout as a collection of ‘widgets’.
* A style: this defines what colors and underline/bold/italic styles are used
    everywhere.
* A set of key bindings.

## [The
layout](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#the-layout)

With the `Layout` object you define the graphical structure of the application,
it accepts as argument a nested structure of `Container` objects, these arrange
the layout by splitting the screen in many regions, while controls (children of
`UIControl`, such as `BufferControl` or `FormattedTextControl`) are responsible
for generating the actual content.

Some of the `Container`s you can use are: `HSplit`, `Vsplit`, `FloatContainer`,
`Window` or `ScrollablePane`. The `Window` class itself is particular: it is
a `Container` that can contain a `UIControl`. Thus, it’s the adapter between the
two. The `Window` class also takes care of scrolling the content and wrapping the
lines if needed.

### [Tables](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/305)

Currently they are not supported :(, although there is an [old
PR](https://github.com/prompt-toolkit/python-prompt-toolkit/pull/724).

## Controls

### [Focusing windows](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#focusing-windows)

Focusing something can be done by calling the `focus()` method. This method is
very flexible and accepts a `Window`, a `Buffer`, a `UIControl` and more.

In the following example, we use `get_app()` for getting the active application.

```python
from prompt_toolkit.application import get_app

# This window was created earlier.
w = Window()

# ...

# Now focus it.
get_app().layout.focus(w)
```

To focus the next window in the layout you can use `app.layout.focus_next()`.

### [Key
bindings](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#key-bindings)

In order to react to user actions, we need to create a `KeyBindings` object and
pass that to our `Application`.

There are two kinds of key bindings:

* [Global key bindings](#global-key-bindings), which are always active.
* Key bindings that belong to a certain `UIControl` and are only active when
    this control is focused. Both `BufferControl` and `FormattedTextControl`
    take a `key_bindings` argument.

#### [Global key
bindings](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#global-key-bindings)

Key bindings can be passed to the application as follows:

```python
from prompt_toolkit import Application
from prompt_toolkit.key_binding.key_processor import KeyPressEvent

kb = KeyBindings()
app = Application(key_bindings=kb)
app.run()
```

To register a new keyboard shortcut, we can use the `add()` method as
a decorator of the key handler:

```python
from prompt_toolkit import Application
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.key_binding.key_processor import KeyPressEvent

kb = KeyBindings()

@kb.add('c-q')
def exit_(event: KeyPressEvent) -> None:
    """
    Pressing Ctrl-Q will exit the user interface.

    Setting a return value means: quit the event loop that drives the user
    interface and return this value from the `Application.run()` call.
    """
    event.app.exit()

app = Application(key_bindings=kb, full_screen=True)
app.run()
```

[Here](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/key_bindings.html#key-bindings)
you can read for more complex patterns with key bindings.

A more programmatically way to add bindings is:

```python
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.key_binding.bindings.focus import focus_next

kb = KeyBindings()
kb.add("tab")(focus_next)
```

## [Styles](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/styling.html#)

Many user interface controls, like `Window` accept a style argument which can be
used to pass the formatting as a string. For instance, we can select
a foreground color:

* `fg:ansired`: ANSI color palette
* `fg:ansiblue`: ANSI color palette
* `fg:#ffaa33`: hexadecimal notation
* `fg:darkred`: named color

Or a background color:

* `bg:ansired`: ANSI color palette
* `bg:#ffaa33`: hexadecimal notation

Like we do for web design, it is not a good habit to specify all styling inline.
Instead, we can attach [class names to UI
controls](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/styling.html#class-names)
and have a style sheet that refers to these class names. The Style can be passed
as an argument to the `Application`.

```python
from prompt_toolkit.layout import VSplit, Window
from prompt_toolkit.styles import Style

layout = VSplit([
    Window(BufferControl(...), style='class:left'),
    HSplit([
        Window(BufferControl(...), style='class:top'),
        Window(BufferControl(...), style='class:bottom'),
    ], style='class:right')
])

style = Style([
     ('left', 'bg:ansired'),
     ('top', 'fg:#00aaaa'),
     ('bottom', 'underline bold'),
 ])
```

You may need to define the 24bit [color
depths](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/styling.html#color-depths)
to see the colors you expect:

```python
from prompt_toolkit.output.color_depth import ColorDepth

app = Application(
    color_depth=ColorDepth.DEPTH_24_BIT,
    # ...
)
```

### Dynamically changing the style

You'll need to create a widget, you can take as inspiration the package
[widgets](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/widgets/base.py).

To create a row that changes color when it's focused use:

```python
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.layout.containers import Window
from prompt_toolkit.application import get_app

class Row:
    """Define row.

    Args:
        text: text to print
    """

    def __init__(
        self,
        text: str,
    ) -> None:
        """Initialize the widget."""
        self.text = text
        self.control = FormattedTextControl(
            self.text,
            focusable=True,
        )

        def get_style() -> str:
            if get_app().layout.has_focus(self):
                return "class:row.focused"
            else:
                return "class:row"

        self.window = Window(
            self.control, height=1, style=get_style, always_hide_cursor=True
        )

    def __pt_container__(self) -> Window:
        """Return the window object.

        Mandatory to be considered a widget.
        """
        return self.window
```

An example of use would be:

```python
layout = HSplit(
    [
        Row("Test1"),
        Row("Test2"),
        Row("Test3"),
    ]
)

# Key bindings

kb = KeyBindings()

kb.add("j")(focus_next)
kb.add("k")(focus_previous)


@kb.add("c-c", eager=True)
@kb.add("q", eager=True)
def exit_(event: KeyPressEvent) -> None:
    """Exit the user interface."""
    event.app.exit()


# Styles

style = Style(
    [
        ("row", "bg:#073642 #657b83"),
        ("row.focused", "bg:#002b36 #657b83"),
    ]
)

# Application

app = Application(
    layout=Layout(layout),
    full_screen=True,
    key_bindings=kb,
    style=style,
    color_depth=ColorDepth.DEPTH_24_BIT,
)

app.run()
```




## Examples

The best way to understand how it works is by running the
[examples](https://github.com/prompt-toolkit/python-prompt-toolkit/tree/master/examples/full-screen)
in the repository, some interesting ones in increasing order of difficult are:

* [Managing
    autocompletion](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/autocompletion.py)
* [Managing
    focus](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/focus.py)
* [Managing
    floats](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/floats.py),
    and [floats with
    transparency](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/float-transparency.py)
* [Add
    margins](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/margins.py),
    such as line number or a scroll bar.
* [Managing
    styles](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/buttons.py).
* [Wrapping lines in
    buffercontrol, and line prefixes](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/simple-demos/line-prefixes.py)
* [A working REPL
    example](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/calculator.py).
    Interesting to see the `SearchToolbar` in use (press `Ctrl+r`), and how to
    interact with other windows with handlers.
* [A working
    editor](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/examples/full-screen/text-editor.py):
    Complex application that shows how to build a working menu.
* [pyvim](https://github.com/prompt-toolkit/pyvim): A rewrite of vim in python,
    it shows how to test, handle commands and a lot more, very interesting.
* [pymux](https://github.com/prompt-toolkit/pymux): Another full screen
    application example.

# References

* [Docs](https://python-prompt-toolkit.readthedocs.io/en/master/)
* [Git](https://github.com/prompt-toolkit/python-prompt-toolkit)
* [Projects using prompt_toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/PROJECTS.rst)
