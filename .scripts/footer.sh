#!/bin/bash

echo "Checking the Not by AI badge"
find docs -iname '*md' -print0 | while read -r -d $'\0' file; do
	if ! grep -q not-by-ai.svg "$file"; then
		echo "Adding the Not by AI badge to $file"
		echo "[![](not-by-ai.svg){: .center}](https://notbyai.fyi)" >>"$file"
	fi
done
