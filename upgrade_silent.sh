#!/bin/bash

# silent version of upgrade script
#run before monthend or alldata commands
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x backupdb/remove_old_backups.sh

#make backups and reports directories if they don't exist
DIRECTORIES=( ~/.reports ~/backups )
for DIRECTORY in ${DIRECTORIES[@]}; do
	if [ ! -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	fi
done

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
# test -f /etc/nginx/nginx.conf
# if [ "$?" = "0" ]; then
# 	sudo rm /etc/nginx/nginx.conf
# 	sudo cp ~/.scripts/config/nginx.conf /etc/nginx/
# else
# 	sudo cp ~/.scripts/config/nginx.conf /etc/nginx/
# fi

# test -f /etc/nginx/sites-available/kolibri.conf
# if [ "$?" = "0" ]; then
# 	sudo rm /etc/nginx/sites-available/kolibri.conf
# 	sudo cp ~/.scripts/config/kolibri.conf /etc/nginx/sites-available/
# 	sudo ln etc/nginx/sites-available/kolibri.conf /etc/nginx/sites-enabled
# else
# 	sudo cp ~/.scripts/config/kolibri.conf /etc/nginx/sites-available/
# 	sudo ln etc/nginx/sites-available/kolibri.conf /etc/nginx/sites-enabled
# fi

#Make txt file on desktop with command to restore all aliases and ka commands
~/.scripts/config/create_kolibri_commands_file.sh > /dev/null

# check if postgresql is installed and alert user if it is not installed
if [ $(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "PostgreSQL is not installed. Please contact support"
  
else
  echo "PostgreSQL is already installed. Skipping.."
fi

~/.scripts/config/increase_session_timeout.sh

#Run backup script
~/.scripts/backupdb/backup.sh
