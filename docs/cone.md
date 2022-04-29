---
title: Cone
date: 20210126
author: Lyz
---

[Cone](https://cone.tangential.info/) is a mobile ledger application compatible
with [beancount](beancount.md). I use it as part of my [accounting automation
workflow](money_management.md).

# Installation

* Download the application from [F-droid](https://f-droid.org/packages/info.tangential.cone/).
* It assumes that [you have a txt file to store the
    information](https://github.com/bradyt/cone/issues/38). As it doesn't yet
    [support the edition or deletion of
    transactions](https://github.com/bradyt/cone/issues/25), I suggest you
    create the `ledger.txt` file with your favorite mobile editor such as
    [Markor](https://f-droid.org/en/packages/net.gsantner.markor/).
* Open the application and load the `ledger.txt` file.

# Usage

To be compliant with my [beancount](beancount.md) ledger:

* I've initialized the `ledger.txt` file with the `open` statements of the
    beancount accounts, so the transaction UI autocompletes them.
* Cone doesn't still support the [beancount
    format](https://github.com/bradyt/cone/issues/12) by default, so in the
    description of the transaction I also introduce the payee. For example:
    `* "payee1" "Bought X` instead of just `Bought X`.

If I need to edit or delete a transaction, I change it with the Markor editor.

To send the ledger file to the computer, I use either [Share via
HTTP](https://f-droid.org/en/packages/com.MarcosDiez.shareviahttp/) or
[Termux](https://f-droid.org/en/packages/com.termux/) through ssh.

# References

* [Git](https://github.com/bradyt/cone)
* [Docs](https://cone.tangential.info/)
