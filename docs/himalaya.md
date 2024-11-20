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
$ cargo install --git https://github.com/pimalaya/himalaya.git --force himalaya
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

## Vim plugin installation

Using lazy:

```lua
return {
  {
    "pimalaya/himalaya-vim",
  },
}
```

You can then run `:Himalaya account_name` and it will open himalaya in your editor.

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

- In the email view:
  - `d`: Delete email
  - `q`: Return to the list of emails view 

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
          -- Bind `q` to close the window
          vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true })
        end,
      })

      vim.api.nvim_create_augroup("HimalayaEmailCustomBindings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "HimalayaEmailCustomBindings",
        pattern = "mail",
        callback = function()
          -- Bind `q` to close the window
          vim.api.nvim_buf_set_keymap(0, "n", "q", ":q<CR>", { noremap = true, silent = true })
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
      { "<leader>rj", ':lua FetchEmails("lyz")<CR>', desc = "Fetch lyz@example.org" },
    },
    config = function()
      function FetchEmails(account)
        vim.notify("Fetching emails for " .. account .. ", please wait...", vim.log.levels.INFO)
        vim.cmd("redraw")
        vim.fn.jobstart("mbsync " .. account, {
          on_exit = function(_, exit_code, _)
            if exit_code == 0 then
              vim.notify("Emails for " .. account .. " fetched successfully!", vim.log.levels.INFO)
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

You still need to open again `:Himalaya account_name` as the plugin does not reload if there are new emails.

## Show notifications when emails arrive

You can set up [mirador](mirador.md) to get those notifications.
# Not there yet

- [With the vim plugin you can't switch accounts](https://github.com/pimalaya/himalaya-vim/issues/8)
- [Let the user delete emails without confirmation](https://github.com/pimalaya/himalaya-vim/issues/12)
- [Fetching emails from within vim](https://github.com/pimalaya/himalaya-vim/issues/13)

# Troubleshooting

## [Cannot find maildir matching name INBOX](https://github.com/pimalaya/himalaya/issues/490)

`mbrsync` uses `Inbox` instead of the default `INBOX` so it  doesn't find it. In theory you can use `folder.alias.inbox = "Inbox"` but it didn't work with me, so I finally ended up doing a symbolic link from `INBOX` to `Inbox`.

## Cannot find maildir matching name Trash

That's because the `Trash` directory does not follow the Maildir structure. I had to create the `cur` `tmp` and `new` directories.
# References
- [Source](https://github.com/pimalaya/himalaya)
- [Vim plugin source](https://github.com/pimalaya/himalaya-vim)