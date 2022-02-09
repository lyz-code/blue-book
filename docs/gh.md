---
title: Github cli client
date: 20211115
author: Lyz
---

[`gh`](https://github.com/cli/cli) is GitHub’s official command line tool.

# [Installation](https://github.com/cli/cli#installation)

Get the `deb` file from the [releases
page](https://github.com/cli/cli/releases/latest) and install it with `sudo dpkg -i`

Authenticate the command following the steps of:

```bash
gh auth login
```

# Usage

## Create a pull request

Whenever you do a git push it will show you the link to create the pull request.
To avoid going into the browser, you can use `gh pr create`.

You can also merge a ready pull request with `gh pr merge`

## Workflow runs

With `gh run list` you can get the list of the last workflow runs. If you want
to see the logs of one of the runs, get the id and run `gh run view {{ run_id
}}`.

To see what failed, run `gh run view {{ run_id }} --log-failed`.

## Pull request checks

`gh` allows you to check the status of the checks of a pull requests, this is
useful to get an alert once the checks are done. For example you can use the
next bash/zsh function:

```bash
function checks(){
    while true; do
        gh pr checks
        if [[ -z "$(gh pr status --json statusCheckRollup | grep IN_PROGRESS)" ]]; then
          break
        fi
        sleep 1
        echo
    done
    gh pr checks
    echo -e '\a'
}
```

## Trigger a workflow run

To manually trigger a workflow you need to first configure it to allow
[`workflow_dispatch`
events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch).

```yaml
on:
    workflow_dispatch:
```

Then you can trigger the workflow with `gh workflow run {{ workflow_name }}`,
where you can get the `workflow_name` with `gh workflow list`

# References

* [Git](https://github.com/cli/cli)
