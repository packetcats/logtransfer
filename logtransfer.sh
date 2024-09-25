#!/bin/bash
#
# logtransfer.sh                                         2024-09-25   packetcats
# ==============================================================================
# Overview: This script performs several operations on files within a specified
#           directory that are dated prior to today's date.
#
# The operations include:
# 1. Checking for files with dates older than the current date.
# 2. Changing the ownership and permissions of these files.
# 3. Compressing the identified files.
# 4. Securely transferring the compressed files to an archival server using SCP.
#
# Notes: Authentication for file transfer is managed through an SSH key pair to
#        ensure secure access. Script run daily via CRON.
#
# Define the following environment variables in .env file:
# SOURCE_DIR="/home/user/source_files"
# USR_GRP="user:group"
# PERMISSIONS="0644"
# DESTINATION="user@10.15.1.99:/mnt/archive/network_logs"

# Include the environment variables file
source .env

# Get current date in YYYYMMDD format
CURRENT_DATE=$(date +%Y%m%d)

# Navigate to the directory
cd "$SOURCE_DIR"

# Find files with a date in their name, older than today's date
for file in *; do
    # Extract date from filename and convert it to YYYYMMDD format
    file_date=$(echo $file | grep -o '[0-9]\{8\}')

    # Proceed if a date was found in the filename
    if [[ ! -z "$file_date" ]]; then
        # Check if the file date is less than yesterday's date
        if [[ "$file_date" < "$CURRENT_DATE" ]]; then
            echo "Processing $file..."

            # Perform chown and chmod operations
            chown $USR_GRP "$file"
            chmod $PERMISSIONS "$file"

            # Compress the file
            gzip "$file"

            # Move the compressed file to another server
            scp "$file.gz" $DESTINATION

            # If successful, delete the original file (now redundant as it's compressed)
            if [ $? -eq 0 ]; then
                echo "Transfer successful, deleting original file."
                rm -f "$file.gz"
            else
                echo "Transfer failed, original file kept."
            fi
        fi
    fi
done
