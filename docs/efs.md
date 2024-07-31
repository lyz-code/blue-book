# Snippets

## List the size of the recovery points

```bash
#!/bin/bash

# Replace with your backup vault name
BACKUP_VAULT_NAME="your-vault-name"

# List all recovery points with their sizes
RECOVERY_POINTS=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name $BACKUP_VAULT_NAME --query 'RecoveryPoints[*].[RecoveryPointArn,BackupSizeInBytes,CreationDate]' --output text)
#
# # Loop through each recovery point and convert size to terabytes
echo -e "Creation Date\t\tRecovery Point ARN\t\t\t\t\t\t\t\t\tSize (TB)"
echo "---------------------------------------------------------------------------------------------------------------------"

while read -r RECOVERY_POINT_ARN BACKUP_SIZE_BYTES CREATION_DATE; do
    # Remove the decimal part from the epoch time
    EPOCH_TIME=$(echo $CREATION_DATE | cut -d'.' -f1)
    # Convert the creation date from epoch time to YYYY-MM-DD format
    FORMATTED_DATE=$(date -d @$EPOCH_TIME +"%Y-%m-%d")
    SIZE_TB=$(echo "scale=6; $BACKUP_SIZE_BYTES / (1024^4)" | bc)
    # echo -e "$FORMATTED_DATE\t$RECOVERY_POINT_ARN\t$SIZE_TB"
   	printf "%-16s %-80s %10.6f\n" "$FORMATTED_DATE" "$RECOVERY_POINT_ARN" "$SIZE_TB"
done <<< "$RECOVERY_POINTS"
```
## List the size of the jobs

To list AWS Backup jobs and display their completion dates and sizes in a human-readable format, you can use the following AWS CLI command combined with `jq` for parsing and formatting the output. This command handles cases where the backup size might be null and rounds the size to the nearest whole number in gigabytes.

```sh
aws backup list-backup-jobs --output json | jq -r '
  .BackupJobs[] | 
  [
    (.CompletionDate | strftime("%Y-%m-%d %H:%M:%S")),
    (if .BackupSizeInBytes == null then "0GB" else ((.BackupSizeInBytes / 1024 / 1024 / 1024) | floor | tostring + " GB") end)
  ] | 
  @tsv' | column -t -s$'\t'
```
Explanation:

- `aws backup list-backup-jobs --output json`: Lists all AWS Backup jobs in JSON format.
- `.BackupJobs[]`: Iterates over each backup job.
- `(.CompletionDate | strftime("%Y-%m-%d %H:%M:%S"))`: Converts the Unix timestamp in CompletionDate to a human-readable date format (YYYY-MM-DD HH:MM:SS).
- `(if .BackupSizeInBytes == null then "0GB" else ((.BackupSizeInBytes / 1024 / 1024 / 1024) | floor | tostring + " GB") end)`: Checks if BackupSizeInBytes is null. If it is, outputs "0GB". Otherwise, converts the size from bytes to gigabytes, rounds it down to the nearest whole number, and appends " GB".
- `| @tsv`: Formats the output as tab-separated values.
- `column -t -s$'\t'`: Formats the TSV output into a table with columns aligned.

# Troubleshooting

## Don't have enough permissions to start restore from backup

That may be because the default EFS backup policy doesn't let you do that (stupid, I know).

To fix it go into the backup policy and remove the next line from the `Deny` policy:

```json
backup:StartRestoreJob
```
