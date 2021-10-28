---
title: Helm Secrets
date: 20200212
author: Lyz
---

[Helm-secrets](https://github.com/jkroepke/helm-secrets) is a helm plugin
that manages secrets with Git workflow and stores them anywhere. It delegates
the cryptographic operations to [Mozilla's
Sops](https://github.com/mozilla/sops) tool, which supports PGP, AWS KMS and GCP
KMS.

The configuration is stored in `.sops.yaml` files. You can find in [Mozilla's
documentation](https://github.com/mozilla/sops) a detailed configuration guide.
For my use case, I'm only going to use a list of PGP keys, so the following
contents should be in the `.sops.yaml` file at the project root directory.

```yaml
creation_rules:
    - pgp: >-
        {{ gpg_key_1 }},
        {{ gpg_key_2}}
```

# [Installation](https://github.com/jkroepke/helm-secrets#installation-and-dependencies)

Weirdly, `helm plugin install https://github.com/jkroepke/helm-secrets --version
v3.9.1` asks for your github user :S so I'd rather install it by hand.

```bash
wget https://github.com/jkroepke/helm-secrets/releases/download/v3.9.1/helm-secrets.tar.gz
tar xvzf helm-secrets.tar.gz -C "$(helm env HELM_PLUGINS)"
rm helm-secrets.tar.gz
```

If you're going to use GPG as backend you need to install `sops`. It's in your
distribution repositories, but probably not in the latest version, therefore
I suggest you install the binary directly:

* Grab the [latest release](https://github.com/mozilla/sops/releases)
* Download, `chmod +x` and move it somewhere in your `$PATH`.

# Prevent committing decrypted files to git

From the [docs](https://github.com/futuresimple/helm-secrets):
> If you like to secure situation when decrypted file is committed by mistake to
> git you can add your secrets.yaml.dec files to you charts project repository
> .gitignore.

> A second level of security is to add for example a .sopscommithook file inside
> your chart repository local commit hook.

> This will prevent committing decrypted files without sops metadata.

> .sopscommithook content example:

> ```yaml
> #!/bin/sh

> for FILE in $(git diff-index HEAD --name-only | grep <your vars dir> | grep "secrets.y"); do
>     if [ -f "$FILE" ] && ! grep -C10000 "sops:" $FILE | grep -q "version:"; then
>         echo "!!!!! $FILE" 'File is not encrypted !!!!!'
>         echo "Run: helm secrets enc <file path>"
>         exit 1
>     fi
> done
> exit
> ```

# Usage

## Encrypt secret files

Imagine you've got a `values.yaml` with the following information:
```yaml
grafana:
  enabled: true
  adminPassword: admin
```

If you want to encrypt `adminPassword`, remove that line from the `values.yaml`
and create a `secrets.yaml` file with:
```yaml
grafana:
  adminPassword: supersecretpassword
```

And encrypt the file.
```bash
helm secrets enc secrets.yaml
```

If you use [Helmfile](helmfile.md), you'll need to add the secrets file to your
helmfile.yaml.
```yaml
  values:
    - values.yaml
  secrets:
    - secrets.yaml
```

From that point on, `helmfile` will automatically decrypt the credentials.

## Edit secret files

```bash
helm secrets edit secrets.yaml
```

## Decrypt secret files

```bash
helm secrets dec secrets.yaml
```

It will generate a `secrets.yaml.dec` file that it's not decrypted.

Be [careful not to add these files to
git](#prevent-committing-decrypted-files-to-git).

## Clean all the decrypted files

```bash
helm secrets clean .
```

## Add or remove keys

Until [this helm-secrets
issue](https://github.com/futuresimple/helm-secrets/issues/147) has been solved,
if you want to add or remove PGP keys from `.sops.yaml`, you need to execute
`sops updatekeys -y` for each `secrets.yaml` file in the repository.

Check [sops
documentation](https://github.com/mozilla/sops#adding-and-removing-keys) for
more options.

# Links

* [Git](https://github.com/futuresimple/helm-secrets)
