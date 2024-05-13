The Python type system supports two ways of deciding whether two objects are compatible as types: nominal subtyping and structural subtyping.

Nominal subtyping is strictly based on the class hierarchy. If class Dog inherits class `Animal`, it’s a subtype of `Animal`. Instances of `Dog` can be used when `Animal` instances are expected. This form of subtyping subtyping is what Python’s type system predominantly uses: it’s easy to understand and produces clear and concise error messages, and matches how the native `isinstance` check works – based on class hierarchy.

Structural subtyping is based on the operations that can be performed with an object. Class `Dog` is a structural subtype of class `Animal` if the former has all attributes and methods of the latter, and with compatible types.

Structural subtyping can be seen as a static equivalent of duck typing, which is well known to Python programmers. See [PEP 544](https://peps.python.org/pep-0544/) for the detailed specification of protocols and structural subtyping in Python.
# Usage

You can define your own protocol class by inheriting the special Protocol class:

```python
from typing import Iterable
from typing_extensions import Protocol

class SupportsClose(Protocol):
    # Empty method body (explicit '...')
    def close(self) -> None: ...

class Resource:  # No SupportsClose base class!

    def close(self) -> None:
       self.resource.release()

    # ... other methods ...

def close_all(items: Iterable[SupportsClose]) -> None:
    for item in items:
        item.close()

close_all([Resource(), open('some/file')])  # OK
```

`Resource` is a subtype of the `SupportsClose` protocol since it defines a compatible close method. Regular file objects returned by `open()` are similarly compatible with the protocol, as they support `close()`.

If you want to define a docstring on the method use the next syntax:

```python
    def load(self, filename: Optional[str] = None) -> None:
        """Load a configuration file."""
        ...
```

## [Make subprotocols and subclassing protocols](https://mypy.readthedocs.io/en/stable/protocols.html#defining-subprotocols-and-subclassing-protocols)

You can also define subprotocols. Existing protocols can be extended and merged using multiple inheritance. Example:

```python
# ... continuing from the previous example

class SupportsRead(Protocol):
    def read(self, amount: int) -> bytes: ...

class TaggedReadableResource(SupportsClose, SupportsRead, Protocol):
    label: str

class AdvancedResource(Resource):
    def __init__(self, label: str) -> None:
        self.label = label

    def read(self, amount: int) -> bytes:
        # some implementation
        ...

resource: TaggedReadableResource
resource = AdvancedResource('handle with care')  # OK
```

Note that inheriting from an existing protocol does not automatically turn the subclass into a protocol – it just creates a regular (non-protocol) class or ABC that implements the given protocol (or protocols). The `Protocol` base class must always be explicitly present if you are defining a protocol:

```python
class NotAProtocol(SupportsClose):  # This is NOT a protocol
    new_attr: int

class Concrete:
   new_attr: int = 0

   def close(self) -> None:
       ...

# Error: nominal subtyping used by default
x: NotAProtocol = Concrete()  # Error!
```
You can also include default implementations of methods in protocols. If you explicitly subclass these protocols you can inherit these default implementations.

Explicitly including a protocol as a base class is also a way of documenting that your class implements a particular protocol, and it forces mypy to verify that your class implementation is actually compatible with the protocol. In particular, omitting a value for an attribute or a method body will make it implicitly abstract:

```python
class SomeProto(Protocol):
    attr: int  # Note, no right hand side
    def method(self) -> str: ...  # Literally just ... here

class ExplicitSubclass(SomeProto):
    pass

ExplicitSubclass()  # error: Cannot instantiate abstract class 'ExplicitSubclass'
                    # with abstract attributes 'attr' and 'method'
```

Similarly, explicitly assigning to a protocol instance can be a way to ask the type checker to verify that your class implements a protocol:

```python
_proto: SomeProto = cast(ExplicitSubclass, None)
```

## [Make protocols work with `isinstance`](https://mypy.readthedocs.io/en/stable/protocols.html#using-isinstance-with-protocols)
To check an instance against the protocol using `isinstance`, we need to decorate our protocol with `@runtime_checkable`

```python
from typing_extensions import Protocol, runtime_checkable

@runtime_checkable
class Portable(Protocol):
    handles: int

class Mug:
    def __init__(self) -> None:
        self.handles = 1

def use(handles: int) -> None: ...

mug = Mug()
if isinstance(mug, Portable):  # Works at runtime!
   use(mug.handles)
```

`isinstance()` with protocols is not completely safe at runtime. For example, signatures of methods are not checked. The runtime implementation only checks that all protocol members exist, not that they have the correct type. `issubclass()` with protocols will only check for the existence of methods.

`isinstance()` with protocols can also be surprisingly slow. In many cases, you’re better served by using `hasattr()` to check for the presence of attributes.

## [Make a protocol property variable](https://mypy.readthedocs.io/en/stable/protocols.html#invariance-of-protocol-attributes)

## [Make protocol of functions](https://mypy.readthedocs.io/en/stable/protocols.html#callback-protocols)

# References
- [Mypy article on protocols](https://mypy.readthedocs.io/en/stable/protocols.html)
- [Predefined protocols reference](https://mypy.readthedocs.io/en/stable/protocols.html#predefined-protocol-reference)
\n\n[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
