
To analyze which hiking routes are available in a zone I'm following the next process

- [ ] Check in my `trips` orgmode directory to see if the zone has already been indexed.
- [ ] Do a first search of routes
  - [ ] Identify which books or magazines describe the zone
  - [ ] For each of the described routes in each of these books:
    - [ ] Create the `Routes` section with tag `:route:` if it doesn't exist
    - [ ] Fill up the route form in a `TODO` heading. Something similar to:
      ~~~
      Reference: Book Page
      Source: Where does it start
      Distance: X km
      Slope: X m 
      Type: [Lineal/Circular/Semi-lineal]
      Difficulty:
      Track: URL (only if you don't have to search for it)
      ~~~
    - [ ] Add tags of the people I'd like to do it with
    - [ ] Put a postit on the book/magazine if it's likely I'm going to do it
    - [ ] Open a web maps tab with the source of the route to calculate the time from the different lodgins
  - [ ] If there are not enough, repeat the process above for each of your online route reference blogs

- [ ] Choose the routes to do
  - [ ] Show the gathered routes to the people you want to go with
  - [ ] Select which ones you'll be more likely to do

- [ ] For each of the chosen routes
  - [ ] Search the track in wikiloc if it's missing
  - [ ] Import the track in [OsmAnd+](osmand.md)
