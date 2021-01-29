---
title: Beancount
date: 20170713
author: Lyz
---

[Beancount](http://furius.ca/beancount/) is a Python double entry accounting command
line tool similar to `ledger`.

# Installation

```bash
pip3 install beancount
```

# Tools

`beancount` is the core component, it's a declarative language. It parses a text
file, and produces reports from the resulting data structures.

## bean-check

`bean-check` is the program you use to verify that your input syntax and
transactions work correctly. All it does is load your input file and run the
various plugins you configured in it, plus some extra validation checks.

```bash
bean-check /path/to/file.beancount
```

If there are no errors, there should be no output, it should exit quietly.

## bean-report

This is the main tool used to extract specialized reports to the console in text
or one of the various other formats.

For a graphic exploration of your data, use the [fava](https://github.com/beancount/fava) web application
instead.

```bash
bean-report /path/to/file.beancount {{ report_name }}
```

There are many reports available, to get a full list run `bean-report
--help-reports`

Report names sometimes may accept arguments, if they do  so use `:`

```bash
bean-report /path/to/file.beancount balances:Vanguard
```

### To get the balances

```bash
bean-report {{ path/to/file.beancount }} balances | treeify
```

### To get the journal

```bash
bean-report {{ path/to/file.beancount }} journal
```

### To get the holdings

To get the aggregations for the total list of holdings

```bash
bean-report {{ path/to/file.beancount }} holdings
```

### To get the accounts

```bash
bean-report {{ path/to/file.beancount }} accounts
```

## bean-query

`bean-query` is a command-line tool that acts like a client to that in-memory
database in which you can type queries in a variant of SQL. It has it's own
document

```bash
bean-query /path/to/file.beancount
```

## bean-web

!!! warning "*Deprecated* use [fava](https://github.com/beancount/fava) instead"

`bean-web` serves all the reports on a web server that runs on your computer

```bash
bean-web /path/to/file.beancount
```

It will serve on `localhost:8080`

## bean-doctor

This is a debugging tool used to perform various diagnostics and run debugging
commands, and to help provide information for reporting bugs.

## bean-format

Pure text processing tool will reformat Beancount input to right-align all the
numbers at the same, minimal column.

## bean-example

Generates an example Beancount input file.

## bean-identify

Given a messy list of downloaded files automatically identify which of your
configured importers is able to handle them and print them out. This is to be
used for debugging and figuring out if your configuration is properly associating
a suitable importer for each of the files you downloaded.

## bean-extract

Extracts transactions and statement date from each file, if at all possible.
This produces some Beancount input text to be moved to your input file.

```bash
bean-extract {{ path/to/config.config }} {{ path/to/source/files }}
```

The tool calls methods on importer objects. You must provide a list of such
importers; this list is the configuration for the importing process.

For each file found, each of the importers is called to assert whether it can or
cannot handle that file. If it deems that it can, methods can be called to
produce a list of transactions extract a date, or produce a cleaned up filename
for the downloaded file.

The configuration should be a python3 module in which you instantiate the
importers and assign the list to the module-level "CONFIG" variable

```python

#!/usr/bin/env python3
from myimporters.bank import acmebank
from myimporters.bank import chase
…
CONFIG = [
acmebank.Importer(),
chase.Importer(),
…
]
```

### Writing an importer

Each of the importers must comply with a particular protocol and implement at
least some of its methods. The full detail of the protocol is in the source of
[importer.py](https://bitbucket.org/blais/beancount/src/tip/beancount/ingest/importer.py?fileviewer=file-view-default)

```python
"""Importer protocol.

All importers must comply with this interface and implement at least some of its
methods. A configuration consists in a simple list of such importer instances.
The importer processes run through the importers, calling some of its methods in
order to identify, extract and file the downloaded files.

Each of the methods accept a cache.FileMemo object which has a 'name' attribute
with the filename to process, but which also provides a place to cache
conversions. Use its convert() method whenever possible to avoid carrying out
the same conversion multiple times. See beancount.ingest.cache for more details.

Synopsis:

 name(): Return a unique identifier for the importer instance.
 identify(): Return true if the identifier is able to process the file.
 extract(): Extract directives from a file's contents and return of list of entries.
 file_account(): Return an account name associated with the given file for this importer.
 file_date(): Return a date associated with the downloaded file (e.g., the statement date).
 file_name(): Return a cleaned up filename for storage (optional).

Just to be clear: Although this importer will not raise NotImplementedError
exceptions (it returns default values for each method), you NEED to derive from
it in order to do anything meaningful. Simply instantiating this importer will
not match not provide any useful information. It just defines the protocol for
all importers.
"""
__copyright__ = "Copyright (C) 2016  Martin Blais"
__license__ = "GNU GPLv2"

from beancount.core import flags


class ImporterProtocol:
    "Interface that all source importers need to comply with."

    # A flag to use on new transaction. Override this flag in derived classes if
    # you prefer to create your imported transactions with a different flag.
    FLAG = flags.FLAG_OKAY

    def name(self):
        """Return a unique id/name for this importer.

        Returns:
          A string which uniquely identifies this importer.
        """
        cls = self.__class__
        return '{}.{}'.format(cls.__module__, cls.__name__)

    __str__ = name

    def identify(self, file):
        """Return true if this importer matches the given file.

        Args:
          file: A cache.FileMemo instance.
        Returns:
          A boolean, true if this importer can handle this file.
        """

    def extract(self, file):
        """Extract transactions from a file.

        Args:
          file: A cache.FileMemo instance.
        Returns:
          A list of new, imported directives (usually mostly Transactions)
          extracted from the file.
        """

    def file_account(self, file):
        """Return an account associated with the given file.

        Note: If you don't implement this method you won't be able to move the
        files into its preservation hierarchy; the bean-file command won't work.

        Also, normally the returned account is not a function of the input
        file--just of the importer--but it is provided anyhow.

        Args:
          file: A cache.FileMemo instance.
        Returns:
          The name of the account that corresponds to this importer.
        """

    def file_name(self, file):
        """A filter that optionally renames a file before filing.

        This is used to make tidy filenames for filed/stored document files. The
        default implementation just returns the same filename. Note that a
        simple RELATIVE filename must be returned, not an absolute filename.

        Args:
          file: A cache.FileMemo instance.
        Returns:
          The tidied up, new filename to store it as.
        """

    def file_date(self, file):
        """Attempt to obtain a date that corresponds to the given file.

        Args:
          file: A cache.FileMemo instance.
        Returns:
          A date object, if successful, or None if a date could not be extracted.
          (If no date is returned, the file creation time is used. This is the
          default.)
```

A summary of the methods you need to, or may want to implement:

* *name()*: Provides a unique id for each importer instance. It's convenient to
  be able to refer to your importers with a unique name; it gets printed out by
  the identification process.

* *identify()*: This method just returns true if this importer can handle the
  given file. **You must implement this method**, and all the tools invoke it ot
  figure out the list of (file, importer) pairs.

* *extract()*: This is called to attempt to extract some Beancount directives
  from the file contents. It must create the directives by instatiating the
  objects define in beancout.core.data and return them.

```python
from beancount.ingest import importer

class Importer(importer.ImporterProtocol):

  def identify(self, file):
  …
  # Override other methods…
```

Some importer examples:

* [mterwill gist](https://gist.github.com/mterwill/7fdcc573dc1aa158648aacd4e33786e8)
* [wzyboy importers](https://github.com/wzyboy/awesome-beancount/tree/master/importers)

## bean-file

* `bean-file` filing documents. It si able to identify which document belongs to
  which account, it can move the downloaded file to the documents archive
  automatically.

# Basic concepts

## Beancount transaction

```
2014-05-23 * "CAFE MOGADOR NEW YO" "Dinner with Caroline"
  Liabilities:US:BofA:CreditCard -98.32 USD
  Expenses:Restaurant
```

* Currencies must be entirely in capital letters.
* Account names do not admit spaces.
* Description strings must be quoted.
* Dates are only parsed in YYYY-MM-DD format.
* Tags must begin with `#` and links with `^`.

## Beancount Operators

### Open

All accounts need to be declared *open* in order to accept amounts posted to
them.

```beancount
YYYY-MM-DD open {{ account_name }} [{{ ConstrainCurrency }}]
```

### Close

```beancount
YYYY-MM-DD close {{ account_name }}
```

It's useful to insert a balance of 0 units just before closing an account, just
to make sure its contents are empty as you close it.

### Commodity

It can be used to declare currencies, financial instruments, commodities... It's
optional

```beancount
YYYY-MM-DD commodity {{ currency_name }}
```

### Transactions

```beancount
YYYY-MM-DD txn "[{{ payee }}]"  "{{ Comment }}"
  {{ Account1 }} {{ value}}
  [{{ Accountn-1 }} {{ value }}]
  {{ Accountn }}
```

Payee is a string that represents an external entity that is involved in the
transaction. Payees are sometimes useful on transactions that post amounts to
Expense accounts, whereby the account accumulates a category of expenses from
multiple business

As transactions is the most common, you can substitute `txn` for a flag, by
default :
* `*`: Completed transaction, known amounts, "this looks correct"
* `!`: Incomplete transaction, needs confirmation or revision, "this looks
  incorrect"

You can also attach flags to the postings themselves, if you want to flag one of
the transaction's legs in particular:

```beancount
2014-05-05 * "Transfer from Savings account"
  Assets:MyBank:Checking     -400.00 USD
  ! Assets:MyBank:Savings
```

This is useful in the intermediate stage of de-duping transactions

### Tags vs Payee

You can tag your transactions with `#{{tag_name}}`, so you can later filter or
generate reports based on that tag. Therefore the Payee could be used as whom or
who pays and the tag for the context. For example, for a trip I could use the
tag #34C3

To mark a series of transactions with tags use the following syntax
```beancount
pushtag #berlin-trip-2014

2014-04-23 * "Flight to Berlin"
  Expenses:Flights -1230.27 USD
  Liabilities:CreditCard

...

poptag #berlin-trip-2014
```

### Links

Transactions can also be linked together. You may think of the link as a special
kind of tag that can be used to group together a set of financially related
transactions over time.

```beancount
2014-02-05 * "Invoice for January" ^invoice-acme-studios-jan14
  Income:Clients:ACMEStudios   -8450.00 USD
  Assets:AccountsReceivable

...

2014-02-20 * "Check deposit - payment from ACME" ^invoice-acme-studios-jan14
  Assets:BofA:Checking         8450.00 USD
  Assets:AccountsReceivable
```

### Balance

A balance assertion is a way for you to input your statement balance into the
flow of transactions. It tells Beancount to verify that the number of units of
a particular commodity in some account should equal some expected value at some
point in time.

If no error is reported, you should have some confidence that the list of
transactions that precedes it in this account is highly likely to be correct.
This is useful in practice because in many cases some transactions can get
imported separately from the accounts of each of their postings.

*As all other non-transaction directives, it applies at the beginning of it's
date*. Just imagine that the balance checks occurs right after midnight on that
day.

```beancount
YYYY-MM-DD balance {{ account_name }} {{ amount }}
```

### Pad

A padding directive automatically inserts a transaction that will make the
subsequent balance assertion succeed, if it is needed. It inserts the difference
needed to fulfill that balance assertion.

Being *subsequent* in date order, not in the order of the declarations in the
file.

```beancount
YYYY-MM-DD pad {{ account_name }} {{ account_name_to_pad }}
```

The first account is the account to credit the automatically calculated amount
to. This is the account that should have a balance assertion following it. The
second leg is the source where the funds will come from, and this is almost
always some Equity account.

```beancount
1990-05-17 open Assets:Cash EUR
1990-05-17 pad Assets:Cash Equity:Opening-Balances
2017-12-26 balance Assets:Cash 250 EUR
```

You could also insert pad entries between balance assertions so as to fix un
registered transactions

### Notes

A note directive is simply used to attach a dated comment to the journal of
a particular account.

this can be useful to record facts and claims associated with a financial event.

```beancount
YYYY-MM-DD note {{ account_name }} {{ comment }}
```

### Document

A Document directive can be used to attach an external file to the journal of an
account.

The filename gets rendered as a browser link in the journals of the web interface
for the corresponding account and you should be able to click on it to view the
contents of the file itself.

```beancount
YYYY-MM-DD {{ account_name }} {{ path/to/document }}
```

### Includes

This allows you to split up large input files into multiple files.

```beancount
include {{ path/to/file.beancount }}
```

The path could be relative or absolute.

# Library usage

Beancount can also be used as a Python library.

There are some articles in the documentation where you can start seeing how to
use it: [scripting
plugins](https://beancount.github.io/docs/beancount_scripting_plugins.html)
, [external
contributions](https://beancount.github.io/docs/external_contributions.html) and
the [api reference](https://beancount.github.io/docs/api_reference/index.html).
Although I found it more pleasant to read the source code itself as it's really
well documented (both by docstrings and type hints).

# References

* [Homepage](http://furius.ca/beancount/)
* [Git](https://github.com/beancount/beancount)
* [Docs](https://beancount.github.io/docs/)
* [Awesome beancount](https://awesome-beancount.com/)
* [Docs in google](https://docs.google.com/document/d/1RaondTJCS_IUPBHFNdT8oqFKJjVJDsfsn6JEjBG04eA/edit)
* [Vim plugin](https://github.com/nathangrigg/vim-beancount)
