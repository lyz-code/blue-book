---
title: Solid
date: 20200626
author: Lyz
---

[SOLID](https://en.wikipedia.org/wiki/SOLID) is a mnemonic acronym for five design principles intended to make software designs more understandable, flexible and maintainable.

# [Single-responsibility](https://en.wikipedia.org/wiki/Single-responsibility_principle)(SRP)

Every module or class should have responsibility over a single part of the
functionality provided by the software, and that responsibility should be
entirely encapsulated by the class, module or function. All its services should
be narrowly aligned with that responsibility.

As an example, consider a module that compiles and prints a report. Imagine such
a module can be changed for two reasons. First, the content of the report could
change. Second, the format of the report could change. These two things change
for very different causes; one substantive, and one cosmetic. The
single-responsibility principle says that these two aspects of the problem are
really two separate responsibilities, and should, therefore, be in separate
classes or modules. It would be a bad design to couple two things that change
for different reasons at different times.

# [Open-closed](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)

Software entities (classes, modules, functions, etc.) should be open for
extension, but closed for modification.

Implemented through the use of abstracted interfaces (abstract base classes),
where the implementations can be changed and multiple implementations could be
created and polymorphically substituted for each other. Interface specifications
can be reused through inheritance but implementation need not be. The existing
interface is closed to modifications and new implementations must, at a minimum,
implement that interface.

# [Liskov substitution](https://en.wikipedia.org/wiki/Liskov_substitution_principle)(LSP)

If *S* is a subtype of *T*, then objects of type *T* may be replaced with
objects of type *S* without altering any of the desirable properties of the
program.

It imposes some standard requirements on
[signatures](https://en.wikipedia.org/wiki/Type_signature)(the inputs and outputs for a function, subroutine or method):

* [Contravariance](https://en.wikipedia.org/wiki/Covariance_and_contravariance_%28computer_science%29)
    of method arguments in the subtype.
* [Covariance](https://en.wikipedia.org/wiki/Covariance_and_contravariance_%28computer_science%29)
    of return types in the subtype.
* No new exceptions should be thrown by methods of the subtype, except where
    those exceptions are themselves subtypes of exception thrown by the methods
    of the supertype.

Additionally, the subtype must meet the following behavioural conditions that
restrict how contracts can interact with the inheritance:

* [Preconditions](https://en.wikipedia.org/wiki/Precondition) cannot be strengthened in a subtype.
* [Postconditions](https://en.wikipedia.org/wiki/Postcondition) cannot be
    weakened in a subtype.
* [Invariants](https://en.wikipedia.org/wiki/Invariant_%28computer_science%29)
    of the supertype must be preserved in a subtype.
* History constraint. Objects are regarded as being modifiable only through their methods. Because
    subtypes may introduce methods that are not present in the supertype, the
    introduction of these methods may allow state changes in the subtype that
    are not permissible in the supertype. This is not allowed. Fields added to
    the subtype may however be safely modified because they are not observable
    through the supertype methods.

# [Interface segregation](https://en.wikipedia.org/wiki/Interface_segregation_principle) (ISP)

No client should be forced to depend on methods it does not use. ISP splits
interfaces that are very large into smaller and more specific ones so that
clients will only have to know about the methods that are of interest to them.
ISP is intended to keep a system decoupled and thus easier to refactor, change,
and redeploy.

For example, Xerox had created a new printer system that could perform a variety
of tasks such as stapling and faxing. The software for this system was created
from the ground up. As the software grew, making modifications became more and
more difficult so that even the smallest change would take a redeployment cycle
of an hour, which made development nearly impossible.

The design problem was that a single Job class was used by almost all of the
tasks. Whenever a print job or a stapling job needed to be performed, a call was
made to the Job class. This resulted in a 'fat' class with multitudes of methods
specific to a variety of different clients. Because of this design, a staple job
would know about all the methods of the print job, even though there was no use
for them.

The solution suggested by Martin utilized what is today called the Interface
Segregation Principle. Applied to the Xerox software, an interface layer between
the Job class and its clients was added using the Dependency Inversion
Principle. Instead of having one large Job class, a Staple Job interface or
a Print Job interface was created that would be used by the Staple or Print
classes, respectively, calling methods of the Job class. Therefore, one
interface was created for each job type, which was all implemented by the Job
class.

# [Dependency inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

Specific form of decoupling software modules where the conventional dependency
relationships established from high-level, policy setting modules to low-level,
dependency modules are reversed, thus rendering high-level modules independent
of the low-level module implementation details.

* High-level modules should not depend on low-level modules. Both should depend
    on abstractions (e.g. interfaces).

    *Depends on* doesn't mean imports or calls, necessarily, but rather a more
    general idea that one module *knows about* or *needs* another module.

* Abstractions should not depend on details. Details (concrete implementations)
    should depend on abstractions.

The idea behind points A and B of this principle is that when designing the
interaction between a high-level module and a low-level one, the interaction
should be thought of as an abstract interaction between them. This not only has
implications on the design of the high-level module, but also on the low-level
one: the low-level one should be designed with the interaction in mind and it
may be necessary to change its usage interface. Thinking about the interaction
in itself as an abstract concept allows the coupling of the components to be
reduced without introducing additional coding patterns, allowing only a lighter
and less implementation dependent interaction schema.

# References

* [SOLID Wikipedia article](https://en.wikipedia.org/wiki/SOLID)
* [Architecture Patterns with
    Python](https://www.cosmicpython.com/book/preface.html) by
    Harry J.W. Percival and Bob Gregory.
