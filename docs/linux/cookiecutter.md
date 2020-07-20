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

## [Prevent cookiecutter from processing some files](https://stackoverflow.com/questions/39138386/how-to-protect-some-files-from-the-jinja-template-processor)

By default cookiecutter will try to process every file as a Jinja template. This
behaviour produces wrong results if you have Jinja templates that are meant to
be taken as literal. Starting with cookiecutter 1.1, you can
tell cookiecutter to only copy some files [without interpreting them as Jinja
templates](http://cookiecutter.readthedocs.io/en/latest/advanced/copy_without_render.html).

Add a `_copy_without_render` key in the cookiecutter config file
(`cookiecutter.json`). It takes a list of regular expressions. If a filename matches the regular expressions it will be copied and not processed as a Jinja template.

```json
{
    "project_slug": "sample",
    "_copy_without_render": [
        "*.js",
        "not_rendered_dir/*",
        "rendered_dir/not_rendered_file.ini"
    ]
}
```

# Testing your own cookiecutter templates

The [pytest-cookies](https://pytest-cookies.readthedocs.io) plugin comes with
a `cookies` fixture which is a wrapper for the cookiecutter API for generating
projects. It helps you verify that your template is working as expected and
takes care of cleaning up after running the tests.

## Install

```bash
pip install pytest-cookies
```

## [Usage](https://pytest-cookies.readthedocs.io/en/latest/getting_started/)

@pytest.fixture
def context():
    return {
        "playbook_name": "My Test Playbook",
    }


The `cookies.bake()` method generates a new project from your template based on
the default values specified in cookiecutter.json:

```python
def test_bake_project(cookies):
    result = cookies.bake(extra_context={'repo_name': 'hello world'})

    assert result.exit_code == 0
    assert result.exception is None
    assert result.project.basename == 'hello world'
    assert result.project.isdir()
```

It accepts the `extra_context` keyword argument that is passed to
cookiecutter. The given dictionary will override the default values of the
template context, allowing you to test arbitrary user input data.

The
[cookiecutter-django](https://github.com/pydanny/cookiecutter-django/blob/master/tests/test_cookiecutter_generation.py)
has a nice test file using this fixture.

## Mocking the contents of the cookiecutter hooks

Sometimes it's interesting to add interactions with external services in the
cookiecutter hooks, for example to activate a CI pipeline.

If you want to test the cookiecutter template you need to mock those external
interactions. But it's difficult to mock the contents of the hooks because their
contents aren't run by the `cookies.bake()` code. Instead it delegates in
cookiecutter to run them, which opens [a `subprocess` to run
them](https://github.com/cookiecutter/cookiecutter/blob/afc83a3cb55d1ec0b4c3c716e928cda27d3f1a05/cookiecutter/hooks.py#L82),
so the mocks don't work.

The alternative is setting an environmental variable in your tests to skip those
steps:

!!! note "File: tests/conftest.py"
    ```python
    import os

    os.environ["COOKIECUTTER_TESTING"] = "true"
    ```

!!! note "File: hooks/pre_gen_project.py"
    ```python
    def main():
        # ... pre_hook content ...


    if __name__ == "__main__":

        if os.environ.get("COOKIECUTTER_TESTING") != "true":
            main()
    ```
If you want to test the content of `main`, you can now mock each of the external
interactions. But you'll face the problem that these files are jinja2 templates
of python files, so it's tricky to test them, due to syntax errors.

# References

* [Git](https://github.com/cookiecutter/cookiecutter)
* [Docs](https://cookiecutter.readthedocs.io/)
