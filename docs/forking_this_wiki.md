---
title: How to create your own wiki from this one
date: 2021-04-08
tags: [ 'wiki' ]
---

Follow the next steps.

## Download the repository

On your terminal, clone this repository with:

```bash
git clone https://github.com/lyz-code/blue-book.git
```

I recommend against forking the repository via Github. If you do that, you'll have all the history of my repository, which will make your repository more heavy than it should (as I have a lot of images), and it will make it hard for me to make pull requests to your digital garden.

Furthermore, you'll always see a message in your repo similar to `This branch is 909 commits ahead, 1030 commits behind lyz-code:master. ` like you can see in [this fork](https://github.com/m0wer/memento). Also if you don't want to keep all the content I've made so far and want to start from scratch then the only thing that is useful for you is the skeleton I've made, and I don't need any attribution or credit for that :P.

If on the other hand you do want to keep all my content, then wouldn't it be better to just make contributions to this repository instead?

Therefore the best way to give credit and attribution is by building your garden (the more we are writing the merrier :) ), and then if you want to spread the word that my garden exists within your content then that would be awesome.

If you end up building your own, remember to add yourself to the [digital
garden's list](https://github.com/lyz-code/best-of-digital-gardens).

## Adaptations

### Project name and repository URL

There are several files that contain references to this repository's name and URL, which is
different to the new forked repository URL, since the user name and the repository name
might have changed. As of now, the files where you should replace the references are:

* `README.md`
* `mkdocs.yml`
* `theme/main.html`

Blue book is the name of my personal digital garden, try to find a different
name for your project that is meaningful to you.

### Documents and structure

You can either use the documents of this wiki and extend them, or change the
structure by editing the  `nav` section of the `mkdocs.yml` file. If you want to
start from scratch, remove everything on the `docs` directory.

If you're worried about giving credit to the blue-book then you can link each
section of a document from wherever you took the information, or add a link to
the bottom of the documents under a References section. Take for example the
[Python snippets
document](https://lyz-code.github.io/blue-book/coding/python/python_snippets),
each section has a link to where I took the info from. You could do the same on
the articles you got from my book by linking to them.

### Remove the newsletter feature

The [newsletter
feature](https://lyz-code.github.io/blue-book/newsletter/0_newsletter_index/)
allows your readers to keep updated on the changes of your garden. If you don't
want them:

* Remove the plugin `mkdocs-newsletter` from the `requirements.in` and
    `mkdocs.yaml` files.
* Remove the references both to header and footer. To do that, undo the steps described
    [here](https://lyz-code.github.io/mkdocs-newsletter/install/#mkdocs-configuration-enhancements).
* Remove the cron configuration of the `.github/workflows/gh-pages.yml`
    pipeline:

    ```yaml
    schedule:
        - cron: 11 06 * * *
    ```

## Dependencies

In order to be able to build your site, some Python dependencies are needed. You
can install them by running

```bash
make update
```

## Checking how it looks

First, clean the old generated site with

```bash
make clean
```

Then, you can preview the site on your local machine by running

```bash
make
```

and then opening the link in your web browser.

## Set up the Github repository

On GitHub create a new repository by clicking on the `+` symbol on the top right
and then `New Repository`.


## Removing the old commits

The [mkdocs-newsletter](https://github.com/lyz-code/mkdocs-newsletter/) plugin
uses the commit history to generate the newsletter articles, so if you want to start the newsletter from scratch, a way of doing so is removing the commit history.

A way of doing so is removing the *.git* folder and re-initializing the repository.
Within the repository directory do

```bash
rm -rf .git
git init
git remote add origin git@github.com:your_username/your_project_name.git
git add .
git commit -m "Initial commit"
git push --set-upstream origin master
```

Remember to change `your_username` and `your_project_name` to your real values.

## Setting up GitHub Pages

To enable the Github Pages website associated with your repo, follow these steps:

* [Create SSH Deploy Key](https://github.com/peaceiris/actions-gh-pages#-create-ssh-deploy-key).
* Activate the GitHub Pages repository configuration with the `gh-pages` branch.

Now, the site will be built whenever you push new commits and periodically,
according to the `cron` configuration from *.github/workflows/gh-pages.yml*.
