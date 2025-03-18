---
title: Renovate
date: 20221012
author: Lyz
---

[Renovate](https://docs.renovatebot.com/) is a program that does automated
dependency updates. Multi-platform and multi-language.

Why use Renovate?

- Get pull requests to update your dependencies and lock files.
- Reduce noise by scheduling when Renovate creates PRs.
- Renovate finds relevant package files automatically, including in monorepos.
- You can customize the bot's behavior with configuration files.
- Share your configuration with ESLint-like config presets.
- Get replacement PRs to migrate from a deprecated dependency to the community
  suggested replacement (npm packages only).
- Open source.
- Popular (more than 9.7k stars and 1.3k forks)
- Beautifully integrate with main Git web applications (Gitea, Gitlab, Github).
- It supports most important languages: Python, Docker, Kubernetes, Terraform,
  Ansible, Node, ...

# [Installation](https://about.gitea.com/resources/tutorials/use-gitea-and-renovate-bot-to-automatically-monitor-software-packages)

- Create Renovate Bot Account and generate a token for the Gitea Action secret
- Add the renovate bot account as collaborator with write permissions to the repository you want to update.
- Create a repository to store our Renovate bot configurations, assuming called renovate-config.

In renovate-config, create a file config.js to configure Renovate:

```json
module.exports = {
    "endpoint": "https://gitea.com/api/v1", // replace it with your actual endpoint
    "gitAuthor": "Renovate Bot <renovate-bot@yourhost.com>",
    "platform": "gitea",
    "onboardingConfigFileName": "renovate.json",
    "autodiscover": true,
    "optimizeForDisabled": true,
};
```

If you're using mysql or you see errors like `.../repository/pulls 500 internal error` you [may need to set `unicodeEmoji: false`](https://github.com/renovatebot/renovate/issues/10264).

# [Configuration](https://docs.renovatebot.com/configuration-options)

## [automerge](https://docs.renovatebot.com/configuration-options/#automerge)

By default, Renovate raises PRs but leaves them to someone or something else to merge them. By configuring this setting, you allow Renovate to automerge PRs or even branches. Using automerge reduces the amount of human intervention required.

Usually you won't want to automerge all PRs, for example most people would want to leave major dependency updates to a human to review first. You could configure Renovate to automerge all but major this way:

```json
{
  "packageRules": [
    {
      "matchUpdateTypes": ["minor", "patch", "pin", "digest"],
      "automerge": true
    }
  ]
}
```

Also note that this option can be combined with other nested settings, such as dependency type. So for example you could choose to automerge all (passing) devDependencies only this way:

```json
{
  "packageRules": [
    {
      "matchDepTypes": ["devDependencies"],
      "automerge": true
    }
  ]
}
```

## Configure docker version extraction

- [Ansible Manager Docker-type dependency extraction · renovatebot/renovate · Discussion #18190 · GitHub](https://github.com/renovatebot/renovate/discussions/18190)
- [Automated Dependency Updates for Ansible - Renovate Docs](https://docs.renovatebot.com/modules/manager/ansible/)
- [Pin packages in ansible roles · Issue #3720 · renovatebot/renovate](https://github.com/renovatebot/renovate/issues/3720)
- [Support default environment variable values in docker-compose · Issue #4635 · renovatebot/renovate](https://github.com/renovatebot/renovate/issues/4635)
- [Support docker-compose.yml versions from .env files · Issue #31685 · renovatebot/renovate](https://github.com/renovatebot/renovate/issues/31685)

## Combine all updates to one branch/PR

- [Group Presets - Renovate Docs group all non major](https://docs.renovatebot.com/presets-group/#groupallnonmajor)
- [Group Presets - Renovate Docs group all](https://docs.renovatebot.com/presets-group/#groupall)
- [config - Renovate: Combine all updates to one branch/PR - Stack Overflow](https://stackoverflow.com/questions/66471226/renovate-combine-all-updates-to-one-branch-pr)
-

# Behind the scenes

## How Renovate updates a package file

Renovate:

- Scans your repositories to detect package files and their dependencies.
- Checks if any newer versions exist.
- Raises Pull Requests for available updates.

The Pull Requests patch the package files directly, and include Release Notes
for the newer versions (if they are available).

By default:

- You'll get separate Pull Requests for each dependency.
- Major updates are kept separate from non-major updates.

# References

- [Docs](https://docs.renovatebot.com/)
- [Upgrade notes](https://docs.renovatebot.com/release-notes-for-major-versions/)
