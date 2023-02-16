#!/bin/sh

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   - "
  echo
  echo "DESCRIPTION"
  echo "    This script is used to clean up old backups in the specified directory."
  echo "    The number of days specified in 'DAYS' determines how old the backups must be before being deleted."
  echo
  echo "    Backup files with the extension '.py' will not be deleted."
  exit 1
fi

# Backups directory
DIR=~/backups
# Today's date
now=$(date +%s)
# Specify number of days older old backups will be
DAYS=40

echo "Cleaning up old backups..."

for file in "$DIR"*
do
    if [ $((($(stat "$file" -c '%Y')) + (86400 * DAYS))) -lt "$now" ]
    then
    	# Python file which creates backups will eventually become more than 40 days old. So prevent it being deleted by this script
    	if [ "${file##*.}" != "py" ]; then
    		rm "$file"
    	fi
    	echo Removed "$file"
    fi
done