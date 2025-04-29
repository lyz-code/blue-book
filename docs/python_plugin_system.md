---
title: Python plugin system
date: 20210413
author: Lyz
---

When building Python applications, it's good to develop the core of your
program, and allow extension via plugins.

Since [python 3.8 this is native thanks to entry points for plugins!](https://setuptools.pypa.io/en/latest/userguide/entry_point.html#entry-points-for-plugins)

Let us consider a simple example to understand how we can implement entry points corresponding to plugins. Say we have a package `timmins` with the following directory structure:

```
timmins
├── pyproject.toml        # and/or setup.cfg, setup.py
└── src
    └── timmins
        └── __init__.py
```

and in `src/timmins/__init__.py` we have the following code:

```python
def display(text):
    print(text)

def hello_world():
    display('Hello world')
```

Here, the `display()` function controls the style of printing the text, and the `hello_world()` function calls the `display()` function to print the text `Hello world`.

Now, let us say we want to print the text `Hello world` in different ways. Say we want another style in which the text is enclosed within exclamation marks:

```
!!! Hello world !!!
```

Right now the `display()` function just prints the text as it is. In order to be able to customize it, we can do the following. Let us introduce a new group of entry points named `timmins.display`, and expect plugin packages implementing this entry point to supply a `display()`-like function. Next, to be able to automatically discover plugin packages that implement this entry point, we can use the `importlib.metadata` module, as follows:

```python
from importlib.metadata import entry_points
display_eps = entry_points(group='timmins.display')
```

Note: Each `importlib.metadata.EntryPoint` object is an object containing a `name`, a `group`, and a `value`. For example, after setting up the plugin package as described below, `display_eps` in the above code will look like this:

```python
(
EntryPoint(name='excl', value='timmins_plugin_fancy:excl_display', group='timmins.display'),
...,
)
```

`display_eps` will now be a list of `EntryPoint` objects, each referring to `display()`-like functions defined by one or more installed plugin packages. Then, to import a specific `display()`-like function - let us choose the one corresponding to the first discovered entry point - we can use the `load()` method as follows:

```python
display = display_eps[0].load()
```

Finally, a sensible behaviour would be that if we cannot find any plugin packages customizing the `display()` function, we should fall back to our default implementation which prints the text as it is. With this behaviour included, the code in `src/timmins/**init**.py` finally becomes:

```python
from importlib.metadata import entry_points
display_eps = entry_points(group='timmins.display')
try:
    display = display_eps[0].load()
except IndexError:
    def display(text):
        print(text)

def hello_world():
    display('Hello world')
```

That finishes the setup on timmins’s side. Next, we need to implement a plugin which implements the entry point `timmins.display`. Let us name this plugin timmins-plugin-fancy, and set it up with the following directory structure:

```
timmins-plugin-fancy
├── pyproject.toml # and/or setup.cfg, setup.py
└── src
    └── timmins_plugin_fancy
        └── __init__.py
```

And then, inside `src/timmins_plugin_fancy/**init**.py`, we can put a function named `excl_display()` that prints the given text surrounded by exclamation marks:

```python
def excl_display(text):
    print('!!!', text, '!!!')
```

This is the `display()`-like function that we are looking to supply to the timmins package. We can do that by adding the following in the configuration of `timmins-plugin-fancy`:
`pyproject.toml`

```toml
# Note the quotes around timmins.display in order to escape the dot .

[project.entry-points."timmins.display"]
excl = "timmins_plugin_fancy:excl_display"
```

Basically, this configuration states that we are a supplying an entry point under the group `timmins.display`. The entry point is named excl and it refers to the function `excl_display` defined by the package `timmins-plugin-fancy`.

Now, if we install both `timmins` and `timmins-plugin-fancy`, we should get the following:

```python
>>> from timmins import hello_world

>>> hello_world()
!!! Hello world !!!
```

whereas if we only install `timmins` and not `timmins-plugin-fancy`, we should get the following:

```python
>>> from timmins import hello_world

>>> hello_world()
Hello world
```

Therefore, our plugin works.

Our plugin could have also defined multiple entry points under the group `timmins.display`. For example, in `src/timmins_plugin_fancy/**init**.py` we could have two `display()`-like functions, as follows:

```python
def excl_display(text):
    print('!!!', text, '!!!')

def lined_display(text):
    print(''.join(['-' for * in text]))
    print(text)
    print(''.join(['-' for _ in text]))
```

The configuration of `timmins-plugin-fancy` would then change to:

```toml
[project.entry-points."timmins.display"]
excl = "timmins_plugin_fancy:excl_display"
lined = "timmins_plugin_fancy:lined_display"
```

On the `timmins` side, we can also use a different strategy of loading entry points. For example, we can search for a specific display style:

```python
display_eps = entry_points(group='timmins.display')
try:
    display = display_eps['lined'].load()
except KeyError: # if the 'lined' display is not available, use something else
    ...
```

Or we can also load all plugins under the given group. Though this might not be of much use in our current example, there are several scenarios in which this is useful:

```python
display_eps = entry_points(group='timmins.display')
for ep in display_eps:
    display = ep.load() # do something with display
    ...
```

Another point is that in this particular example, we have used plugins to customize the behaviour of a function (`display()`). In general, we can use entry points to enable plugins to not only customize the behaviour of functions, but also of entire classes and modules.

In summary, entry points allow a package to open its functionalities for customization via plugins. The package soliciting the entry points need not have any dependency or prior knowledge about the plugins implementing the entry points, and downstream users are able to compose functionality by pulling together plugins implementing the entry points.
