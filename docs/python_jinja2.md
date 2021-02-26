---
title: Jinja2
date: 20210225
author: Lyz
---

[Jinja2](https://jinja.palletsprojects.com) is a modern and designer-friendly
templating language for Python, modelled after Django’s templates. It is fast,
widely used and secure with the optional sandboxed template execution
environment:

```jinja2
<title>{% block title %}{% endblock %}</title>
<ul>
{% for user in users %}
  <li><a href="{{ user.url }}">{{ user.username }}</a></li>
{% endfor %}
</ul>
```

Features:

* Sandboxed execution.
* Powerful automatic HTML escaping system for XSS prevention.
* Template inheritance.
* Compiles down to the optimal python code just in time.
* Optional ahead-of-time template compilation.
* Easy to debug. Line numbers of exceptions directly point to the correct line
    in the template.
* Configurable syntax.

# [Installation](https://jinja.palletsprojects.com/en/2.11.x/intro/#installation)

```bash
pip install Jinja2
```

# Usage


The most basic way to create a template and render it is through `Template`. This
however is not the recommended way to work with it if your templates are not
loaded from strings but the file system or another data source:

```python
>>> from jinja2 import Template
>>> template = Template('Hello {{ name }}!')
>>> template.render(name='John Doe')
u'Hello John Doe!'
```
Jinja uses a central object called the template
[`Environment`](https://jinja.palletsprojects.com/en/2.11.x/api/#jinja2.Environment).
Instances of this class are used to store the configuration and global objects,
and are used to load templates from the file system or other locations.

The simplest way to configure Jinja to load templates for your application looks
roughly like this:

```python
from jinja2 import Environment, PackageLoader, select_autoescape
env = Environment(
    loader=PackageLoader('yourapplication', 'templates'),
    autoescape=select_autoescape(['html', 'xml'])
)
```

This will create a template environment with the default settings and a loader
that looks up the templates in the templates folder inside the `yourapplication`
python package. Different loaders are available and you can also write your own
if you want to load templates from a database or other resources. This also
enables autoescaping for HTML and XML files.

To load a template from this environment you just have to call the
get_template() method which then returns the loaded Template:

```python
template = env.get_template('mytemplate.html')
```

To render it with some variables, just call the `render()` method:

```python
print(template.render(the='variables', go='here'))
```

# Template guidelines

## Variables

Reference variables using `{{ braces }}` notation.

## Iteration/Loops

One in each line:

```jinja2
{% for host in groups['tag_Function_logdb'] %}
elasticsearch_discovery_zen_ping_unicast_hosts = {{ host }}:9300
{% endfor %}
```

Inline:

```jinja2
ALLOWED_HOSTS = [{% for domain in domains %}" {{ domain }}",{% endfor %}]
```

### [Get the counter of the iteration](https://stackoverflow.com/questions/12145434/how-to-output-loop-counter-in-python-jinja-template)

```python
>>> from jinja2 import Template

>>> s = "{% for element in elements %}{{loop.index}} {% endfor %}"
>>> Template(s).render(elements=["a", "b", "c", "d"])
1 2 3 4
```

## Lookup

### Get environmental variable

```jinja2
lookup('env','HOME')
```

## Join

```jinja2
lineinfile: dest=/etc/hosts line="{{ item.ip }} {{ item.aliases|join(' ') }}"
```

## Map

Get elements of a dictionary

```yaml
  set_fact: asg_instances="{{ instances.results | map(attribute='instances') | map('first') | map(attribute='public_ip_address') | list}}"
```

## Default

Set default value of variable

```yaml
name: 'lol'
new_name: "{{ name | default('trol') }}"
```

## Rejectattr

Exclude elements from a list.

Filters a sequence of objects by applying a test to the specified attribute of
each object, and rejecting the objects with the test succeeding.

If no test is specified, the attribute's value will be evaluated as a boolean.

```jinja2
{{ users|rejectattr("is_active") }}
{{ users|rejectattr("email", "none") }}
```

## Regex

```jinja2
{{ 'ansible' | regex_replace('^a.*i(.*)$', 'a\\1') }}
{{ 'foobar' | regex_replace('^f.*o(.*)$', '\\1') }}
{{ 'localhost:80' | regex_replace('^(?P<host>.+):(?P<port>\\d+)$', '\\g<host>, \\g<port>') }}
```

## Slice string

```jinja2
{{ variable_name[:-8] }}
```

## Conditional

### [Conditional variable definition](https://stackoverflow.com/questions/14214942/python-jinja2-shorthand-conditional)

```yaml
{{ 'Update' if files else 'Continue' }}
```

### Check if variable is defined

```yaml
{% if variable is defined %}
Variable: {{ variable }} defined
{% endif %}
```

### With two statements:

```yaml
{% if (backend_environment == 'backend' and environment == 'Dev'): %}

{% elif ... %}
{% else %}
{% endif %}
```

## Extract extension from file

```jinja2
s3_object        : code/frontal/vodafone-v8.18.81.zip
remote_clone_dir : "{{deploy_dir}}/{{ s3_object | basename | splitext | first}}"
```

## Comments

`{# comment here #}`

## Inheritance

For simple inclusions use `include` for more complex `extend`.

### Include

To include a snippet from another file you can use
```jinja2
{% include '_post.html' %}
```

### Extend

To inherit from another document you can use the `block` control statement.
Blocks are given a unique name, which derived templates can reference when they
provide their content

.base.html
```html
<html>
    <head>
      {% if title %}
      <title>{{ title }} - Microblog </title>
      {% else %}
      <title>Welcome to Microblog</title>
      {% endif %}
    </head>
    <body>
        <div>
          Microblog: <a href="/index">Home</a>
        </div>
        <hr>
        {% block content %}{% endblock %}
    </body>
</html>
```
.index.html
```html
{% extends "base.html" %}

{% block content %}
  <h1>Hi</h1>
{% endblock %}
```

## Execute a function and return the value to a variable

```jinja2
{% with messages = get_flashed_messages() %}
{% if messages %}
<ul>
  {% for message in messages %}
  <li>{{ message }}</li>
  {% endfor %}
</ul>
{% endif %}
{% endwith %}
```

## [Macros](https://jinja.palletsprojects.com/en/2.11.x/templates/#macros)

Macros are comparable with functions in regular programming languages. They are
useful to put often used idioms into reusable functions to not repeat yourself
(“DRY”).

```jinja2
{% macro input(name, value='', type='text', size=20) -%}
    <input type="{{ type }}" name="{{ name }}" value="{{
        value|e }}" size="{{ size }}">
{%- endmacro %}
```

The macro can then be called like a function in the namespace:

```jinja2
<p>{{ input('username') }}</p>
<p>{{ input('password', type='password') }}</p>
```

## [Wrap long lines and indent](https://stackoverflow.com/questions/55066246/wrapping-long-text-sections-in-jinja2)

You can prepend the given string with a newline character, then use the
[`wordwrap`](https://jinja.palletsprojects.com/en/2.11.x/templates/?highlight=wordwrap#wordwrap)
filter to wrap the text into multiple lines first, and use the replace filter to
replace newline characters with newline plus '    ':

```jinja2
{{ ('\n' ~ item.comment) | wordwrap(76) | replace('\n', '\n    ') }}
```

The above assumes you want each line to be no more than 80 characters. Change 76
to your desired line width minus 4 to leave room for the indentation.

## [Test if variable is None](https://stackoverflow.com/questions/19614027/jinja2-template-variable-if-none-object-set-a-default-value)

Use the `none` test (not to be confused with Python's `None` object!):

```jinja2
{% if p is not none %}
    {{ p.User['first_name'] }}
{% else %}
    NONE
{% endif %}
```

# References

* [Docs](https://jinja.palletsprojects.com)
