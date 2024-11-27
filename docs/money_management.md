---
title: Money Management
date: 20210126
author: Lyz
---

Money management is the act of analyzing where you spend your money on with
the least amount of mental load.

Some years ago I started using [the double entry counting
method](https://beancount.github.io/docs/the_double_entry_counting_method.html#introduction)
with [beancount](beancount.md).

# System inputs

I have two types of financial transactions to track:

* The credit/debit card movements: Easy to track as usually the banks support
    exporting them as CSV, and beancount have [specific bank
    importers](https://awesome-beancount.com/#importers).

* The cash movements: Harder to track as you need to keep them manually. This
    has been my biggest source of errors, once I understood how to correctly use
    [beancount](beancount.md).

    In the latest iteration, I'm using the [cone](cone.md) Android app to keep
    track of these expenses.

# Workflow

# Beancount ledger organization

My beancount project directory tree is:

```
.
├── .git
│   └── ...
├── 2011
│   ├── 09.book
│   ├── 10.book
│   ├── 11.book
│   ├── 12.book
│   └── year.book
├── ...
├── 2020
│   ├── 01.book
│   ├── 02.book
│   ├── ...
│   ├── 11.book
│   ├── 12.book
│   └── year.book
├── ledger.book
├── .closed.accounts.book
├── roadmap.md
└── to.process
    ├── cone.book
    ├── bank1.csv
    └── bank2.csv
```

Where:

* `.git`: I keep everything in a git repository to have a version controlled ledger.
* Each year has it's own directory with:
    * A `book` file per month, check below it's contents.
    * A `year.book` file with just include statements:

        ```beancount
        include "01.book"
        include "02.book"
        include "03.book"
        include "04.book"
        include "05.book"
        include "06.book"
        include "07.book"
        include "08.book"
        include "09.book"
        # include "10.book"
        # include "11.book"
        # include "12.book"
        ```
* `ledger.book`: The beancount entry point where the accounts are defined.
* `.closed.accounts.book`: To store the account closing statements.
* `roadmap.md`: To store the financial plan for the semester/year/life.
* `to.process`: To store the raw data from external sources.

## The main ledger

The `ledger.book` file contains the beancount configuration, with the opening of
accounts and inclusion of the monthly books. I like to split it in sections.

??? note "TL;DR: The full `ledger.book`"
    ```beancount
    # Options
    option "title" "Lyz Lair Ledge"
    option "operating_currency" "EUR"

    # Events
    2016-12-19 event "employer" "XXX"

    # Eternal accounts

    # Assets

    2010-05-17 open Assets:Cash EUR
    2021-01-25 open Assets:Cash:Coins EUR
    2021-01-25 open Assets:Cash:Paper EUR
    2018-09-10 open Assets:Cashbox EUR
    2019-01-11 open Assets:Cashbox:Coins EUR
    2019-01-11 open Assets:Cashbox:Paper EUR
    2018-04-01 open Assets:Savings EUR
    2019-08-01 open Assets:Savings:CashFlowRefiller EUR
    2019-08-01 open Assets:Savings:UnexpectedExpenses EUR
    2019-08-01 open Assets:Savings:Home EUR
    2018-04-01 open Assets:CashFlowCard EUR
    2018-04-01 open Assets:CashDeposit EUR

    # Debts

    2016-01-01 open Assets:Debt:Person1 EUR
    2016-01-01 open Assets:Debt:Person2 EUR

    # Income

    2016-12-01 open Income:Employer1 EUR
    2019-05-21 open Income:Employer2 EUR
    2010-05-17 open Income:State EUR
    2019-01-01 open Income:Gifts EUR

    # Equity

    2010-05-17 open Equity:Opening-Balances
    2010-05-17 open Equity:Errors
    2010-05-17 open Equity:Forgiven

    # Expenses

    2010-01-01 open Expenses:Bills EUR
    2013-01-01 open Expenses:Bills:Gas EUR
    2010-01-01 open Expenses:Bills:Phone EUR
    2019-01-01 open Expenses:Bills:Light EUR
    2010-01-01 open Expenses:Bills:Rent EUR
    2010-01-01 open Expenses:Bills:PublicTransport EUR
    2017-01-01 open Expenses:Bills:Subscriptions EUR
    2016-01-01 open Expenses:Bills:Union EUR
    2010-01-01 open Expenses:Books EUR
    2010-12-01 open Expenses:Car EUR
    2010-12-01 open Expenses:Car:Fuel EUR
    2010-12-01 open Expenses:Car:Insurance EUR
    2010-12-01 open Expenses:Car:Repair EUR
    2010-12-01 open Expenses:Car:Taxes EUR
    2010-12-01 open Expenses:Car:Tickets EUR
    2010-01-01 open Expenses:Clothes EUR
    2018-11-01 open Expenses:Donations EUR
    2010-05-17 open Expenses:Financial EUR
    2010-01-01 open Expenses:Games EUR
    2010-01-01 open Expenses:Games:Steam EUR
    2010-01-01 open Expenses:Games:HumbleBundle EUR
    2019-06-01 open Expenses:Games:GOG EUR
    2020-06-01 open Expenses:Games:Itchio EUR
    2010-01-01 open Expenses:Gifts EUR
    2010-01-01 open Expenses:Gifts:Person1 EUR
    2010-01-01 open Expenses:Gifts:Person2 EUR
    2010-01-01 open Expenses:Gifts:Mine EUR
    2010-01-01 open Expenses:Groceries EUR
    2018-11-01 open Expenses:Groceries:Extras EUR
    2020-01-01 open Expenses:Groceries:Supermarket EUR
    2020-01-01 open Expenses:Groceries:Prepared EUR
    2020-01-01 open Expenses:Groceries:GreenGrocery EUR
    2010-01-01 open Expenses:Hardware EUR
    2010-01-01 open Expenses:Home EUR
    2010-01-01 open Expenses:Home:WashingMachine EUR
    2010-01-01 open Expenses:Home:DishWasher EUR
    2010-01-01 open Expenses:Home:Fridge EUR
    2020-06-01 open Expenses:Legal EUR
    2010-01-01 open Expenses:Medicines EUR
    2010-01-01 open Expenses:Social EUR
    2010-01-01 open Expenses:Social:Eat EUR
    2010-01-01 open Expenses:Social:Drink EUR
    2019-06-01 open Expenses:Taxes:Tax1 EUR
    2016-01-01 open Expenses:Taxes:Tax2 EUR
    2010-05-17 open Expenses:Trips EUR
    2010-05-17 open Expenses:Trips:Accommodation EUR
    2010-05-17 open Expenses:Trips:Drink EUR
    2010-05-17 open Expenses:Trips:Food EUR
    2010-05-17 open Expenses:Trips:Tickets EUR
    2010-05-17 open Expenses:Trips:Transport EUR
    2019-05-20 open Expenses:Work EUR
    2019-05-20 open Expenses:Work:Phone EUR
    2019-05-20 open Expenses:Work:Hardware EUR
    2019-05-20 open Expenses:Work:Trips EUR
    2019-05-20 open Expenses:Work:Trips:Accommodation EUR
    2019-05-20 open Expenses:Work:Trips:Drink EUR
    2019-05-20 open Expenses:Work:Trips:Food EUR
    2019-05-20 open Expenses:Work:Trips:Tickets EUR
    2019-05-20 open Expenses:Work:Trips:Transport EUR

    ## Initialization

    2010-05-17 pad Assets:Cash Equity:Opening-Balances
    2016-01-01 pad Assets:Debt:Person1 Equity:Opening-Balances

    # Transfers

    include ".closed.accounts.book"
    include "2011/year.book"
    include "2012/year.book"
    include "2013/year.book"
    include "2014/year.book"
    include "2015/year.book"
    include "2016/year.book"
    include "2017/year.book"
    include "2018/year.book"
    include "2019/year.book"
    include "2020/year.book"
    ```

### [Assets](https://beancount.github.io/docs/the_double_entry_counting_method.html#types-of-accounts)

Asset accounts represent something you have.

```beancount
# Assets

2010-05-17 open Assets:Cash EUR
2021-01-25 open Assets:Cash:Coins EUR
2021-01-25 open Assets:Cash:Paper EUR
2018-09-10 open Assets:Cashbox EUR
2019-01-11 open Assets:Cashbox:Coins EUR
2019-01-11 open Assets:Cashbox:Paper EUR
2018-04-01 open Assets:Savings EUR
2019-08-01 open Assets:Savings:CashFlowRefiller EUR
2019-08-01 open Assets:Savings:UnexpectedExpenses EUR
2019-08-01 open Assets:Savings:Home EUR
2018-04-01 open Assets:CashFlowCard EUR
2018-04-01 open Assets:CashDeposit EUR
```

Being a privacy minded person, I try to pay everything by cash. To track it,
I've created the following asset accounts:

* `Assets:Cash:Paper`: Paper money in my wallet. I like to have a 5, 10 and 20
    euro bills as it gives the best flexibility without carrying too much money.
* `Assets:Cash:Coins`: Coins in my wallet.
* `Assets:Cashbox:Paper`: Paper money stored at home. I fill it up monthly to
    my average monthly expenses, so I reduce the trips to the ATM to the
    minimum. Once this account is below 100 EUR, I add the mental task to refill
    it.
* `Assets:Cashbox:Coins`: Coins stored at home. I keep it at 10 EUR in
    coins of 2 EUR, so it's quick to count at the same time as it's able to
    cover most of the things you need to buy with coins.
* `Assets:Cashbox:SmallCoins`: If my coins wallet is starting to get heavy,
    I extract the coins smaller than 50 cents into a container with copper
    coins.
* `Assets:CashDeposit`: You never know when the bank system is going to fuck
    you, so it's always good to have some cash under the mattress.

Having this level of granularity and doing weekly balances of each of those
accounts has helped me understand the flaws in my processes that lead to the
cash accounting errors.

As most humans living in the first world, I'm forced to have at least one bank
account. For security reasons I have two:

* `Assets:CashFlowCard`: The bank account with an associated debit card. Here is
    from where I make my expenses, such as home rental, supplies payment, ATM
    money withdrawal. As it is exposed to all the payment platforms, I assume
    that it will come a time when a vulnerability is found in one of them, so
    I keep the least amount of money I can. As with the `Cashbox` I monthly
    refill it with the expected expenses amount plus a safety amount.
* `Assets:Savings`: The bank account where I store my savings. I have it
    subdivided in three sections:

    * `Assets:Savings:CashFlowRefiller`: Here I store the average monthly
        expenses for the following two months.
    * `Assets:Savings:UnexpectedExpenses`: Deposit for unexpected expenses such
        as car or domestic appliances repairs.
    * `Assets:Savings:Home`: Deposit for the initial payment or a house.

### Debts

Debts can be tracked either as an asset or as a liability. If you expect them to
owe you more often (you lend a friend some money), model it as an asset, if
you're going to owe them (you borrow from the bank to buy a house), model it as
a liability.

```beancount
# Debts

2016-01-01 open Assets:Debt:Person1 EUR
2016-01-01 open Assets:Debt:Person2 EUR
```

### Income

Income accounts represent where you get the money from.

```beancount
# Income

2016-12-01 open Income:Employer1 EUR
2019-05-21 open Income:Employer2 EUR
2010-05-17 open Income:State EUR
2019-01-01 open Income:Gifts EUR
```

### Equity

I use equity accounts to make adjustments.

```beancount
# Equity

2010-05-17 open Equity:Opening-Balances
2010-05-17 open Equity:Errors
2010-05-17 open Equity:Forgiven
```

* `Equity:Opening-Balances`: Used to set the initial balance of an account.
* `Equity:Errors`: Used with the `pad` statements to track the errors in the
    accounting.
* `Equity:Forgiven`: Used in the transactions to forgive someone's debts.

### Expenses

Expense accounts model where you expend the money on.

```beancount
# Expenses

2010-01-01 open Expenses:Bills EUR
2013-01-01 open Expenses:Bills:Gas EUR
2010-01-01 open Expenses:Bills:Phone EUR
2019-01-01 open Expenses:Bills:Light EUR
2010-01-01 open Expenses:Bills:Rent EUR
2010-01-01 open Expenses:Bills:PublicTransport EUR
2017-01-01 open Expenses:Bills:Subscriptions EUR
2016-01-01 open Expenses:Bills:Union EUR
2010-01-01 open Expenses:Books EUR
2010-12-01 open Expenses:Car EUR
2010-12-01 open Expenses:Car:Fuel EUR
2010-12-01 open Expenses:Car:Insurance EUR
2010-12-01 open Expenses:Car:Repair EUR
2010-12-01 open Expenses:Car:Taxes EUR
2010-12-01 open Expenses:Car:Tickets EUR
2010-01-01 open Expenses:Clothes EUR
2018-11-01 open Expenses:Donations EUR
2010-05-17 open Expenses:Financial EUR
2010-01-01 open Expenses:Games EUR
2010-01-01 open Expenses:Games:Steam EUR
2010-01-01 open Expenses:Games:HumbleBundle EUR
2019-06-01 open Expenses:Games:GOG EUR
2020-06-01 open Expenses:Games:Itchio EUR
2010-01-01 open Expenses:Gifts EUR
2010-01-01 open Expenses:Gifts:Person1 EUR
2010-01-01 open Expenses:Gifts:Person2 EUR
2010-01-01 open Expenses:Gifts:Mine EUR
2010-01-01 open Expenses:Groceries EUR
2018-11-01 open Expenses:Groceries:Extras EUR
2020-01-01 open Expenses:Groceries:Supermarket EUR
2020-01-01 open Expenses:Groceries:Prepared EUR
2020-01-01 open Expenses:Groceries:GreenGrocery EUR
2010-01-01 open Expenses:Hardware EUR
2010-01-01 open Expenses:Home EUR
2010-01-01 open Expenses:Home:WashingMachine EUR
2010-01-01 open Expenses:Home:DishWasher EUR
2010-01-01 open Expenses:Home:Fridge EUR
2020-06-01 open Expenses:Legal EUR
2010-01-01 open Expenses:Medicines EUR
2010-01-01 open Expenses:Social EUR
2010-01-01 open Expenses:Social:Eat EUR
2010-01-01 open Expenses:Social:Drink EUR
2019-06-01 open Expenses:Taxes:Tax1 EUR
2016-01-01 open Expenses:Taxes:Tax2 EUR
2010-05-17 open Expenses:Trips EUR
2010-05-17 open Expenses:Trips:Accommodation EUR
2010-05-17 open Expenses:Trips:Drink EUR
2010-05-17 open Expenses:Trips:Food EUR
2010-05-17 open Expenses:Trips:Tickets EUR
2010-05-17 open Expenses:Trips:Transport EUR
2019-05-20 open Expenses:Work EUR
2019-05-20 open Expenses:Work:Phone EUR
2019-05-20 open Expenses:Work:Hardware EUR
2019-05-20 open Expenses:Work:Trips EUR
2019-05-20 open Expenses:Work:Trips:Accommodation EUR
2019-05-20 open Expenses:Work:Trips:Drink EUR
2019-05-20 open Expenses:Work:Trips:Food EUR
2019-05-20 open Expenses:Work:Trips:Tickets EUR
2019-05-20 open Expenses:Work:Trips:Transport EUR
```

I decided to split my expenses in:

* `Expenses:Bills`: All the periodic bills I pay
    * `Expenses:Bills:Gas`:
    * `Expenses:Bills:Phone`:
    * `Expenses:Bills:Light`:
    * `Expenses:Bills:Rent`:
    * `Expenses:Bills:PublicTransport`:
    * `Expenses:Bills:Subscriptions`: Newspaper, magazine, web service
        subscriptions.
    * `Expenses:Bills:Union`:
* `Expenses:Books`:
* `Expenses:Car`:
    * `Expenses:Car:Fuel`:
    * `Expenses:Car:Insurance`:
    * `Expenses:Car:Repair`:
    * `Expenses:Car:Taxes`:
    * `Expenses:Car:Tickets`:
* `Expenses:Clothes`:
* `Expenses:Donations`:
* `Expenses:Financial`: Expenses related to financial operations or account
    maintenance.
* `Expenses:Games`:
    * `Expenses:Games:Steam`:
    * `Expenses:Games:HumbleBundle`:
    * `Expenses:Games:GOG`:
    * `Expenses:Games:Itchio`:
* `Expenses:Gifts`:
    * `Expenses:Gifts:Person1`:
    * `Expenses:Gifts:Person2`:
    * `Expenses:Gifts:Mine`:
* `Expenses:Groceries`:
    * `Expenses:Groceries:Extras`:
    * `Expenses:Groceries:Supermarket`:
    * `Expenses:Groceries:Prepared`:
    * `Expenses:Groceries:GreenGrocery`:
* `Expenses:Hardware`:
* `Expenses:Home`:
    * `Expenses:Home:WashingMachine`:
    * `Expenses:Home:DishWasher`:
    * `Expenses:Home:Fridge`:
* `Expenses:Legal`:
* `Expenses:Medicines`:
* `Expenses:Social`:
    * `Expenses:Social:Eat`:
    * `Expenses:Social:Drink`:
* `Expenses:Taxes`:
    * `Expenses:Taxes:Tax1`:
    * `Expenses:Taxes:Tax2`:
* `Expenses:Trips`:
    * `Expenses:Trips:Accommodation`:
    * `Expenses:Trips:Drink`:
    * `Expenses:Trips:Food`:
    * `Expenses:Trips:Tickets`:
    * `Expenses:Trips:Transport`:
* `Expenses:Work`:
    * `Expenses:Work:Phone`:
    * `Expenses:Work:Hardware`:
    * `Expenses:Work:Trips`:
    * `Expenses:Work:Trips:Accommodation`:
    * `Expenses:Work:Trips:Drink`:
    * `Expenses:Work:Trips:Food`:
    * `Expenses:Work:Trips:Tickets`:
    * `Expenses:Work:Trips:Transport`:

### Initialization of accounts

```
# Initialization

2010-05-17 pad Assets:Cash Equity:Opening-Balances
2016-01-01 pad Assets:Debt:Person1 Equity:Opening-Balances
```

### Transfer includes

I reference each year's `year.book` and the `.closed.accounts.book`.

```
# Transfers

include ".closed.accounts.book"
include "2011/year.book"
...
include "2020/year.book"
```

## The monthly book

Each month has a file with this structure:

```beancount
# Cash transfers

# CashFlowCard

# Savings

# Balances taken at 2020-12-06T19:32

## Active accounts

2020-12-06 balance Assets:Cashbox:Paper  EUR
2020-12-06 balance Assets:Cashbox:Coins  EUR
2020-12-06 balance Assets:Cash:Paper  EUR
2020-12-06 balance Assets:Cash:Coins  EUR

2020-12-06 balance Assets:CashFlowCard  EUR
2020-12-06 balance Assets:Savings  EUR

## Deposits

2020-12-06 balance Assets:Savings:CashFlowRefiller XXX EUR
2020-12-06 balance Assets:Savings:UnexpectedExpenses XXX EUR
2020-12-06 balance Assets:CashDeposit XXX EUR

## Debts

2020-12-06 balance Assets:Debt:Person1 XXX EUR

## Equity

# 2020-12-05 pad Assets:Cash Equity:Errors
# 2020-12-05 pad Assets:Cashbox Equity:Errors

# Weekly balances

## Measure done on 2020-09-04T17:10
2020-09-04 balance Assets:Cash:Coins XXX EUR
2020-09-04 balance Assets:Cash:Paper XXX EUR
2020-09-04 balance Assets:Cashbox:Coins XXX EUR
2020-09-04 balance Assets:Cashbox:Paper XXX EUR
```

Where each section stores:

* `Cash transfers`: The transactions done by cash, extracted from the
    Android [`cone`](cone.md) application.

* `CashFlowCard`: Bank account extracts transformed from the csv to postings
    with [`bean-extract`](beancount.md).

* `Savings`: Bank account extracts transformed from the csv to postings
    with [`bean-extract`](beancount.md).

* `Monthly balances`: I try to review the accounts once each month. This section
is subdivided in:

    * `Active accounts`: The accounts whose value changes monthly.
    * `Deposits`: The accounts that don't change much each month.
    * `Debts`: The balance of debt accounts.
    * `Equity`: The `pad` statements to track the errors in the monthly account.

* `Weekly balances`: As doing the monthly review is long, but it doesn't give me
    the enough information to not mess up the cash transactions, I do a weekly
    balance of those accounts.
