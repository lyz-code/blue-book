[Orgzly](https://www.orgzlyrevived.com/) is an android application to interact with [orgmode](orgmode.md) files.

# Tips

## Not adding a todo state when creating a new element by default

The default state `NOTE` doesn't add any state.

# Troubleshooting

## All files give conflicts when nothing has changed

Thinks broke bad, so I exported and sent the files I knew had changed since it broke and then I cleared the orgzly by:

- Removing the repositories connection (Settings / Sync / Repositories): Hard press (copy the path) and then remove
- Removing the database (Settings / Application / Clean local database)
- Restarting the app
- Adding again the repository
- Do a sync

## Avoid the conflicts in the files edited in two places

If you use syncthing you may be seeing conflicts in your files. This happens specially if you use the Orgzly widget to add tasks, this is because it doesn't synchronize the files to the directory when using the widget. If you have a file that changes a lot in a device, for example the `inbox.org` of my mobile, it's interesting to have a specific file that's edited mainly in the mobile, and when you want to edit it elsewhere, you sync as specified below and then process with the editing. Once it's done manually sync the changes in orgzly again. The rest of the files synced to the mobile are for read only reference, so they rarely change.

If you want to sync reducing the chance of conflicts then:

- Open Orgzly and press Synchronize
- Open Syncthing.

If that's not enough [check these automated solutions](https://github.com/orgzly/orgzly-android/issues/8):

- [Orgzly auto syncronisation for sync tools like syncthing](https://gist.github.com/fabian-thomas/6f559d0b0d26737cf173e41cdae5bfc8)
- [watch-for-orgzly](https://gitlab.com/doak/orgzly-watcher/-/blob/master/watch-for-orgzly?ref_type=heads)


Other interesting solutions:

- [org-orgzly](https://codeberg.org/anoduck/org-orgzly): Script to parse a chosen org file or files, check if an entry meets required parameters, and if it does, write the entry in a new file located inside the folder you desire to sync with orgzly.
- [Git synchronization](https://github.com/orgzly/orgzly-android/issues/24): I find it more cumbersome than syncthing but maybe it's interesting for you.
## [Both local and remote notebook have been modified](https://github.com/orgzly/orgzly-android/issues/35)
You can force load or force save a single note with a long tap.
# References

- [Home](https://www.orgzlyrevived.com/)
- [Docs](https://orgzly.com/docs)
- [F-droid page](https://f-droid.org/en/packages/com.orgzlyrevived/)
- [Source](https://github.com/orgzly-revived/orgzly-android-revived)
- [Old Home](https://orgzly.com/)
- [Alternative docs](https://github.com/orgzly/documentation)
- [Alternative fork maintained by the community](https://github.com/orgzly-revived/orgzly-android-revived)
