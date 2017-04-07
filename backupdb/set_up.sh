#!/bin/sh

# Not much setup needed for backup scripts. Only a directory to store backups
mkdir ~/backups
# copy python script to backups directory
cp backup.py ~/backups
test -f ~/backups/backup.py
if [ "$?" = "0" ]; then
	
fi
