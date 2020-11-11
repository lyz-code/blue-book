---
title: Folium
date: 20200710
author: Lyz
---

[folium](https://python-visualization.github.io/folium/index.html) makes it easy
to visualize data that’s been manipulated in Python on an interactive leaflet
map. It enables both the binding of data to a map for choropleth visualizations
as well as passing rich vector/raster/HTML visualizations as markers on the
map.

The library has a number of built-in tilesets from OpenStreetMap, Mapbox, and
Stamen, and supports custom tilesets with Mapbox or Cloudmade API keys. folium
supports both Image, Video, GeoJSON and TopoJSON overlays.

!!! warning "Use [dash-leaflet](dash_leaflet.md) if you want to do complex stuff."
    If you want to do multiple filters on the plotted data or connect the map
    with other graphics, use dash-leaflet instead.

# Install

Although you can install it with `pip install folium` their release pace is
slow, therefore I recommend pulling it directly from `master`

```bash
pip install git+https://github.com/python-visualization/folium.git@master
```

It's a heavy repo, so it might take some time.

# Usage

Use the following snippet to create an empty map centered in Spain

```python
import folium

m = folium.Map(
    location=[40.0884, -3.68042],
    zoom_start=7,
)

# Map configuration goes here

m.save("map.html")
```

From now on, those lines are going to be assumed, and all the snippets are
supposed to go in between the definition and the save.

If you need to center the map elsewhere, I suggest that you configure the map to
show the coordinates of the mouse with

```python
from folium.plugins import MousePosition

MousePosition().add_to(m)
```

## Change tileset

Folium
[Map](https://python-visualization.github.io/folium/modules.html#folium.folium.Map)
object supports different tiles by default. It also supports any WMS or WMTS by
passing a Leaflet-style URL to the tiles parameter:
`http://{s}.yourtiles.com/{z}/{x}/{y}.png`.

To use the [IGN](https://www.ign.es/) beautiful map as a fallback and the
OpenStreetMaps as default use the following snippet:

```python
m = folium.Map(
    location=[40.0884, -3.68042],
    zoom_start=7,
    tiles=None,
)
folium.raster_layers.TileLayer(
    name="OpenStreetMaps",
    tiles="OpenStreetMap",
    attr="OpenStreetMaps",
).add_to(m)


folium.raster_layers.TileLayer(
    name="IGN",
    tiles="https://www.ign.es/wmts/mapa-raster?request=getTile&layer=MTN&TileMatrixSet=GoogleMapsCompatible&TileMatrix={z}&TileCol={x}&TileRow={y}&format=image/jpeg",
    attr="IGN",
).add_to(m)

folium.LayerControl().add_to(m)
```

We need to set the `tiles=None` in the Map definition so both are shown in the
LayerControl menu.

## Loading the data

### Using geojson

```python
folium.GeoJson("my_map.geojson", name="geojson").add_to(m)
```

If you don't want the data to be embedded in the html use `embed=False`, this
can be handy if you don't want to redeploy the web application on each change of
data. You'll need to supply a valid url to the data file.

The downside (as of today) of using geojson is that you [can't have different
markers for the
data](https://github.com/python-visualization/folium/issues/1059). The solution
is to load it and iterate over the elements. See the issue for more information.

### Using gpx

Another popular data format is gpx, which is the one that
[OsmAnd](https://osmand.net/) uses. To import it we'll use the
[gpxpy](https://github.com/tkrajina/gpxpy) library.

```python
import gpxpy
import gpxpy.gpx

gpx_file = open('map.gpx', 'r')
gpx = gpxpy.parse(gpx_file)
```

# References

* [Git](https://github.com/python-visualization/folium)
* [Docs](https://python-visualization.github.io/folium/index.html)
* [Quickstart](https://python-visualization.github.io/folium/quickstart.html)
* [Examples](https://nbviewer.jupyter.org/github/python-visualization/folium/tree/master/examples/),
    [more examples](https://nbviewer.jupyter.org/github/python-visualization/folium_contrib/tree/master/notebooks/)

## Use examples

* [Flask example](https://github.com/python-visualization/folium/blob/master/examples/flask_example.py)
* [Build Interactive GPS activity maps from GPX files](https://towardsdatascience.com/build-interactive-gps-activity-maps-from-gpx-files-using-folium-cf9eebba1fe7)
* [Use Open Data to build interactive maps](https://walkenho.github.io/beergarden-happiness-with-python/)

### Search examples

* [Official docs](https://nbviewer.jupyter.org/github/python-visualization/folium/blob/master/examples/plugin-Search.ipynb)
* [Leafleft search control](https://github.com/stefanocudini/leaflet-search)
* [Leafleft search
    examples](https://labs.easyblog.it/maps/leaflet-search/)([source
    code](https://github.com/stefanocudini/leaflet-search/tree/master/examples))
* [Searching in OSM data](https://labs.easyblog.it/maps/leaflet-search/examples/geocoding-nominatim.html)

It seems that it doesn't yet support searching for [multiple attributes in the
geojson data](https://github.com/stefanocudini/leaflet-search/issues/34)
