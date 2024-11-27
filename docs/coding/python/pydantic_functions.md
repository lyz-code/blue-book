---
title: Pydantic validating functions
date: 20201009
author: Lyz
---

The `validate_arguments` decorator allows the arguments passed to a function to
be parsed and validated using the function's annotations before the function is
called. While under the hood this uses the same approach of model creation and
initialisation; it provides an extremely easy way to apply validation to your
code with minimal boilerplate.

!!! info "In Beta"
    The `validate_arguments` decorator is in **beta**, it has been added to
    *pydantic* in **v1.5** on a **provisional basis**. It may change
    significantly in future releases and its interface will not be concrete
    until **v2**. Feedback from the community while it's still provisional would
    be extremely useful; either comment on
    [#1205](https://github.com/samuelcolvin/pydantic/issues/1205) or create
    a new issue.

    Be sure you understand it's
    [limitations](https://pydantic-docs.helpmanual.io/usage/validation_decorator/#limitations).

Example of usage:

```python
from pydantic import validate_arguments, ValidationError


@validate_arguments
def repeat(s: str, count: int, *, separator: bytes = b'') -> bytes:
    b = s.encode()
    return separator.join(b for _ in range(count))


a = repeat('hello', 3)
print(a)
#> b'hellohellohello'

b = repeat('x', '4', separator=' ')
print(b)
#> b'x x x x'

try:
    c = repeat('hello', 'wrong')
except ValidationError as exc:
    print(exc)
    """
    1 validation error for Repeat
    count
      value is not a valid integer (type=type_error.integer)
    """
```

# [Usage with mypy](https://pydantic-docs.helpmanual.io/usage/validation_decorator/#usage-with-mypy)

The `validate_arguments` decorator should work "out of the box" with
[mypy](http://mypy-lang.org/) since it's defined to return a function with the
same signature as the function it decorates. The only limitation is that since
we trick mypy into thinking the function returned by the decorator is the same
as the function being decorated; access to the [raw function](#raw-function) or
other attributes will require `type: ignore`.

# References

* [Pydantic validation decorator docs](https://pydantic-docs.helpmanual.io/usage/validation_decorator/)
