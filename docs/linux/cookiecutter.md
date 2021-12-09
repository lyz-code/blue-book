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

!!! warning "DEPRECATION: use [cruft](cruft.md) instead"
    You may want to use [cruft](cruft.md) to generate your templates instead, as
    it will help you maintain the project with the template updates. Something
    that it's not easy with [cookiecutter
    alone](https://github.com/cookiecutter/cookiecutter/issues/784)

```bash
cookiecutter {{ path_or_url_to_cookiecutter_template }}
```

## [User config](https://cookiecutter.readthedocs.io/en/1.7.2/advanced/user_config.html)

If you use Cookiecutter a lot, you’ll find it useful to have a user config file.
By default Cookiecutter tries to retrieve settings from a `.cookiecutterrc` file
in your home directory.

Example user config:

```yaml
default_context:
    full_name: "Audrey Roy"
    email: "audreyr@example.com"
    github_username: "audreyr"
cookiecutters_dir: "/home/audreyr/my-custom-cookiecutters-dir/"
replay_dir: "/home/audreyr/my-custom-replay-dir/"
abbreviations:
    python: https://github.com/audreyr/cookiecutter-pypackage.git
    gh: https://github.com/{0}.git
    bb: https://bitbucket.org/{0}
```

Possible settings are:

`default_context`
: A list of key/value pairs that you want injected as context
    whenever you generate a project with Cookiecutter. These values are treated
    like the defaults in `cookiecutter.json`, upon generation of any project.

`cookiecutters_dir`
: Directory where your cookiecutters are cloned to when you
    use Cookiecutter with a repo argument.

`replay_dir`
: Directory where Cookiecutter dumps context data to, which you
    can fetch later on when using the replay feature.

`abbreviations`
: A list of abbreviations for cookiecutters. Abbreviations can be simple aliases
    for a repo name, or can be used as a prefix, in the form `abbr:suffix`. Any suffix
    will be inserted into the expansion in place of the text `{0}`, using standard
    Python string formatting. With the above aliases, you could use the
    `cookiecutter-pypackage` template simply by saying cookiecutter `python`.

# Write your own cookietemplates

## [Create files or directories with conditions](https://github.com/cookiecutter/cookiecutter/issues/723)

For files use a filename like `'{{ ".vault_pass.sh" if
cookiecutter.vault_pass_entry != "None" else "" }}'`.

For directories I haven't yet found a nice way to do it (as the above will
fail), check the issue or the [hooks
documentation](https://cookiecutter.readthedocs.io/en/latest/advanced/hooks.html#example-conditional-files-directories)
for more information.

!!! note "File: `post_gen_project.py`"
    ```python
    import os
    import sys

    REMOVE_PATHS = [
        '{% if cookiecutter.packaging != "pip" %} requirements.txt {% endif %}',
        '{% if cookiecutter.packaging != "poetry" %} poetry.lock {% endif %}',
    ]

    for path in REMOVE_PATHS:
        path = path.strip()
        if path and os.path.exists(path):
            if os.path.isdir(path):
                os.rmdir(path)
            else:
                os.unlink(path)
    ```

## Add some text to a file if a condition is met

Use jinja2 conditionals. Note the `-` at the end of the conditional opening,
play with `{%- ... -%}` and `{% ... %}` for different results on line appending.

```yaml
{% if cookiecutter.install_docker == 'yes' -%}
- src: git+ssh://mywebpage.org/ansible-roles/docker.git
  version: 1.0.3
{%- else -%}
- src: git+ssh://mywebpage.org/ansible-roles/other-role.git
  version: 1.0.2
{%- endif %}
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

## Prevent additional whitespaces when jinja condition is not met.

Jinja2 has a [whitespace
control](https://jinja.palletsprojects.com/en/2.10.x/templates/#whitespace-control)
that can be used to manage the whitelines existent between the Jinja blocks. The
problem comes when a condition is not met in an `if` block, in that case, Jinja
adds a whitespace which will break most linters.

This is the solution I've found out that works as expected.

```jinja2
### Multienvironment

This playbook has support for the following environments:

{% if cookiecutter.production_environment == "True" -%}
* Production
{% endif %}
{%- if cookiecutter.staging_environment == "True" -%}
* Staging
{% endif %}
{%- if cookiecutter.development_environment == "True" -%}
* Development
{% endif %}
### Tags
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

## Debug failing template generation

Sometimes the generation of the templates will fail in the tests, I've found
that the easier way to debug why is to inspect the result object of the
`result = cookies.bake()` statement with pdb.

It has an `exception` method with `lineno` argument and `source`. With that
information I've been able to locate the failing line. It also has a `filename`
attribute but it doesn't seem to work for me.

# References

* [Git](https://github.com/cookiecutter/cookiecutter)
* [Docs](https://cookiecutter.readthedocs.io/)
