## logtransfer.sh

### Overview:
This script performs several operations on files within a specified
directory that are dated prior to today's date.

The operations include:
1. Checking for files with dates older than the current date.
2. Changing the ownership and permissions of these files.
3. Compressing the identified files.
4. Securely transferring the compressed files to an archival server using SCP.

Notes: Authentication for file transfer is managed through an SSH key pair to
ensure secure access. Script run daily via CRON.

Define the following environment variables in .env file:
```
SOURCE_DIR="/home/user/source_files"
USR_GRP="user:group"
PERMISSIONS="0644"
DESTINATION="user@10.15.1.20:/mnt/archive/network_logs"
```

```
crontab -e
```

Run script at 0100 hours daily:
```
0 1 * * * /path/to/logtransfer.sh
```
