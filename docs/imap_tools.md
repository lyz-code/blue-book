`imap-tools` is a high-level IMAP client library for Python, providing a simple and intuitive API for common email tasks like fetching messages, flagging emails as read/unread, labeling/moving/deleting emails, searching/filtering emails, and more.

Features:

- Basic message operations: fetch, uids, numbers
- Parsed email message attributes
- Query builder for search criteria
- Actions with emails: copy, delete, flag, move, append
- Actions with folders: list, set, get, create, exists, rename, subscribe, delete, status
- IDLE commands: start, poll, stop, wait
- Exceptions on failed IMAP operations
- No external dependencies, tested

# Installation

```bash
pip install imap-tools
```

# Usage

Both the [docs](https://github.com/ikvk/imap_tools) and the [examples](https://github.com/ikvk/imap_tools/tree/master/examples) are very informative on how to use the library.

## [Basic usage](https://github.com/ikvk/imap_tools/blob/master/examples/basic.py)
```python
from imap_tools import MailBox, AND

"""
Get date, subject and body len of all emails from INBOX folder

1. MailBox()
    Create IMAP client, the socket is created here
    
2. mailbox.login()
    Login to mailbox account
    It supports context manager, so you do not need to call logout() in this example
    Select INBOX folder, cause login initial_folder arg = 'INBOX' by default (set folder may be disabled with None)
    
3. mailbox.fetch()
    First searches email uids by criteria in current folder, then fetch and yields MailMessage
    Criteria arg is 'ALL' by default
    Current folder is 'INBOX' (set on login), by default it is INBOX too.
    Fetch each message separately per N commands, cause bulk arg = False by default
    Mark each fetched email as seen, cause fetch mark_seen arg = True by default
    
4. print
    msg variable is MailMessage instance
    msg.date - email data, converted to datetime.date
    msg.subject - email subject, utf8 str
    msg.text - email plain text content, utf8 str
    msg.html - email html content, utf8 str
"""
with MailBox('imap.mail.com').login('test@mail.com', 'pwd') as mailbox:
    for msg in mailbox.fetch():
        print(msg.date, msg.subject, len(msg.text or msg.html))

# Equivalent verbose version:
mailbox = MailBox('imap.mail.com')
mailbox.login('test@mail.com', 'pwd', 'INBOX')  # or use mailbox.folder.set instead initial_folder arg
for msg in mailbox.fetch(AND(all=True)):
    print(msg.date, msg.subject, len(msg.text or msg.html))
mailbox.logout()
```

## [Action with emails](https://github.com/ikvk/imap_tools?tab=readme-ov-file#actions-with-emails)

Action's uid_list arg may takes:

- str, that is comma separated uids
- Sequence, that contains str uids

To get uids, use the maibox methods: uids, fetch.

For actions with a large number of messages imap command may be too large and will cause exception at server side, use 'limit' argument for fetch in this case.

```python
with MailBox('imap.mail.com').login('test@mail.com', 'pwd', initial_folder='INBOX') as mailbox:

    # COPY messages with uid in 23,27 from current folder to folder1
    mailbox.copy('23,27', 'folder1')

    # MOVE all messages from current folder to INBOX/folder2
    mailbox.move(mailbox.uids(), 'INBOX/folder2')

    # DELETE messages with 'cat' word in its html from current folder
    mailbox.delete([msg.uid for msg in mailbox.fetch() if 'cat' in msg.html])

    # FLAG unseen messages in current folder as \Seen, \Flagged and TAG1
    flags = (imap_tools.MailMessageFlags.SEEN, imap_tools.MailMessageFlags.FLAGGED, 'TAG1')
    mailbox.flag(mailbox.uids(AND(seen=False)), flags, True)

    # APPEND: add message to mailbox directly, to INBOX folder with \Seen flag and now date
    with open('/tmp/message.eml', 'rb') as f:
        msg = imap_tools.MailMessage.from_bytes(f.read())  # *or use bytes instead MailMessage
    mailbox.append(msg, 'INBOX', dt=None, flag_set=[imap_tools.MailMessageFlags.SEEN])
```

## [Run search queries](https://github.com/ikvk/imap_tools/blob/master/examples/search.py)

You can get more information on the search criteria [here](https://github.com/ikvk/imap_tools?tab=readme-ov-file#search-criteria)
```python
"""
Query builder examples.

NOTES:

# Infix notation (natural to humans)
    NOT ((FROM='11' OR TO="22" OR TEXT="33") AND CC="44" AND BCC="55")
# Prefix notation (Polish notation, IMAP version)
    NOT (((OR OR FROM "11" TO "22" TEXT "33") CC "44" BCC "55"))
# Python query builder
    NOT(AND(OR(from_='11', to='22', text='33'), cc='44', bcc='55'))

# python to prefix notation steps:
1. OR(1=11, 2=22, 3=33) ->
    "(OR OR FROM "11" TO "22" TEXT "33")"
2. AND("(OR OR FROM "11" TO "22" TEXT "33")", cc='44', bcc='55') ->
    "AND(OR(from_='11', to='22', text='33'), cc='44', bcc='55')"
3. NOT("AND(OR(from_='11', to='22', text='33'), cc='44', bcc='55')") ->
    "NOT (((OR OR FROM "1" TO "22" TEXT "33") CC "44" BCC "55"))"
"""

import datetime as dt
from imap_tools import AND, OR, NOT, A, H, U

# date in the date list (date=date1 OR date=date3 OR date=date2)
q1 = OR(date=[dt.date(2019, 10, 1), dt.date(2019, 10, 10), dt.date(2019, 10, 15)])
# '(OR OR ON 1-Oct-2019 ON 10-Oct-2019 ON 15-Oct-2019)'

# date not in the date list (NOT(date=date1 OR date=date3 OR date=date2))
q2 = NOT(OR(date=[dt.date(2019, 10, 1), dt.date(2019, 10, 10), dt.date(2019, 10, 15)]))
# 'NOT ((OR OR ON 1-Oct-2019 ON 10-Oct-2019 ON 15-Oct-2019))'

# subject contains "hello" AND date greater than or equal dt.date(2019, 10, 10)
q3 = A(subject='hello', date_gte=dt.date(2019, 10, 10))
# '(SUBJECT "hello" SINCE 10-Oct-2019)'

# from contains one of the address parts
q4 = OR(from_=["@spam.ru", "@tricky-spam.ru"])
# '(OR FROM "@spam.ru" FROM "@tricky-spam.ru")'

# marked as seen and not flagged
q5 = AND(seen=True, flagged=False)
# '(SEEN UNFLAGGED)'

# (text contains tag15 AND subject contains tag15) OR (text contains tag10 AND subject contains tag10)
q6 = OR(AND(text='tag15', subject='tag15'), AND(text='tag10', subject='tag10'))
# '(OR (TEXT "tag15" SUBJECT "tag15") (TEXT "tag10" SUBJECT "tag10"))'

# (text contains tag15 OR subject contains tag15) OR (text contains tag10 OR subject contains tag10)
q7 = OR(OR(text='tag15', subject='tag15'), OR(text='tag10', subject='tag10'))
# '(OR (OR TEXT "tag15" SUBJECT "tag15") (OR TEXT "tag10" SUBJECT "tag10"))'

# header IsSpam contains '++' AND header CheckAntivirus contains '-'
q8 = A(header=[H('IsSpam', '++'), H('CheckAntivirus', '-')])
# '(HEADER "IsSpam" "++" HEADER "CheckAntivirus" "-")'

# UID range
q9 = A(uid=U('1034', '*'))
# '(UID 1034:*)'

# complex from README
q10 = A(OR(from_='from@ya.ru', text='"the text"'), NOT(OR(A(answered=False), A(new=True))), to='to@ya.ru')
# '((OR FROM "from@ya.ru" TEXT "\\"the text\\"") NOT ((OR (UNANSWERED) (NEW))) TO "to@ya.ru")'
```

## [Save attachments](https://github.com/ikvk/imap_tools/blob/master/examples/email_attachments_to_files.py)

```python
from imap_tools import MailBox

# get all attachments from INBOX and save them to files
with MailBox('imap.my.ru').login('acc', 'pwd', 'INBOX') as mailbox:
    for msg in mailbox.fetch():
        for att in msg.attachments:
            print(att.filename, att.content_type)
            with open('C:/1/{}'.format(att.filename), 'wb') as f:
                f.write(att.payload)
```

## [Action with directories](https://github.com/ikvk/imap_tools?tab=readme-ov-file#actions-with-folders)

```python
with MailBox('imap.mail.com').login('test@mail.com', 'pwd') as mailbox:

    # LIST: get all subfolders of the specified folder (root by default)
    for f in mailbox.folder.list('INBOX'):
        print(f)  # FolderInfo(name='INBOX|cats', delim='|', flags=('\\Unmarked', '\\HasChildren'))

    # SET: select folder for work
    mailbox.folder.set('INBOX')

    # GET: get selected folder
    current_folder = mailbox.folder.get()

    # CREATE: create new folder
    mailbox.folder.create('INBOX|folder1')

    # EXISTS: check is folder exists (shortcut for list)
    is_exists = mailbox.folder.exists('INBOX|folder1')

    # RENAME: set new name to folder
    mailbox.folder.rename('folder3', 'folder4')

    # SUBSCRIBE: subscribe/unsubscribe to folder
    mailbox.folder.subscribe('INBOX|папка два', True)

    # DELETE: delete folder
    mailbox.folder.delete('folder4')

    # STATUS: get folder status info
    stat = mailbox.folder.status('some_folder')
    print(stat)  # {'MESSAGES': 41, 'RECENT': 0, 'UIDNEXT': 11996, 'UIDVALIDITY': 1, 'UNSEEN': 5}

```
## [Fetch by pages](https://github.com/ikvk/imap_tools/blob/master/examples/fetch_by_pages.py)

```python
from imap_tools import MailBox

with MailBox('imap.mail.com').login('test@mail.com', 'pwd', 'INBOX') as mailbox:
    criteria = 'ALL'
    found_nums = mailbox.numbers(criteria)
    page_len = 3
    pages = int(len(found_nums) // page_len) + 1 if len(found_nums) % page_len else int(len(found_nums) // page_len)
    for page in range(pages):
        print('page {}'.format(page))
        page_limit = slice(page * page_len, page * page_len + page_len)
        print(page_limit)
        for msg in mailbox.fetch(criteria, bulk=True, limit=page_limit):
            print(' ', msg.date, msg.uid, msg.subject)
```
# References
- [Source](https://github.com/ikvk/imap_tools)
- [Docs](https://github.com/ikvk/imap_tools)
- [Examples](https://github.com/ikvk/imap_tools/tree/master/examples)
