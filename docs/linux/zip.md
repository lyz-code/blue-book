---
title: zip
date: 20200220
author: Lyz
---

`zip` is an UNIX command line tool to package and compress files.

# Usage

## Create a zip file

```bash
zip -r {{ zip_file }} {{ files_to_save }}
```

## Split files to a specific size

```bash
zip -s {{ size }} -r {{ destination_zip }} {{ files }}
```

Where `{{ size }}` can be `950m`

## Compress with password

```bash
zip -er {{ zip_file }} {{ files_to_save }}
```

## Read files to compress from a file

```bash
cat {{ files_to_compress.txt }} | zip -er {{ destination_zip }} -@
```

## Uncompress a zip file

```bash
unzip {{ zip_file }}
```
