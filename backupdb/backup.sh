#!/bin/bash

# file extension for backup files is custom format with extension .backup
file_extension=".backup"

# Get today's date and use it as timestamp for database backup file
timestamp=$(date +"%Y%m%d")

# get database name using direct query on terminal
database_name=$(PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD psql -d $KOLIBRI_DATABASE_NAME -U $KOLIBRI_DATABASE_USER -h $KOLIBRI_DATABASE_HOST -p $KOLIBRI_DATABASE_PORT -t -c "select name from kolibriauth_collection where id = (select default_facility_id from device_devicesettings);")

#remove leading whitespace
database_name="${database_name##*( )}"

#remove trailing whitespace
database_name="${database_name%%*( )}"

# Derive backup name by combining the dataabse name, timestamp and file extension
backup_name=${database_name}_${timestamp}${file_extension}

# Create database backup using credentials from environment variables 
echo "Creating database backup"
PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD pg_dump $KOLIBRI_DATABASE_NAME -U $KOLIBRI_DATABASE_USER -h $KOLIBRI_DATABASE_HOST -p $KOLIBRI_DATABASE_PORT -Fc > ~/backups/"$backup_name"

# Call script to remove backups older than 40 days
~/.scripts/backupdb/remove_old_backups.sh

echo "Done"

