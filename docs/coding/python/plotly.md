---
title: plotly
date: 20200617
author: Lyz
---

[Plotly](https://plotly.com/python/) is a Python graphing library that makes
interactive, publication-quality graphs.

# Install

```bash
pip3 install plotly
```

Import

```python
import plotly.graph_objects as go
```

# Snippets

## [Select graph source using dropdown](https://stackoverflow.com/questions/46410738/plotly-how-to-select-graph-source-using-dropdown)

```python
# imports
import plotly.graph_objects as go
import numpy as np

# data
x = list(np.linspace(-np.pi, np.pi, 100))
values_1 = list(np.sin(x))
values_1b = [elem*-1 for elem in values_1]
values_2 = list(np.tan(x))
values_2b = [elem*-1 for elem in values_2]

# plotly setup]
fig = go.Figure()

# Add one ore more traces
fig.add_traces(go.Scatter(x=x, y=values_1))
fig.add_traces(go.Scatter(x=x, y=values_1b))

# construct menus
updatemenus = [{'buttons': [{'method': 'update',
                             'label': 'Val 1',
                             'args': [{'y': [values_1, values_1b]},]
                              },
                            {'method': 'update',
                             'label': 'Val 2',
                             'args': [{'y': [values_2, values_2b]},]}],
                'direction': 'down',
                'showactive': True,}]

# update layout with buttons, and show the figure
fig.update_layout(updatemenus=updatemenus)
fig.show()
```

# References

* [Homepage](https://plotly.com/python/)
* [Git](https://github.com/plotly/plotly.py)
