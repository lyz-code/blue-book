---
title: Python pytest
date: 20200527
author: Lyz
---

[pytest](https://docs.pytest.org/en/latest) is a Python framework to makes it
easy to write small tests, yet scales to support complex functional testing for
applications and libraries.

# pytest integration with Vim

Integrating pytest into your Vim workflow enhances your productivity while
writing code, thus making it easier to code using TDD.

I use [Janko-m's Vim-test plugin](https://github.com/janko-m/vim-test) (which
can be installed through [Vundle](https://github.com/VundleVim/Vundle.vim)) with the
following configuration.

```vim
nmap <silent> t :TestNearest<CR>
nmap <silent> <leader>t :TestSuite tests/unit<CR>
nmap <silent> <leader>i :TestSuite tests/integration<CR>
nmap <silent> <leader>T :TestFile<CR>

let test#python#runner = 'pytest'
let test#strategy = "neovim"
```

I often open Vim with a vertical split (`:vs`), in the left window I have the
tests and in the right the code. Whenever I want to run a single test I press
`t` when the cursor is inside that test. If you need to make changes in the
code, you can press `t` again while the cursor is at the code you are testing
and it will run the last test.

Once the unit test has passed, I run the whole unit tests with `;t` (as `;` is
my `<leader>`). And finally I use `;i` to run the integration tests.

Finally, if the test suite is huge, I use `;T` to run only the tests of a single
file.

# [Mocking sys.exit](https://medium.com/python-pandemonium/testing-sys-exit-with-pytest-10c6e5f7726f)

```python
with pytest.raises(SystemExit):
    # Code to test
```

# Reference

* [Docs](https://docs.pytest.org/en/latest/)
* [Vim-test plugin](https://github.com/janko-m/vim-test)
