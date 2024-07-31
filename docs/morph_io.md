[morph.io](https://morph.io/) is a web service that runs your scrapers for you.

Write your scraper in the language you know and love, push your code to GitHub, and they take care of the boring bits. Things like running your scraper regularly, alerting you if there's a problem, storing your data, and making your data available for download or through a super-simple API.

To sign in you'll need a GitHub account. This is where your scraper code is stored.

The data is stored in an sqlite


# Usage limits

Right now there are very few limits. They are trusting you that you won't abuse this.

However, they do impose a couple of hard limits on running scrapers so they don't take up too many resources

- max 512 MB memory
- max 24 hours run time for a single run

If a scraper runs out of memory or runs too long it will get killed automatically.

There's also a soft limit:

- max 10,000 lines of log output

If a scraper generates more than 10,000 lines of log output the scraper will continue running uninterrupted. You just won't see any more output than that. To avoid this happening simply print less stuff to the screen.

Note that they are keeping track of the amount of cpu time (and a whole bunch of other metrics) that you and your scrapers are using. So, if they do find that you are using too much they reserve the right to kick you out. In reality first they'll ask you nicely to stop.
# References
- [Docs](https://morph.io/documentation)
- [Home](https://morph.io/)
