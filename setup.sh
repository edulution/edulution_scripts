#!/bin/bash

#make backups and reports directories if they don't exist
DIRECTORIES=( ~/.reports ~/backups )
for DIRECTORY in ${DIRECTORIES[@]}; do
	if [ ! -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	else
		echo "${blue}$DIRECTORY already exists. Skipping this step${reset}"
	fi
done

# switch to home directory
cd ~

#If bash aliases already exists, replace it with latest version. If not, create it
if test -f ~/.bash_aliases; then
	echo "${blue}Bash aliases file already exists. Replacing with latest version${reset}"
	sudo rm .bash_aliases
	sudo cp .scripts/.bash_aliases ~
else
	echo "${blue}${bold}Aliases file does not exist. Inserting latest version${reset}"
	sudo cp ~/.scripts/.bash_aliases ~
fi

#If bash colors already exists, replace it with latest version. If not, create it
if test -f ~/.bash_colors; then
	echo "${blue}Bash aliases file already exists. Replacing with latest version${reset}"
	sudo rm .bash_colors
	sudo cp .scripts/.bash_colors ~
else
	echo "${blue}${bold}Aliases file does not exist. Inserting latest version${reset}"
	sudo cp ~/.scripts/.bash_colors ~
fi

#test if upgrade script exists. If not add it
if test -f ~/upgrade; then
	echo "${blue}Upgrade script already exists. Replacing with latest version${reset}"
	sudo rm upgrade
	sudo cp .scripts/upgrade ~
else
	echo "${blue}${bold}Upgrade script does not exist. Inserting it now${reset}"
	sudo cp ~/.scripts/upgrade ~
fi

# check if postgresql is installed. Alert user to contact support if it is not installed
if [ $(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "${red}${bold}PostgreSQL is not installed. Please contact support${reset}"
  
else
  echo "${blue}PostgreSQL is already installed. Skipping..${reset}"
fi

# Run backup script
~/.scripts/backupdb/backup.sh > /dev/null

#Send testfile to make sure scripts are correctly set up
touch ~/.reports/test.R

# Populate the test file with the output of the whoru script
~/.scripts/identify/whoru >> ~/.reports/test.R

# Test the report submission by sending the test file
echo "${white}${bold}Testing report submission...${reset}"

# if connection lost the script will exit with status 1 and output error message
if sshpass -p $SSHPASS scp ~/.reports/test.R edulution@130.211.93.74:/home/edulution/reports; then
	echo "${green}${bold}Report submitted successfully!${reset}"
	echo "${green}${bold}Scripts have been set up correctly${reset}"
else
	echo "${red}${bold}Something went wrong or internet connection was lost${reset}" 1>&2
	exit 1
fi

# Delete testfile
rm ~/.reports/test.R
