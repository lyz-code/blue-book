---
title: Nodejs
date: 20200402
author: Lyz
---

Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.

# Install

The debian base repositories are really outdated, install it directly

## [Using nvm](https://nodejs.org/en/download/package-manager)

```bash
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# download and install Node.js (you may need to restart the terminal)
nvm install 22

# verifies the right Node.js version is in the environment
node -v # should print `v22.12.0`

# verifies the right npm version is in the environment
npm -v # should print `10.9.0`
```

## Using nodesource

```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs npm
nodejs --version
```

# Links

* [Home](https://nodejs.org/en/)
