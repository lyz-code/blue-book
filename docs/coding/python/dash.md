---
title: Dash
date: 20201107
author: Lyz
---

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

# References

* [Docs](https://dash.plotly.com/)
* [Gallery](https://dash-gallery.plotly.host/Portal)
* [Introduction video](https://www.youtube.com/watch?v=5BAthiN0htc)
