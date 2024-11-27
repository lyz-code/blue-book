Bash Automated Testing System is a TAP-compliant testing framework for Bash 3.2 or above. It provides a simple way to verify that the UNIX programs you write behave as expected.

A Bats test file is a Bash script with special syntax for defining test cases. Under the hood, each test case is just a function with a description.

```bash
#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "addition using dc" {
  result="$(echo 2 2+p | dc)"
  [ "$result" -eq 4 ]
}
```

Bats is most useful when testing software written in Bash, but you can use it to test any UNIX program.

# References
- [Source](https://github.com/bats-core/bats-core)
- [Docs](https://bats-core.readthedocs.io/)
