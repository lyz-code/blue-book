[Matrix](https://wiki.archlinux.org/index.php/Matrix) is a FLOSS protocol for open federated instant messaging. Matrix ecosystem consists of many servers which can be used for registration.
# [Choose a server](https://tatsumoto-ren.github.io/blog/list-of-matrix-servers.html)
Choose a server that doesn't engage in chaotic account or room purges. Being on such a homeserver is no different from being on Discord. If a homeserver has rules, read them to check if they're unreasonably strict. Keep an eye on the usual things that tend to stink. For example, if a homeserver is trying to suppress certain political opinions, restrict you from posting certain types of content or otherwise impose authoritarian environment.

https://view.matrix.org/ gives an overview of the most used channels and on each of them you can see what do the people use. Looking at meaningful channels:

- [Arch linux](https://view.matrix.org/room/!GtIfdsfQtQIgbQSxwJ:archlinux.org/servers)
- GrapheneOs: [1](https://view.matrix.org/room/!lAoVmVifHHtoeOAmHO:grapheneos.org/servers), [2](https://view.matrix.org/room/!UVEsOAdphEMYhxzTah:grapheneos.org/servers)
- [Techlore](https://view.matrix.org/room/!zjYxZkVEqwWcQQhXxc:techlore.net/servers)

You can say that the most used (after matrix.org) are:

- envs.net: They have [an element page](https://element.envs.net/#/welcome), I don't find any political statement
- tchncs.de: Run by [an individual](https://tchncs.de/), I don't find any political statement either.
- t2bot.io: [It's for bots](https://t2bot.io/) so nope.
- nitro.chat: Run by [Nitrokey](https://www.nitrokey.com/about) is the world-leading company in open source security hardware. Nitrokey develops IT security hardware for data encryption, key management and user authentication, as well as secure network devices, PCs, laptops and smartphones. The company has been founded in Berlin, Germany in 2015 and can already count ten thousands of users from more than 120 countries including numerous well-known international enterprises from various industries. It lists Amazon, nvidia, Ford, Google between their clients -> Nooope!

[Tatsumoto](https://tatsumoto-ren.github.io/blog/list-of-matrix-servers.html) doesn't recommend some of them saying that the admin blocked rooms in the pursuit of censorship, but he also references a page that looks pretty Zionist so I'm not sure rick... Maybe that censorship means they are good servers xD.
## Avoid matrix.org
If you already have an account hosted on Matrix.org, please deactivate your account and create a new account on another homeserver immediately. Matrix.org is the largest Matrix homeserver, and most Matrix apps suggest it by default. Many users new to Matrix end up using this server because they don't know that other servers exist. Unfortunately, Matrix.org is far from the best choice. Due to its absurdly strict rules, the server is known for frequent bans of rooms and user accounts, and it does so without prior notice. Basically, Matrix.org uses its size and special status to impose censorship.


# [Installation](https://doc.matrix.tu-dresden.de/clients/install_linux/)

```bash
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
sudo apt update
sudo apt install element-desktop
```


# References

- [Matrix Arch wiki page](https://wiki.archlinux.org/index.php/Matrix)
