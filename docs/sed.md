---
Title: Sed
Author: Lyz
Date: 20170119
Keywords: sed
Tags: publish
---

# Snippets

## If variable has /

```bash
sed "s|$variable||g"
```

## Replace in files

```bash
sed -i {{ sed_replace_expression }} {{ files_to_replace }}
```

## Replace recursively in directories and subdirectories

```bash
find {{ directory }} -type f -exec sed -i 's/nano/vim/g' {} +
```

## Non greedy

Sed doesn't support non greedy, use `.[^{{ character }}]*` instead

## Delete match

```bash
sed '/<match>/d' file
```

## Delete the last line of file

```bash
sed '$d' -i file.txt
```

## Delete the first line of file

```bash
sed '1d' -i file.txt
```
