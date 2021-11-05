---
title: Prompt toolkit full screen applications
date: 20211028
author: Lyz
---

[Prompt toolkit](prompt_toolkit.md) can be used to build [full screen
interfaces](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html).
This section focuses in how to do it. If you want to build REPL applications
instead go to [this other article](prompt_toolkit_repl.md).

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

# [The layout](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#the-layout)

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

## [Conditional Containers](https://python-prompt-toolkit.readthedocs.io/en/master/pages/reference.html?highlight=ConditionalContainer#prompt_toolkit.layout.ConditionalContainer)

Sometimes you only want to show containers when a condition is met,
`ConditionalContainers` are meant to fulfill this case. They accept other
containers, and a `filter` condition.

You can read more about filters
[here](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/filters.html),
the simplest use case is if you have a boolean variable and you use the
`to_filter` function.

```python
from prompt_toolkit.layout import ConditionalContainer
from prompt_toolkit.filters.utils import to_filter

show_header = True
ConditionalContainer(
    Label('This is an optional text'), filter=to_filter(show_header)
)
```

## [Tables](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/305)

Currently they are not supported :(, although there is an [old
PR](https://github.com/prompt-toolkit/python-prompt-toolkit/pull/724).

# Controls

## [Focusing windows](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#focusing-windows)

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

## [Key
bindings](https://python-prompt-toolkit.readthedocs.io/en/master/pages/full_screen_apps.html#key-bindings)

In order to react to user actions, we need to create a `KeyBindings` object and
pass that to our `Application`.

There are two kinds of key bindings:

* [Global key bindings](#global-key-bindings), which are always active.
* Key bindings that belong to a certain `UIControl` and are only active when
    this control is focused. Both `BufferControl` and `FormattedTextControl`
    take a `key_bindings` argument.

For complex keys you can always look at [the `Keys`
class](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/keys.py#L10).

### [Global key
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

### Pass more than one key

To map an action to two key presses use `kb.add('g', 'g')`.


# [Styles](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/styling.html#)

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

If you want to see if a style is being applied in a component, set the style to
`bg:#dc322f` and it will be highlighted in red.

## Dynamically changing the style

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

# Examples

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

# [Testing](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/unit_testing.html)

Prompt toolkit application testing can be done at different levels:

* Component level: Useful to test how a component manages it's data by itself.
* Application level: Useful to test how a user interacts with the component.

If you don't know how to test something, I suggest you check how [prompt
toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit/tree/master/tests)
tests itself. You can also check how do third party packages do their tests too,
such as
[`prompt-toolkit-table`](https://github.com/lyz-code/prompt-toolkit-table/tree/master/tests)
or [`pyvim`](https://github.com/prompt-toolkit/pyvim/tree/master/tests).

Keep in mind that you don't usually want to check the result of the `stdout` or
`stderr` directly, but the state of your component or the application itself.

## Component level

If your component accepts some input and does some magic on that input without
the need to load the application, import the object directly and run tests
changing the input directly and asserting the results of the output.

## Application level

If you want to test the interaction with your component at application level,
for example what happens when a user presses a key, you need to instantiate
a dummy application and play with it.

Imagine we have a `TableControl` component we want to test that accepts some
input in the form of `data`. We'll use the `set_dummy_app` function to configure
an application that outputs to `DummyOutput`, and a helper function
`get_app_and_processor` to return the active app and a `processor` to send key
presses.

```python
def set_dummy_app(data: Any) -> Any:
    """Return a context manager that starts the dummy application.

    This is important, because we need an `Application` with `is_done=False`
    flag, otherwise no keys will be processed.
    """
    app: Application[Any] = Application(
        layout=Layout(Window(TableControl(data))),
        output=DummyOutput(),
        input=create_pipe_input(),
    )

    return set_app(app)


def get_app_and_processor() -> Tuple[Application[Any], KeyProcessor]:
    """Return the active application and it's key processor."""
    app = get_app()
    key_bindings = app.layout.container.get_key_bindings()

    if key_bindings is None:
        key_bindings = KeyBindings()
    processor = KeyProcessor(key_bindings)
    return app, processor
```

We've loaded the `processor` with the key bindings defined in the container. If
you want other bindings change them there. For example
[prompt-toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/tests/test_key_binding.py#L42)
uses a fixture to set them. Remember that you have the `merge_key_bindings` to
join two key binding objects with:

```python
key_bindings = merge_key_bindings([key_bindings, control_bindings])
```

Once the functions are set, you can make your test. Imagine that we want to
check that if the user presses `j`, the variable `_focused_row` is incremented
by 1. This variable will be used by the component internally to change the style
of the rows so that the next element is highlighted.

```python
def test_j_moves_to_the_next_row(self, pydantic_data: PydanticData) -> None:
    """
    Given: A well configured table
    When: j is press
    Then: the focus is moved to the next line
    """
    with set_dummy_app(pydantic_data):
        app, processor = get_app_and_processor()

        processor.feed(KeyPress("j", "j"))  # act

        processor.process_keys()
        assert app.layout.container.content._focused_row == 1
```

# References

* [Docs](https://python-prompt-toolkit.readthedocs.io/en/master/)
* [Git](https://github.com/prompt-toolkit/python-prompt-toolkit)
* [Projects using prompt_toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/PROJECTS.rst)
