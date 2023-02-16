#!/bin/bash


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "	backup - Backup"
  echo
  echo "DESCRIPTION"
  echo "	This script is used to create backups of the Kolibri and Baseline databases."
  echo "	It uses the credentials from environment variables to connect to the databases and create backups."
  echo "	The backups are then zipped and stored in the specified backup directory."
  echo
  echo "USAGE"
  echo "	./backup.sh "
  echo "  ./backup.sh ~/Desktop"
  exit 1
fi

# File extension for backup files is custom format with extension .backup
file_extension=".backup"

# Directory to store backups
backups_dir=~/backups/

# Get today's date and use it as timestamp for database backup file
timestamp=$(date +"%Y%m%d")

# Get database name using direct query on terminal. remove leading and trailing whitespace
database_name=$(PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD psql -d "$KOLIBRI_DATABASE_NAME" -U "$KOLIBRI_DATABASE_USER" -h "$KOLIBRI_DATABASE_HOST" -p "$KOLIBRI_DATABASE_PORT" -t -c 'select name from kolibriauth_collection where id = (select default_facility_id from device_devicesettings);' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Derive backup name by combining the dataabse name, timestamp and file extension
kolibri_backup_name=${database_name}_kolibri_${timestamp}${file_extension}

# name of baseline backup
baseline_backup_name=${database_name}_baseline_${timestamp}${file_extension}

# Name of zip file
zip_file_name=${database_name}_backups_${timestamp}

# Create database backup using credentials from environment variables 
echo "Creating Kolibri database backup"
PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD pg_dump "$KOLIBRI_DATABASE_NAME" -U "$KOLIBRI_DATABASE_USER" -h "$KOLIBRI_DATABASE_HOST" -p "$KOLIBRI_DATABASE_PORT" -Fc > "$backups_dir/$kolibri_backup_name"

echo "Creating Baseline database backup"
PGPASSWORD=$BASELINE_DATABASE_PASSWORD pg_dump "$BASELINE_DATABASE_NAME" -U "$BASELINE_DATABASE_USER" -h "$BASELINE_DATABASE_HOST" -p "$BASELINE_DATABASE_PORT" -Fc > "$backups_dir/$baseline_backup_name"

echo "Creating zip file with backups"
# create zip file containing both backups taken above and remove the original files
zip -jm "$backups_dir/$zip_file_name" "$backups_dir/$kolibri_backup_name" "$backups_dir/$baseline_backup_name"

# Remove spaces from names of backups
rename "s/ //g" "$backups_dir"*.backup

# Call script to remove backups older than 40 days
~/.scripts/backupdb/remove_old_backups.sh

echo "Done"

