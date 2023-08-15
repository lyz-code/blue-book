
[Copier](https://github.com/copier-org/copier) is a library and CLI app for rendering project templates.

- Works with local paths and Git URLs.
- Your project can include any file and Copier can dynamically replace values in any kind of text file.
- It generates a beautiful output and takes care of not overwriting existing files unless instructed to do so.

# [Installation](https://github.com/copier-org/copier)

```bash
pipx install copier
```

Until [this issue is solved](https://github.com/copier-org/copier/issues/1225) you also need to downgrade `pydantic`

```bash
pipx inject copier 'pydantic<2'
```

# [Basic concepts](https://github.com/copier-org/copier#basic-concepts)

Copier is composed of these main concepts:

- Templates: They lay out how to generate the subproject.
- Questionaries: They are configured in the template. Answers are used to generate projects.
- Projects: This is where your real program lives. But it is usually generated and/or updated from a template.

Copier targets these main human audiences:

- Template creators: Programmers that repeat code too much and prefer a tool to do it for them.
    This quote on their docs made my day:

    > Copier doesn't replace the DRY principle... but sometimes you simply can't be DRY and you need a DRYing machine...

- Template consumers: Programmers that want to start a new project quickly, or that want to evolve it comfortably.

Non-humans should be happy also by using Copier's CLI or API, as long as their expectations are the same as for those humans... and as long as they have feelings.

Templates have these goals:

- [Code scaffolding](https://en.wikipedia.org/wiki/Scaffold_%28programming%29): Help consumers have a working source code tree as quickly as possible. All templates allow scaffolding.
- Code lifecycle management. When the template evolves, let consumers update their projects. Not all templates allow updating.

Copier tries to have a smooth learning curve that lets you create simple templates that can evolve into complex ones as needed.

# Usage

## [Creating a template](https://copier.readthedocs.io/en/latest/creating/)

A template is a directory: usually the root folder of a Git repository.

The content of the files inside the project template is copied to the destination without changes, unless they end with `.jinja`. In that case, the templating engine will be used to render them.

Jinja2 templating is used. Learn more about it by reading [Jinja2 documentation](https://jinja.palletsprojects.com/).

If a YAML file named `copier.yml` or `copier.yaml` is found in the root of the project, the user will be prompted to fill in or confirm the default values.

Minimal example:

```
📁 my_copier_template                            # your template project
├── 📄 copier.yml                                # your template configuration
├── 📁 .git/                                     # your template is a Git repository
├── 📁 {{project_name}}                          # a folder with a templated name
│   └── 📄 {{module_name}}.py.jinja              # a file with a templated name
└── 📄 {{_copier_conf.answers_file}}.jinja       # answers are recorded here
```

Where: 

- copier.yml

        ```yaml
    # questions
    project_name:
        type: str
        help: What is your project name?

    module_name:
        type: str
        help: What is your Python module name?
    ```

- `{{project_name}}/{{module_name}}.py.jinja`

    ```python
    print("Hello from {{module_name}}!")
    ```

- `{{_copier_conf.answers_file}}.jinja`

    ```
    # Changes here will be overwritten by Copier
    {{ _copier_answers|to_nice_yaml -}}
    ```

Generating a project from this template using `copier copy my_copier_template generated_project` answering `super_project` and `world` for the `project_name` and `module_name` questions respectively would create in the following directory and files:

```
📁 generated_project
├── 📁 super_project
│   └── 📄 world.py
└── 📄 .copier-answers.yml
```

Where:

- `super_project/world.py`

    ```python
    print("Hello from world!")
    ```

- `.copier-answers.yml`

    ```yaml
    # Changes here will be overwritten by Copier
    _commit: 0.1.0
    _src_path: gh:your_account/your_template
    project_name: super_project
    module_name: world
    ```

### [Template helpers](https://copier.readthedocs.io/en/latest/creating/#template-helpers)

In addition to [all the features Jinja supports](https://jinja.palletsprojects.com/en/3.1.x/templates/), Copier includes:

- All functions and filters from [jinja2-ansible-filters](https://gitlab.com/dreamer-labs/libraries/jinja2-ansible-filters/). This includes the `to_nice_yaml` filter, which is used extensively in our context.

- `_copier_answers` includes the current answers dict, but slightly modified to make it suitable to autoupdate your project safely:
    - It doesn't contain secret answers.
    - It doesn't contain any data that is not easy to render to JSON or YAML.
    - It contains special keys like `_commit` and `_src_path`, indicating how the last template update was done.
- `_copier_conf` includes a representation of the current Copier Worker object, also slightly modified:
    - It only contains JSON-serializable data.
    - You can serialize it with `{{ _copier_conf|to_json }}`.
    - ⚠️ It contains secret answers inside its `.data` key.
    - Modifying it doesn't alter the current rendering configuration.
    - It contains the current commit hash from the template in `{{ _copier_conf.vcs_ref_hash }}`.
    - Contains Operating System-specific directory separator under `sep` key.

## [Configuring a template](https://copier.readthedocs.io/en/latest/configuring)

### [The `copier.yaml` file](https://copier.readthedocs.io/en/latest/configuring/#the-copieryml-file)

The `copier.yml` (or `copier.yaml`) file is found in the root of the template, and it is the main entrypoint for managing your template configuration.

For each key found, Copier will prompt the user to fill or confirm the values before they become available to the project template.

This `copier.yml` file:

```yaml
name_of_the_project: My awesome project
number_of_eels: 1234
your_email: ""
```

Will result in a questionary similar to:

```
🎤 name_of_the_project
  My awesome project
🎤 number_of_eels (int)
  1234
🎤 your_email
```

Apart from the simplified format, as seen above, Copier supports a more advanced format to ask users for data. To use it, the value must be a dict.

Supported keys:

- type: User input must match this type. Options are: `bool`, `float`, `int`, `json`, `str`, `yaml` (default).
- help: Additional text to help the user know what's this question for.
- choices: To restrict possible values.

    A choice can be validated by using the extended syntax with dict-style and tuple-style choices. For example:

    ```yaml
    cloud:
        type: str
        help: Which cloud provider do you use?
        choices:
            - Any
            - AWS
            - Azure
            - GCP

    iac:
        type: str
        help: Which IaC tool do you use?
        choices:
            Terraform: tf
            Cloud Formation:
                value: cf
                validator: "{% if cloud != 'AWS' %}Requires AWS{% endif %}"
            Azure Resource Manager:
                value: arm
                validator: "{% if cloud != 'Azure' %}Requires Azure{% endif %}"
            Deployment Manager:
                value: dm
                validator: "{% if cloud != 'GCP' %}Requires GCP{% endif %}"
    ```

    When the rendered validator is a non-empty string, the choice is disabled and the message is shown. Choice validation is useful when the validity of a choice depends on the answer to a previous question.

- default: Leave empty to force the user to answer. Provide a default to save them from typing it if it's quite common. When using choices, the default must be the choice value, not its key, and it must match its type. If values are quite long, you can use YAML anchors.
- secret: When true, it hides the prompt displaying asterisks (*****) and doesn't save the answer in the answers file
- placeholder: To provide a visual example for what would be a good value. It is only shown while the answer is empty, so maybe it doesn't make much sense to provide both default and placeholder.
- multiline: When set to `true`, it allows multiline input. This is especially useful when type is json or yaml.
- validator: Jinja template with which to validate the user input. This template will be rendered with the combined answers as variables; it should render nothing if the value is valid, and an error message to show to the user otherwise.
- when: Condition that, if false, skips the question.

    If it is a boolean, it is used directly, but it's a bit absurd in that case.

    If it is a string, it is converted to boolean using a parser similar to YAML, but only for boolean values.

    This is most useful when templated.

    If a question is skipped, its answer will be:

    - The default value, if you're generating the project for the first time.
    - The last answer recorded, if you're updating the project.

    ```yaml
    project_creator:
        type: str

    project_license:
        type: str
        choices:
            - GPLv3
            - Public domain

    copyright_holder:
        type: str
        default: |-
            {% if project_license == 'Public domain' -%}
                {#- Nobody owns public projects -#}
                nobody
            {%- else -%}
                {#- By default, project creator is the owner -#}
                {{ project_creator }}
            {%- endif %}
        # Only ask for copyright if project is not in the public domain
        when: "{{ project_license != 'Public domain' }}"
    ```

    ```yaml
    love_copier:
        type: bool # This makes Copier ask for y/n
        help: Do you love Copier?
        default: yes # Without a default, you force the user to answer

    project_name:
        type: str # Any value will be treated raw as a string
        help: An awesome project needs an awesome name. Tell me yours.
        default: paradox-specifier
        validator: >-
            {% if not (project_name | regex_search('^[a-z][a-z0-9\-]+$')) %}
            project_name must start with a letter, followed one or more letters, digits or dashes all lowercase.
            {% endif %}

    rocket_launch_password:
        type: str
        secret: true # This value will not be logged into .copier-answers.yml
        placeholder: my top secret password

    # I'll avoid default and help here, but you can use them too
    age:
        type: int
        validator: "{% if age <= 0 %}Must be positive{% endif %}"

    height:
        type: float

    any_json:
        help: Tell me anything, but format it as a one-line JSON string
        type: json
        multiline: true

    any_yaml:
        help: Tell me anything, but format it as a one-line YAML string
        type: yaml # This is the default type, also for short syntax questions
        multiline: true

    your_favorite_book:
        # User will choose one of these and your template will get the value
        choices:
            - The Bible
            - The Hitchhiker's Guide to the Galaxy

    project_license:
        # User will see only the dict key and choose one, but you will
        # get the dict value in your template
        choices:
            MIT: &mit_text |
                Here I can write the full text of the MIT license.
                This will be a long text, shortened here for example purposes.
            Apache2: |
                Full text of Apache2 license.
        # When using choices, the default value is the value, **not** the key;
        # that's why I'm using the YAML anchor declared above to avoid retyping the
        # whole license
        default: *mit_text
        # You can still define the type, to make sure answers that come from --data
        # CLI argument match the type that your template expects
        type: str

    close_to_work:
        help: Do you live close to your work?
        # This format works just like the dict one
        choices:
            - [at home, I work at home]
            - [less than 10km, quite close]
            - [more than 10km, not so close]
            - [more than 100km, quite far away]
    ```

#### [Include other YAML files](https://copier.readthedocs.io/en/latest/configuring/#include-other-yaml-files)

The `copier.yml` file supports multiple documents as well as using the `!include` tag to include settings and questions from other YAML files. This allows you to split up a larger `copier.yml` and enables you to reuse common partial sections from your templates. When multiple documents are used, care has to be taken with questions and settings that are defined in more than one document:

- A question with the same name overwrites definitions from an earlier document.
- Settings given in multiple documents for `exclude`, `skip_if_exists`, `jinja_extensions` and `secret_questions` are concatenated.
- Other settings (such as `tasks` or `migrations`) overwrite previous definitions for these settings.

You can use Git submodules to sanely include shared code into templates!

```yaml
---
# Copier will load all these files
!include shared-conf/common.*.yml

# These 3 lines split the several YAML documents
---
# These two documents include common questions for these kind of projects
!include common-questions/web-app.yml
---
!include common-questions/python-project.yml
---

# Here you can specify any settings or questions specific for your template
_skip_if_exists:
    - .password.txt
custom_question: default answer
```

that includes questions and settings from `common-questions/python-project.yml`

```yaml
version:
    type: str
    help: What is the version of your Python project?

# Settings like `_skip_if_exists` are merged
_skip_if_exists:
    - "pyproject.toml"
```

### [Conditional files and directories](https://copier.readthedocs.io/en/latest/configuring/#conditional-files-and-directories)

You can take advantage of the ability to template file and directory names to make them "conditional", i.e. to only generate them based on the answers given by a user.

For example, you can ask users if they want to use pre-commit:

```yaml
use_precommit:
    type: bool
    default: false
    help: Do you want to use pre-commit?
```

And then, you can generate a `.pre-commit-config.yaml` file only if they answered "yes":

```
📁 your_template
├── 📄 copier.yml
└── 📄 {% if use_precommit %}.pre-commit-config.yaml{% endif %}.jinja
```

Note that the chosen template suffix must appear outside of the Jinja condition, otherwise the whole file won't be considered a template and will be copied as such in generated projects.

You can even use the answers of questions with choices:

```yaml
ci:
    type: str
    help: What Continuous Integration service do you want to use?
    choices:
        GitHub CI: github
        GitLab CI: gitlab
    default: github
```

```
📁 your_template
├── 📄 copier.yml
├── 📁 {% if ci == 'github' %}.github{% endif %}
│   └── 📁 workflows
│       └── 📄 ci.yml
└── 📄 {% if ci == 'gitlab' %}.gitlab-ci.yml{% endif %}.jinja
```

Contrary to files, directories must not end with the template suffix.

### [Generating a directory structure](https://copier.readthedocs.io/en/latest/configuring/#generating-a-directory-structure)

You can use answers to generate file names as well as whole directory structures.

```yaml
package:
    type: str
    help: Package name
```

```
📁 your_template
├── 📄 copier.yml
└── 📄 {{ package.replace('.', _copier_conf.sep) }}{{ _copier_conf.sep }}__main__.py.jinja
```

If you answer `your_package.cli.main` Copier will generate this structure:

```
📁 your_project
└── 📁 your_package
    └── 📁 cli
        └── 📁 main
            └── 📄 __main__.py
```

You can either use any separator, like `.`, and replace it with `_copier_conf.sep`, like in the example above, or just use `/`.

### [Importing Jinja templates and macros](https://copier.readthedocs.io/en/latest/configuring/#importing-jinja-templates-and-macros)

You can [include templates](https://jinja.palletsprojects.com/en/3.1.x/templates/#include) and [import macros](https://jinja.palletsprojects.com/en/3.1.x/templates/#import) to reduce code duplication. A common scenario is the derivation of new values from answers, e.g. computing the slug of a human-readable name:

- `copier.yaml`:
    ```yaml
    _exclude:
        - name-slug

    name:
        type: str
        help: A nice human-readable name

    slug:
        type: str
        help: A slug of the name
        default: "{% include 'name-slug.jinja' %}"
    ```

- `name-slug.jinja`

    ```jinja2
    {# For simplicity ... -#}
    {{ name|lower|replace(' ', '-') }}
    ```

```
📁 your_template
├── 📄 copier.yml
└── 📄 name-slug.jinja
```

It is also possible to include a template in a templated folder name

```
📁 your_template
├── 📄 copier.yml
├── 📄 name-slug.jinja
└── 📁 {% include 'name-slug.jinja' %}
    └── 📄 __init__.py
```

or in a templated file name

```
📁 your_template
├── 📄 copier.yml
├── 📄 name-slug.jinja
└── 📄 {% include 'name-slug.jinja' %}.py
```

or in the templated content of a text file:

```toml
# pyproject.toml.jinja

[project]
name = "{% include 'name-slug.jinja' %}"
```

Similarly, a Jinja macro can be defined and imported, e.g. in copier.yml.

```jinja
slugify.jinja

{# For simplicity ... -#}
{% macro slugify(value) -%}
{{ value|lower|replace(' ', '-') }}
{%- endmacro %}
```

```yaml
# copier.yml

_exclude:
    - slugify

name:
    type: str
    help: A nice human-readable name

slug:
    type: str
    help: A slug of the name
    default: "{% from 'slugify.jinja' import slugify %}{{ slugify(name) }}"
```

or in a templated folder name, in a templated file name, or in the templated content of a text file.

As the number of imported templates and macros grows, you may want to place them in a dedicated directory such as `includes`:

```
📁 your_template
├── 📄 copier.yml
└── 📁 includes
    ├── 📄 name-slug.jinja
    ├── 📄 slugify.jinja
    └── 📄 ...
```

Then, make sure to exclude this folder in `copier.yml`

```yaml
_exclude:
    - includes
```

or use a subdirectory, e.g.:

```yaml
_subdirectory: template
```

To import it you can use either:

```
{% include pathjoin('includes', 'name-slug.jinja') %}
```

or

```
{% from pathjoin('includes', 'slugify.jinja') import slugify %}
```

### [Available settings](https://copier.readthedocs.io/en/latest/configuring/#available-settings)

Remember that the key must be prefixed with an underscore if you use it in the `copier.yml` file.

Check [the source for a complete list of settings](https://copier.readthedocs.io/en/latest/configuring/#available-settings)

### [The `.copier.answers.yml` file](https://copier.readthedocs.io/en/latest/configuring/#the-copier-answersyml-file)

If the destination path exists and a `.copier-answers.yml` file is present there, it will be used to load the last user's answers to the questions made in the `copier.yml` file.

This makes projects easier to update because when the user is asked, the default answers will be the last ones they used.

The file must be called exactly `{{ _copier_conf.answers_file }}.jinja` in your template's root folder to allow applying multiple templates to the same subproject.

The file must have this content:

```yaml
# Changes here will be overwritten by Copier; NEVER EDIT MANUALLY
{{ _copier_answers|to_nice_yaml -}}
```

### [Apply multiple templates to the same subproject](https://copier.readthedocs.io/en/latest/configuring/#applying-multiple-templates-to-the-same-subproject)

Imagine this scenario:

- You use one framework that has a public template to generate a project. It's available at https://github.com/example-framework/framework-template.git.
- You have a generic template that you apply to all your projects to use the same pre-commit configuration (formatters, linters, static type checkers...). You have published that in https://gitlab.com/my-stuff/pre-commit-template.git.
- You have a private template that configures your subproject to run in your internal CI. It's found in git@gitlab.example.com:my-company/ci-template.git.

All 3 templates are completely independent:

- Anybody can generate a project for the specific framework, no matter if they want to use pre-commit or not.
- You want to share the same pre-commit configurations, no matter if the subproject is for one or another framework.
- You want to have a centralized CI configuration for all your company projects, no matter their pre-commit configuration or the framework they rely on.

You need to use a different answers file for each one. All of them contain a `{{ _copier_conf.answers_file }}.jinja` file as specified above. Then you apply all the templates to the same project:

```bash
mkdir my-project
cd my-project
git init
# Apply framework template
copier copy -a .copier-answers.main.yml https://github.com/example-framework/framework-template.git .
git add .
git commit -m 'Start project based on framework template'
# Apply pre-commit template
copier copy -a .copier-answers.pre-commit.yml https://gitlab.com/my-stuff/pre-commit-template.git .
git add .
pre-commit run -a  # Just in case 😉
git commit -am 'Apply pre-commit template'
# Apply internal CI template
copier copy -a .copier-answers.ci.yml git@gitlab.example.com:my-company/ci-template.git .
git add .
git commit -m 'Apply internal CI template'
```

Done!

After a while, when templates get new releases, updates are handled separately for each template:

```bash
copier update -a .copier-answers.main.yml
copier update -a .copier-answers.pre-commit.yml
copier update -a .copier-answers.ci.yml
```

## [Generating a template](https://copier.readthedocs.io/en/latest/generating/)

You can generate a project from a template using the copier command-line tool:

```bash
copier copy path/to/project/template path/to/destination
```

Or within Python code:

```bash
copier.run_copy("path/to/project/template", "path/to/destination")
```

The "template" parameter can be a local path, an URL, or a shortcut URL:

- GitHub: `gh:namespace/project`
- GitLab: `gl:namespace/project`

If Copier doesn't detect your remote URL as a Git repository, make sure it starts with one of `git+https://`, `git+ssh://`, `git@` or `git://`, or it ends with `.git`.

Use the `--data` command-line argument or the `data` parameter of the `copier.run_copy()` function to pass whatever extra context you want to be available in the templates. The arguments can be any valid Python value, even a function.

Use the `--vcs-ref` command-line argument to checkout a particular Git ref before generating the project.

All the available options are described with the `--help-all` option.

## [Updating a project](https://copier.readthedocs.io/en/latest/updating/)

The best way to update a project from its template is when all of these conditions are true:

- The destination folder includes a valid `.copier-answers.yml` file.
- The template is versioned with Git (with tags).
- The destination folder is versioned with Git.

If that's your case, then just enter the destination folder, make sure `git status` shows it clean, and run:

```bash
copier update
```

This will read all available Git tags, will compare them using PEP 440, and will check out the latest one before updating. To update to the latest commit, add `--vcs-ref=HEAD`. You can use any other Git ref you want.

When updating, Copier will do its best to respect your project evolution by using the answers you provided when copied last time. However, sometimes it's impossible for Copier to know what to do with a diff code hunk. In those cases, copier handles the conflict in one of two ways, controlled with the `--conflict` option:

- `--conflict rej`: Creates a separate `.rej` file for each file with conflicts. These files contain the unresolved diffs.
- `--conflict inline` (default): Updates the file with conflict markers. This is quite similar to the conflict markers created when a git merge command encounters a conflict.

If the update results in conflicts, you should review those manually before committing.

You probably don't want to lose important changes or to include merge conflicts in your Git history, but if you aren't careful, it's easy to make mistakes.

That's why the recommended way to prevent these mistakes is to add a pre-commit (or equivalent) hook that forbids committing conflict files or markers. The recommended hook configuration depends on the `conflict` setting you use.

Never update `.copier-answers.yml` manually!!!


If you want to just reuse all previous answers use `copier update --force`.

### [Migration across Copier major versions](https://copier.readthedocs.io/en/latest/updating/#migration-across-copier-major-versions)

When there's a new major release of Copier (for example from Copier 5.x to 6.x), there are chances that there's something that changed. Maybe your template will not work as it did before.

Copier needs to make a copy of the template in its old state with its old answers so it can actually produce a diff with the new state and answers and apply the smart update to the project. To overcome this situation you can:

- Write good [migrations](https://copier.readthedocs.io/en/latest/configuring/#migrations).
- Then you can test them on your template's CI on a matrix against several Copier versions.
- Or you can just [recopy the project](https://copier.readthedocs.io/en/latest/generating/#regenerating-a-project) when you update to a newer Copier major release.

## Tasks and migrations

[tasks](https://copier.readthedocs.io/en/latest/configuring/#tasks) are commands to execute after generating or updating a project from your template. They run ordered, and with the `$STAGE=task` variable in their environment.

```yaml
# copier.yml

_tasks:
    # Strings get executed under system's default shell
    - "git init"
    - "rm {{ name_of_the_project }}/README.md"
    # Arrays are executed without shell, saving you the work of escaping arguments
    - [invoke, "--search-root={{ _copier_conf.src_path }}", after-copy]
    # You are able to output the full conf to JSON, to be parsed by your script
    - [invoke, end-process, "--full-conf={{ _copier_conf|to_json }}"]
    # Your script can be run by the same Python environment used to run Copier
    - ["{{ _copier_python }}", task.py]
    # OS-specific task (supported values are "linux", "macos", "windows" and `None`)
    - >-
      {% if _copier_conf.os in ['linux', 'macos'] %}
      rm {{ name_of_the_project }}/README.md
      {% elif _copier_conf.os == 'windows' %}
      Remove-Item {{ name_of_the_project }}/README.md
      {% endif %}
```

Note: the example assumes you use Invoke as your task manager. But it's just an example. The point is that we're showing how to build and call commands.

[Migrations](https://copier.readthedocs.io/en/latest/configuring/#migrations) are like tasks, but each item in the list is a dict with these keys:

- `version`: Indicates the version that the template update has to go through to trigger this migration. It is evaluated using PEP 440.
- `before` (optional): Commands to execute before performing the update. The answers file is reloaded after running migrations in this stage, to let you migrate answer values.
- `after` (optional): Commands to execute after performing the update.

Migrations will run in the same order as declared in the file (so you could even run a migration for a higher version before running a migration for a lower version if the higher one is declared before and the update passes through both).

They will only run when new `version >= declared version > old version`. And only when updating (not when copying for the 1st time).

If the migrations definition contains Jinja code, it will be rendered with the same context as the rest of the template.

Migration processes will receive these environment variables:

- `$STAGE`: Either before or after.
- `$VERSION_FROM`: Git commit description of the template as it was before updating.
- `$VERSION_TO`: Git commit description of the template as it will be after updating.
- `$VERSION_CURRENT`: The version detector as you indicated it when describing migration tasks.
- `$VERSION_PEP440_FROM`, `$VERSION_PEP440_TO`, `$VERSION_PEP440_CURRENT`: Same as the above, but normalized into a standard PEP 440 version string indicator. If your scripts use these environment variables to perform migrations, you probably will prefer to use these variables.

```yaml
# copier.yml

_migrations:
    - version: v1.0.0
      before:
          - rm ./old-folder
      after:
          # {{ _copier_conf.src_path }} points to the path where the template was
          # cloned, so it can be helpful to run migration scripts stored there.
          - invoke -r {{ _copier_conf.src_path }} -c migrations migrate $VERSION_CURRENT
```

# Developing a copier template

## Avoid doing commits when developing

While you're developing it's useful to see the changes before making a commit, to do so you can use `copier copy -r HEAD ./src ./dst`. Keep in mind that you won't be able to use `copier update` so the changes will be applied incrementally, not declaratively. So if you make a file in an old run that has been deleted in the source, it won't be removed in the destination. It's a good idea then to remove the destination directory often.

## [Apply migrations only once](https://github.com/copier-org/copier/issues/240)

Currently `copier` allows you to run two kind of commands:

- Tasks: that run each time you either `copy` or `update`
- Migrations: That run only on `update`s if you're coming from a previous version

But there [isn't yet a way](https://github.com/copier-org/copier/issues/240) to run a task only on the `copy` of a project. Until there is you can embed inside the generated project's Makefile an `init` target that runs the init script. The user will then need to:

```
copier copy src dest
cd dest
make init
```

Not ideal but it can be a workaround until we have the `pre-copy` tasks.

Another solution I thought of is to:

- Create a tag `0.0.0` on the first valid commit of the template
- Create an initial migration script for version `0.1.0`. 

That way instead of doing `copier copy src dest` you can do:

```bash
copier copy -r 0.0.0 src dest
copier update
```

It will run over all the migrations steps you make in the future. A way to tackle this is to eventually release a `1.0.0` and move the `0.1.0` migration script to `1.1.0` using `copier copy -r 1.0.0 src dest`. 

However, @pawamoy thinks that this can eventually backfire because all the versions of the template will not be backward compatible with 0.0.0. If they are now, they probably won't be in the future. This might be because of the template itself, or because of the extensions it uses, or because of the version of Copier it required at the time of each version release. So this can be OK for existing projects, but not when trying to generate new ones.

## [Create your own jinja extensions](https://github.com/pawamoy/copier-pdm/blob/main/copier.yml)

You can create your own jinja filters. For example [creating an `extensions.py` file](https://github.com/pawamoy/copier-pdm/blob/main/extensions.py) with the contents:

```python
import re
import subprocess
import unicodedata
from datetime import date

from jinja2.ext import Extension


def git_user_name(default: str) -> str:
    return subprocess.getoutput("git config user.name").strip() or default


def git_user_email(default: str) -> str:
    return subprocess.getoutput("git config user.email").strip() or default


def slugify(value, separator="-"):
    value = unicodedata.normalize("NFKD", str(value)).encode("ascii", "ignore").decode("ascii")
    value = re.sub(r"[^\w\s-]", "", value.lower())
    return re.sub(r"[-_\s]+", separator, value).strip("-_")


class GitExtension(Extension):
    def __init__(self, environment):
        super().__init__(environment)
        environment.filters["git_user_name"] = git_user_name
        environment.filters["git_user_email"] = git_user_email


class SlugifyExtension(Extension):
    def __init__(self, environment):
        super().__init__(environment)
        environment.filters["slugify"] = slugify


class CurrentYearExtension(Extension):
    def __init__(self, environment):
        super().__init__(environment)
        environment.globals["current_year"] = date.today().year
```

Then you can [import it in your `copier.yaml` file](https://github.com/pawamoy/copier-pdm/blob/main/copier.yml):

```yaml
_jinja_extensions:
    - copier_templates_extensions.TemplateExtensionLoader
    - extensions.py:CurrentYearExtension
    - extensions.py:GitExtension
    - extensions.py:SlugifyExtension


author_fullname:
  type: str
  help: Your full name
  default: "{{ 'Timothée Mazzucotelli' | git_user_name }}"

author_email:
  type: str
  help: Your email
  default: "{{ 'pawamoy@pm.me' | git_user_email }}"

repository_name:
  type: str
  help: Your repository name
  default: "{{ project_name | slugify }}"
```

You'll need to install `copier-templates-extensions`, if you've installed `copier` with pipx you can:

```bash
pipx inject copier copier-templates-extensions
```

# References

- [Source](https://github.com/copier-org/copier)
- [Docs](https://copier.readthedocs.io/en/latest/)
- [Example templates](https://github.com/topics/copier-template)
