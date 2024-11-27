There are two ways to interact with Telegram through python:

- Client libraries
- Bot libraries

# Client libraries

Client libraries use your account to interact with Telegram itself through a developer API token.

The most popular to use is [Telethon](https://docs.telethon.dev/en/stable/index.html).

# Bot libraries

[Telegram lists many libraries to interact with the bot API](https://core.telegram.org/bots/samples#python), the most interesting are:

- [python-telegram-bot](#python-telegram-bot)
- [pyTelegramBotAPI](#pytelegrambotapi)
- [aiogram](#aiogram)

If there comes a moment when we have to create the messages ourselves, [telegram-text](https://telegram-text.alinsky.tech/api_reference) may be an interesting library to check.

## [python-telegram-bot](https://github.com/python-telegram-bot/python-telegram-bot)

Pros:

- Popular: 23k stars, 4.9k forks
- Maintained: last commit 3 days ago
- They have a developers community to get help in [this telegram group](https://telegram.me/pythontelegrambotgroup)
- I like how they try to minimize third party dependencies, and how you can install the complements if you need them
- Built on top of asyncio
- Nice docs
- Fully supports the [Telegram bot API](https://core.telegram.org/bots/api)
- Has many examples

Cons:

- Interface is a little verbose and complicated at a first look
- Only to be run in a single thread (not a problem)

References:

- [Package documentation](https://docs.python-telegram-bot.org/) is the technical reference for python-telegram-bot. It contains descriptions of all available classes, modules, methods and arguments as well as the changelog.
- [Wiki](https://github.com/python-telegram-bot/python-telegram-bot/wiki/) is home to number of more elaborate introductions of the different features of python-telegram-bot and other useful resources that go beyond the technical documentation.
- [Examples](https://docs.python-telegram-bot.org/examples.html) section contains several examples that showcase the different features of both the Bot API and python-telegram-bot
- [Source](https://github.com/python-telegram-bot/python-telegram-bot)

## [pyTelegramBotAPI](https://github.com/eternnoir/pyTelegramBotAPI)

Pros:

- Popular: 7.1k stars, 1.8k forks
- Maintained: last commit 3 weeks ago
- Both sync and async 
- Nicer interface with decorators and simpler setup
- [They have an example on how to split long messages](https://github.com/eternnoir/pyTelegramBotAPI#sending-large-text-messages)
- [Nice docs on how to test](https://github.com/eternnoir/pyTelegramBotAPI#testing)
- They have a developers community to get help in [this telegram group](https://telegram.me/joinchat/Bn4ixj84FIZVkwhk2jag6A)
- Fully supports the [Telegram bot API](https://core.telegram.org/bots/api)
- Has examples

Cons:

- Uses lambdas inside the decorators, I don't know why it does it.
- The docs are not as throughout as `python-telegram-bot` one.

References:

- [Documentation](https://pytba.readthedocs.io/en/latest/index.html)
- [Source](https://github.com/eternnoir/pyTelegramBotAPI)
- [Async Examples](https://github.com/eternnoir/pyTelegramBotAPI/tree/master/examples/asynchronous_telebot)

## [aiogram](https://github.com/aiogram/aiogram)

Pros:

- Popular: 3.8k stars, 717k forks
- Maintained: last commit 4 days ago
- Async support
- They have a developers community to get help in [this telegram group](https://t.me/aiogram)
- Has type hints
- Cleaner interface than `python-telegram-bot`
- Fully supports the [Telegram bot API](https://core.telegram.org/bots/api)
- Has examples

Cons:

- Less popular than `python-telegram-bot`
- Docs are written at a developer level, difficult initial barrier to understand how to use it.

References:

- [Documentation](https://docs.aiogram.dev/en/dev-3.x/)
- [Source](https://github.com/aiogram/aiogram)
- [Examples](https://github.com/aiogram/aiogram/tree/dev-3.x/examples)

## Conclusion

Even if `python-telegram-bot` is the most popular and with the best docs, I prefer one of the others due to the easier interface. `aiogram`s documentation is kind of crap, and as it's the first time I make a bot I'd rather have somewhere good to look at.

So I'd say to go first with `pyTelegramBotAPI` and if it doesn't go well, fall back to `python-telegram-bot`.
