#!/bin/bash

database_path=~/.kalite/database/data.sqlite
database_name=$(sqlite3 $database_path "SELECT d.name FROM securesync_device d JOIN securesync_devicemetadata s WHERE s.device_id = d.id AND s.is_own_device = 1")

# Lock database and do integrity check, then unlock
integrity_check=$(sqlite3 $database_path "begin immediate;pragma integrity_check;rollback")

file_extension=".sqlite"

# Timestamp for database backup file
timestamp=$(date +"%Y%m%d")

# Complete timestamp in the format YYYY-MM-DD_hh:mm:ss
complete_timestamp=$(date +%F_%T)

backup_name=${database_name}_${timestamp}${file_extension}

# Append database name to the string "db_errorlog" to make errolog file
# Check if file exists and
filename=${database_name}_"db_error.log"

if [ ! -e "$filename" ] ; then
    touch "$filename"
fi

# Log result of integrity check to errorlog file
echo ${complete_timestamp}-${integrity_check} >> $filename

# create backup file using variables above
echo "Checking Database integrity and creating backup"
sqlite3 $database_path << EOF
.backup $backup_name
EOF

# Move backup file created into backups folder
mv ~/.scripts/backupdb/$backup_name ~/backups/$backup_name

# Call script to remove old backups
~/.scripts/backupdb/remove_old_backups.sh

echo "Done"

