[Tails](https://tails.net/install/linux/index.en.html) is a portable operating system that protects against surveillance and censorship.

# [Installation](https://tails.net/install/linux/index.en.html)

# [Upgrading a tails USB](https://tails.net/upgrade/tails/index.en.html)

# Configure some applications

## pass

To configure `pass` you need to first [configure the persistent storage](#configure-the-persistent-storage) and then:

```bash
echo -e '/home/amnesia/.password-store source=pass' | sudo tee -a /live/persistence/TailsData_unlocked/persistence.conf > /dev/null
```

Restart tails and then initialize the `pass` store with `pass init your-gpg-id`.

# [Configure the persistent storage](https://tails.net/doc/persistent_storage/configure/index.en.html#index13h2)

## Dotfiles

When the Dotfiles feature is turned on:

- All the files in the `/live/persistence/TailsData_unlocked/dotfiles` folder are linked in the Home folder using Linux symbolic links.

- All the files in subfolders of `/live/persistence/TailsData_unlocked/dotfiles` are also linked in the corresponding subfolder of the Home folder using Linux symbolic links.

- A shortcut is provided in the left pane of the Files browser and in the Places menu in the top navigation bar to access the `/live/persistence/TailsData_unlocked/dotfiles` folder.

For example, having the following files in `/live/persistence/TailsData_unlocked/dotfiles`:

```
/live/persistence/TailsData_unlocked/dotfiles
├── file_a
├── folder
│   ├── file_b
│   └── subfolder
│       └── file_c
└── emptyfolder
```

Produces the following result in `/home/amnesia`:

```
/home/amnesia
├── file_a → /live/persistence/TailsData_unlocked/dotfiles/file_a
└── folder
    ├── file_b → /live/persistence/TailsData_unlocked/dotfiles/folder/file_b
    └── subfolder
        └── file_c → /live/persistence/TailsData_unlocked/dotfiles/folder/subfolder/file_c
```

# Troubleshooting

## [Change the window manager](https://www.reddit.com/r/tails/comments/qzruhv/changing_window_manager/)

Don't do it, they say it it will break Tails although I don't understand why

# References

- [Home](https://tails.net/index.en.html)
- [Docs](https://tails.net/doc/index.en.html)
