---
title: Service Pattern
date: 20200702
author: Lyz
---

The service layer gathers all the *orchestration* functionality such as fetching
stuff out of our repository, validating our input against database state,
handling errors, and commiting in the happy path. Most of these things don't
have anything to do with the view layer (an API or a command line tool), so
they're not really things that need to be tested by end-to-end tests.

## Unconnected thoughts

By combining the service layer with our repository abstraction over the
database, we're able to write fast test, not just of our domain model but of the
entire workflow for a use case.

# References

* [The service layer pattern chapter of the Architecture Patterns with
    Python](https://www.cosmicpython.com/book/chapter_04_service_layer.html) book by
    Harry J.W. Percival and Bob Gregory.
