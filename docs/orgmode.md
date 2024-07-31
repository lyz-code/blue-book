[`nvim-orgmode`](https://github.com/nvim-orgmode/orgmode#agenda) is a Orgmode clone written in Lua for Neovim. Org-mode is a flexible note-taking system that was originally created for Emacs. It has gained wide-spread acclaim and was eventually ported to Neovim. This page is heavily focused to the nvim plugin, but you can follow the concepts for emacs as well.

If you use Android try [orgzly](orgzly.md).
# [Installation](https://github.com/nvim-orgmode/orgmode#installation)

## Using lazyvim

```lua
return {
  'nvim-orgmode/orgmode',
  ```lua
    {
        'nvim-orgmode/orgmode',
        dependencies = {
      { 'nvim-treesitter/nvim-treesitter', lazy = true },
    },
        event = 'VeryLazy',
        config = function()
    -- Load treesitter grammar for org
    require('orgmode').setup_ts_grammar()

    -- Setup treesitter
    require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'org' },
        },
        ensure_installed = { 'org' },
      })

    -- Setup orgmode
    require('orgmode').setup({
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
      })
  end,
  }
  ```
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter', lazy = true },
  },
  event = 'VeryLazy',
  config = function()
    -- Load treesitter grammar for org
    require('orgmode').setup_ts_grammar()

    -- Setup treesitter
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'org' },
      },
      ensure_installed = { 'org' },
    })

    -- Setup orgmode
    require('orgmode').setup({
      org_agenda_files = '~/orgfiles/**/*',
      org_default_notes_file = '~/orgfiles/refile.org',
    })
  end,
}
```
## Using packer

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

## The Org file syntax

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

`TODO` items are meant to model tasks that evolve between states.  Check [this article](time_management_abstraction_levels.md) to see advanced uses of `TODO` items.

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

##### Start working on a task dates

`SCHEDULED` defines when you are plan to start working on that task.

