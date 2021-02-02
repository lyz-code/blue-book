---
title: questionary
date: 20210130
author: Lyz
---

[questionary](https://questionary.readthedocs.io) is a Python library for
effortlessly building pretty command line interfaces. It makes it very easy to
query your user for input.

![ ](questionary.gif)

## [Installation](https://questionary.readthedocs.io/en/stable/pages/installation.html)

```bash
pip install questionary
```

## [Usage](https://questionary.readthedocs.io/en/stable/pages/quickstart.html)

### [Asking a single question](https://questionary.readthedocs.io/en/stable/pages/quickstart.html#asking-a-single-question)

Questionary ships with a lot of different [Question Types](#question-types) to
provide the right prompt for the right question. All of them work in the same
way though.

```python
import questionary

answer = questionary.text("What's your first name").ask()
```

Since our question is a text prompt, answer will contain the text the user typed
after they submitted it.

### [Asking Multiple Questions](https://questionary.readthedocs.io/en/stable/pages/quickstart.html#asking-multiple-questions)

You can use the `form()` function to ask a collection of `Questions`. The
questions will be asked in the order they are passed to `questionary.form`.

```python
import questionary

answers = questionary.form(
    first = questionary.confirm("Would you like the next question?", default=True),
    second = questionary.select("Select item", choices=["item1", "item2", "item3"])
).ask()
```

The output will have the following format:

```json
{'first': True, 'second': 'item2'}
```

The `prompt()` function also allows you to ask a collection of questions,
however instead of taking Question instances, it takes a dictionary:

```python
import questionary

questions = [
  {
    "type": "confirm",
    "name": "first",
    "message": "Would you like the next question?",
    "default": True,
  },
  {
    "type": "select",
    "name": "second",
    "message": "Select item",
    "choices": ["item1", "item2", "item3"],
  },
]

questionary.prompt(questions)
```

## [Question types](https://questionary.readthedocs.io/en/stable/pages/types.html)


The different question types are meant to cover different use cases. The
parameters and configuration options are explained in detail for each type. But
before we get into to many details, here is a cheatsheet with the available
question types:

* Use [`Text`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-text) to ask for free text input.
* Use
    [`Password`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-password)
    to ask for free text where the text is hidden.
* Use [`File
    Path`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-path)
    to ask for a file or directory path with autocompletion.
* Use
    [`Confirmation`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-confirm)
    to ask a yes or no question.
* Use
    [`Select`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-select)
    to ask the user to select one item from a beautiful list.
* Use
    [`Raw
    Select`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-raw-select)
    to ask the user to select one item from a list.
* Use
    [`Checkbox`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-checkbox)
    to ask the user to select any number of items from a list.
* Use
    [`Autocomplete`](https://questionary.readthedocs.io/en/stable/pages/types.html#type-autocomplete)
    to ask for free text with autocomplete help.

Check the [examples](https://github.com/tmbo/questionary/examples) to see them
in action and how to use them.

# Testing

To test questionary code, follow the guidelines of [testing
prompt_toolkit](prompt_toolkit.md#testing).

# References

* [Docs](https://questionary.readthedocs.io)
* [Git](https://github.com/tmbo/questionary)
