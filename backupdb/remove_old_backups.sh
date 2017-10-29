#!/bin/sh
#backups directory
DIR=~/backups
#today's date
now=$(date +%s)
#Specify number of days older old backups will be
DAYS=40

echo "Cleaning up old backups..."

for file in "$DIR/"*
do
    if [ $(((`stat $file -c '%Y'`) + (86400 * $DAYS))) -lt $now ]
    then
    	# Python file which creates backups will eventually become more than 40 days old. So prevent it being deleted by this script
    	if [ "${file##*.}" != "py" ]; then
    		rm $file
    	fi
    	echo "Removed $file"
    fi
    
done