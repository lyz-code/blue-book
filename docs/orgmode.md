[`nvim-orgmode`](https://github.com/nvim-orgmode/orgmode#agenda) is a Orgmode clone written in Lua for Neovim. Org-mode is a flexible note-taking system that was originally created for Emacs. It has gained wide-spread acclaim and was eventually ported to Neovim. This page is heavily focused to the nvim plugin, but you can follow the concepts for emacs as well.

If you use Android try [orgzly](orgzly.md).

# [Installation](https://github.com/nvim-orgmode/orgmode#installation)

Add to your plugin config:

```lua
use {'nvim-orgmode/orgmode', config = function()
  require('orgmode').setup{}
end
}
```

Then install it with `:PackerInstall`.

Tweak the configuration:

```lua
-- init.lua

-- Load custom treesitter grammar for org filetype
require('orgmode').setup_ts_grammar()

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop,
  -- highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    -- Required for spellcheck, some LaTex highlights and
    -- code block highlights that do not have ts grammar
    additional_vim_regex_highlighting = {'org'},
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require('orgmode').setup({
  org_agenda_files = {'~/Dropbox/org/*', '~/my-orgs/**/*'},
  org_default_notes_file = '~/Dropbox/org/refile.org',
})
```

You can check the default configuration file [here](https://github.com/nvim-orgmode/orgmode/blob/master/lua/orgmode/config/defaults.lua).

## [Key bindings](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#mappings)

Mappings or Key bindings can be changed on the `mappings` attribute of the `setup`. The program has these kinds of mappings:

* [Org](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org-mappings)
* [Agenda](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#agenda-mappings)
* [Capture](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#capture-mappings)
* [Global](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#global-mappings)

For example the `global` mappings live under `mappings.global` and can be overridden like this:

```lua
require('orgmode').setup({
  mappings = {
    global = {
      org_agenda = 'gA',
      org_capture = 'gC'
    }
  }
})
```

## Be ready when breaking changes come

The developers have [created an issue](https://github.com/nvim-orgmode/orgmode/issues/217) to track breaking changes, subscribe to it so you're notified in advance.

# Usage

If you are new to Orgmode, check the [vim Dotoo video](https://www.youtube.com/watch?v=nsv33iOnH34), it's another plugin but the developers say it's the same. If you, like me, prefer written tutorials check the hands-on [tutorial](https://github.com/nvim-orgmode/orgmode/wiki/Getting-Started).

If you get lost in any view you can use `g?` to get the mappings of the view.

## Org File

### Headings

Any line starting with one or more asterisks `*` but without any preceding whitespace is a heading (also called headline).

```org
* Org Bullets
* Vim table-mode
```

Once you are over a header, you can create a new header at the same level below the current subtree `<leader><enter>`, if you want to add a heading after the current item use `<control><enter>` if you use these [key bindings](#key-bindings):

```lua
require('orgmode').setup({
  mappings = {
    org = {
      org_meta_return = '<c-cr>',
      org_insert_heading_respect_content = '<leader><cr>',
    }
  }
})
```

To be able [to use it in insert mode](https://github.com/nvim-orgmode/orgmode/issues/70) too add below the org-mode configuration:

```lua
vim.cmd[[
  imap <c-cr> <c-o><c-cr>
  imap <leader><cr> <c-o><leader><cr>
]]
```

The number of asterisks denotes the level of the heading: the more asterisks, the deeper the level. That is how we achieve nested structures in our org files.

```org
* Org Bullets
** Synopsis
* Vim table-mode
```

The content within a heading can be free form text, include links, be a list, or any combination thereof. For example:

```org
* Org Bullets
** Synopsis
   This plugin is a clone of org-bullets. It replaces the asterisks in org
   syntax with unicode characters.
* Vim table-mode
```

The full syntax for a headline is

```
STARS KEYWORD PRIORITY TITLE TAGS
*     TODO    [#A]     foo   :bar:baz:
```

Where:

* `KEYWORD`: if present, turns the heading into a [`TODO` item](#todo-items). 
* `PRIORITY` sets a [priority level](#priority) to be used in the Agenda.
* `TITLE` is the main body of the heading.
* `TAGS` is a colon surrounded and delimited list of [tags](#tags) used in searching in the Agenda.

#### Toogle line to headline

You can change a text line into a headline with `<leader>h` (Default: `<leader>o*`) with the next configuration:

```lua
org = {
  org_toggle_heading = '<leader>h',
}
```

If you have a checkbox inside a TODO item, it will transform it to a children TODO item.

#### Change heading level

To change the heading level use `<<` or `>>`. It doesn't work in visual mode though, if you want to change the level of the whole subtree you can use `<S` and `>S`. 

```lua
org = {
  org_do_promote = '<<',
  org_do_demote = '>>',
  org_promote_subtree = '<S',
  org_demote_subtree = '>S',
}
```

To be able [to use it in insert mode](https://github.com/nvim-orgmode/orgmode/issues/70) too add below the org-mode configuration:

```lua
vim.cmd[[
  imap >> <esc>>>
  imap << <esc><<
  imap >S <esc>>s
  imap <S <esc><s

]]
```

If you don't like seeing so many stars, you can enable the `org_hide_leading_stars = true` option. To me it looks much cleaner.

#### Moving headings

To move the subtrees up and down you can use `J` (Default `<leader>oJ`) and `K` (Default `<leader>oK`) with the next conf:

```lua
    org = {
      org_move_subtree_up = "K",
      org_move_subtree_down = "J",
    }
```

#### Folding headings

To fold the headings you can use either the normal vim bindings `zc`, `zo`, `zM`, ... or `<tab>` to toogle the fold of an element or `<shift><tab>` to toogle the whole file.

#### Navigate through headings

It's easy to navigate through your heading tree with:

* Next/previous heading of any level with `<control>j`/`<control>k` (Default `}`/`{`)
* Next/previous heading of the same level with `<control>n`/`<control>p` (Default `]]`/`[[`)
* Go to the parent heading with `gp` (Default `g{`)

```lua
org = {
  org_next_visible_heading = '<c-j>',
  org_previous_visible_heading = '<c-k>',
  org_forward_heading_same_level = '<c-n>',
  org_backward_heading_same_level = '<c-p>',
  outline_up_heading = 'gp',
}
```

To be able [to use it in insert mode](https://github.com/nvim-orgmode/orgmode/issues/70) too add below the org-mode configuration:

```lua
vim.cmd[[
  imap <c-j> <esc><c-j>
  imap <c-k> <esc><c-k>
  imap <c-n> <esc><c-n>
  imap <c-p> <esc><c-p>
]]
```

### TODO items

`TODO` items are meant to model tasks that evolve between states. 

As creating `TODO` items is quite common you can:

* Create an item with the same level as the item above in the current position with `;t` (by default is `<leader>oit`).
* Create an item with the same level as the item above after all the children of the item above with `;T` (by default is `<leader>oit`).

```lua
org = {
  org_insert_todo_heading = ";t",
  org_insert_todo_heading_respect_content = ";T",
}
```

To be able [to use it in insert mode](https://github.com/nvim-orgmode/orgmode/issues/70) too add below the org-mode configuration:

```lua
vim.cmd[[
  imap ;t <c-o>;t
  imap ;T <c-o>;T
]]
```

You can transition the state forward and backwards by using `t`/`T` (Default: `cit`/`ciT`) if you use:

```lua
org = {
  org_todo = 't',
  org_todo_prev = 'T',
}
```

#### TODO state customization

By default they are `TODO` or `DONE` but you can define your own using the `org_todo_keywords` configuration. It accepts a list of *unfinished* states and *finished* states separated by a `'|'`. For example:

```lua
org_todo_keywords = { 'TODO', 'NEXT', '|', 'DONE' }
```

You can also use [fast access states](https://orgmode.org/manual/Fast-access-to-TODO-states.html#Fast-access-to-TODO-states):

```lua
org_todo_keywords = { 'TODO(t)', 'NEXT(n)', '|', 'DONE(d)' }
```

Sadly you can't [yet use different todo sequences](https://github.com/nvim-orgmode/orgmode/issues/250).

### Priority

TODO items can also have a priority, by default you have 3 levels `A`, `B` and `C`. If you don't set a priority it's set to `B`.

You can increase/decrease the priority with `=`/`-` (Default: `ciR`/`cir`):

```lua
org = {
  org_priority_up = '-',
  org_priority_down = '=',
}
```

I feel more comfortable with these priorities:

- `A`: Critical
- `B`: High
- `C`: Normal
- `D`: Low

This gives you room to usually work on priorities `B-D` and if something shows up that is really really important, you can use `A`. You can set this setting with the next snippet:

```lua
require('orgmode').setup({
  org_priority_highest = 'A',
  org_priority_default = 'C',
  org_priority_lowest = 'D',
})
```

### [Dates](https://orgmode.org/manual/Deadlines-and-Scheduling.html)

TODO items can also have [timestamps](https://orgmode.org/manual/Timestamps.html) which are specifications of a date (possibly with a time or a range of times) in a special format, either `<2003-09-16 Tue>` or `<2003-09-16 Tue 09:39>` or `<2003-09-16 Tue 12:00-12:30>`. A timestamp can appear anywhere in the headline or body of an Org tree entry. Its presence causes entries to be shown on specific dates in the [agenda](#agenda).

#### Date types

##### Appointments

Meant to be used for elements of the org file that have a defined date to occur, think of a calendar appointment. In the [agenda](#agenda) display, the headline of an entry associated with a plain timestamp is shown exactly on that date. 

```org
* TODO Meet with Marie
<2023-02-24 Fri>
```

When you insert the timestamps with the date popup picker with `;d` (Default: `<leader>oi.`) you can only select the day and not the time, but you can add it manually. 

You can also define a timestamp range that spans through many days `<2023-02-24 Fri>--<2023-02-26 Sun>`. The headline then is shown on the first and last day of the range, and on any dates that are displayed and fall in the range.  

##### [Recurring tasks](https://orgmode.org/manual/Repeated-tasks.html)

A timestamp may contain a repeater interval, indicating that it applies not only on the given date, but again and again after a certain interval of N hours (h), days (d), weeks (w), months (m), or years (y). The following shows up in the agenda every Wednesday:

```org
* TODO Go to pilates
  <2007-05-16 Wed 12:30 +1w>
```

When you mark a recurring task with the TODO keyword ‘DONE’, it no longer produces entries in the agenda. The problem with this is, however, is that then also the next instance of the repeated entry will not be active. Org mode deals with this in the following way: when you try to mark such an entry as done, it shifts the base date of the repeating timestamp by the repeater interval, and immediately sets the entry state back to TODO.

As a consequence of shifting the base date, this entry is no longer visible in the agenda when checking past dates, but all future instances will be visible. 

With the `+1m` cookie, the date shift is always exactly one month. So if you have not paid the rent for three months, marking this entry DONE still keeps it as an overdue deadline. Depending on the task, this may not be the best way to handle it. For example, if you forgot to call your father for 3 weeks, it does not make sense to call him 3 times in a single day to make up for it. For these tasks you can use the `++` operator, for example `++1m`. Finally, there are tasks, like changing batteries, which should always repeat a certain time after the last time you did it you can use the `.+` operator. For example:

```org
** TODO Call Father
   DEADLINE: <2008-02-10 Sun ++1w>
   Marking this DONE shifts the date by at least one week, but also
   by as many weeks as it takes to get this date into the future.
   However, it stays on a Sunday, even if you called and marked it
   done on Saturday.

** TODO Empty kitchen trash
   DEADLINE: <2008-02-08 Fri 20:00 ++1d>
   Marking this DONE shifts the date by at least one day, and also
   by as many days as it takes to get the timestamp into the future.
   Since there is a time in the timestamp, the next deadline in the
   future will be on today's date if you complete the task before
   20:00.

** TODO Check the batteries in the smoke detectors
   DEADLINE: <2005-11-01 Tue .+1m>
   Marking this DONE shifts the date to one month after today.

** TODO Wash my hands
   DEADLINE: <2019-04-05 08:00 Fri .+1h>
   Marking this DONE shifts the date to exactly one hour from now.
```

##### Scheduled

`SCHEDULED` defines when you are plan to start working on that task.

The headline is listed under the given date. In addition, a reminder that the scheduled date has passed is present in the compilation for today, until the entry is marked as done.

```org
*** TODO Call Trillian for a date on New Years Eve.
    SCHEDULED: <2004-12-25 Sat>
```

If you want to delay the display of this task in the agenda, use `SCHEDULED: <2004-12-25 Sat -2d>` the task is still scheduled on the 25th but will appear two days later. In case the task contains a repeater, the delay is considered to affect all occurrences; if you want the delay to only affect the first scheduled occurrence of the task, use `--2d` instead. 

Scheduling an item in Org mode should not be understood in the same way that we understand scheduling a meeting. Setting a date for a meeting is just [a simple appointment](#appointments), you should mark this entry with a simple plain timestamp, to get this item shown on the date where it applies. This is a frequent misunderstanding by Org users. In Org mode, scheduling means setting a date when you want to start working on an action item. 

You can set it with `<leader>s` (Default: `<leader>ois`)

##### Deadline

`DEADLINE` defines when the task is supposed to be finished on. On the deadline date, the task is listed in the agenda. In addition, the agenda for today carries a warning about the approaching or missed deadline, starting `org_deadline_warning_days` before the due date (14 by default), and continuing until the entry is marked as done. An example:

```org
* TODO Do this 
DEADLINE: <2023-02-24 Fri>
```

You can set it with `<leader>d` (Default: `<leader>oid`).

Using too many tasks with a `DEADLINE` will clutter your agenda. Use it only for the actions that you need to have a reminder, instead try to using [appointment](#appointments) dates instead. The problem of using appointments is that once the date is over you don't get a reminder in the agenda that it's overdue, if you need this, use `DEADLINE` instead.

If you need a different warning period for a special task, you can specify it. For example setting a warning period of 5 days `DEADLINE: <2004-02-29 Sun -5d>`. If you do use `DEADLINES` for many small tasks you may want to configure the default number of days to `0`. Most of times you are able to finish the task in the day, for those that you can't specify a different warning period in the task.


```lua
require('orgmode').setup({
  org_deadline_warning_days = 0,
})
```

#### Date management

```lua
  org = {
    org_deadline = '<leader>d',
    org_schedule = '<leader>s',
    org_time_stamp = ';d',
  }
```

To edit existing dates you can:

* Increase/decrease the date under the cursor by 1 day with `<shift><up>`/<shift><down>`
* Increase/decrease the part of the date under the cursor with `<control>a`/`<control>x`
* Bring the date pop up with `<control>e` (Default `cid`)

```lua
  org = {
    org_change_date = '<c-e>',
  }
```

To be able [to use the bindings in insert mode](https://github.com/nvim-orgmode/orgmode/issues/70) too add below the org-mode configuration:

```lua
vim.cmd[[
  imap ;d <c-o>;d
  imap <c-e> <c-o><c-e>
]]
```

You can also use the next [abbreviations](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#abbreviations):

* `:today:`: expands to today's date (example: <2021-06-29 Tue>)
* `:itoday:`: expands to an invactive version of today's date (example: [2021-06-29 Tue])
* `:now:`: expands to today's date and current time (example: <2021-06-29 Tue 15:32>)
* `:inow:`: expands to invactive version of today's date and current time (example: [2021-06-29 Tue 15:32]

### [Tags](https://orgmode.org/manual/Tag-Inheritance.html)

You can also use tags to organize your items. To edit them use `<leader>g` (Default `<leader>ot`).

```lua
  org = {
    org_set_tags_command = '<leader>g',
  },
```

When you press that key you can type:

* `tag1`: It will add `:tag1:`.
* `tag1:tag2`: It will add `:tag1:tag2:`.
* Press `ESC`: It will remove all tags from the item.

Tags are seen as `:tag1:tag2:` on the right of the TODO item description.

Note: tags can't have spaces so use `long_break` instead of `long break`.

Tags make use of the hierarchical structure of outline trees. If a heading has a certain tag, all subheadings inherit the tag as well. For example, in the list

```
* Meeting with the French group      :work:
** Summary by Frank                  :boss:notes:
*** TODO Prepare slides for him      :action:
```

The final heading has the tags `work`, `boss`, `notes`, and `action` even though the final heading is not explicitly marked with those tags. You can also set tags that all entries in a file should inherit just as if these tags were defined in a hypothetical level zero that surrounds the entire file. Using a line like the next one:

```
#+FILETAGS: :Peter:Boss:Secret:
```

If you plan to use the [Capture](#capture) function on the file, add the `FILETAGS` like at the top of the file, otherwise it will end up in the middle of it as you capture new elements.

### `Lists

Lists start with a dash:

```org
- Org bullets
```

To create new list item press `<control><enter>`.

### Checkboxes 

Checkboxes or checklists are a special type of [list](#lists):

```org
- [ ] Item 1
  - [ ] Subitem 1
  - [ ] Subitem 2
- [ ] Item 2
```

If you're over an item you can create new ones with `<control><enter>` (if you have the `org_meta_return = '<c-cr>'` binding set). 

You can change the checkbox state with `<control><space>`, if you check a subitem the parent item will be marked as started `<3` automatically:

```org
- [-] Item 1
  - [X] Subitem 1
  - [ ] Subitem 2
- [ ] Item 2
```

You can't yet [manage the checkboxes as you do the headings](https://github.com/nvim-orgmode/orgmode/issues/508) by promoting, demoting and moving them around.

Follow [this issue](https://github.com/nvim-orgmode/orgmode/issues/305) if you want to see the progress of it's children at the parent checkbox.

### Links

One final aspect of the org file syntax are links. Links are of the form `[[link][description]]`, where link can be an:

* [Internal reference](#internal-document-links)
* [External reference](#external-links)

A link that does not look like a URL refers to the current document. You can follow it with `gx` when point is on the link (Default `<leader>oo`) if you use the next configuration.

```lua
org = {
  org_open_at_point = 'gx',
}
```

#### [Internal document links](https://orgmode.org/manual/Internal-Links.html)

Org provides several refinements to internal navigation within a document. Most notably:

* `[[*Some section]]`: points to a headline with the name `Some section`.
* `[[#my-custom-id]]`: targets the entry with the `CUSTOM_ID` property set to `my-custom-id`. 

When the link does not belong to any of the cases above, Org looks for a dedicated target: the same string in double angular brackets, like `<<My Target>>`.

If no dedicated target exists, the link tries to match the exact name of an element within the buffer. Naming is done, unsurprisingly, with the `NAME` keyword, which has to be put in the line before the element it refers to, as in the following example

```org
#+NAME: My Target
| a  | table      |
|----+------------|
| of | four cells |
```

Ultimately, if none of the above succeeds, Org searches for a headline that is exactly the link text but may also include a `TODO` keyword and tags, or initiates a plain text search.

Note that you must make sure custom IDs, dedicated targets, and names are unique throughout the document. Org provides a linter to assist you in the process, if needed, but I have not searched yet one for nvim.


#### [External links](https://orgmode.org/guide/Hyperlinks.html)

* URL (`http://`, `https://`)
* Path to a file (`file:/path/to/org/file`). File links can contain additional information to jump to a particular location in the file when following a link. This can be:
  * `file:~/code/main.c::255`: A line number 
  * `file:~/xx.org::My Target`: A search for `<<My Target>>`
  * `file:~/xx.org::#my-custom-id`: A	search for-  a custom ID

### [Properties](https://orgmode.org/guide/Properties.html)

Properties are key-value pairs associated with an entry. They live in a special drawer with the name `PROPERTIES`. Each property is specified on a single line, with the key (surrounded by colons) first, and the value after it:

```org
* CD collection
** Classic
*** Goldberg Variations
    :PROPERTIES:
    :Title:     Goldberg Variations
    :Composer:  J.S. Bach
    :Publisher: Deutsche Grammophon
    :NDisks:    1
    :END:
```

You may define the allowed values for a particular property `Xyz` by setting a property `Xyz_ALL`. This special property is inherited, so if you set it in a level 1 entry, it applies to the entire tree. When allowed values are defined, setting the corresponding property becomes easier and is less prone to typing errors. For the example with the CD collection, we can pre-define publishers and the number of disks in a box like this:

```org
* CD collection
  :PROPERTIES:
  :NDisks_ALL:  1 2 3 4
  :Publisher_ALL: "Deutsche Grammophon" Philips EMI
  :END:
```

If you want to set properties that can be inherited by any entry in a file, use a line like:

```org
#+PROPERTY: NDisks_ALL 1 2 3 4
```

This can be interesting for example if you want to track when was a header created:

```org
*** Title of header
   :PROPERTIES:
   :CREATED: <2023-03-03 Fri 12:11> 
   :END:
```

## Archiving

When we no longer need certain parts of our org files, they can be archived. You can archive items by pressing `;A` (Default `<Leader>o$`) while on the heading. This will also archive any child headings. The default location for archived headings is `<name-of-current-org-file>.org_archive`, which can be changed with the `org_archive_location` option.

The problem is that when you archive an element you loose the context of the item unless it's a first level item. 

Another way to archive is by adding the `:ARCHIVE:` tag with `;a` and once all elements are archived move it to the archive.

```lua
org = {
  org_toggle_archive_tag = ';a',
  org_archive_subtree = ';A',
}

There are some work in progress to improve archiving in the next issues [1](https://github.com/nvim-orgmode/orgmode/issues/413), [2](https://github.com/nvim-orgmode/orgmode/issues/369) and [3](https://github.com/joaomsa/telescope-orgmode.nvim/issues/2). 

## Refiling

Refiling lets you easily move around elements of your org file, such as headings or TODOs. You can refile with `<leader>r` with the next snippet:

```lua
org = {
  org_refile = '<leader>r',
}
```

When you press the refile key binding you are supposed to press `<tab>` to see the available options, once you select the correct file, if you will be shown a autocomplete with the possible items to refile it to. Luckily there is [a Telescope plugin](https://github.com/joaomsa/telescope-orgmode.nvim).

Install it by adding to your plugin config:

```lua
use 'joaomsa/telescope-orgmode.nvim'
```

Then install it with `:PackerInstall`.

You can setup the extension by doing:

```lua
require('telescope').load_extension('orgmode')
```

To replace the default refile prompt:

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true })
  callback = function()
    vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
    vim.keymap.set('n', '<leader>g', require('telescope').extensions.orgmode.search_headings)
  end,
})
```

If the auto command doesn't override the default `orgmode` one, bind it to another keys and never use it.

The plugin also allows you to use `telescope` to search through the headings of the different files with `search_headings`, with the configuration above you'd use `<leader>g`.

## Agenda

The org agenda is used to get an overview of all your different org files. Pressing `ga` (Default: `<leader>oa`) gives you an overview of the various specialized views into the agenda that are available. Remember that you can press `g?` to see all the available key mappings for each view.

```lua
  global = {
    org_agenda = 'ga',
  },
```

You'll be presented with the next views:

* `a`: Agenda for current week or day
* `t`: List of all TODO entries
* `m`: Match a TAGS/PROP/TODO query
* `M`: Like `m`, but only TODO entries
* `s`: Search for keywords
* `q`: Quit

So far the `nvim-orgmode` agenda view lacks the next features:

- Custom agenda commands
- These interactions with the items:
  - Remove it
  - Promote/demote it
  - Order it up and down

### Move around the agenda view

* `.`: Go to Today
* `J`: Opens a popup that allows you to select the date to jump to.
* `<c-n>`: Next agenda span (Default `f`). For example if you are in the week view it will go to the next week.
* `<c-p>`: Previous agenda span (Default `b`).
* `/`: Opens a prompt that allows filtering current agenda view by category, tags and title. 
  
  For example, having a `todos.org` file with headlines that have tags `mytag` or `myothertag`, and some of them have check in content, searching by `todos+mytag/check/` returns all headlines that are in `todos.org` file, that have `mytag` tag, and have `check` in headline title. 

  Note that `regex` is case sensitive by default. Use the vim regex flag `\c` to make it case insensitive. For more information see `:help vim.regex()` and `:help /magic`.

  Pressing `<TAB>` in filter prompt autocompletes categories and tags.

* `q`: Quit                                                                                                

```lua
  agenda = {
    org_agenda_later = '<c-n>',
    org_agenda_earlier = '<c-p>',
  },
```

### Act on the agenda elements

* `<enter>`: Open the file containing the element on your cursor position. By default it opens it in the same buffer as the agenda view, which is a bit uncomfortable for me, I prefer the behaviour of `<tab>` so I'm using that instead.
* `t`: Change `TODO` state of an item both in the agenda and the original Org file
* `=`/`-`: Change the priority of the element
* `r`: Reload all org files and refresh the current agenda view.

```lua
  agenda = {
    org_agenda_switch_to = '<tab>',
    org_agenda_goto = '<cr>',
    org_agenda_priority_up = '=',
    org_agenda_set_tags = '<leader>g',
    org_agenda_deadline = '<leader>d',
    org_agenda_schedule = '<leader>s',
  },
```

### Agenda views:

* `vd`: Show the agenda of the day
* `vw`: Show the agenda of the week
* `vm`: Show the agenda of the month
* `vy`: Show the agenda of the year

Once you open one of the views you can do most of the same stuff that you on othe org mode file:

There is still no easy way to define your [custom agenda views](https://orgmode.org/manual/Custom-Agenda-Views.html), but it looks possible [1](https://github.com/nvim-orgmode/orgmode/issues/478) and [2](https://github.com/nvim-orgmode/orgmode/issues/135).

### [Agenda searches](https://orgmode.org/worg/org-tutorials/advanced-searching.html#property-searches)

When using the search agenda view you can:

* Search by TODO states with `/WAITING`
* Search by tags `+home`. The syntax for such searches follows a simple boolean logic:

  - `|`: or
  - `&`: and
  - `+`: include matches
  - `-`: exclude matches 

  Here are a few examples:

  - `+computer&+urgent`: Returns all items tagged both `computer` and `urgent`.
  - `+computer|+urgent`: Returns all items tagged either `computer` or `urgent`.
  - `+computer&-urgent`: Returns all items tagged `computer` and not `urgent`.


  As you may have noticed, the syntax above can be a little verbose, so org-mode offers convenient ways of shortening it. First, `-` and `+` imply `and` if no boolean operator is stated, so example three above could be rewritten simply as:

  ```
  +computer-urgent
  ```

  Second, inclusion of matches is implied if no `+` or `-` is present, so example three could be further shortened to:

  ```
  computer-urgent
  ```

  Example number two, meanwhile, could be shortened to:

  ```
  computer|urgent
  ```

  There is no way (as yet) to express search grouping with parentheses. The `and` operators (`&`, `+`, and `-`) always bind terms together more strongly than `or` (`|`). For instance, the following search

  ```
  computer|work+email
  ```

  Results in all headlines tagged either with `computer` or both `work` and `email`. An expression such as `(computer|work)&email` is not supported at the moment. You can construct a regular expression though:

  ```
  +{computer\|work}+email
  ```

* [Search by properties](https://orgmode.org/worg/org-tutorials/advanced-searching.html#property-searches): You can search by properties with the `PROPERTY="value"` syntax. Properties with numeric values can be queried with inequalities `PAGES>100`. To search by partial searches use a regular expression, for example if the entry had `:BIB_TITLE: Mysteries of the Amazon` you could use `BIB_TITLE={Amazon}`

## [Capture](https://orgmode.org/manual/Capture.html)

Capture lets you quickly store notes with little interruption of your work flow. It works the next way:

- Open the interface with `;c` (Default `<leader>oc`) that asks you what kind of element you want to capture. 
- Select the template you want to use. By default you only have the `Task` template, that introduces a task into the same file where you're at, select it by pressing `t`.
- Fill up the template.
- Choose what to do with the captured content:
  - Save it to the configured file by pressing `;w` (Default `<control>c`)
  - Refile it to a file by pressing `;r` (Default `<leader>or`).
  - Abort the capture `;q` (Default `<leader>ok`).

```lua
mappings = {
  global = {
    org_capture = ';c',
    },
  capture = {
    org_capture_finalize = ';w',
    org_capture_refile = ';r',
    org_capture_kill = ';q',
  },
}
```

### Configure the capture templates

Capture lets you define different templates for the different inputs. Each template has the next elements:

* Keybinding: Keys to press to activate the template
* Description: What to show in the capture menu to describe the template
* Template: The actual template of the capture, look below to see how to create them.
* Target: The place where the captured element will be inserted to. For example `~/org/todo.org`. If you don't define it it will go to the file configured in `org_default_notes_file`.
* Headline: An [optional headline](https://github.com/nvim-orgmode/orgmode/issues/196) of the Target file to insert the element. 

For example:

```lua
org_capture_templates = {
  t = { description = 'Task', template = '* TODO %?\n  %u' }
}
```

For the template you can use the next variables:

- `%?: `Default cursor position when template is opened
- `%t`: Prints current date (Example: `<2021-06-10 Thu>`)
- `%T`: Prints current date and time (Example: `<2021-06-10 Thu 12:30>`)
- `%u`: Prints current date in inactive format (Example: `[2021-06-10 Thu]`)
- `%U`: Prints current date and time in inactive format (Example: `[2021-06-10 Thu 12:30]`)
- `%<FORMAT>`: Insert current date/time formatted according to lua date format (Example: `%<%Y-%m-%d %A>` produces `2021-07-02 Friday`)
- `%x`: Insert content of the clipboard via the "+" register (see `:help clipboard`)
- `%^{PROMPT|DEFAULT|COMPLETION...}`: Prompt for input, if completion is provided an `:h inputlist` will be used
- `%(EXP)`: Runs the given lua code and inserts the result. NOTE: this will internally pass the content to the lua `load()` function. So the body inside `%()` should be the body of a function that returns a string.
- `%f`: Prints the file of the buffer capture was called from.
- `%F`: Like `%f` but inserts the full path.
- `%n`: Inserts the current `$USER`
- `%a`: File and line number from where capture was initiated (Example: `[[file:/home/user/projects/myfile.txt +2]]`)

For example:

```lua
{ 
  T = {
    description = 'Todo',
    template = '* TODO %?\n %u',
    target = '~/org/todo.org'
  },
  j = {
    description = 'Journal',
    template = '\n*** %<%Y-%m-%d %A>\n**** %U\n\n%?',
    target = '~/sync/org/journal.org'
  },
  -- Nested key example:
  e =  'Event',
  er = {
    description = 'recurring',
    template = '** %?\n %T',
    target = '~/org/calendar.org',
    headline = 'recurring'
  },
  eo = {
    description = 'one-time',
    template = '** %?\n %T',
    target = '~/org/calendar.org',
    headline = 'one-time'
  },
  -- Example using a lua function
  r = {
    description = "Repo URL",
    template = "* [[%x][%(return string.match('%x', '([^/]+)$'))]]%?",
    target = "~/org/repos.org",
  }
}
```


### Use capture

## Synchronize with external calendars

You may want to synchronize your calendar entries with external ones shared with other people, such as nextcloud calendar or google.

The orgmode docs have a tutorial to [sync with google](https://orgmode.org/worg/org-tutorials/org-google-sync.html) and suggests some orgmode packages that do that, sadly it won't work with `nvim-orgmode`. We'll need to go the "ugly way" by:

* Downloading external calendar events to ics with [`vdirsyncer`](vdirsyncer.md).
* [Importing the ics to orgmode](#importing-the-ics-to-orgmode)
* Editing the events in orgmode
* [Exporting from orgmode to ics](#exporting-from-orgmode-to-ics)
* Uploading then changes to the external calendar events with [`vdirsyncer`](vdirsyncer.md).

### Importing the ics to orgmode

There are many tools that do this:

* [`ical2orgpy`](https://github.com/ical2org-py/ical2org.py) 
* [`ical2org` in go](https://github.com/rjhorniii/ical2org)

They import an `ics` file

### Exporting from orgmode to ics



## Other interesting features

Some interesting features for the future are:

* [Effort estimates](https://orgmode.org/manual/Effort-Estimates.html)
* [Clocking](https://orgmode.org/manual/Clocking-Work-Time.html)

# Troubleshooting

## Sometimes <c-cr> doesn't work

Close the terminal and open a new one (pooooltergeist!).

# Comparison with Markdown

What I like of Org mode over Markdown:

* The whole interface to interact with the elements of the document through key bindings:
  * Move elements around.
  * Create elements
* The TODO system is awesome
* The Agenda system
* How it handles checkboxes <3
* Easy navigation between references in the document
* Archiving feature
* Refiling feature
* `#` is used for comments.
* Create internal document links is easier, you can just copy and paste the heading similar to `[[*This is the heading]]` on markdown you need to edit it to `[](#this-is-the-heading)`.

What I like of markdown over Org mode:

* The syntax of the headings `## Title` better than `** Title`. Although it makes sense to have `#` for comments.
* The syntax of the links: `[reference](link)` is prettier to read and write than `[[link][reference]]`, although this can be improved if only the reference is shown by your editor (nvim-orgmode doesn't do his yet)

# References

* [Source](https://github.com/nvim-orgmode/orgmode)
* [Docs](https://nvim-orgmode.github.io/)
* [Developer docs](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org_export)
* [List of supported commands](https://github.com/nvim-orgmode/orgmode/wiki/Feature-Completeness#nvim-org-commands-not-in-emacs)
