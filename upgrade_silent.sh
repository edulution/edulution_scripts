#!/bin/bash

# exit if anything returns a non-zero code
set -e

# silent version of upgrade script

kolibri_helper_scripts_dir=~/.kolibri_helper_scripts

# shellcheck source=/dev/null
# source helper function to create or replace config files
source ~/.scripts/config/check_file_and_replace.sh
# shellcheck source=/dev/null
source ~/.scripts/config/check_or_create_dirs.sh

DIRECTORIES=( ~/.reports ~/backups )

#make backups and reports directories if they don't exist
check_or_create_dirs "${DIRECTORIES[@]}" > /dev/null

# create or replace the bash colors file
check_file_and_replace ~/.bash_colors ~/.scripts/config/.bash_colors 1 > /dev/null

# create or replace the upgrade script
check_file_and_replace ~/upgrade ~/.scripts/upgrade 0 > /dev/null

# create or replace the bash aliases
check_file_and_replace ~/.bash_aliases ~/.scripts/config/.bash_aliases 0 > /dev/null

# Make txt file on desktop with command to restore all aliases and ka commands
~/.scripts/config/create_kolibri_commands_file.sh > /dev/null

# Check if postgresql is installed and alert user if it is not installed
if [ "$(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c 'ok installed')" -eq 0 ];
then
  echo "PostgreSQL is not installed or service is not running. Please contact support"
  
else
  echo "PostgreSQL is already installed. Skipping.."
fi

~/.scripts/config/increase_session_timeout.sh

# Check if kolibri helper scripts directory exists. pull it if it does not
if [ -d "$kolibri_helper_scripts_dir" ]; then
	cd $kolibri_helper_scripts_dir && git reset --hard origin/namibia && git pull origin namibia && cd ~ || exit

else
	echo "Helper scripts directory does not exist. Cloning now..."
	git clone https://github.com/edulution/kolibri_helper_scripts.git $kolibri_helper_scripts_dir
	cd $kolibri_helper_scripts_dir && git reset --hard origin/namibia && git pull origin namibia && cd ~ || exit
fi

# Run backup script
~/.scripts/backupdb/backup.sh

# Run flyway migrations for baseline_testing silently
~/.scripts/config/flyway_bl.sh migrate > /dev/null


# Add any other scripts you would like to run below this line
###################
~/.scripts/config/add_pgtune_settings.sh