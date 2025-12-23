[autorandr](https://github.com/phillipberndt/autorandr) is a command line tool to automatically select a display configuration based on connected devices.

# Installation

```bash
apt-get install autorandr
```

# Usage

Save your current display configuration and setup with:

```bash
autorandr --save mobile
```

Connect an additional display, configure your setup and save it:

```bash
autorandr --save docked
```

Now autorandr can detect which hardware setup is active:

```bash
$ autorandr
  mobile
  docked (detected)
```

To automatically reload your setup:

```bash
$ autorandr --change
```

To manually load a profile:

```bash
$ autorandr --load <profile>
```

or simply:

```bash
$ autorandr <profile>
```
