[WezTerm](https://github.com/wez/wezterm) is a powerful cross-platform terminal emulator and multiplexer implemented in Rust.

# [Installation](https://wezfurlong.org/wezterm/install/linux.html)

You can configure your system to use that APT repo by following these steps:

```bash
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
```

Update your dependencies:

```bash
sudo apt update
```

Now you can install wezterm:

```bash
sudo apt install wezterm
```

or to install a nightly build:

```bash
sudo apt install wezterm-nightly
```
# Troubleshooting 
## [Install in Debian 12 error](https://github.com/wez/wezterm/issues/3973)
Install from nightly.
# References

- [Code](https://github.com/wez/wezterm)
- [Docs](https://wezfurlong.org/wezterm/index.html)
- [Home](https://wezfurlong.org/wezterm/index.html)