The headline is listed under the given date. In addition, a reminder that the scheduled date has passed is present in the compilation for today, until the entry is marked as done or [disabled](#how-to-deal-with-overdue-SCHEDULED-and-DEADLINE-tasks).

```org
*** TODO Call Trillian for a date on New Years Eve.
    SCHEDULED: <2004-12-25 Sat>
```

Although is not a good idea (as it promotes the can pushing through the street), if you want to delay the display of this task in the agenda, use `SCHEDULED: <2004-12-25 Sat -2d>` the task is still scheduled on the 25th but will appear two days later. In case the task contains a repeater, the delay is considered to affect all occurrences; if you want the delay to only affect the first scheduled occurrence of the task, use `--2d` instead. 

Scheduling an item in Org mode should not be understood in the same way that we understand scheduling a meeting. Setting a date for a meeting is just [a simple appointment](#appointments), you should mark this entry with a simple plain timestamp, to get this item shown on the date where it applies. This is a frequent misunderstanding by Org users. In Org mode, scheduling means setting a date when you want to start working on an action item. 

You can set it with `<leader>s` (Default: `<leader>ois`)

##### Deadlines

`DEADLINE` are like [appointments](#appointments) in the sense that it defines when the task is supposed to be finished on. On the deadline date, the task is listed in the agenda. The difference with appointments is that you also see the task in your agenda if it is overdue and you can set a warning about the approaching deadline, starting `org_deadline_warning_days` before the due date (14 by default). It's useful then to set `DEADLINE` for those tasks that you don't want to miss that the deadline is over.

An example:

```org
* TODO Do this 
DEADLINE: <2023-02-24 Fri>
```

You can set it with `<leader>d` (Default: `<leader>oid`).

If you need a different warning period for a special task, you can specify it. For example setting a warning period of 5 days `DEADLINE: <2004-02-29 Sun -5d>`.  

If you're as me, you may want to remove the warning feature of `DEADLINES` to be able to keep your agenda clean. Most of times you are able to finish the task in the day, and for those that you can't specify a `SCHEDULED` date. To do so set the default number of days to `0`. 

```lua
require('orgmode').setup({
  org_deadline_warning_days = 0,
})
```

Using too many tasks with a `DEADLINE` will clutter your agenda. Use it only for the actions that you need to have a reminder, instead try to using [appointment](#appointments) dates instead. The problem of using appointments is that once the date is over you don't get a reminder in the agenda that it's overdue, if you need this, use `DEADLINE` instead.

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
   SCHEDULED: <2008-02-10 Sun ++1w>
   Marking this DONE shifts the date by at least one week, but also
   by as many weeks as it takes to get this date into the future.
   However, it stays on a Sunday, even if you called and marked it
   done on Saturday.

** TODO Empty kitchen trash
   SCHEDULED: <2008-02-08 Fri 20:00 ++1d>
   Marking this DONE shifts the date by at least one day, and also
   by as many days as it takes to get the timestamp into the future.
   Since there is a time in the timestamp, the next deadline in the
   future will be on today's date if you complete the task before
   20:00.

** TODO Check the batteries in the smoke detectors
   SCHEDULED: <2005-11-01 Tue .+1m>
   Marking this DONE shifts the date to one month after today.

** TODO Wash my hands
   SCHEDULED: <2019-04-05 08:00 Fri .+1h>
   Marking this DONE shifts the date to exactly one hour from now.

** TODO Send report
   DEADLINE: <2019-04-05 08:00 Fri .+1m>
```

##### How to deal with overdue SCHEDULED and DEADLINE tasks.

Quite often you may not meet the `SCHEDULED` or `DEADLINE` date. If it's not a recurring task and you have it already in your `todo.org` list, then you can safely remove the SCHEDULED or DEADLINE line.

If it's a recurring task you may want to keep the line for future iterations. That doesn't mean that it has to show in your agenda. If you have it already tracked you may want to hide it. One way I'm managing it is by deactivating the date (transforming the `<>` into `[]` {you can do that by pressing `C-a` over the `<` or `[`}) and adding a special state (`READY`) so I don't mark the task as done by error. For example if we have:

```orgmode
** READY Check the batteries in the smoke detectors
   SCHEDULED: [2005-11-01 Tue .+1m]
   Marking this DONE shifts the date to one month after today.
```

Once the task is ready to be marked as done you need to change the `[]` to `<>` and then you can mark it as `DONE`.

##### How to deal with recurring tasks that have checklists

Some recurring tasks may have checklists. For example:

```orgmode
* TODO Clean the inbox
  SCHEDULED: <2024-01-04 ++1w>
  - [x] Clean email
  - [x] Clean physical inbox
  - [ ] Clean computer inbox
  - [ ] Clean mobile inbox
```

Once you mark the task as done, the done items are not going to be reseted. That's why I use a special state `CHECK` to prevent the closing of a task before checking it.

For those tasks that you want to always check before closing you can add a `(CHECK)` at the end of the title. The reason is because each time you mark a recurrent task as done it switches back the state to `TODO`. For example, as of right now nvim-orgmode doesn't support the recurrence type of "the first wednesday of the month". As a workaround you can do:

```orgmode
* TODO Do X the first thursday of the month (CHECK)
  DEADLINE: <2024-01-04 ++1m>
  
  - [ ] Step 1
  - [ ] Step 2
  - [ ] Step ...

  - [ ] Adjust the date to match the first thursday of the month
```

##### How to deal with recurring tasks that are not yet ready to be acted upon

By default when you mark a recurrent task as `DONE` it will transition the date (either appointment, `SCHEDULED` or `DEADLINE`) to the next date and change the state to `TODO`. I found it confusing because for me `TODO` actions are the ones that can be acted upon right now. That's why I'm using the next states instead:

- `INACTIVE`: Recurrent task which date is not yet close so you should not take care of it.
- `READY`: Recurrent task which date [is overdue](#how-to-deal-with-overdue-SCHEDULED-and-DEADLINE-tasks), we acknowledge the fact and mark the date as inactive (so that it doesn't clobber the agenda).

The idea is that once an INACTIVE task reaches your agenda, either because the warning days of the `DEADLINE` make it show up, or because it's the `SCHEDULED` date you need to decide whether to change it to `TODO` if it's to be acted upon immediately or to `READY` and deactivate the date.


`INACTIVE` then should be the default state transition for the recurring tasks once you mark it as `DONE`. To do this, set in your config:

```lua
org_todo_repeat_to_state = "INACTIVE",
```

If a project gathers a list of recurrent subprojects or subactions it can have the next states:

- `READY`: If there is at least one subelement in state `READY` and the rest are `INACTIVE`
- `TODO`:  If there is at least one subelement in state `TODO` and the rest may have `READY` or `INACTIVE`
- `INACTIVE`: The project is not planned to be acted upon soon. 
- `WAITING`: The project is planned to be acted upon but all its subelements are in `INACTIVE` state.
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

If you plan refile elements to the root of a file (such as using a bare [Capture](#capture)), add the `FILETAGS` like at the top of the file, otherwise it will end up in the middle of it as you capture new elements. For the rest of cases leave it at the bottom, that way you will only see it when you need it and you skip one `j` movement each time you browse the file.

Tags are useful for [Agenda searches](#agenda-searches). I've found interesting to create tags based on:

- Temporal context:
  - lunch 
  - dinner
  - night
- Spatial context:
  - kitchen
  - couch
  - mobile 
  - bathroom 
- Event context:
  - daily
  - retro 
  - planning
- Mental context:
  - down
  - sad
  - strategic
  - design
  - inspired
- People context:
  - mom 
  - dad 
  - ...
- Roadmap area context:
  - activism 
  - well-being 
  - care
  - work 
- Focus area context:
  - maintenance 
  - improvement
- Knowledge area context:
  - efficiency 
  - politics
  - ...

So that it's easy to find elements to work on based on each context.
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

* `[[Some section]]`: points to a headline with the name `Some section`.
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
  * `file:~/xx.org::*My Target`: A search for `<<My Target>>` heading.
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

### [Code blocks](https://orgmode.org/manual/Structure-of-Code-Blocks.html)

Org offers two ways to structure source code in Org documents: in a source code block, and directly inline. Both specifications are shown below.

A source code block conforms to this structure:

```org
#+NAME: <name>
#+BEGIN_SRC <language> <switches> <header arguments>
  <body>
#+END_SRC
```

You need to use snippets for this to be usable.

An inline code block has two possibilies

- Language agnostic inline block is any string between `=` or `~` such as:
  ```org
  If ~variable == true~ where =variable= is ...
  ```

- Language specific block conforms to this structure:

  ```org
  src_<language>{<body>}
  ```

  or

  ```org
  src_<language>[<header arguments>]{<body>}
  ```

Where:

- `#+NAME: <name>`: (Optional) Names the source block so it can be called, like a function, from other source blocks or inline code to evaluate or to capture the results. Code from other blocks, other files.
- `#+BEGIN_SRC’ … ‘#+END_SRC`: (Mandatory) They mark the start and end of a block that Org requires.
- `<language>`: (Mandatory) It is the identifier of the source code language in the block. See [Languages](https://orgmode.org/worg/org-contrib/babel/languages/index.html) for identifiers of supported languages.
- `<switches>`: (Optional) Switches provide finer control of the code execution, export, and format.
- `<header arguments>`: (Optional) Heading arguments control many aspects of evaluation, export and tangling of code blocks. Using Org’s properties feature, header arguments can be selectively applied to the entire buffer or specific subtrees of the Org document.
- `<body>`: Source code in the dialect of the specified language identifier. 
## Archiving

When we no longer need certain parts of our org files, they can be archived. You can archive items by pressing `;A` (Default `<Leader>o$`) while on the heading. This will also archive any child headings. The default location for archived headings is `<name-of-current-org-file>.org_archive`, which can be changed with the `org_archive_location` option.

The problem is that when you archive an element you loose the context of the item unless it's a first level item. 

Another way to archive is by adding the `:ARCHIVE:` tag with `;a` and once all elements are archived move it to the archive.

```lua
org = {
  org_toggle_archive_tag = ';a',
  org_archive_subtree = ';A',
}
```

There are some work in progress to improve archiving in the next issues [1](https://github.com/nvim-orgmode/orgmode/issues/413), [2](https://github.com/nvim-orgmode/orgmode/issues/369) and [3](https://github.com/joaomsa/telescope-orgmode.nvim/issues/2). 

If you [don't want to have dangling org_archive files](https://github.com/nvim-orgmode/orgmode/issues/628) you can create an `archive` directory somewhere and then set:

```lua
local org = require('orgmode').setup({
  org_archive_location = "~/orgmode/archive/" .. "%s_archive",
)}
```

### Use archiving to clean long checklists

When you have big tasks that have nested checklists, when you finish the day working on the task you may want to clean the checklist without loosing what you've done, for example for reporting purposes.

In those cases what I do is archive the task, and then undo the archiving. That way you have a copy of the state of the task in your archive with a defined date. Then you can safely remove the done checklist items.
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

If you refile from the capture window, [until this issue is solved](https://github.com/joaomsa/telescope-orgmode.nvim/issues/4), your task will be refiled but the capture window won't be closed.

Be careful that it only refiles the first task there is, so you need to close the capture before refiling the next

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
* `f`: Next agenda span. For example if you are in the week view it will go to the next week.
* `b`: Previous agenda span .
* `/`: Opens a prompt that allows filtering current agenda view by category, tags and title. 
  
  For example, having a `todos.org` file with headlines that have tags `mytag` or `myothertag`, and some of them have check in content, searching by `todos+mytag/check/` returns all headlines that are in `todos.org` file, that have `mytag` tag, and have `check` in headline title. 

  Note that `regex` is case sensitive by default. Use the vim regex flag `\c` to make it case insensitive. For more information see `:help vim.regex()` and `:help /magic`.

  Pressing `<TAB>` in filter prompt autocompletes categories and tags.

* `q`: Quit                                                                                                

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


### [Reload the agenda con any file change](https://github.com/nvim-orgmode/orgmode/issues/656)
There are two ways of doing this:

- Reload the agenda each time you save a document
- Reload the agenda each X seconds

#### Reload the agenda each time you save a document
Add this to your configuration:

```lua
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.org',
  callback = function()
    local bufnr = vim.fn.bufnr('orgagenda') or -1
    if bufnr > -1 then
      require('orgmode').agenda:redo()
    end
  end
})
```

This will reload agenda window if it's open each time you write any org file, it won't work if you archive without saving though yet. But that can be easily fixed if you use [the auto-save plugin](vim_autosave.md).
#### Reload the agenda each X seconds
Add this to your configuration:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  group = vim.api.nvim_create_augroup("orgmode", { clear = true }),
  callback = function()
    -- Reload the agenda each second if its opened so that unsaved changes 
    -- in the files are shown
    local timer = vim.loop.new_timer()
    timer:start(
      0,
      10000,
      vim.schedule_wrap(function()
        local bufnr = vim.fn.bufnr("orgagenda") or -1
        if bufnr > -1 then
          require("orgmode").agenda:redo(true)
        end
      end)
    )
  end,
})
```

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
## Links

Orgmode supports the insertion of links with the `org_insert_link` and `org_store_link` commands. I've changed the default `<leader>oli` and `<leader>ols` bindings to some quicker ones:

```lua
mappings = {
  org = {
    -- link management
    org_insert_link = "<leader>l",
    org_store_link = "<leader>ls",
  },
}
```
There are the next possible workflows:

- Discover links as you go: If you more less know in which file are the headings you want to link:
  - Start the link helper with `<leader>l`
  - Type `file:./` and press `<tab>`, this will show you the available files. Select the one you want
  - Then type `::*` and press `<tab>` again to get the list of available headings.
- Store the links you want to paste:
  - Go to the heading you want to link
  - Press `<leader>ls` to store the link 
  - Go to the place where you want to paste the link 
  - Press `<leader>l` and then `<tab>` to iterate over the saved links.
## The orgmode repository file organization

How to structure the different orgmode files is something that has always confused me, each one does it's own way, and there are no good posts on why one structure is better than other, people just state what they do.

I've started with a typical [gtd](gtd.md) structure with a directory for the `todo` another for the `calendar` then another for the `references`. In the `todo` I had a file for personal stuff, another for each of my work clients, and the `someday.org`. Soon making the internal links was cumbersome so I decided to merge the personal `todo.org` and the `someday.org` into the same file and use folds to hide uninteresting parts of the file. The reality is that I feel that orgmode is less responsive and that I often feel lost in the file. 

I'm now more into the idea of having files per project in a flat structure and use an index.org file to give it some sense in the same way I do with the mkdocs repositories. Then I'd use internal links in the todo.org file to organize the priorities of what to do next.

Benefits:

- As we're using a flat structure at file level, the links between the files are less cumbersome `file:./project.org::*heading`. We only need to have unique easy to remember names for the files, instead of having to think on which directory was the file I want to make the link to. The all in one file structure makes links even easier, just `*heading`, but the disadvantages make it not worth it.
- You have the liberty to have a generic link like `Work on project` or if you want to fine grain it, link the specific task of the project
- The todo file will get smaller.
- It has been the natural evolution of other knowledge repositories such as blue

Cons:

- Filenames must be unique. It hasn't been a problem in blue.
- Blue won't be flattened into Vida as it's it's own knowledge repository
## Synchronizations

### Synchronize with other orgmode repositories

I use orgmode both at the laptop and the mobile, I want to syncronize some files between both with the next requisites:

- The files should be available on the devices when I'm not at home
- The synchronization will be done only on the local network
- The synchronization mechanism will only be able to see the files that need to be synched. 
- Different files can be synced to different devices. If I have three devices (laptop, mobile, tablet) I want to sync all mobile files to the laptop but just some to the tablet).

Right now I'm already using [syncthing](syncthing.md) to sync files between the mobile and my server, so it's tempting to use it also to solve this issue. So the first approach is to spawn a syncthing docker at the laptop that connects with the server to sync the files whenever I'm at home. 

#### Mount the whole orgmode repository with syncthing

I could mount the whole orgmode directory and use the [ignore patterns of syncthing](https://willschenk.com/howto/2020/using_syncthing/), but that will make syncthing see more files than I want even though it won't sync them to the other devices. The ideal scenario is where syncthing only sees the files that needs to sync, so that in case of a vulnerability only a subset of the files is leaked.

#### Mount a specific directory to sync

An alternative would be to have a `.mobile` directory at the orgmode repository where the files that need to be synced will live. The problem is that it would break the logical structure of the repository and it would make difficult to make internal links between files as you need to remember or need to search if the file is in the usual place or in the mobile directory. To avoid this we could use hard links. Soft links don't work well because:

- If you have the file in the org repo and do the soft link in the mobile directory, syncthing won't know what to do with it
- If you have the file in the mobile repo and do a hard link in the repository it wont work because syncthing overwrites the file when updating from a remote thus breaking the hard links
- If you have the file in the mobile repo and do the soft link in the repository, nvim-orgmode sometimes behaves weirdly with the symlinks, try moving the files and recreating the links to a different path. For example I discovered that all links that pointed to a directory which contained the `nas` string didn't work, the rest did. Super weird.

If we use this workflow, we'd need to manually create the links each time a new file is created that needs to be linked.

This is also a good solution for the different authorization syncs as you can only have one syncthing directory per Linux directory so if you want different authorization for different devices you won't be able to do this unless you create a specific directory for that share. For example if I want to have only one file shared to the tablet I'd need a tablet directory.

#### Select which files to mount on the docker command

We could also select which files to mount on the syncthing docker of the laptop. I find this to be an ugly solution because we'd first need to mount a directory so that syncthing can write it's internal data and then map each of the files we want to sync. So each time a new file is added, we need to change the docker command... Unpleasant.


#### Use the org-orgzly script

Another solution would be to use [org-orgzly script](https://codeberg.org/anoduck/org-orgzly) to parse a chosen org file or files, check if an entry meets required parameters, and if it does, write the entry in a new file located inside the directory you desire to sync with orgzly. In theory it may work but I feel it's too Dropbox focused.

#### Conclusion on the synchronization

The best solution for me is to [Mount a specific directory to sync](#mount-a-specific-directory-to-sync).

### Synchronize with external calendars

You may want to synchronize your calendar entries with external ones shared with other people, such as nextcloud calendar or google.

The orgmode docs have a tutorial to [sync with google](https://orgmode.org/worg/org-tutorials/org-google-sync.html) and suggests some orgmode packages that do that, sadly it won't work with `nvim-orgmode`. We'll need to go the "ugly way" by:

* Downloading external calendar events to ics with [`vdirsyncer`](vdirsyncer.md).
* [Importing the ics to orgmode](#importing-the-ics-to-orgmode)
* Editing the events in orgmode
* [Exporting from orgmode to ics](#exporting-from-orgmode-to-ics)
* Uploading then changes to the external calendar events with [`vdirsyncer`](vdirsyncer.md).

#### Importing the ics to orgmode

There are many tools that do this:

* [`ical2orgpy`](https://github.com/ical2org-py/ical2org.py) 
* [`ical2org` in go](https://github.com/rjhorniii/ical2org)

They import an `ics` file

#### Exporting from orgmode to ics
## Other interesting features

Some interesting features for the future are:

* [Effort estimates](https://orgmode.org/manual/Effort-Estimates.html)
* [Clocking](https://orgmode.org/manual/Clocking-Work-Time.html)
# Troubleshooting
## <c-i> doesn't go up in the jump list
It's because [<c-i> is a synonym of <tab>](https://github.com/neovim/neovim/issues/5916), and `org_cycle` is [mapped by default as <tab>](https://github.com/nvim-orgmode/orgmode/blob/c0584ec5fbe472ad7e7556bc97746b09aa7b8221/lua/orgmode/config/defaults.lua#L146)
If you're used to use `zc` then you can disable the `org_cycle` by setting the mapping `org_cycle = "<nop>"`.

## [Prevent Enter to create `*` on headings](https://github.com/LazyVim/LazyVim/discussions/2529)
With a clean install of LazyVim distribution when pressing `<CR>` from a heading it creates a new heading instead of moving the cursor to the body of the heading:

```org
* Test <--  press enter in insert mode
```
The result is:
```org
* Test
* <-- cursor here
```
The expected behaviour is:
```org
* Test
  <-- cursor here
```

It's because of the [`formatoptions`](https://vimhelp.org/change.txt.html#fo-table). If you do `:set fo-=r`, you will observe the difference. 

The `r` option automatically inserts the current comment leader after pressing `<Enter>` in Insert mode.

To make the change permanent, you should enforce it with an auto-command. I really have no idea what makes Neovim think that the character `*` is a comment leader in `.org` files.

```lua 
vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  group = vim.api.nvim_create_augroup("orgmode", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "r" })
  end,
})
```

## Create an issue in the orgmode repository

Note: if you want to debug orgmode with DAP use [this config instead](#troubleshoot-orgmode-with-dap)

- [Create a new issue](https://github.com/nvim-orgmode/orgmode/issues/new/choose)
- Create the `minimal_init.lua` file from [this file](https://github.com/nvim-orgmode/orgmode/blob/master/scripts/minimal_init.lua)
  ```lua
  vim.cmd([[set runtimepath=$VIMRUNTIME]])
  vim.cmd([[set packpath=/tmp/nvim/site]])

  local package_root = '/tmp/nvim/site/pack'
  local install_path = package_root .. '/packer/start/packer.nvim'
  vim.g.mapleader = ' '

  local function load_plugins()
    require('packer').startup({
      {
        'wbthomason/packer.nvim',
        { 'nvim-treesitter/nvim-treesitter' },
        { 'kristijanhusak/orgmode.nvim', branch = 'master' },
      },
      config = {
        package_root = package_root,
        compile_path = install_path .. '/plugin/packer_compiled.lua',
      },
    })
  end

  _G.load_config = function()
    require('orgmode').setup_ts_grammar()
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'org' },
      },
    })

    vim.cmd([[packadd nvim-treesitter]])
    vim.cmd([[runtime plugin/nvim-treesitter.lua]])
    vim.cmd([[TSUpdateSync org]])

    -- Close packer after install
    if vim.bo.filetype == 'packer' then
      vim.api.nvim_win_close(0, true)
    end

    require('orgmode').setup({
      org_agenda_files = {
        './*'
      }
    }
    )

    -- Reload current file if it's org file to reload tree-sitter
    if vim.bo.filetype == 'org' then
      vim.cmd([[edit!]])
    end
  end

  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
    load_plugins()
    require('packer').sync()
    vim.cmd([[autocmd User PackerCompileDone ++once lua load_config()]])
  else
    load_plugins()
    load_config()
  end
  ```
- Add the leader configuration at the top of the file `vim.g.mapleader = ' '`
- Open it with `nvim -u minimal_init.lua`

## Troubleshoot orgmode from within lazyvim
To start a fresh instance of lazyvim with orgmode you can run

```bash
mkdir ~/.config/newstarter && cd ~/.config/newstarter
git clone https://github.com/LazyVim/starter .
rm -rf .git*
NVIM_APPNAME=newstarter nvim # and wait for installation of plugins to finish
# Quit Neovim and start again with 
NVIM_APPNAME=newstarter nvim lua/plugins/orgmode.lua
# Paste the contents of the installation steps for `lazy.nvim` mentioned [here](https://github.com/nvim-orgmode/orgmode#installation) in the file that you opened. 
# Quit and restart Neovim again with the aforementioned command 
```

Once you're done clean up with:

```bash
rm -rf ~/.config/newstarter ~/.local/share/newstarter
```
## Troubleshoot orgmode with dap

### To debug

You already have configured `dap` just press `<F5>` in the window where you are running orgmode and set the breakpoints with the other nvim.
### To open an issue
Use the next config and follow the steps of [Create an issue in the orgmode repository](#create-an-issue-in-the-orgmode-repository).

```lua
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

