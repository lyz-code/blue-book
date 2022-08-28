---
title: Bash Snippets
date: 20220827
author: Lyz
---

# [Do the remainder or modulus of a number](https://stackoverflow.com/questions/39006278/how-does-bash-modulus-remainder-work)

```bash
expr 5 % 3
```

# [Update a json file with jq](https://stackoverflow.com/questions/36565295/jq-to-replace-text-directly-on-file-like-sed-i)

Save the next snippet to a file, for example `jqr` and add it to your `$PATH`.

```bash
#!/bin/zsh

query="$1"
file=$2

temp_file="$(mktemp)"

# Update the content
jq "$query" $file > "$temp_file"

# Check if the file has changed
cmp -s "$file" "$temp_file"
if [[ $? -eq 0 ]] ; then
  /bin/rm "$temp_file"
else
  /bin/mv "$temp_file" "$file"
fi
```

Imagine you have the next json file:

```json
{
  "property": true,
  "other_property": "value"
}
```

Then you can run:

```bash
jqr '.property = false' status.json
```

And then you'll have:

```json
{
  "property": false,
  "other_property": "value"
}
```
