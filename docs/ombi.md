---
title: Ombi
date: 20221116
author: Lyz
---

[Ombi](https://ombi.io/) is a self-hosted web application that automatically
gives your shared Jellyfin users the ability to request content by themselves!
Ombi can be linked to multiple TV Show and Movie DVR tools to create a seamless
end-to-end experience for your users.

If Ombi is not for you, you may try [Overseerr](https://overseerr.dev/).

# Installation

## [Protect ombi behind authentik](https://docs.ombi.app/settings/authentication/#enable-authentication-with-header-variable)

This option allows the user to select a HTTP header value that contains the desired login username.

> Note that if the header value is present and matches an existing user, default authentication is bypassed - use with caution.

This is most commonly utilized when Ombi is behind a reverse proxy which handles authentication. For example, if using Authentik, the X-authentik-username HTTP header which contains the logged in user's username is set by Authentik's proxy outpost.
# Tips

## [Set default quality of request per user](https://docs.ombi.app/guides/usermanagement/#quality-root-path-preferences)

Sometimes one specific user continuously asks for a better quality of the content. If you go into the user configuration (as admin) you can set the default quality profiles for that user.

# References

- [Homepage](https://ombi.io/)
- [Docs](https://docs.ombi.app/guides/installation/)
- [Source](https://github.com/Ombi-app/Ombi)
