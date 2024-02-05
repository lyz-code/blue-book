# Troubleshooting

## Don't have enough permissions to start restore from backup

That may be because the default EFS backup policy doesn't let you do that (stupid, I know).

To fix it go into the backup policy and remove the next line from the `Deny` policy:

```json
backup:StartRestoreJob
```
