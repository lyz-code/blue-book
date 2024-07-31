[Alacritty](https://alacritty.org/) is a modern terminal emulator that comes with sensible defaults, but allows for extensive configuration. By integrating with other applications, rather than reimplementing their functionality, it manages to provide a flexible set of features with high performance.

# [Installation](https://github.com/alacritty/alacritty/blob/master/INSTALL.md#debianubuntu)

- Clone the repo
  ```bash
  git clone https://github.com/alacritty/alacritty.git
  cd alacritty
  ```
- [Install `rustup`](https://rustup.rs/)
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh 
  ```
- To make sure you have the right Rust compiler installed, run
  ```bash
  rustup override set stable
  rustup update stable
  ```
- Install the dependencies
  ```bash
  apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
  ```
- Build the release
  ```bash
  cargo build --release
  ```
  If all goes well, this should place a binary at `target/release/alacritty`
- Move the binary to somewhere in your PATH

  ```bash
  mv target/release/alacritty ~/.local/bin
  ```
- Check the terminfo: To make sure Alacritty works correctly, either the `alacritty` or `alacritty-direct` terminfo must be used. The `alacritty` terminfo will be picked up automatically if it is installed.
  If the following command returns without any errors, the `alacritty` terminfo is already installed:

  ```bash
  infocmp alacritty
  ```

  If it is not present already, you can install it globally with the following command:

  ```bash
  sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
  ```

# [Configuration](https://alacritty.org/config-alacritty.html)
Alacritty's configuration file uses the TOML format. It doesn't create the config file for you, but it looks for one in `~/.config/alacrity/alacritty.toml`

# Not there yet
- [Support for ligatures](https://github.com/alacritty/alacritty/issues/50)
# References
- [Homepage](https://alacritty.org/)
- [Source](https://github.com/alacritty/alacritty)
- [Docs](https://github.com/alacritty/alacritty/blob/master/docs/features.md)
