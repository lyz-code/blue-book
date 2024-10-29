In Python, there are several libraries available for interacting with IMAP servers to fetch and manipulate emails. Some popular ones include:

# Comparison of libraries
## imaplib
This is the built-in IMAP client library in Python's standard library (`imaplib`). It provides basic functionality for connecting to an IMAP server, listing mailboxes, searching messages, fetching message headers, and more.

The [documentation](https://docs.python.org/3/library/imaplib.html) is awful to read. I'd use it only if you can't or don't want to install other more friendly libraries

### Usage
Example usage:
```python
import imapclient

mail = imapclient.IMAPClient('imap.example.com', ssl=True)
mail.login('username', 'password')

```
### References

- [Docs](https://docs.python.org/3/library/imaplib.html)
- [Usage article](https://medium.com/@juanrosario38/how-to-use-pythons-imaplib-to-check-for-new-emails-continuously-b0c6780d796d)

## imapclient

This is a higher-level library built on top of imaplib. It provides a more user-friendly API, reducing the complexity of interacting with IMAP servers.

It's docs are better than the standard library but they are old fashioned and not very extensive. It has 500 stars on github, the last commit was 3 months ago, and the last release was on December 2023 (as of October 2024)

### References

- [Source](https://github.com/mjs/imapclient/)
- [Docs](https://imapclient.readthedocs.io/en/3.0.0/)

## [`imap_tools`](imap_tools.md)

`imap-tools` is a high-level IMAP client library for Python, providing a simple and intuitive API for common email tasks like fetching messages, flagging emails as read/unread, labeling/moving/deleting emails, searching/filtering emails, and more.

It's interface looks the most pleasant, with the most powerful features, last commit was 3 weeks ago, 700 stars, last release on august 2024, it has type hints.

### Usage
Example usage:
```python
import imap_tools

mail = imap_tools.Mail('imap.example.com', ssl=True)
mail.login('username', 'password')

# List messages
messages = mail.list()

# Fetch a message by ID
message = mail.fetch('1234567890')
```

### References
- [Source](https://github.com/ikvk/imap_tools)
- [Docs](https://github.com/ikvk/imap_tools)
- [Examples](https://github.com/ikvk/imap_tools/tree/master/examples)
## pyzmail

`pyzmail` is a powerful library for reading and parsing mail messages in Python, supporting both POP3 and IMAP protocols.

It has 60 stars on github and the last commit was 9 years ago, so it's a dead project

### Usage
Example usage:
```python
import pyzmail

p = pyzmail.PyzMail()
p.connect("imap.example.com", "username", "password")
p.select_folder('INBOX')
messages = p.get_messages()
```

### References
- [Home](https://www.magiksys.net/pyzmail/)
- [Source](https://github.com/aspineux/pyzmail)

## Conclusion

If you don't want to install any additional library go with `imaplib`, else use [`imap_tools`](imap_tools.md)