local package_root = '/tmp/nvim/site/pack'
local install_path = package_root .. '/packer/start/packer.nvim'

local function load_plugins()
  require('packer').startup({
    {
      'wbthomason/packer.nvim',
      { 'nvim-treesitter/nvim-treesitter' },
      { 'nvim-lua/plenary.nvim'},
      { 'nvim-orgmode/orgmode'},
      { 'nvim-telescope/telescope.nvim'},
      { 'lyz-code/telescope-orgmode.nvim' },
      { 'jbyuki/one-small-step-for-vimkind' },
      { 'mfussenegger/nvim-dap' },
      { 'kristijanhusak/orgmode.nvim', branch = 'master' },
    },
    config = {
      package_root = package_root,
      compile_path = install_path .. '/plugin/packer_compiled.lua',
    },
  })
end

_G.load_config = function()
  require('orgmode').setup_ts_grammar()
  require('nvim-treesitter.configs').setup({
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'org' },
    },
  })

  vim.cmd([[packadd nvim-treesitter]])
  vim.cmd([[runtime plugin/nvim-treesitter.lua]])
  vim.cmd([[TSUpdateSync org]])

  -- Close packer after install
  if vim.bo.filetype == 'packer' then
    vim.api.nvim_win_close(0, true)
  end

  require('orgmode').setup({
    org_agenda_files = {
      './*'
    }
  }
  )

  -- Reload current file if it's org file to reload tree-sitter
  if vim.bo.filetype == 'org' then
    vim.cmd([[edit!]])
  end
