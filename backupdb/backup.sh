#!/bin/bash

# file extension for backup files is custom format with extension .backup
file_extension=".backup"

# Get today's date and use it as timestamp for database backup file
timestamp=$(date +"%Y%m%d")

# Complete timestamp in the format YYYY-MM-DD_hh:mm:ss
complete_timestamp=$(date +%F_%T)

backup_name=${database_name}_${timestamp}${file_extension}

# Create database backup using credentials from environment variables 
echo "Creating database backup"
PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD pg_dump $KOLIBRI_DATABASE_NAME -U $KOLIBRI_DATABASE_USER -h $KOLIBRI_DATABASE_HOST -p $KOLIBRI_DATABASE_PORT -Fc > ~/.backups/$backup_name

# Call script to remove backups older than 40 days
~/.scripts/backupdb/remove_old_backups.sh

echo "Done"

