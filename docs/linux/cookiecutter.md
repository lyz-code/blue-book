---
title: Cookiecutter
date: 20200713
author: Lyz
---

[Cookiecutter](https://github.com/cookiecutter/cookiecutter) is a command-line
utility that creates projects from cookiecutters (project templates).

# Install

```bash
pip install cookiecutter
```

# Use

```bash
cookiecutter {{ path_or_url_to_cookiecutter_template }}
```

# Write your own cookietemplates

## [Create files or directories with conditions](https://github.com/cookiecutter/cookiecutter/issues/723)

For files use a filename like `'{{ ".vault_pass.sh" if
cookiecutter.vault_pass_entry != "None" else "" }}'`.

For directories I haven't yet found a nice way to do it (as the above will
fail), check the issue or the [hooks
documentation](https://cookiecutter.readthedocs.io/en/latest/advanced/hooks.html#example-conditional-files-directories)
for more information.

## Add some text to a file if a condition is met

Use jinja2 conditionals. Note the `-` at the end of the conditional opening,
play with `{%- ... -%}` and `{% ... %}` for different results on line appending.

```yaml
{% if cookiecutter.install_docker == 'yes' -%}
- src: git+ssh://mywebpage.org/ansible-roles/docker.git
  version: 1.0.3
{% endif %}
```

## [Initialize git repository on the created cookiecutter](https://stackoverflow.com/questions/38556622/create-a-git-versioned-project-with-cookiecutter)

Added the following to the post generation hooks.

!!! note "File: hooks/post_gen_project.py"

    ```python
    import subprocess

    subprocess.call(['git', 'init'])
    subprocess.call(['git', 'add', '*'])
    subprocess.call(['git', 'commit', '-m', 'Initial commit'])
    ```

# References

* [Git](https://github.com/cookiecutter/cookiecutter)
* [Docs](https://cookiecutter.readthedocs.io/)
