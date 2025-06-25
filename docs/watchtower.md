[Watchtower](https://containrrr.dev/watchtower/) is a container-based solution for automating Docker container base image updates.

With watchtower you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry. Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially. Run the watchtower container with the following command:

```bash
$ docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower
```

# Usage

## Exclude image from being pruned

Add to the dockerfile:

```Dockerfile
LABEL com.centurylinklabs.watchtower.enable=false
```

# References

- [Source](https://github.com/containrrr/watchtower)
- [Docs](https://containrrr.dev/watchtower/)
