---
title: Gettext
date: 20220513
author: Lyz
---

[Gettext](https://docs.python.org/3/library/gettext.html) is the defacto
universal solution for [internationalization](python_internationalization.md)
(I18N) and localization (L10N), offering a set of tools that provides
a framework to help other packages produce multi-lingual messages. It gives an
opinionated way of how programs should be written to support translated message
strings and a directory and file naming organisation for the messages that need
to be translated.

In regards to directory conventions, we need to have a place to put our
localised translations based on the specified locale language. For example,
let’s say we need to support 2 languages English and Greek. Their language codes
are `en` and `el` respectively.

We can create a directory named `locales` and inside we need to create
directories for each language code and each folder will contain another
directory named each `LC_MESSAGES`  with one or multiple `.po` files.

So, the file structure should look like this:

```
locales/
├── el
│   └── LC_MESSAGES
│       └── base.po
└── en
    └── LC_MESSAGES
        └── base.po
```

A PO file contains a number of messages, partly independent text segments to be
translated, which have been grouped into one file according to some logical
division of what is being translated. Those groups are called domains. In the
example above, we have only one domain named as `base`. The PO files themselves
are also called message catalogs. The PO format is a plain text format.

Apart from PO files, you might sometimes encounter `.mo` files. MO, or Machine
Object is a binary data file that contains object data referenced by a program.
It is typically used to translate program code, and can be loaded or imported
into the GNU gettext program.

In addition, there are also `.pot` files. These are the template files for PO
files. They will have all the translation strings left empty. A POT file is
essentially an empty PO file without the translations, with just the original
strings. In practice we have the `.pot` files be generated from some tools and we
should not modify them directly.

# Usage

The `gettext` module comes shipped with Python. It exposes two APIs. The first
one is the basic API that supports the GNU gettext catalog API. The second one
is the higher level one, class-based API that may be more appropriate for Python
files. The class bases API offers more flexibility and greater convenience than
the GNU gettext API and it is the recommended way of localizing your Python
applications and modules.

In order to provide multilingual messages for your Python programs, you need to
take the next steps:

* Mark all translatable strings in your program with a wrapper function.
* Run a suite of tools over your marked files to generate raw messages catalogs
    or POT files.
* Duplicate the POT files into specific locale folders and write the
    translations.
* Import and use the gettext module so that message strings are properly
    translated.

Let’s start with a function that prints some strings.

```python
# main.py
def print_some_strings():
    print("Hello world")
    print("This is a translatable string")

if __name__ == '__main__':
    print_some_strings()
```

Now as it is you cannot provide localization options using `gettext`.

The first step is to specially mark all translatable strings in the program. To
do that we need to wrap all the translatable strings inside `_()`.

```python
# main.py
import gettext
_ = gettext.gettext
def print_some_strings():
    print(_("Hello world"))
    print(_("This is a translatable string"))
if __name__=='__main__':
    print_some_strings()
```

Notice that we imported `gettext` and assigned `_`  as `gettext.gettext`. This
is to ensure that our program compiles as well.

If you run the program, you will see that nothing has changed:

```bash
$: python main.py
Hello world
This is a translatable string
```

However, now we are able to proceed to the next steps which are extracting the
translatable messages in a POT file.

## Create the POT files

For the purpose of automating the process of generating raw translatable
messages from wrapped strings throughout the applications, the `gettext` library
authors have provided a set to tools that help to parse the source files and to
extract the messages in a general message catalog.

The Python distribution includes some specific programs called `pygettext.py`
and `msgfmt.py` that recognize only python source code and not other languages.

Call it specifying the file you want to parse the strings for:

```bash
$: pygettext -d base -o locales/base.pot src/main.py
```

If you want to search for other strings than `_`, use the `-k` flag, for example
`-k gettext`.

That will generate a `base.pot` file in the `locales` directory taken from our
`main.py` program. Remember that POT files are just templates and we should not
touch them. Let us inspect the contents of the `base.pot` file:

```
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR ORGANIZATION
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"POT-Creation-Date: 2018-01-28 16:47+0000\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Generated-By: pygettext.py 1.5\n"
#: src/main.py:5
msgid "Hello world"
msgstr ""
#: src/main.py:6
msgid "This is a translatable string"
msgstr ""
```

In a bigger program, we would have many translatable strings following.  Here we
specified a domain called base because the application is only one file. In
bigger ones, I would use multiple domains in order to logically separate the
different messages based on the application scope.

Notice that we have a simple convention for our translatable strings. `msgid` is
the original string wrapped in `_()` . `msgstr` is the translation we need to
provide.

## Create the PO files

Now we are ready to create our translations. Because we have the template
generated for us, the next step is to create the required directory structure
and copy the template into the right spot. We’ve seen the recommended file
structure before. We are going to create 2 additional directories inside
`locales` with the structure `locales/$language/LC_MESSAGES/$domain.po`

Where:

* `$language` is the language identifier such as `en` or `el`
* `$domain` is `base`.

Copy and rename the `base.pot` into the following directories
`locales/en/LC_MESSAGES/base.po` and `locales/el/LC_MESSAGES/base.po`. Then
modify their headers to include more information about the locale. For example,
this is the Greek translation.

```
# My App.
# Copyright (C) 2018
#
msgid ""
msgstr ""
"Project-Id-Version: 1.0\n"
"POT-Creation-Date: 2018-01-28 16:47+0000\n"
"PO-Revision-Date: 2018-01-28 16:48+0000\n"
"Last-Translator: me <johndoe@example.com>\n"
"Language-Team: Greek <yourteam@example.com>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Generated-By: pygettext.py 1.5\n"
#: main.py:5
msgid "Hello world"
msgstr "Χέρε Κόσμε"
#: main.py:6
msgid "This is a translatable string"
msgstr "Αυτό είναι ένα μεταφραζόμενο κείμενο"
```

## Updating POT and PO files

Once you add more strings or change some strings in your program, you execute
again `pygettext` which regenerates the template file:

```bash
pygettext main.py -o po/hello.pot
```

Then you can update individual translation files to match newly created
templates (this includes reordering the strings to match new template) with
[`msgmerge`](https://www.gnu.org/software/gettext/manual/html_node/msgmerge-Invocation.html):

```bash
msgmerge --previous --update po/cs.po po/hello.pot
```

## Create the MO files

The catalog is built from the `.po` file using a tool called `msgformat.py`.
This tool will parse the `.po` file and generate an equivalent `.mo` file.

```bash
$: msgfmt -o base.mo base
```

This command will generate a `base.mo` file in the same folder as the `base.po` file.

So, the final file structure should look like this:

```
locales
├── el
│   └── LC_MESSAGES
│       ├── base.mo
│       └── base.po
├── en
│   └── LC_MESSAGES
│       ├── base.mo
│       └── base.po
└── base.pot
```

## Switching Locale

To have the ability to switch locales in our program we need to actually use the
Class based `gettext` API. One of it's methods is `gettext.translation`, it
accepts some parameters that can be used to load the associated `.mo` files of
a particular language. If no `.mo` file is found, it raises an error.

Add the following code to the program:

```python
import gettext
el = gettext.translation('base', localedir='locales', languages=['el'])
el.install()
_ = el.gettext # Greek
```

The first argument base is the domain and the method will look for a `.po`  file
with the same name in our locale directory. If you don’t specify a domain it will
fallback to the messages domain. The `localedir` parameter is the directory
location of the `locales` directory you created. The `languages` parameter is a hint for the searching mechanism to load particular language code more resiliently.

If you run the program again you will see the translations happening:

```bash
$ python main.py
Χαίρε Κόσμε
Αυτό είναι ένα μεταφραζόμενο κείμενο
```

The install method will cause all the `_()` calls to return the Greek
translated strings globally into the built-in namespace. This is because we
assigned `_` to point to the Greek dictionary of translations. To go back to the
English just assign `_` to be the original `gettext` object.

```python
_ = gettext.gettext
```

## Finding Message Catalogs

When there are cases where you need to locate all translation files at runtime,
you can use the `find` function as provided by the class-based API. This function
takes a few parameters in order to retrieve from the disk a list of `.mo` files
available.

You can pass a `localedir`, a `domain` and a list of `languages`. If you don’t,
the library module will use the respective defaults, which is not what you
intended to do in most cases. For example, if you don’t specify a `localdir`
parameter, it will fallback to `sys.prefix + ‘/share/locale’`  which is a global
locale dir that can contain a lot of random files.

The `language` portion of the path is taken from one of several environment
variables that can be used to configure localization features (LANGUAGE, LC_ALL,
LC_MESSAGES, and LANG). The first variable found to be set is used. Multiple
languages can be selected by separating the values with a colon :.

```python
>>> os.environ['LANGUAGE']='el:en'
>>> gettext.find('base', 'locales')
'locales/el/LC_MESSAGES/base.mo'
>>> gettext.find('base', 'locales', all=True)
 ['locales/el/LC_MESSAGES/base.mo', 'locales/en/LC_MESSAGES/base.mo']
```

## [Using f-strings](https://stackoverflow.com/questions/49797658/how-to-use-gettext-with-python-3-6-f-strings)

You can't use f-strings inside `gettext`, you'll get an `Seen unexpected token
"f"` error, you need to use the old `format` method:

```python
_('Hey {},').format(username)
```

# Integrations

You can use it with
[weblate](https://docs.weblate.org/en/latest/devel/gettext.html).

# References

* [Homepage](https://docs.python.org/3/library/gettext.html)
* [Reference](https://docs.python.org/3/library/gettext.html)
* [Phrase blog on Localizing with GNU gettext](https://phrase.com/blog/posts/translate-python-gnu-gettext/)
