---
title: Bandit
date: 20201016
author: Lyz
---

[Bandit](https://bandit.readthedocs.io/en/latest/) finds common security issues
in Python code. To do this, Bandit processes each file, builds an AST from it,
and runs appropriate plugins against the AST nodes. Once Bandit has finished
scanning all the files, it generates a report.

!!! note ""
    You can use [this cookiecutter
    template](https://github.com/lyz-code/cookiecutter-python-project) to create
    a python project with `bandit` already configured.

# Installation

```bash
pip install bandit
```

# Usage

## Ignore an error.

Add the `# nosec` comment in the line.

# Configuration

You can run bandit through:

* Pre-commit:

    !!! note "File: .pre-commit-config.yaml"
        ```yaml
        repos:
            - repo: https://github.com/Lucas-C/pre-commit-hooks-bandit
              rev: v1.0.4
              hooks:
              - id: python-bandit-vulnerability-check
        ```

        bandit takes a lot of time to run, so it slows down too much the
        commiting, therefore it should be run only in the CI.

* Github Actions: Make sure to check that the correct python version is applied.

    !!! note "File: .github/workflows/security.yml"
        ```yaml
        name: Security

        on: [push, pull_request]

        jobs:
          bandit:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout
                uses: actions/checkout@v2
              - uses: actions/setup-python@v2
                with:
                  python-version: 3.7
              - name: Install dependencies
                run: pip install bandit
              - name: Execute bandit
                run: bandit -r project
        ```

# Solving warnings

## B603: subprocess_without_shell_equals_true
The `B603: subprocess_without_shell_equals_true` issue in Bandit is raised when the `subprocess` module is used without setting `shell=True`. Bandit flags this because using `shell=True` can be a security risk if the command includes user-supplied input, as it opens the door to shell injection attacks.

To fix it:

1. Avoid `shell=True` if possible: Instead, pass the command and its arguments as a list to `subprocess.Popen` (or `subprocess.run`, `subprocess.call`, etc.). This way, the command is executed directly without invoking the shell, reducing the risk of injection attacks.

   Here's an example:

   ```python
   import subprocess

   # Instead of this:
   # subprocess.Popen("ls -l", shell=True)

   # Do this:
   subprocess.Popen(["ls", "-l"])
   ```

2. When you must use `shell=True`: - If you absolutely need to use `shell=True` (e.g., because you are running a complex shell command or using shell features like wildcards), ensure that the command is either hardcoded or sanitized to avoid security risks.

   Example with `shell=True`:

   ```python
   import subprocess

   # Command is hardcoded and safe
   command = "ls -l | grep py"
   subprocess.Popen(command, shell=True)
   ```

   If the command includes user input, sanitize the input carefully:

   ```python
   import subprocess

   user_input = "some_directory"
   command = f"ls -l {subprocess.list2cmdline([user_input])}"
   subprocess.Popen(command, shell=True)
   ```

   **Note:** Even with precautions, using `shell=True` is risky with user input, so avoid it if possible.

3. Explicitly tell bandit you have considered the risk: If you have reviewed the code and are confident that the code is safe in your particular case, you can mark the line with a `# nosec` comment to tell Bandit to ignore the issue:

   ```python
   import subprocess

   command = "ls -l | grep py"
   subprocess.Popen(command, shell=True)  # nosec
   ```

### Summary

- **Preferred**: Avoid using `shell=True` and pass the command as a list of arguments.
- **If Required**: Use `shell=True` carefully with sanitized input.
- **Mark as Safe**: If you understand the risks and are confident in your use, mark the line with `# nosec` to suppress the Bandit warning.

# References

* [Docs](https://bandit.readthedocs.io/en/latest/)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
