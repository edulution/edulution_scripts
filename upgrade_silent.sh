#!/bin/bash

# silent version of upgrade script
#run before monthend or alldata commands
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x reporting/fix_crazy/fixcrazy
chmod +x backupdb/remove_old_backups.sh
chmod +x config/increase_session_timeout

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

#ncrease idle session timeout to 15 minutes
~/.scripts/config/increase_session_timeout

#Make simplifed login work even when over 1000 students present at facility
~/.scripts/config/fix_user_limit_on_simplified_login

# Install sqlite3 package if not already installed
if [ $(dpkg-query -W -f='${Status}' sqlite3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing sqlite3 package"
  sudo apt-get install -y sqlite3
else
  echo "sqlite3 package already installed. Skipping.."
fi

#Run backup script
~/.scripts/backupdb/backup.sh
