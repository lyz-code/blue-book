---
title: Rtorrent
date: 20220222
author: Lyz
---

# Debugging

* Get into the docker with `docker exec -it docker_name bash`
* `cd /home/nobody`
* Open the `rtorrent.sh` file add `set -x` above the line you think is starting your `rtorrent` and `set +x` below to fetch the command that is launching your rtorrent instance, for example:

    ```
    /usr/bin/tmux new-session -d -s rt -n rtorrent /usr/bin/rtorrent -b 12.5.232.12 -o ip=232.234.324.211
    ```

If you manually run `/usr/bin/rtorrent -b 12.5.232.12 -o ip=232.234.324.211`
you'll get more information on why `rtorrent` is not starting.
