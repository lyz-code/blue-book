---
title: Vim tabs
date: 20210318
author: Lyz
---

!!! note "This article is almost a copy paste of [joshldavis post](http://joshldavis.com/2014/04/05/vim-tab-madness-buffers-vs-tabs/)"

First I have to admit, I was a heavy user of tabs in Vim.

I was using tabs in Vim as you’d use tabs in most other programs (Firefox,
Terminal, Adium, etc.). I was used to the idea of a tab being the place where
a document lives.

When you want to edit a document, you open a new tab and edit away! That’s how
tabs work so that must be how they work in Vim right?

Nope.

# Stop the Tab Madness

If you are using tabs like this then you are really limiting yourself and
using a feature of Vim that wasn't meant to work like this.

Before I explain that, let’s be sure we understand what a buffer is in Vim as
well as a few other basic things.

After that, I’ll explain the correct way to use tabs within Vim.

# Buffers

A buffer is nothing more than text that you are editing. For example, when you
open a file, the content of the file is loaded into a buffer. So when you
issue this command:

```bash
vim .vimrc
```

You are actually launching Vim with a single buffer that is filled with the
contents of the `.vimrc` file.

Now let’s look at what happens when you try to edit multiple files. Let’s
issue this command:

```bash
vim .vimrc .bashrc
```

In Vim run `:bnext`

Vim does what it did before, but instead of just 1 buffer, it opens another
buffer that is filled with `.bashrc`. So now we have two buffers open.

If you want to pause editing `.vimrc` and move to `.bashrc`, you could run this
command in Vim `:bnext` which will show the `.bashrc` buffer. There are various
other commands to manipulate buffers which you can see if you type `:h
buffer-list`. Or you can use [easymotion](vim_plugins.md#vim-easymotion).

# Windows

A window in Vim is just a way to view a buffer. Whenever you create a new
vertical or horizontal split, that is a window. For example, if you were to
type in `:help window`, it would launch a new window that shows the help
documentation.

The important thing to note is that a window can view any buffer it wishes; it
isn't forced to look at the same buffer. When editing a file, if we type
`:vsplit`, we will get a vertical split and in the other window, we will see the
current buffer we are editing.

That should no longer be confusing because a window lets us look at any
buffer. It just so happens that when creating a new split: `:split` or
`:vsplit`, the buffer that we view is just the current one.

By running any of the buffer commands from `:h buffer-list`, we can modify
which buffer a window is viewing.

For an example of this, by running the following commands, we will start
editing two files in Vim, open a new window by horizontally splitting, and
then view the second buffer in the original window.

```bash
vim .vimrc .bashrc
```

In Vim run: `:split` and `:bnext`

# So a Tab is…?

So now that we know what a buffer is and what a window is. Here is what Vim
says in the Vim documentation regarding a buffer/window/tab:

Summary:

* A buffer is the in-memory text of a file.
* A window is a viewport on a buffer.
* A tab page is a collection of windows.

According to the documentation, a tab is just a collection of windows. This
goes back to our earlier definition in that a tab is really just a layout.

A tab is only designed to give you a different layout of windows.

# The Tab Problem

Tabs were only designed to let us have different layouts of windows. They
aren't intended to be where an open file lives; an open file is instead loaded
into a buffer.

If you can view the same buffer across all tabs, how is this like a normal tab
in most other editors?

If you try to force a single tab to point to a single buffer, that is just
futile. Vim just wasn't meant to work like this.

# The Buffer Solution

To reconcile all of this and learn how to use Vim’s buffers/windows
effectively, it might be useful to stop using tabs altogether until you
understand how to edit with just using buffers/windows.

The first thing I did was install a plugin that allows me to visualize all the
buffers open across the top. I use [bufferline](https://github.com/bling/vim-bufferline)
for this.

Instead of replicating tabs across the top like we did in the previous
solution, we are instead going to use the power of being able to open many
buffers simultaneously without worrying about which ones are open.

In my experience, [CtrlP](https://github.com/ctrlpvim/ctrlp.vim) gives a powerful fuzzy
finder to navigate through the buffers.

Instead of worrying about closing buffers and managing your pseudo-tabs that
was mentioned in the previous solution, you just open files that you want to
edit using CtrlP and don't worry about closing buffers or how many you have
opened.

When you are done editing a file, you just save it and then open CtrlP and
continue onto the next file.

CtrlP offers a few different ways to fuzzy find. You can use the following
fuzziness:

* Find in your current directory.
* Find within all your open buffers.
* Find within all your open buffers sorted by Most Recently Used (MRU).
* Find with a mix of all the above.

# Using Tabs Correctly

This doesn't mean you should stop using tabs altogether. You should just use
them how Vim intended you to use them.

Instead you should use them to change the layout among windows. Imagine you
are working on a C project. It might be helpful to have one tab dedicated to
normal editing, but another tab for using a vertical split for the file.h and
file.c files to make editing between them easier.

Tabs also work really well to divide up what you are working on. You could be
working on one part of the project in one tab and another part of the project
in another tab.

Just remember though, if you are using a single tab for each file, that isn't
how tabs in Vim were designed to be used.

# Default option when switching

The default behavior when trying to switch the buffer is to not allow you to
change buffer if it's not saved, but we can change it if we set one of the next
options:

* `set hidden`: allow to switch buffers even though it's changes aren't saved.
* `set autowrite`: Auto save when switching buffers.

# Share buffers and all vim information between vim instances.

This is not my ideal behavior, nvim should let the user use the window manager
to manage the windows... duh, instead of vsplitting buffers or using tabs.

But sadly as of Nvim 0.1.7 and Vim 8.0 [it's not
implemented](https://superuser.com/questions/234708/using-vim-gvim-with-multiple-gui-windows).
You have the `--server` option but it only sends files to the already opened vim
instance.  you can't connect two vim instances to the same buffer pool.

It's been discussed in neovim [1](https://github.com/neovim/neovim/issues/2161),
[2](https://github.com/neovim/neovim/issues/3119).

> Currently gVim cannot have separate 'toplevel' windows for the same
> process/session. There is a TODO item to implement an inter-process
> communication system between multiple Vim instances to make it behave as
> though the separate processes are unified. (See :help todo and search for
> "top-level".)

There is an interesting
[hax](https://www.reddit.com/r/vim/comments/3hh42z/can_i_replace_vims_windows_with_a_tiling_window/cuc8gk5/)
formalized in [here](https://github.com/teto/i3-dispatch) which I will want to
have time to test.

Another solution would be to try to use [neovim remote](https://github.com/mhinz/neovim-remote)
