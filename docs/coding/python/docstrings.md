---
title: Docstrings
date: 20201022
author: Lyz
---


Docstrings are strings that define the purpose and use of a module, class, function or
method. They are accessible from the doc attribute `__doc__` and with the
built-in `help()` function.

!!! note ""

    Documenting your code is very important as it's *more often read than written*.

# [Documenting vs commenting](https://realpython.com/documenting-python-code/#commenting-vs-documenting-code)

Commenting is describing your code to/for developers. The intended audience is
the maintainers and developers of the Python code. In conjuction with
well-written code, comments help to guide the reader to better understand your
code and its purpose and design.

Documenting is describing its use and functionality to your users. While it may
be helpful in the development process, the main intended audience are the users.

# Docstring format

Docstrings should use the triple-double quote (`"""`) string format. This should
be done whether the docstring is multi-lined or not. At a bare minimum,
a docstring should be a quick summary of whatever is it you’re describing and
should be contained within a single line.

Multi-lined docstrings are used to further elaborate on the object beyond the
summary. All multi-lined docstrings have the following parts:

* A one-line summary line
* A blank line proceeding the summary
* Any further elaboration for the docstring
* Another blank line

To ensure your docstrings follow these practices, configure
[flakeheaven](flakeheaven.md) with the `flake8-docstrings` extension.

# Docstring types

## [Class docstrings](https://realpython.com/documenting-python-code/#class-docstrings)

Class Docstrings are created for the class itself, as well as any class methods.
The docstrings are placed immediately following the class or class method
indented by one level:

class SimpleClass:
    """Class docstrings go here."""

    def say_hello(self, name: str):
        """Class method docstrings go here."""
        print(f'Hello {name}')

Class docstrings should contain the following information:

* A brief summary of its purpose and behavior
* Any public methods, along with a brief description
* Any class properties (attributes)
* Anything related to the interface for subclassers, if the class is intended to
    be subclassed

The class constructor parameters should be documented within the __init__ class
method docstring. Individual methods should be documented using their individual
docstrings. Class method docstrings should contain the following:

* A brief description of what the method is and what it’s used for
* Any arguments (both required and optional) that are passed including keyword arguments
* Label any arguments that are considered optional or have a default value
* Any side effects that occur when executing the method
* Any exceptions that are raised
* Any restrictions on when the method can be called

## [Package and module docstrings](https://realpython.com/documenting-python-code/#package-and-module-docstrings)

Package docstrings should be placed at the top of the package’s `__init__.py`
file. This docstring should list the modules and sub-packages that are exported
by the package.

Module docstrings should include the following:

* A brief description of the module and its purpose
* A list of any classes, exception, functions, and any other objects exported by
    the module. Only needed if they are not defined in the same file, otherwise
    `help()` will get them automatically.

The docstring for a module function should include the same items as a class
method.

## [Docstring formats](https://realpython.com/documenting-python-code/#docstring-formats)

* [Google
    docstrings](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods):
    the most user friendly.
* [reStructured Text](http://docutils.sourceforge.net/rst.html): The official
    ones, but super ugly to write.
* [Numpy docstrings](https://numpydoc.readthedocs.io/en/latest/format.html).

### [Google Docstrings](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods)

Napoleon gathered a nice [cheatsheet with
examples](https://sphinxcontrib-napoleon.readthedocs.io/en/latest/example_google.html#example-google).

#### [Functions and methods](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods)

A method that overrides a method from a base class may have a simple docstring
sending the reader to its overridden method’s docstring, such as `"""See base
class."""`. The rationale is that there is no need to repeat in many places
documentation that is already present in the base method’s docstring. However,
if the overriding method’s behavior is substantially different from the
overridden method, or details need to be provided (e.g., documenting additional
side effects), a docstring with at least those differences is required on the
overriding method.

Certain aspects of a function should be documented in special sections, listed
below. Each section begins with a heading line, which ends with a colon. All
sections other than the heading should maintain a hanging indent of two or four
spaces (be consistent within a file). These sections can be omitted in cases
where the function’s name and signature are informative enough that it can be
aptly described using a one-line docstring.

Args
: List each parameter by name. A description should follow the name, and be
    separated by a colon followed by either a space or newline. If the
    description is too long to fit on a single 80-character line, use a hanging
    indent of 2 or 4 spaces more than the parameter name (be consistent with the
    rest of the docstrings in the file). The description should include required
    type(s) if the code does not contain a corresponding type annotation. If
    a function accepts `*foo` (variable length argument lists) and/or `**bar`
    (arbitrary keyword arguments), they should be listed as `*foo` and `**bar`.
Returns (or Yields: for generators)
:  Describe the type and semantics of the return value. If the function only
    returns None, this section is not required. It may also be omitted if the
    docstring starts with Returns or Yields (e.g. `"""Returns row from API as
    a tuple of strings."""`) and the opening sentence is sufficient to describe
    return value.

Raises
: List all exceptions that are relevant to the interface followed by
    a description. Use a similar exception name + colon + space or newline and
    hanging indent style as described in Args:. You should not document
    exceptions that get raised if the API specified in the docstring is violated
    (because this would paradoxically make behavior under violation of the API
    part of the API).

# Tests docstrings

## Without template

[jml has very good tips on writing test's
docstrings](https://jml.io/pages/test-docstrings.html):

If you’re struggling to write docstrings for your tests, here’s a handy five-step guide:

* Write the first docstring that comes to mind. It will almost certainly be:

    ```python
    """Test that input is parsed correctly."""
    ```

* Get rid of “Test that” or “Check that”. We know it’s a test.

    ```python
    """Input should be parsed correctly."""
    ```

* Seriously?! Why’d you have to go and add “should”? It’s a test, it’s all about “should”.

    ```python
    """Input is parsed correctly."""
    ```

* “Correctly”, “properly”, and “as we expect” are all redundant. Axe them too.

    ```python
    """Input is parsed."""
    ```

* Look at what’s left. Is it saying anything at all? If so, great. If not,
    consider adding something specific about the test behaviour and perhaps even
    why it’s desirable behaviour to have.

    ```python
    """
    Input is parsed into an immutable dict according to the config
    schema, so we get config info without worrying about input
    validation all the time.
    """
    ```

## [Given When Then](https://martinfowler.com/bliki/GivenWhenThen.html)

Given-When-Then is a style of representing test. It's an approach developed as
part of Behavior-Driven Development (BDD).  It appears as a structuring approach
for many testing frameworks such as Cucumber. You can also look at it as
a reformulation of the Four-Phase Test pattern.

The essential idea is to break down writing a scenario (or test) into three
sections:

* The *given* part describes the state of the world before you begin the
    behavior you're specifying in this scenario. You can think of it as the
    pre-conditions to the test.
* The *when* section is that behavior that you're specifying.
* Finally the *then* section describes the changes you expect due to the
    specified behavior.

I already implement this test structure with the [Arrange, Act,
Assert](https://xp123.com/articles/3a-arrange-act-assert/) structure, so it made
sense to use it in the docstring too. The side effects is that you repeat a lot
of prose where a single line would suffice.

# Automatic documentation generation

Use the [mkdocstrings](mkdocstrings.md) plugin to automatically generate the
documentation.

# References

* [Real Python post on docstrings by James Mertz](https://realpython.com/documenting-python-code/)
