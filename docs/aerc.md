[aerc](https://aerc-mail.org/) is an email client that runs in your terminal.

Some of its more interesting features include:

- Editing emails in an embedded terminal tmux-style, allowing you to check on incoming emails and reference other threads while you compose your replies
- Render HTML emails with an interactive terminal web browser, highlight patches with diffs, and browse with an embedded less session
- Vim-style keybindings and ex-command system, allowing for powerful automation at a single keystroke
- First-class support for working with git & email
- Open a new tab with a terminal emulator and a shell running for easy access to nearby git repos for parallel work
- Support for multiple accounts, with IMAP, Maildir, Notmuch, Mbox and JMAP backends. Along with IMAP, JMAP, SMTP, and sendmail transfer protocols.
- Asynchronous IMAP and JMAP support ensures the UI never gets locked up by a flaky network.
- Efficient network usage - aerc only downloads the information which is necessary to present the UI, making for a snappy and bandwidth-efficient experience
- Email threading (with and/or without IMAP server support).
- PGP signing, encryption and verification using GNUpg.
- 100% free and open source software!

# [Installation](https://git.sr.ht/~rjarry/aerc/tree/0.21.0/item/README.md)

## Source

Download the [latest version](https://git.sr.ht/~rjarry/aerc)
Compile it with the repo instructions

## Debian

The debian version is very old, compile it directly

```bash
sudo apt-get install aerc
```

# Documentation

The docs are few and hard to read online, but there are throughout in local.

If you're lost you can always run again the tutorial with `:help tutorial`

# Configuration

On its first run, aerc will copy the default config files to `~/.config/aerc` on Linux. When you start the program for the first time a wizard will configure an account and start up the tutorial.

Read [Bence](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#sending-msmtpq) post, it's a nice guideline.

## [notmuch](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#notmuch)

Notmuch can be used directly as a backend for several email clients, including alot, dodo, Emacs, vim and (more importantly for us) aerc. While it can be used on its own, we are going to use it for its search index, and ability to seamlessly operate over multiple accounts' maildir folder. This will provide us with the ability to search all of our email regardless of account, and to show a unified overview of certain folders, e.g. a unified inbox. If you are only setting this up for a single account, I still recommend using notmuch for its search capabilities.

## [Gmail](https://frostyx.cz/posts/synchronize-your-2fa-gmail-with-mbsync)

If [these guidelines](https://frostyx.cz/posts/synchronize-your-2fa-gmail-with-mbsync) don't work, try [this others](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#oauth-mailctl).

## Monitorization

If you are using the mailsync scripts proposed above or on Bence's post you can check if the service failed with:

```yaml
groups:
  - name: email
    rules:
      - alert: MailsyncError
        expr: |
          count_over_time({user_service_name=~"mailsync-.*"} |= `Failed` [15m]) > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Error syncing the email with service {{ $labels.user_service_name }} at {{ $labels.host}}"
```

It assumes that you have the `user_service_name` label defined in your logs. I create them with [vector](vector.md) with the next config:

```yaml
transforms:
  journald_labels:
    type: remap
    inputs:
      - journald_filter
    source: |
      .service_name = ._SYSTEMD_UNIT || "unknown"
      .user_service_name = .USER_UNIT || ._SYSTEMD_USER_UNIT || "unknown"
```

# Usage

`aerc` has many commands that can be bound to keybindings, to see them all check `man 1 aerc`.

## Main page

- <C-p>, <C-n>: Cycles to the previous or next tab
- k, j: Scrolls up and down between messages
- <C-u>, <C-d>: Scrolls half a page up or down
- g, G: Selects the first or last message, respectively
- K, J: Switches between folders in the sidebar
- <Enter>: Opens the selected message

You can also search the selected folder with /, or filter with \ . When searching you can use n and p to jump to the next and previous result. Filtering hides any non-matching message.

## Message viewer

Press <Enter> to open a message. By default, the message viewer will display your message using less(1). This should also have familiar, vim-like keybindings for scrolling around in your message.

Multipart messages (messages with attachments, or messages with several alternative formats) show a part selector on the bottom of the message viewer.

- <C-k>, <C-j>: Cycle between parts of a multipart message
- q: Close the message viewer
- f: next message
- b: previous message

To show HTML messages, uncomment the text/html filter in your aerc.conf file (which is probably in ~/.config/aerc/) and install its dependencies: w3m and dante-utils.

You can also do many tasks you could do in the message list from here, like replying to emails, deleting the email, or view the next and previous message (J and K).

Some interesting commands are:

- `:unsubscribe`: Attempt to automatically unsubscribe the user from the mailing list through use of the List-Unsubscribe header. If supported, aerc may open a compose window pre-filled with the unsubscribe information or open the unsubscribe URL in a web browser.

## Composing messages

- C: Compose a new message
- rr: Reply-all to a message
- rq: Reply-all to a message, and pre-fill the editor with a quoted version of the message being replied to
- Rr: Reply to a message
- Rq: Reply to a message, and pre-fill the editor with a quoted version of the message being replied to

The message composer will appear. You should see To, From, and Subject lines, as well as your $EDITOR. You can use <Tab> or <C-j> and <C-k> to cycle between these fields (tab won't cycle between fields once you enter the editor, but <C-j> and <C-k> will).

# References

- [Home](https://aerc-mail.org/)
- [Source](https://git.sr.ht/~rjarry/aerc)
- [Docs](https://man.sr.ht/~rjarry/aerc/)
- [Issues](https://todo.sr.ht/~rjarry/aerc?__goaway_challenge=meta-refresh&__goaway_id=7efb941c2542b6ec58b84a4b88e1c20b)

## Interesting configurations

- [Bence post](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#sending-msmtpq)
- [Acarg post](https://www.acarg.ch/posts/aerc-email-setup/)
- [Drew post](https://drewdevault.com/2021/05/17/aerc-with-mbsync-postfix.html)
