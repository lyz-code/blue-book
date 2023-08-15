---
title: Bash Snippets
date: 20220827
author: Lyz
---

# [Get the root path of a git repository](https://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command)

```bash
git rev-parse --show-toplevel
```

# [Get epoch gmt time](https://unix.stackexchange.com/questions/384672/getting-epoch-time-from-gmt-time-stamp)

```bash
date -u '+%s'
```

# [Check the length of an array with jq](https://phpfog.com/count-json-array-elements-with-jq/)

```
echo '[{"username":"user1"},{"username":"user2"}]' | jq '. | length'
```

# [Exit the script if there is an error](https://unix.stackexchange.com/questions/595249/what-does-the-eu-mean-in-bin-bash-eu-at-the-top-of-a-bash-script-or-a)

```bash
set -eu
```

# [Prompt the user for data](https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script)

```bash
read -p "Ask whatever" choice
```
# [Parse csv with bash](https://www.baeldung.com/linux/csv-parsing)

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
