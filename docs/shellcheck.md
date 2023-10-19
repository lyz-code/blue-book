[Shellcheck](https://www.shellcheck.net/) is a linting tool to finds bugs in your shell scripts.

# [Installation](https://github.com/koalaman/shellcheck#installing)

```bash
apt-get install shellcheck
```

# Errors

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