end
if vim.fn.isdirectory(install_path) == 0 then
  vim.fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  load_plugins()
  require('packer').sync()
  vim.cmd([[autocmd User PackerCompileDone ++once lua load_config()]])
else
  load_plugins()
  load_config()
end


require('telescope').setup{
  defaults = {
    preview = {
      enable = true,
      treesitter = false,
    },
    vimgrep_arguments = {
      "ag",
      "--nocolor",
      "--noheading",
      "--numbers",
      "--column",
      "--smart-case",
      "--silent",
      "--follow",
      "--vimgrep",
    },
    file_ignore_patterns = {
      "%.svg",
      "%.spl",
      "%.sug",
      "%.bmp",
      "%.gpg",
      "%.pub",
      "%.kbx",
      "%.db",
      "%.jpg",
      "%.jpeg",
      "%.gif",
      "%.png",
      "%.org_archive",
      "%.flf",
      ".cache",
      ".git/",
      ".thunderbird",
      ".nas",
    },
    mappings = {
      i = {
        -- Required so that folding works when opening a file in telescope
        -- https://github.com/nvim-telescope/telescope.nvim/issues/559
        ["<CR>"] = function()
            vim.cmd [[:stopinsert]]
            vim.cmd [[call feedkeys("\<CR>")]]
        end,
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      }
    }
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      hidden = true,
      follow = true,
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
    heading = {
      treesitter = true,
    },
  }
}

