---
title: Using warnings to evolve your package
date: 20220310
author: Lyz
---

Regardless of the [versioning system](versioning.md) you're using, once you
reach your first stable version, the commitment to your end users must be that
you give them time to adapt to the changes in your program. So whenever you want
to introduce a breaking change release it under a new interface, and in
parallel, start emitting `DeprecationWarning` or `UserWarning` messages whenever
someone invokes the old one. Maintain this state for a defined period (for
example six months), and communicate explicitly in the warning message the timeline for when users have
to migrate.

This gives everyone time to move to the new interface without breaking their
system, and then the library may remove the change and get rid of the old design
chains forever. As an added benefit, only people using the old interface will
ever see the warning, as opposed to affecting everyone (as seen with the
semantic versioning major version bump).

If you're following [semantic versioning](semantic_versioning.md) you'd do this
change in a `minor` release, and you'll finally remove the functionality in
another `minor` release. As you've given your users enough time to adequate to
the new version of the code, it's not understood as a breaking change.

This allows too for your users to be less afraid and [*stop upper-pinning
you in their dependencies*](versioning.md#upper-version-pinning).

Another benefit of using warnings is that if you configure your test runner to
[capture the warnings](pytest.md#capture-deprecation-warnings) (which you
should!) you can use your test suite to see the real impact of the deprecation,
you may even realize why was that feature there and that you can't deprecate it
at all.

# Using warnings

Even though there are many warnings, I usually use `UserWarning` or
`DeprecationWarning`. The [full list is](https://docs.python.org/3/library/warnings.html#warning-categories):

| Class                     | Description                                                                     |
| ---                       | ---                                                                             |
| Warning                   | This is the base class of all warning category classes.                         |
| UserWarning               | The default category for warn().                                                |
| DeprecationWarning        | Warn other developers about deprecated features.                                |
| FutureWarning             | Warn other end users of applications about deprecated features.                 |
| SyntaxWarning             | Warn about dubious syntactic features.                                          |
| RuntimeWarning            | Warn about dubious runtime features.                                            |
| PendingDeprecationWarning | Warn about features that will be deprecated in the future (ignored by default). |
| ImportWarning             | Warn triggered during the process of importing a module (ignored by default).   |
| UnicodeWarning            | Warn related to Unicode.                                                        |
| BytesWarning              | Warn related to bytes and bytearray.                                            |
| ResourceWarning           | Warn related to resource usage (ignored by default).                            |


## [How to raise a warning](https://docs.python.org/3/library/warnings.html)

Warning messages are typically issued in situations where it is useful to alert
the user of some condition in a program, where that condition doesn’t
warrant raising an exception and terminating the program.

```python
import warnings

def f():
    warnings.warn('Message', DeprecationWarning)
```

## [Suppressing a warning](https://stackoverflow.com/questions/9134795/how-to-get-rid-of-specific-warning-messages-in-python-while-keeping-all-other-wa)

To disable in the whole file, add to the top:

```python
import warnings
warnings.filterwarnings("ignore", message="divide by zero encountered in divide")
```

If you want this to apply to only one section of code, then use the warnings context manager:

```python
import warnings
with warnings.catch_warnings():
    warnings.filterwarnings("ignore", message="divide by zero encountered in divide")
    # .. your divide-by-zero code ..
```

And if you want to disable it for the whole code base configure [pytest
accordingly](pytest.md#capture-deprecation-warnings).

# How to evolve your code

To ensure that the transition is smooth you need to tweak your code so that the
user can switch a flag and make sure that their code keeps on working with the
new changes. For example imagine that we have a class `MyClass` with a method
`my_method`.

```python
class MyClass:
    def my_method(self, argument):
        # my_method code goes here
```

You can add an argument `deprecate_my_method` that defaults to `False`, or you
can take the chance to change the signature of the function, so that if the user
is using the old argument, it uses the old behaviour and gets the warning, and
if it's using the new argument, it uses the new. The advantage of changing the
signature is that you don't need to do another deprecation for the temporal
argument flag.

!!! note "Or you can [use environmental
variables](#use-environmental-variables)"

```python
class MyClass:
    def __init__(self, deprecate_my_method = False):
        self.deprecate_my_method = deprecate_my_method

    def my_method(self, argument):
        if self.deprecate_my_method:
            # my_method new functionality
        else:
            warnings.warn("Use my_new_method instead", UserWarning)
            # my_method old code goes here
```

That way when users get the new version of your code, if they are not using
`my_method` they won't get the exception, and if they are, they can change how
they initialize their classes with `MyClass(deprecate_my_method=True)`, run
their tests tweaking their code to meet the new functionality and make sure that
they are ready for the method to be deprecated. Once removed, another
UserWarning will be raised to stop using `deprecate_my_method` as an argument to
initialize the class as it is no longer needed.

Until you remove the old code, you need to keep both functionalities and make
sure all your test suite works with both cases. To do that, create the warning,
run the tests and see what tests are raising the exception. For each of them you
need to think if this test will make sense with the new code:

* If it doesn't, make sure [that the warning is raised](#testing-warnings).
* If it is, make sure [that the warning is raised](#testing-warnings) and create
    another test with the `deprecate_my_method` enabled.

Once the deprecation date arrives you'll need to search for the date in your
code to see where the warning is raised and used, remove the old functionality
and update the tests. If you used a temporal argument to let the users try the
new behaviour, issue the warning to deprecate it.

## Use environmental variables

A cleaner way to handle it is with environmental variables, that way you don't
need to change the signature of the function twice. I've learned this from
[boto](https://github.com/boto/botocore/issues/2705) where they informed their
users this way:


* If you wish to test the new feature we have created a new environment variable
    `BOTO_DISABLE_COMMONNAME`. Setting this to `true` will suppress the warning and
    use the new functionality.
* If you are concerned about this change causing disruptions, you can pin your
    version of `botocore` to `<1.28.0` until you are ready to migrate.
* If you are only concerned about silencing the warning in your logs, use
    `warnings.filterwarnings` when instantiating a new service client.

    ```python
    import warnings
    warnings.filterwarnings('ignore', category=FutureWarning, module='botocore.client')
    ```

# Testing warnings

To test the function with pytest you can use
[`pytest.warns`](https://docs.pytest.org/en/stable/how-to/capture-warnings.html#warns):

```python
import warnings
import pytest


def test_warning():
    with pytest.warns(UserWarning, match='my warning'):
        warnings.warn("my warning", UserWarning)
```

For the `DeprecationWarnings` you can use [`deprecated_call`](https://docs.pytest.org/en/stable/how-to/capture-warnings.html#ensuring-code-triggers-a-deprecation-warning):

Or you can use
[`deprecated`](https://deprecated.readthedocs.io/en/latest/index.html):

```python
def test_myfunction_deprecated():
    with pytest.deprecated_call():
        f()
```

```python
@deprecated(version='1.2.0', reason="You should use another function")
def some_old_function(x, y):
    return x + y
```

But it adds a dependency to your program, although they don't have any
downstream dependencies.

# References

* [Bernat post on versioning](https://bernat.tech/posts/version-numbers/#a-better-way-to-handle-api-evolution)
