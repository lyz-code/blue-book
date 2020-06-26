---
title: Domain Driven Design
date: 20200626
author: Lyz
---

[Domain-driven Design](https://en.wikipedia.org/wiki/Domain-driven_design)(DDD)
is the concept that the structure and language of your code (class names, class
methods, class variables) should match the business domain.

Domain-driven design is predicated on the following goals:

* Placing the project's primary focus on the core domain and domain logic.
* Basing complex designs on a model of the domain.
* Initiating a creative collaboration between technical and domain experts to
    iteratively refine a conceptual model that addresses particular domain
    problems.

It aims to fix these common pitfalls:

* When asked to design a new system, most developers will start to build
a database schema, with the object model treated as an afterthought. Instead,
*behaviour should come first and drive our storage requirements*.

* Business logic comes spread throughout the layers of our application, making
  it hard to identify, understand and change.

* The feared [big ball of
mud](https://en.wikipedia.org/wiki/Big_ball_of_mud).

They are avoided through:

* *Encapsulation an abstraction*: understanding behavior encapsulation as
    identifying a task that needs to be done in our code and giving that task to
    an abstraction, a well defined object or function.

    Encapsulating behavior with abstractions is a powerful tool for hiding
    details and protecting the consistency of our data thus making code
    more expressive, more testable and easier to maintain.

* *Layering*: When one function, module or object uses another, we say that one
    *depends on* the other creating a dependency graph. In the big ball of mud
    the dependencies are out of control, so changing one node becomes difficult
    because it has the potential to affect many other parts of the system.

    Layered architectures are one way of tackling this problem by dividing our
    code into discrete categories or roles, and introducing rules about which
    categories of code can call each other.

    By following the [Dependency Inversion
    Principle](solid.md#dependency-inversion) (the *D* in [SOLID](solid.md)), we
    must ensure that our business code doesn't depend on technical details,
    instead, both should use abstractions. We don't want high-level modules
    ,which respond to business needs, to be slowed down because they are closely
    coupled to low-level infrastructure details, which are often harder to
    change. Similarly, it is important to *be able* to change the infrastructure
    details when we need to without needing to make changes to the business
    layer.

# References

* [Wikipedia article](https://en.wikipedia.org/wiki/Domain-driven_design)
* [Architecture Patterns with
    Python](https://www.cosmicpython.com/book/preface.html) by
    Harry J.W. Percival and Bob Gregory.

# Further reading

## Books

* Domain-Driven Design by Eric Evans.
* Implementing Domain-Driven Design by Vaughn Vermon.

