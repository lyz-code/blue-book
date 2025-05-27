[Forgejo](https://forgejo.org/) is a self-hosted lightweight software forge.
Easy to install and low maintenance, it just does the job. The awful name comes from `forĝejo`, the Esperanto word for forge. I kind of like though the concept of forge for the repositories.

Brought to you by an inclusive community under the umbrella of [Codeberg e.V.](https://forgejo.org/faq/#what-is-codeberg-ev), a democratic non-profit organization, Forgejo can be trusted to be exclusively Free Software. It is a ["soft" fork of Gitea](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/CONTRIBUTING/WORKFLOW.md#feature-branches) with a focus on scaling, federation and privacy.

The forgejo instance at [codeberg](https://codeberg.org) looks to be production ready they [have forgejo actions](https://docs.codeberg.org/ci/actions/) (although you need to host the runners yourself or use Woodpecker CI :/) and [static pages](#host-static-pages-site). It looks [they won't be moving to forgejo actions soon](https://codeberg.org/Codeberg-CI/feedback/issues/192), if you wish to follow this topic subscribe to [this thread](https://codeberg.org/Codeberg/Community/issues/843). If you want to activate the Woodpecker actions on your repo you need to [file an issue here](https://codeberg.org/Codeberg-e.V./requests), and you can file feedback requests [here](https://codeberg.org/Codeberg-CI/feedback/issues)

I want to migrate everything from github to their server... Let's see how soon I manage to do it xD.

# History

In October 2022 the domains and trademark of Gitea were transferred to a for-profit company without knowledge or approval of the community. Despite [writing an open letter](https://gitea-open-letter.coding.social/), the takeover was later confirmed. The goal of Forgejo is to continue developing the code with a healthy democratic governance.

On the 15th of December of 2022 the [project was born](https://forgejo.org/2022-12-15-hello-forgejo/) with these major objectives:

- The community is in control, and ensures we develop to address community needs.
- We will help liberate software development from the shackles of proprietary tools.

One of the approaches to achieve the last point is through pushing for [the Forgejo federation](https://forgejo.org/2023-01-10-answering-forgejo-federation-questions/) a much needed feature in the git web application ecosystem.

On the 29th of December of 2022 they released [the first stable release](https://forgejo.org/2022-12-29-release-v1-18-0) and they have released several security releases between then and now.

# Pros and cons

Despite what you choose, the good thing is that as long as it's a soft fork [migrating between these software](https://forgejo.org/faq/#are-migrations-between-gitea-and-forgejo-possible) should be straight forward.

Forgejo outshines Gitea in:

- Being built up by the people for the people. The project may die but it's not likely it will follow Gitea's path.
- They are transparent regarding the [gobernance of the project](https://codeberg.org/forgejo/governance) which is created through [open community discussions](https://codeberg.org/forgejo/discussions/issues).
- It's a political project that fights for the people's rights, for example through [federation](https://forgejo.org/2023-01-10-answering-forgejo-federation-questions/) and freely incorporating the new additions of Gitea
- They'll eventually [have a better license](https://codeberg.org/forgejo/discussions/issues/6)
- They get all the features and fixes of Gitea plus the contributions of the developers of the community that run out of Gitea.

Gitea on the other hand has the next advantages:

- It's a more stable project, it's been alive for much more time and now has the back up of a company trying to make profit out of it. Forgejo's community and structure is still [evolving to a stable state](https://codeberg.org/forgejo/meta/issues/187) though, although it looks promising!
- Quicker releases. As Forgejo needs to review and incorporate Gitea's contributions, it takes longer to do a release.

Being a soft-fork has it's disadvantages too, for example deciding where to open the issues and pull requests, [they haven't yet decided which is their policy around this topic](https://codeberg.org/forgejo/meta/issues/114).

# Usage

## [Host static pages site](https://codeberg.page/)

Now you can use static pages similar to Github Pages in forgejo/gitea! check [how they do it at codeberg](https://codeberg.page/).

## [Push to a forgejo docker registry](https://forgejo.org/docs/latest/user/packages/container/)

### Login to the container registry

To push an image or if the image is in a private registry, you have to authenticate:

```bash
docker login forgejo.example.com
```

If you are using 2FA or OAuth use a personal access token instead of the password.

### Image naming convention

Images must follow this naming convention:

```
{registry}/{owner}/{image}
```

When building your docker image, using the naming convention above, this looks like:

```bash
# build an image with tag
docker build -t {registry}/{owner}/{image}:{tag} .

# name an existing image with tag
docker tag {some-existing-image}:{tag} {registry}/{owner}/{image}:{tag}
```

Where your registry is the domain of your forgejo instance (e.g. forgejo.example.com). For example, these are all valid image names for the owner testuser:

- forgejo.example.com/testuser/myimage
- forgejo.example.com/testuser/my-image
- forgejo.example.com/testuser/my/image

NOTE: The registry only supports case-insensitive tag names. So image:tag and image:Tag get treated as the same image and tag.

### Push an image

Push an image by executing the following command:

```bash
docker push forgejo.example.com/{owner}/{image}:{tag}
```

For example:

```bash
docker push forgejo.example.com/testuser/myimage:latest
```

# References

- [Source](https://codeberg.org/forgejo/forgejo)
- [Issues](https://codeberg.org/forgejo/forgejo/issues)
- [Docs](https://forgejo.org/docs/latest)
- [Home](https://forgejo.org/)
- [News](https://forgejo.org/news/)
