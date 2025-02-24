[himalaya](https://github.com/pimalaya/himalaya) is a Rust CLI to manage emails.

Features:

- Multi-accounting
- Interactive configuration via **wizard** (requires `wizard` feature)
- Mailbox, envelope, message and flag management
- Message composition based on `$EDITOR`
- **IMAP** backend (requires `imap` feature)
- **Maildir** backend (requires `maildir` feature)
- **Notmuch** backend (requires `notmuch` feature)
- **SMTP** backend (requires `smtp` feature)
- **Sendmail** backend (requires `sendmail` feature)
- Global system **keyring** for managing secrets (requires `keyring` feature)
- **OAuth 2.0** authorization (requires `oauth2` feature)
- **JSON** output via `--output json`
- **PGP** encryption:
  - via shell commands (requires `pgp-commands` feature)
  - via [GPG](https://www.gnupg.org/) bindings (requires `pgp-gpg` feature)
  - via native implementation (requires `pgp-native` feature)

Cons:

- Documentation is inexistent, you have to dive into the `--help` to understand stuff.

# [Installation](https://github.com/pimalaya/himalaya)

*The `v1.0.0` is currently being tested on the `master` branch, and is the prefered version to use. Previous versions (including GitHub beta releases and repositories published versions) are not recommended.*

Himalaya CLI `v1.0.0` can be installed with a pre-built binary. Find the latest [`pre-release`](https://github.com/pimalaya/himalaya/actions/workflows/pre-release.yml) GitHub workflow and look for the *Artifacts* section. You should find a pre-built binary matching your OS.

Himalaya CLI `v1.0.0` can also be installed with [cargo](https://doc.rust-lang.org/cargo/):

```bash
cargo install --git https://github.com/pimalaya/himalaya.git --force himalaya
```
# [Configuration](https://github.com/pimalaya/himalaya?tab=readme-ov-file#configuration)

Just run `himalaya`, the wizard will help you to configure your default account.

You can also manually edit your own configuration, from scratch:

- Copy the content of the documented [`./config.sample.toml`](https://github.com/pimalaya/himalaya/blob/master/config.sample.toml)
- Paste it in a new file `~/.config/himalaya/config.toml`
- Edit, then comment or uncomment the options you want

## If using mbrsync

My generic configuration for an mbrsync account is:

```
[accounts.account_name]

email = "lyz@example.org"
display-name = "lyz"
envelope.list.table.unseen-char = "u"
envelope.list.table.replied-char = "r"
backend.type = "maildir"
backend.root-dir = "/home/lyz/.local/share/mail/lyz-example"
backend.maildirpp = false
message.send.backend.type = "smtp"
message.send.backend.host = "example.org"
message.send.backend.port = 587
message.send.backend.encryption = "start-tls"
message.send.backend.login = "lyz"
message.send.backend.auth.type = "password"
message.send.backend.auth.command = "pass show mail/lyz.example"
```

Once you've set it then you need to [fix the INBOX directory](#cannot-find-maildir-matching-name-inbox).

Then you can check if it works by running `himalaya envelopes list -a lyz-example`

## [Vim plugin installation](https://github.com/pimalaya/himalaya-vim)

Using lazy:

```lua
return {
  {
    "pimalaya/himalaya-vim",
  },
}
```

You can then run `:Himalaya account_name` and it will open himalaya in your editor.

### Configure navigation bindings

The default bindings conflict with my git bindings, and to make them similar to orgmode agenda I'm changing the next and previous page:

```lua
      vim.api.nvim_create_autocmd("FileType", {
        group = "HimalayaCustomBindings",
        pattern = "himalaya-email-listing",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "n", "b", "<plug>(himalaya-folder-select-previous-page)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "f", "<plug>(himalaya-folder-select-next-page)", { noremap = true, silent = true })
        end,
      })
```
### Configure the account bindings

To avoid typing `:Himalaya account_name` each time you want to check the email you can set some bindings:

```lua
return {
  {
    "pimalaya/himalaya-vim",
    keys = {
      { "<leader>ma", "<cmd>Himalaya account_name<cr>", desc = "Open account_name@example.org" },
      { "<leader>ml", "<cmd>Himalaya lyz<cr>", desc = "Open lyz@example.org" },
    },
  },
}
```

Setting the description is useful to see the configured accounts with which-key by typing `<leader>m` and waiting.

### Configure extra bindings

The default plugin doesn't yet have all the bindings I'd like so I've added the next ones:

- In the list of emails view:
  - `dd` in normal mode or `d` in visual: Delete emails
  - `q`: exit the program

- In the email read view:
  - `d`: Delete email
  - `q`: Return to the list of emails view 

- In the email write view:
  - `q` or `<c-s>`: Save and send the email

If you want them too set the next config:

```lua
return {
  {
    "pimalaya/himalaya-vim",
    config = function()
      vim.api.nvim_create_augroup("HimalayaCustomBindings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "HimalayaCustomBindings",
        pattern = "himalaya-email-listing",
        callback = function()
          -- Bindings to delete emails
          vim.api.nvim_buf_set_keymap(0, "n", "dd", "<plug>(himalaya-email-delete)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "x", "d", "<plug>(himalaya-email-delete)", { noremap = true, silent = true })
          -- Refresh emails
          vim.api.nvim_buf_set_keymap(0, "n", "r", ":lua FetchEmails()<CR>", { noremap = true, silent = true })
          -- Email list view bindings
          vim.api.nvim_buf_set_keymap(0, "n", "b", "<plug>(himalaya-folder-select-previous-page)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "f", "<plug>(himalaya-folder-select-next-page)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "R", "<plug>(himalaya-email-reply-all)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "F", "<plug>(himalaya-email-forward)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "m", "<plug>(himalaya-folder-select)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "M", "<plug>(himalaya-email-move)", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "w", "<plug>(himalaya-email-write)", { noremap = true, silent = true })
          -- Bind `q` to close the window
          vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true })
        end,
      })

      vim.api.nvim_create_augroup("HimalayaEmailCustomBindings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "HimalayaEmailCustomBindings",
        pattern = "mail",
        callback = function()
          -- Get the current buffer's full file path
          local filepath = vim.api.nvim_buf_get_name(0)

          -- Bind `q` and `<c-s>` to close the window
          if string.match(filepath, "write") then
            vim.api.nvim_buf_set_keymap(0, "n", "<c-s>", ":w<CR>:bd<CR>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(0, "n", "q", ":w<CR>:bd<CR>", { noremap = true, silent = true })
          else
            -- In read mode you can't save the buffer
            vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true })
          end

          -- Bind `d` to delete the email and close the window
          vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "d",
            "<plug>(himalaya-email-delete):q<CR>",
            { noremap = true, silent = true }
          )
        end,
      })
    end,
  },
}
```

### Configure email fetching from within vim 

[Fetching emails from within vim](https://github.com/pimalaya/himalaya-vim/issues/13) is not yet supported, so I'm manually refreshing by account:

```lua
return {
  {
    "pimalaya/himalaya-vim",
    keys = {
      -- Email refreshing bindings
      { "r", ":lua FetchEmails()<CR>", desc = "Fetch emails" },
    },
    config = function()
      function FetchEmails()
        local account = vim.api.nvim_eval("himalaya#domain#account#current()")

        vim.notify("Fetching emails for " .. account .. ", please wait...", vim.log.levels.INFO)
        vim.cmd("redraw")

        -- Start the mbsync job
        vim.fn.jobstart("mbsync " .. account, {
          on_exit = function(_, exit_code, _)
            if exit_code == 0 then
              vim.notify("Emails for " .. account .. " fetched successfully!", vim.log.levels.INFO)
              -- Reload Himalaya only after successful mbsync
              vim.cmd("Himalaya " .. account)
            else
              vim.notify("Failed to fetch emails for " .. account .. ". Check the logs.", vim.log.levels.ERROR)
            end
          end,
        })
      end
    end,
  },
}
```

## Show notifications when emails arrive

You can set up [mirador](mirador.md) to get those notifications.

## Configure GPG

Himalaya relies on cargo features to enable gpg. You can see the default enabled features in the [Cargo.toml](https://github.com/pimalaya/himalaya/blob/master/Cargo.toml#L18) file. As of 2025-01-27 the `pgp-commands` is enabled.

You only need to add the next section to your config:

```ini
pgp.type = "commands"
```

And then you can use both the cli and the vim plugin with gpg. Super easy

# Usage

## Searching emails

You can use the `g/` binding from within nvim to search for emails. The query syntax supports filtering and sorting query.

I've tried changing it to `/` without success :'(

### Filters

A filter query is composed of operators and conditions. There is 3 operators and 8 conditions:

- `not <condition>`: filter envelopes that do not match the condition
- `<condition> and <condition>`: filter envelopes that match both conditions
- `<condition> or <condition>`: filter envelopes that match one of the conditions
- `date <yyyy-mm-dd>`: filter envelopes that match the given date
- `before <yyyy-mm-dd>`: filter envelopes with date strictly before the given one
- `after <yyyy-mm-dd>`: filter envelopes with date stricly after the given one
- `from <pattern>`: filter envelopes with senders matching the given pattern
- `to <pattern>`: filter envelopes with recipients matching the given pattern
- `subject <pattern>`: filter envelopes with subject matching the given pattern
- `body <pattern>`: filter envelopes with text bodies matching the given pattern
- `flag <flag>`: filter envelopes matching the given flag

### Sorting 
A sort query starts by "order by", and is composed of kinds and orders. There is 4 kinds and 2 orders:

- `date [order]`: sort envelopes by date
- `from [order]`: sort envelopes by sender
- `to [order]`: sort envelopes by recipient
- `subject [order]`: sort envelopes by subject
- `<kind> asc`: sort envelopes by the given kind in ascending order
- `<kind> desc`: sort envelopes by the given kind in descending order

### Examples

`subject foo and body bar`: filter envelopes containing "foo" in their subject and "bar" in their text bodies
`order by date desc subject`: sort envelopes by descending date (most recent first), then by ascending subject
`subject foo and body bar order by date desc subject`: combination of the 2 previous examples

# Not there yet

- [Replying an email doesn't mark it as replied](https://github.com/pimalaya/himalaya-vim/issues/14) 
- [With the vim plugin you can't switch accounts](https://github.com/pimalaya/himalaya-vim/issues/8)
- [Let the user delete emails without confirmation](https://github.com/pimalaya/himalaya-vim/issues/12)
# Troubleshooting

## Cannot install

Sometimes [the installation steps fail](https://github.com/pimalaya/himalaya/issues/513) as it's still not in stable. A workaround is to download the binary created by the [pre-release CI](https://github.com/pimalaya/himalaya/actions/workflows/pre-releases.yml). You can do it by:

- Click on the latest job
- Click on jobs 
- Click on the job of your architecture
- Click on "Upload release"
- Search for "Artifact download URL" and download the file
- Unpack it and add it somewhere in your `$PATH`

## Emails are shown with different timezones

Set the account configuration `envelope.list.datetime-local-tz = true`

## Emails are not being copied to Sent 

Set the account configuration `message.send.save-copy = true`

## [Cannot find maildir matching name INBOX](https://github.com/pimalaya/himalaya/issues/490)

`mbrsync` uses `Inbox` instead of the default `INBOX` so it  doesn't find it. In theory you can use `folder.alias.inbox = "Inbox"` but it didn't work with me, so I finally ended up doing a symbolic link from `INBOX` to `Inbox`.

## Cannot find maildir matching name Trash

That's because the `Trash` directory does not follow the Maildir structure. I had to create the `cur` `tmp` and `new` directories.
# References
- [Source](https://github.com/pimalaya/himalaya)
- [Vim plugin source](https://github.com/pimalaya/himalaya-vim)
- [Home](https://pimalaya.org/)
