[pyTelegramBotAPI](https://github.com/eternnoir/pyTelegramBotAPI) is an synchronous and asynchronous implementation of the [Telegram Bot API](https://core.telegram.org/bots/api).

# [Installation](https://pytba.readthedocs.io/en/latest/install.html)

```bash
pip install pyTelegramBotAPI
```

# Quickstart

## [Create your bot](https://core.telegram.org/bots/features#botfather)

Use the `/newbot` command to create a new bot. `@BotFather` will ask you for a name and username, then generate an authentication token for your new bot.

- The `name` of your bot is displayed in contact details and elsewhere.
- The `username` is a short name, used in search, mentions and t.me links. Usernames are 5-32 characters long and not case sensitive – but may only include Latin characters, numbers, and underscores. Your bot's username must end in 'bot’, like `tetris_bot` or `TetrisBot`.
- The `token` is a string, like `110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`, which is required to authorize the bot and send requests to the Bot API. Keep your token secure and store it safely, it can be used by anyone to control your bot.


To edit your bot, you have the next available commands:

- `/setname`: change your bot's name.
- `/setdescription`: change the bot's description (short text up to 512 characters). Users will see this text at the beginning of the conversation with the bot, titled 'What can this bot do?'.
- `/setabouttext`: change the bot's about info, a shorter text up to 120 characters. Users will see this text on the bot's profile page. When they share your bot with someone, this text is sent together with the link.
- `/setuserpic`: change the bot's profile picture.
- `/setcommands`: change the list of commands supported by your bot. Users will see these commands as suggestions when they type / in the chat with your bot. See commands for more info.
- `/setdomain`: link a website domain to your bot. See the login widget section.
- `/deletebot`: delete your bot and free its username. Cannot be undone.

## [Synchronous TeleBot](https://pytba.readthedocs.io/en/latest/quick_start.html#synchronous-telebot)

```python
#!/usr/bin/python

# This is a simple echo bot using the decorator mechanism.
# It echoes any incoming text messages.

import telebot

API_TOKEN = '<api_token>'

bot = telebot.TeleBot(API_TOKEN)


# Handle '/start' and '/help'
@bot.message_handler(commands=['help', 'start'])
def send_welcome(message):
    bot.reply_to(message, """\
Hi there, I am EchoBot.
I am here to echo your kind words back to you. Just say anything nice and I'll say the exact same thing to you!\
""")


# Handle all other messages with content_type 'text' (content_types defaults to ['text'])
@bot.message_handler(func=lambda message: True)
def echo_message(message):
    bot.reply_to(message, message.text)


bot.infinity_polling()
```

## [Asynchronous TeleBot](https://pytba.readthedocs.io/en/latest/quick_start.html#asynchronous-telebot)

```python
#!/usr/bin/python

# This is a simple echo bot using the decorator mechanism.
# It echoes any incoming text messages.

from telebot.async_telebot import AsyncTeleBot
bot = AsyncTeleBot('TOKEN')



# Handle '/start' and '/help'
@bot.message_handler(commands=['help', 'start'])
async def send_welcome(message):
    await bot.reply_to(message, """\
Hi there, I am EchoBot.
I am here to echo your kind words back to you. Just say anything nice and I'll say the exact same thing to you!\
""")


# Handle all other messages with content_type 'text' (content_types defaults to ['text'])
@bot.message_handler(func=lambda message: True)
async def echo_message(message):
    await bot.reply_to(message, message.text)


import asyncio
asyncio.run(bot.polling())
```

# References

- [Documentation](https://pytba.readthedocs.io/en/latest/index.html)
- [Source](https://github.com/eternnoir/pyTelegramBotAPI)
- [Async Examples](https://github.com/eternnoir/pyTelegramBotAPI/tree/master/examples/asynchronous_telebot)
