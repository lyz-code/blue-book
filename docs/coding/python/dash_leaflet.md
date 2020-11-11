---
title: Dash Leaflet
date: 20201107
author: Lyz
---

[Dash Leaflet](https://dash-leaflet.herokuapp.com/) is a wrapper of
[Leaflet](https://leafletjs.com/), the leading open-source JavaScript library
for interactive maps.

# Install

```bash
pip install dash
pip install dash-leaflet
```

# Usage

```python
import dash
import dash_leaflet as dl

app = dash.Dash(__name__)
app.layout = dl.Map(dl.TileLayer(), style={'height': '100vh'})

if __name__ == '__main__':
    app.run_server(port=8050, debug=True)
```
That's it! You have now created your first interactive map with Dash Leaflet. If
you visit http://127.0.0.1:8050/ in your browser.

## Change tileset

Leaflet Map object supports different tiles by default. It also supports any WMS
or WMTS by passing a Leaflet-style URL to the tiles parameter:
`http://{s}.yourtiles.com/{z}/{x}/{y}.png`.

To use the [IGN](https://www.ign.es/) beautiful map as a fallback and the
OpenStreetMaps as default use the following snippet:

```python
app.layout = html.Div(
    dl.Map(
        [
            dl.LayersControl(
                [
                    dl.BaseLayer(
                        dl.TileLayer(),
                        name="OpenStreetMaps",
                        checked=True,
                    ),
                    dl.BaseLayer(
                        dl.TileLayer(
                            url="https://www.ign.es/wmts/mapa-raster?request=getTile&layer=MTN&TileMatrixSet=GoogleMapsCompatible&TileMatrix={z}&TileCol={x}&TileRow={y}&format=image/jpeg",
                            attribution="IGN",
                        ),
                        name="IGN",
                        checked=False,
                    ),
                ],
            ),
            get_data(),
        ],
        zoom=7,
        center=(40.0884, -3.68042),
    ),
    style={
        "height": "100vh",
    },
)
```

## Loading the data

### Using Markers

As with [folium](folium.md), loading different custom markers within the same
geojson object is difficult, therefore we are again forced to use markers with
cluster group.

Assuming we've got a gpx file called `data.gpx`, we can use the following
snippet to load all markers with a custom icon.

```python
import dash_leaflet as dl
import gpxpy

icon = {
    "iconUrl": "https://leafletjs.com/examples/custom-icons/leaf-green.png",
    "shadowUrl": "https://leafletjs.com/examples/custom-icons/leaf-shadow.png",
    "iconSize": [38, 95],  # size of the icon
    "shadowSize": [50, 64],  # size of the shadow
    "iconAnchor": [
        22,
        94,
    ],  # point of the icon which will correspond to marker's location
    "shadowAnchor": [4, 62],  # the same for the shadow
    "popupAnchor": [
        -3,
        -76,
    ],  # point from which the popup should open relative to the iconAnchor
}


def get_data():
    gpx_file = open("data.gpx", "r")
    gpx = gpxpy.parse(gpx_file)
    markers = []
    for waypoint in gpx.waypoints:
        markers.append(
            dl.Marker(
                title=waypoint.name,
                position=(waypoint.latitude, waypoint.longitude),
                icon=icon,
                children=[
                    dl.Tooltip(waypoint.name),
                    dl.Popup(waypoint.name),
                ],
            )
        )
    cluster = dl.MarkerClusterGroup(id="markers", children=markers)
    return cluster


app = dash.Dash(__name__)
app.layout = html.Div(
    dl.Map(
        [
            dl.TileLayer(),
            get_data(),
        ],
        zoom=7,
        center=(40.0884, -3.68042),
    ),
    style={
        "height": "100vh",
    },
)
```

Inside `get_data` you can add further logic to change the icon based on the data
of the gpx.


## Configurations

### [Add custom css or js](https://dash.plotly.com/external-resources)

Including custom CSS or JavaScript in your Dash apps is simple. Just create
a folder named assets in the root of your app directory and include your CSS and
JavaScript files in that folder. Dash will automatically serve all of the files
that are included in this folder.

### [Remove the border around the map](https://community.plotly.com/t/how-to-remove-small-border-around-edge-of-app-layout/7933)

Add a custom css file:

!!! note "File: assets/custom.css"
    ```css
    body {
        margin: 0,
    }
    ```

# References

* [Docs](https://dash-leaflet.herokuapp.com/)
* [Git](https://github.com/thedirtyfew/dash-leaflet)
