---
title: Install Google Chrome
date: 20200318
author: Lyz
---

Although I hate it, there are web pages that don't work on Firefox or Chromium.
In those cases I install `google-chrome` and uninstall as soon as I don't need
to use that service.

# Installation

## [Debian](https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-debian-10/)

* Import the GPG key, and use the following command.
  ```bash
  sudo wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg
  ```

* Once the GPG import is complete, you will need to import the Google Chrome repository.

  ```bash
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  ```

* Install the program:
  ```bash
  apt-get update
  apt-get install google-chrome-stable
  ```