require('telescope').load_extension('orgmode')

local key = vim.keymap
vim.g.mapleader = ' '

local builtin = require('telescope.builtin')
key.set('n', '<leader>f', builtin.find_files, {})
key.set('n', '<leader>F', ':Telescope file_browser<cr>')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true }),
  callback = function()
    vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
    vim.keymap.set('n', '<leader>g', require('telescope').extensions.orgmode.search_headings)
  end,
})

require('orgmode').setup_ts_grammar()
local org = require('orgmode').setup({
  org_agenda_files = {
    "./*"
  },
  org_todo_keywords = { 'TODO(t)', 'CHECK(c)', 'DOING(d)', 'READY(r)', 'WAITING(w)', '|', 'DONE(e)', 'REJECTED(j)', 'DUPLICATE(u)' },
  org_hide_leading_stars = true,
  org_deadline_warning_days = 0,
  win_split_mode = "horizontal",
  org_priority_highest = 'A',
  org_priority_default = 'C',
  org_priority_lowest = 'D',
  mappings = {
    global = {
      org_agenda = 'ga',
      org_capture = ';c',
    },
    org = {
      -- Enter new items
      org_meta_return = '<c-cr>',
      org_insert_heading_respect_content = ';<cr>',
      org_insert_todo_heading = "<c-t>",
      org_insert_todo_heading_respect_content = ";t",

      -- Heading promoting and demoting
      org_toggle_heading = '<leader>h',
      org_do_promote = '<h',
      org_do_demote = '>h',
      org_promote_subtree = '<H',
      org_demote_subtree = '>H',

      -- Heading moving
      org_move_subtree_up = "<leader>k",
      org_move_subtree_down = "<leader>j",

      -- Heading navigation
      org_next_visible_heading = '<c-j>',
      org_previous_visible_heading = '<c-k>',
      org_forward_heading_same_level = '<c-n>',
      org_backward_heading_same_level = '<c-p>',
      outline_up_heading = 'gp',
      org_open_at_point = 'gx',

      -- State transition
      org_todo = 't',

      -- Priority change
      org_priority_up = '-',
      org_priority_down = '=',

      -- Date management
      org_deadline = '<leader>d',
      org_schedule = '<leader>s',
      org_time_stamp = ';d',
      org_change_date = '<c-e>',

      -- Tag management
      org_set_tags_command = 'T',

      -- Archive management and refiling
      org_archive_subtree = ';a',
      org_toggle_archive_tag = ';A',
      -- org_refile = '<leader>r',  The refile is being handled below
    },
    agenda = {
      org_agenda_later = '<c-n>',
      org_agenda_earlier = '<c-p>',
      org_agenda_switch_to = '<tab>',
      org_agenda_goto = '<cr>',
      org_agenda_priority_up = '=',
      org_agenda_set_tags = 'T',
      org_agenda_deadline = '<leader>d',
      org_agenda_schedule = '<leader>s',
      org_agenda_archive = 'a',
    },
    capture = {
      org_capture_finalize = ';w',
      org_capture_refile = ';r',
      org_capture_kill = 'qqq',
    },
  }
})
local dap = require"dap"
dap.configurations.lua = { 
  { 
    type = 'nlua', 
    request = 'attach',
    name = "Attach to running Neovim instance",
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
end

vim.api.nvim_set_keymap('n', '<leader>b', [[:lua require"dap".toggle_breakpoint()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>c', [[:lua require"dap".continue()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>n', [[:lua require"dap".step_over()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>m', [[:lua require"dap".repl.open()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>N', [[:lua require"dap".step_into()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<F12>', [[:lua require"dap.ui.widgets".hover()<CR>]], { noremap = true })
vim.api.nvim_set_keymap('n', '<F5>', [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true })
```

## Hide the state changes in the folds

The folding of the recurring tasks iterations is also kind of broken. For the next example

```orgmode
** TODO Recurring task
   DEADLINE: <2024-02-08 Thu .+14d -0d>
   :PROPERTIES:
   :LAST_REPEAT: [2024-01-25 Thu 11:53]
   :END:
   - State "DONE" from "TODO" [2024-01-25 Thu 11:53]
   - State "DONE" from "TODO" [2024-01-10 Wed 23:24]
   - State "DONE" from "TODO" [2024-01-03 Wed 19:39]
   - State "DONE" from "TODO" [2023-12-11 Mon 21:30]
   - State "DONE" from "TODO" [2023-11-24 Fri 13:10]
 
   - [ ] Do X
```

When folded the State changes is not added to the Properties fold. It's shown something like:

```orgmode
** TODO Recurring task
   DEADLINE: <2024-02-08 Thu .+14d -0d>
   :PROPERTIES:...                                                                                                                                                                                              
    
   - State "DONE" from "TODO" [2024-01-25 Thu 11:53]
   - State "DONE" from "TODO" [2024-01-10 Wed 23:24]
   - State "DONE" from "TODO" [2024-01-03 Wed 19:39]
   - State "DONE" from "TODO" [2023-12-11 Mon 21:30]
   - State "DONE" from "TODO" [2023-11-24 Fri 13:10]

   - [ ] Do X
```

I don't know if this is a bug or a feature, but when you have many iterations it's difficult to see the task description. So it would be awesome if they could be included into the properties fold or have their own fold.

I've found though that if you set the [`org_log_into_drawer = "LOGBOOK"` in the config](https://github.com/nvim-orgmode/orgmode/issues/455) this is fixed.

## Sometimes <c-cr> doesn't work

Close the terminal and open a new one (pooooltergeist!).

## Narrow/Widen to subtree

It's [not yet supported](https://github.com/nvim-orgmode/orgmode/issues/200) to focus or zoom on one task.

## Attempt to index local 'src_file' (a nil value) using telescope orgmode

This happens when not all the files are loaded in the telescope cache. You just need to wait until they are. 

I've made some tests and it takes more time to load many small files than few big ones.

Take care then on what files you add to your `org_agenda_files`. For example you can take the next precautions:

- When adding a wildcard, use `*.org` not to load the `*.org_archive` files into the ones to process. Or [save your archive files elsewhere](#archiving).
# Plugins 
nvim-orgmode supports plugins. Check [org-checkbox](https://github.com/massix/org-checkbox.nvim/blob/trunk/lua/orgcheckbox/init.lua) to see a simple one
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
# Interesting things to investigate
- [org-bullets.nvim](https://github.com/akinsho/org-bullets.nvim): Show org mode bullets as UTF-8 characters.
- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim): Add few highlight options for code blocks and headlines.
- [Sniprun](https://github.com/michaelb/sniprun): A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages.
## Convert source code in the fly from markdown to orgmode
It would be awesome that when you do `nvim myfile.md` it automatically converts it to orgmode so that you can use all the power of it and once you save the file it converts it back to markdown

I've started playing around with this but got nowhere. I leave you my breadcrumbs in case you want to follow this path. 

```lua
-- Load the markdown documents as orgmode documents
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.md",
  callback = function()
    local markdown_file = vim.fn.expand("%:p")
    local org_content = vim.fn.system("pandoc -f gfm -t org " .. markdown_file)
    vim.cmd("%delete")
    vim.api.nvim_put(vim.fn.split(org_content, "\n"), "l", false, true)
    vim.bo.filetype = "org"
  end,
})
```

If you make it work please [tell me how you did it!](contact.md)
# Things that are still broken or not developed

- [The agenda does not get automatically refreshed](https://github.com/nvim-orgmode/orgmode/issues/656)
- [Uncheck checkboxes on recurring tasks once they are completed](https://github.com/nvim-orgmode/orgmode/issues/655)
- [Foldings when moving items around](https://github.com/nvim-orgmode/orgmode/issues/524)
- [Refiling from the agenda](https://github.com/nvim-orgmode/orgmode/issues/657)
- [Interacting with the logbook](https://github.com/nvim-orgmode/orgmode/issues/149)
- [Easy list item management](https://github.com/nvim-orgmode/orgmode/issues/472)
# Python libraries
## [org-rw](https://code.codigoparallevar.com/kenkeiras/org-rw)
`org-rw` is a library designed to handle Org-mode files, offering the ability to modify data and save it back to the disk. 

- **Pros**:
  - Allows modification of data and saving it back to the disk
  - Includes tests to ensure functionality

- **Cons**:
  - Documentation is lacking, making it harder to understand and use
  - The code structure is complex and difficult to read
  - Uses `unittest` instead of `pytest`, which some developers may prefer
  - Tests are not easy to read
  - Last commit was made five months ago, indicating potential inactivity
  - [Not very popular]( https://github.com/kenkeiras/org-rw), with only one contributor, three stars, and no forks

## [orgparse](https://github.com/karlicoss/orgparse)
`orgparse` is a more popular library for parsing Org-mode files, with better community support and more contributors. However, it has significant limitations in terms of editing and saving changes.

- **Pros**:
  - More popular with 13 contributors, 43 forks, and 366 stars
  - Includes tests to ensure functionality
  - Provides some documentation, available [here](https://orgparse.readthedocs.io/en/latest/)

- **Cons**:
  - Documentation is not very comprehensive
  - Cannot write back to Org-mode files, limiting its usefulness for editing content
    - The author suggests using [inorganic](https://github.com/karlicoss/inorganic) to convert Org-mode entities to text, with examples available in doctests and the [orger](https://github.com/karlicoss/orger) library.
      - `inorganic` is not popular, with one contributor, four forks, 24 stars, and no updates in five years
      - The library is only 200 lines of code
    - The `ast` is geared towards single-pass document reading. While it is possible to modify the document object tree, writing back changes is more complicated and not a common use case for the author.

## [Tree-sitter](https://tree-sitter.github.io/tree-sitter/)
Tree-sitter is a powerful parser generator tool and incremental parsing library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited.

- **Pros**:
  - General enough to parse any programming language
  - Fast enough to parse on every keystroke in a text editor
  - Robust enough to provide useful results even in the presence of syntax errors
  - Dependency-free, with a runtime library written in pure C
  - Supports multiple languages through community-maintained parsers
  - Used by Neovim, indicating its reliability and effectiveness
  - Provides good documentation, available [here](https://tree-sitter.github.io/tree-sitter/using-parsers)
  - Python library, [py-tree-sitter](https://github.com/tree-sitter/py-tree-sitter), simplifies the installation process

- **Cons**:
  - Requires installation of Tree-sitter and the Org-mode language parser separately
  - The Python library does not handle the Org-mode language parser directly

To get a better grasp of Tree-sitter you can check their talks:

- [Strange Loop 2018](https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html)
- [FOSDEM 2018](https://www.youtube.com/watch?v=0CGzC_iss-8)
- [Github Universe 2017](https://www.youtube.com/watch?v=a1rC79DHpmY).

## [lazyblorg orgparser.py](https://github.com/novoid/lazyblorg/blob/master/lib/orgparser.py)
`lazyblorg orgparser.py` is another tool for working with Org-mode files. However, I didn't look at it.
# References

* [Source](https://github.com/nvim-orgmode/orgmode)
* [Getting started guide](https://github.com/nvim-orgmode/orgmode/wiki/Getting-Started)
* [Docs](https://nvim-orgmode.github.io/)
* [Developer docs](https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md)
* [Default configuration file](https://github.com/nvim-orgmode/orgmode/blob/master/lua/orgmode/config/defaults.lua)
* [List of supported commands](https://github.com/nvim-orgmode/orgmode/wiki/Feature-Completeness#nvim-org-commands-not-in-emacs)
* [Default mappings](https://github.com/nvim-orgmode/orgmode/blob/master/lua/orgmode/config/mappings/init.lua)
* [List of plugins](https://github.com/topics/orgmode-nvim)
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
