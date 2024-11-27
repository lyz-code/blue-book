---
title: Krew
date: 20220307
author: Lyz
---

[Krew](https://github.com/kubernetes-sigs/krew) is a tool that makes it easy to
use kubectl plugins. Krew helps you discover plugins, install and manage them on
your machine. It is similar to tools like apt, dnf or brew.

# [Installation](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)

1. Run this command to download and install krew:

    ```bash
    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )
    ```

1. Add the `$HOME/.krew/bin` directory to your PATH environment variable. To do
   this, update your `.bashrc` or `.zshrc` file and append the following line:

   ```bash
   export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
   ```

1. Restart your shell.

1. Run `kubectl krew` to check the installation.

# References

* [Git](https://github.com/kubernetes-sigs/krew)
* [Docs](https://krew.sigs.k8s.io/)
