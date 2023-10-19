[yq](https://github.com/mikefarah/yq) is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor. It uses `jq` like syntax but works with yaml files as well as json, xml, properties, csv and tsv. It doesn't yet support everything `jq` does - but it does support the most common operations and functions, and more is being added continuously.

# Snippets

## [Find and update items in an array](https://mikefarah.gitbook.io/yq/recipes#find-and-update-items-in-an-array)

We have an array and we want to update the elements with a particular name.

Given a `sample.yaml` file of:

```yaml
- name: Foo
  numBuckets: 0
- name: Bar
  numBuckets: 0
```

Then `yq '(.[] | select(.name == "Foo") | .numBuckets) |= . + 1' sample.yaml` will output:

```yaml
- name: Foo
  numBuckets: 1
- name: Bar
  numBuckets: 0
```

## [Iterate over the elements of a query with a bash loop](https://stackoverflow.com/questions/62898925/using-yq-in-for-loop-bash)

```bash
readarray dependencies < <(yq e -o=j -I=0 '.roles[]' requirements.yaml)
for dependency in "${dependencies[@]}"; do
    source="$(echo "$dependency" | yq e '.src' -)"
done
```

# References

- [Source](https://github.com/mikefarah/yq)
- [Docs](https://mikefarah.gitbook.io/yq)
