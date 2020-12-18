---
title: mkdocstrings
date: 20201022
author: Lyz
---

[mkdocstrings](https://pawamoy.github.io/mkdocstrings) is a library to
automatically generate [mkdocs](mkdocs.md) pages from the code docstrings.

# Install

```bash
pip install mkdocstrings
```

Activate the plugin by adding it to the plugin section in the `mkdocs.yml`
configuration file:

```yaml
plugins:
  - mkdocstrings
```

# [Usage](https://pawamoy.github.io/mkdocstrings/usage/)

MkDocstrings works by processing special expressions in your Markdown files.

The syntax is as follow:

~~~markdown
::: identifier
    YAML block
~~~


The `identifier` is a string identifying the object you want to document.
The format of an identifier can vary from one handler to another.
For example, the Python handler expects the full dotted-path to a Python object:
`my_package.my_module.MyClass.my_method`.

The YAML block is optional, and contains some configuration options:

* `handler`: the name of the handler to use to collect and render this object.
* `selection`: a dictionary of options passed to the handler's collector.
  The collector is responsible for collecting the documentation from the source code.
  Therefore, selection options change how the documentation is collected from the source code.
* `rendering`: a dictionary of options passed to the handler's renderer.
  The renderer is responsible for rendering the documentation with Jinja2 templates.
  Therefore, rendering options affect how the selected object's documentation is rendered.


!!! example "Example with the Python handler"
    === "docs/my_page.md"
        ```md
        # Documentation for `MyClass`

        ::: my_package.my_module.MyClass
            handler: python
            selection:
              members:
                - method_a
                - method_b
            rendering:
              show_root_heading: false
              show_source: false
        ```

    === "mkdocs.yml"
        ```yaml
        nav:
          - "My page": my_page.md
        ```

    === "src/my_package/my_module.py"
        ```python
        class MyClass:
            """Print print print!"""

            def method_a(self):
                """Print A!"""
                print("A!")

            def method_b(self):
                """Print B!"""
                print("B!")

            def method_c(self):
                """Print C!"""
                print("C!")
        ```

    === "Result"
        <h3 id="documentation-for-myclass" style="margin: 0;">Documentation for <code>MyClass</code></h3>
        <div><div><p>Print print print!</p><div><div>
        <h4 id="mkdocstrings.my_module.MyClass.method_a">
        <code class="highlight language-python">
        method_a<span class="p">(</span><span class="bp">self</span><span class="p">)</span> </code>
        </h4><div>
        <p>Print A!</p></div></div><div><h4 id="mkdocstrings.my_module.MyClass.method_b">
        <code class="highlight language-python">
        method_b<span class="p">(</span><span class="bp">self</span><span class="p">)</span> </code>
        </h4><div><p>Print B!</p></div></div></div></div></div>

## [Reference the objects in the documentation](https://pawamoy.github.io/mkdocstrings/usage/#cross-references)

~~~markdown
With a custom title:
[`Object 1`][full.path.object1]

With the identifier as title:
[full.path.object2][]
~~~


# Global options

MkDocstrings accept a few top-level configuration options in `mkdocs.yml`:

- `watch`: a list of directories to watch while serving the documentation. So if
    any file is changed in those directories, the documentation is rebuilt.
- `default_handler`: the handler that is used by default when no handler is specified.
- `custom_templates`: the path to a directory containing custom templates.
  The path is relative to the docs directory.
  See [Customization](https://pawamoy.github.io/mkdocstrings/usage/#customization).
- `handlers`: the handlers global configuration.

Example:

```yaml
plugins:
- mkdocstrings:
    default_handler: python
    handlers:
      python:
        rendering:
          show_source: false
    custom_templates: templates
    watch:
      - src/my_package
```

The handlers global configuration can then be overridden by local configurations:

```yaml
::: my_package.my_module.MyClass
    rendering:
      show_source: true
```

Check the  [Python handler
options](https://pawamoy.github.io/mkdocstrings/handlers/python/) for more
details.

# References

* [Docs](https://pawamoy.github.io/mkdocstrings)
