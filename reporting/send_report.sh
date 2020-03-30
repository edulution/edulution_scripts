#!/bin/bash

# Go into reports folder
cd ~/.reports || exit
#check reports folder for file most recently created from monthend or alldata and send to google server

# if connection lost the script will exit with status 1 and output error message
if sshpass -p "$SSHPASS" scp "$( ls ~/.reports -t | head -n1 )" edulution@130.211.93.74:/home/edulution/reports; then
	echo "${GREEN}${BOLD}Report submitted successfully!${RESET}"
else
	echo "${RED}${BOLD}Report not submitted. Please check your internet connection and try again 1>&2${RESET}"
	exit 1
fi

# Execute script tp semd db errorlog to cloud
#~/.scripts/backupdb/send_errorlog

