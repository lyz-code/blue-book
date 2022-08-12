---
title: Dash
date: 20201107
author: Lyz
---

!!! note
        "Use [Streamlit](https://docs.streamlit.io/) instead!"

[Dash](https://dash.plotly.com/) is a productive Python framework for building
web analytic applications.

Written on top of Flask, Plotly.js, and React.js, Dash is ideal for building
data visualization apps with highly custom user interfaces in pure Python. It's
particularly suited for anyone who works with data in Python.

# [Install](https://dash.plotly.com/installation)

```bash
pip install dash
```

# [Layout](https://dash.plotly.com/layout)

Dash apps are composed of two parts. The first part is the "layout" of the app
and it describes what the application looks like. The second part describes the
interactivity of the application.

Dash provides Python classes for all of the visual components of the
application. They maintain a set of components in the `dash_core_components` and
the `dash_html_components` library but you can also [build your
own](https://github.com/plotly/dash-component-boilerplate) with JavaScript and
React.js.

The scripts are meant to be run with `python app.py`

!!! note "File: app.py"
    ```python
    import dash
    import dash_core_components as dcc
    import dash_html_components as html
    import plotly.express as px
    import pandas as pd

    external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

    app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

    # assume you have a "long-form" data frame
    # see https://plotly.com/python/px-arguments/ for more options
    df = pd.DataFrame({
        "Fruit": ["Apples", "Oranges", "Bananas", "Apples", "Oranges", "Bananas"],
        "Amount": [4, 1, 2, 2, 4, 5],
        "City": ["SF", "SF", "SF", "Montreal", "Montreal", "Montreal"]
    })

    fig = px.bar(df, x="Fruit", y="Amount", color="City", barmode="group")

    app.layout = html.Div(children=[
        html.H1(children='Hello Dash'),

        html.Div(children='''
            Dash: A web application framework for Python.
        '''),

        dcc.Graph(
            id='example-graph',
            figure=fig
        )
    ])

    if __name__ == '__main__':
        app.run_server(debug=True)
    ```

# [Testing](https://dash.plotly.com/testing)

`dash.testing` provides some off-the-rack pytest fixtures and a minimal set of
testing APIs with our internal crafted best practices at the integration level.

After `pip install dash[testing]`, the Dash pytest fixtures are available, you
just need to install the WebDrivers, check the [Selenium](selenium.md) article
if you need help.

Dash integration tests are meant to be used with Chrome WebDriver, but the
fixture allows you to choose another browser from the command line, e.g. `pytest
--webdriver Firefox -k bsly001`.

Headless mode can be used with the `--headless` flag.

## Simple test

A simple test would be:

```python
import dash
import dash_html_components as html
from dash.testing.composite import DashComposite

def test_bsly001_falsy_child(dash_duo: DashComposite) -> None:
    app = dash.Dash(__name__)
    app.layout = html.Div(id="nully-wrapper", children=0)
    # Host the app locally in a thread, all dash server configs could be
    # passed after the first app argument
    dash_duo.start_server(app)
    # Use wait_for_* if your target element is the result of a callback,
    # keep in mind even the initial rendering can trigger callbacks
    dash_duo.wait_for_text_to_equal("#nully-wrapper", "0", timeout=4)

    # Use this form if its present is expected at the action point
    assert dash_duo.find_element("#nully-wrapper").text == "0"
    # To make the checkpoint more readable, you can describe the
    # acceptance criteria as an assert message after the comma.
    assert dash_duo.get_logs() == [], "browser console should contain no error"
    # You can use visual testing with percy snapshot
    dash_duo.percy_snapshot("bsly001-layout")
```

## Basic usage

The default fixture for Dash Python integration tests is `dash_duo`. It contains
a `thread_server` and a WebDriver wrapped with high-level Dash testing APIs, but
there are [others](https://dash.plotly.com/testing#fixtures).

The Selenium WebDriver is exposed via the `driver` property. One of the core
components of selenium testing is finding the web element with a `locator`, and
performing some actions like `click` or `send_keys` on it, and waiting to verify if
the expected state is met after those actions.

There are several strategies to locate elements: CSS selector and XPATH are the
two most versatile ways. We recommend using the CSS Selector in most cases due
to its better performance and robustness across browsers.

The [Selenium WebDriver provides two types of waits](https://selenium-python.readthedocs.io/waits.html):

* *explicit wait*: Makes WebDriver wait for a certain condition to occur before
    proceeding further with execution.
* *implicit wait*: Makes WebDriver poll the DOM for a certain amount of time
    when trying to locate an element. We set a global two-second timeout at the
    driver level.

Check the Dash documentation for more
[Browser](https://dash.plotly.com/testing#browser-apis) and
[Dash](https://dash.plotly.com/testing#dash-apis) testing methods.

# References

* [Docs](https://dash.plotly.com/)
* [Gallery](https://dash-gallery.plotly.host/Portal)
* [Introduction video](https://www.youtube.com/watch?v=5BAthiN0htc)
