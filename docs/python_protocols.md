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

## [Make protocols work with `isinstance`](https://mypy.readthedocs.io/en/stable/protocols.html#using-isinstance-with-protocols)
To check an instance against the protocol using `isinstance`, we need to decorate our protocol with `@runtime_checkable`

## [Make a protocol property variable](https://mypy.readthedocs.io/en/stable/protocols.html#invariance-of-protocol-attributes)

## [Make protocol of functions](https://mypy.readthedocs.io/en/stable/protocols.html#callback-protocols)

# References
- [Mypy article on protocols](https://mypy.readthedocs.io/en/stable/protocols.html)
- [Predefined protocols reference](https://mypy.readthedocs.io/en/stable/protocols.html#predefined-protocol-reference)
