#!/bin/bash

# silent version of upgrade script
#run before monthend or alldata commands
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x backupdb/remove_old_backups.sh

kolibri_helper_scripts_dir=~/.kolibri_helper_scripts

# Make backups and reports directories if they don't exist
DIRECTORIES=( ~/.reports ~/backups )
for DIRECTORY in "${DIRECTORIES[@]}"; do
	if [ ! -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	fi
done

# If bash aliases already exists, replace it with latest version. If not, create it
cd ~ || exit
if test -f ~/.bash_aliases; then
	sudo rm .bash_aliases
	sudo cp .scripts/.bash_aliases ~
else
	sudo cp ~/.scripts/.bash_aliases ~
fi

# If bash colors already exists, replace it with latest version. If not, create it
if test -f ~/.bash_colors; then
	sudo rm .bash_colors
	sudo cp .scripts/.bash_colors ~
else
	sudo cp ~/.scripts/.bash_colors ~
fi

# Test if upgrade script exists. If not add it
if test -f ~/upgrade; then
	sudo rm upgrade
	sudo cp .scripts/upgrade ~
else
	sudo cp ~/.scripts/upgrade ~
fi

# Make txt file on desktop with command to restore all aliases and ka commands
~/.scripts/config/create_kolibri_commands_file.sh > /dev/null

# Check if postgresql is installed and alert user if it is not installed
if [ "$(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c 'ok installed')" -eq 0 ];
then
  echo "PostgreSQL is not installed. Please contact support"
  
else
  echo "PostgreSQL is already installed. Skipping.."
fi

~/.scripts/config/increase_session_timeout.sh

# Check if kolibri helper scripts directory exists. pull it if it does not
if [ -d "$kolibri_helper_scripts_dir" ]; then
	cd $kolibri_helper_scripts_dir && git reset --hard origin/master && git pull origin master && cd ~ || exit
else
	echo "Helper scripts directory does not exist. Cloning now..."
	git clone https://github.com/techZM/kolibri_helper_scripts.git $kolibri_helper_scripts_dir
fi

# Rename numeracy class to learners on program
python ~/.kolibri_helper_scripts/rename_class.py -o "Numeracy" -n "Learners on Program"

# Run backup script
~/.scripts/backupdb/backup.sh
