---
title: JSON
date: 20200715
author: Lyz
---

[JavaScript Object Notation (JSON)](https://en.wikipedia.org/wiki/JSON), is an
open standard file format, and data interchange format, that uses human-readable
text to store and send data objects consisting of attribute–value pairs and
array data types (or any other serializable value).

# Linters and fixers

## [jsonlint](https://github.com/zaach/jsonlint)

`jsonlint` is a pure JavaScript version of the service provided at jsonlint.com.

Install it with:

```bash
npm install jsonlint -g
```

Vim supports this linter through [ALE](vim_plugins.md#ale).

## [jq](https://stedolan.github.io/jq/)

`jq` is like sed for JSON data. You can use it to slice, filter, map and transform
structured data with the same ease that `sed`, `awk`, `grep` and friends let you play with text.

Install it with:

```bash
apt-get install jq
```

Vim supports this linter through [ALE](vim_plugins.md#ale).
