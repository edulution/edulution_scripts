#!/bin/bash

# silent version of upgrade script
#run before monthend or alldata commands
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x reporting/fix_crazy/fixcrazy
chmod +x backupdb/remove_old_backups.sh

#make backups and reports directories if they don't exist
DIRECTORIES=( ~/reports ~/backups )
for DIRECTORY in ${DIRECTORIES[@]}; do
	if [ ! -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	fi
done

#If backup.py script already exists, replace it with latest version. If not, create it
test -f ~/backups/backup.py
if [ "$?" = "0" ]; then
	rm ~/backups/backup.py
	cp backupdb/backup.py ~/backups
else
	cp backupdb/backup.py ~/backups
fi

#If bash aliases already exists, replace it with latest version. If not, create it
cd ~
test -f ~/.bash_aliases
if [ "$?" = "0" ]; then
	sudo rm .bash_aliases
	sudo cp .scripts/.bash_aliases ~
else
	sudo cp ~/.scripts/.bash_aliases ~
fi

#test if upgrade script exists. If not add it
test -f ~/upgrade
if [ "$?" = "0" ]; then
	sudo rm upgrade
	sudo cp .scripts/upgrade ~
else
	sudo cp ~/.scripts/upgrade ~
fi

#replace nginx conf files with latest version
test -f /etc/nginx/nginx.conf
if [ "$?" = "0" ]; then
	sudo rm /etc/nginx/nginx.conf
	sudo cp ~/.scripts/config/nginx.conf /etc/nginx/
else
	sudo cp ~/.scripts/config/nginx.conf /etc/nginx/
fi

test -f /etc/nginx/sites-enabled/kalite.conf
if [ "$?" = "0" ]; then
	sudo rm /etc/nginx/sites-enabled/kalite.conf
	sudo cp ~/.scripts/config/kalite.conf /etc/nginx/sites-enabled/
else
	sudo cp ~/.scripts/config/kalite.conf /etc/nginx/sites-enabled/
fi

