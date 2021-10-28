---
title: Prompt toolkit REPL
date: 20211028
author: Lyz
---

[Prompt toolkit](prompt_toolkit.md) can be used to build REPL interfaces. This
section focuses in how to do it. If you want to build full screen applications
instead go to [this other article](prompt_toolkit_fullscreen_applications.md).

# [Testing](https://python-prompt-toolkit.readthedocs.io/en/master/pages/advanced_topics/unit_testing.html)

Testing prompt_toolkit or any [text-based user
interface](https://en.wikipedia.org/wiki/Text-based_user_interface) (TUI) with
python is not well documented. Some of the main developers suggest [mocking
it](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/477) while
[others](https://github.com/copier-org/copier/pull/260/files#diff-4e8715c7a425ee52e74b7df4d34efd32e8c92f3e60bd51bc2e1ad5943b82032e)
use [pexpect](pexpect.md).

With the first approach you can test python functions and methods internally but
it can lead you to the over mocking problem. The second will limit you to test
functionality exposed through your program's command line, as it will spawn
a process and interact it externally.

Given that the TUIs are entrypoints to your program, it makes sense to test them
in end-to-end tests, so I'm going to follow the second option. On the other
hand, you may want to test a small part of your TUI in a unit test, if you
want to follow this other path, I'd start with
[monkeypatch](https://stackoverflow.com/questions/38723140/i-want-to-use-stdin-in-a-pytest-test),
although I didn't have good results with it.

```python
def test_method(monkeypatch):
    monkeypatch.setattr('sys.stdin', io.StringIO('my input'))
```

## [Using pexpect](https://github.com/copier-org/copier/pull/260/files)

This method is useful to test end to end functions as you need to all the
program as a command line. You can't use it to tests python functions
internally.

!!! note "File: source.py"
    ```python
    from prompt_toolkit import prompt

    text = prompt("Give me some input: ")
    with open("/tmp/tui.txt", "w") as f:
        f.write(text)
    ```

!!! note "File: test_source.py"
    ```python
    import pexpect


    def test_tui() -> None:
        tui = pexpect.spawn("python source.py", timeout=5)
        tui.expect("Give me .*")
        tui.sendline("HI")
        tui.expect_exact(pexpect.EOF)

        with open("/tmp/tui.txt", "r") as f:
            assert f.read() == "HI"
   ```

Where:

* The `tui.expect_exact(pexpect.EOF)` line is required so that the tests aren't
    run before the process has ended, otherwise the file might not exist yet.
* The `timeout=5` is required in case that the `pexpect` interaction is not well
    defined, so that the test is not hung forever.

!!! note "Thank you [Jairo Llopis](https://github.com/Yajo) for this solution."
    I've deduced the solution from his
    [#260](https://github.com/copier-org/copier/pull/260/files) PR into
    [copier](https://github.com/copier-org/copier), and the comments of
    [#1243](https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1243)
