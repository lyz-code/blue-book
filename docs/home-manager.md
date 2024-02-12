[Home manager](https://github.com/nix-community/home-manager) provides a basic system for managing a user environment using the Nix package manager together with the [Nix](nix.md) libraries found in Nixpkgs. It allows declarative configuration of user specific (non-global) packages and dotfiles.

# [Installation](https://nix-community.github.io/home-manager/#sec-install-standalone)
- First [install nix](nix.md#installation)
- Add the appropriate Home Manager channel. If you are following Nixpkgs master or an unstable channel you can run

  ```bash
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  ```

  and if you follow a Nixpkgs version 23.11 channel you can run

  ```bash
  nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  nix-channel --update
  ```

- Run the Home Manager installation command and create the first Home Manager generation:

  ```bash
  nix-shell '<home-manager>' -A install
  ```

Once finished, Home Manager should be active and available in your user environment.
# References

- [Source](https://github.com/nix-community/home-manager)
- [Manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs](https://github.com/NixOS/nixpkgs)
