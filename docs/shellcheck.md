[Shellcheck](https://www.shellcheck.net/) is a linting tool to finds bugs in your shell scripts.

# [Installation](https://github.com/koalaman/shellcheck#installing)

```bash
apt-get install shellcheck
```

# Errors

## [SC1090: Can't follow non-constant source. Use a directive to specify location](https://www.shellcheck.net/wiki/SC1090)

Problematic code:

```bash
. "${util_path}"
```

Correct code:

```bash
# shellcheck source=src/util.sh
. "${util_path}"
```

Rationale:

ShellCheck is not able to include sourced files from paths that are determined at runtime. The file will not be read, potentially resulting in warnings about unassigned variables and similar.

Use a Directive to point shellcheck to a fixed location it can read instead.

Exceptions:

If you don't care that ShellCheck is unable to account for the file, specify `# shellcheck source=/dev/null`.

## [SC2143: Use `grep -q` instead of comparing output with `[ -n .. ]`.](https://www.shellcheck.net/wiki/SC2143)

Problematic code:

```bash
if [ "$(find . | grep 'IMG[0-9]')" ]
then
  echo "Images found"
fi
```

Correct code:

```bash
if find . | grep -q 'IMG[0-9]'
then
  echo "Images found"
fi
```

Rationale:

The problematic code has to iterate the entire directory and read all matching lines into memory before making a decision.

The correct code is cleaner and stops at the first matching line, avoiding both iterating the rest of the directory and reading data into memory.

# References

- [Source](https://github.com/koalaman/shellcheck)
- [Docs](https://www.shellcheck.net/wiki/Home)
- [Home](https://www.shellcheck.net/)
