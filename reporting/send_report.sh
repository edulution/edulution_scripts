#!/bin/bash

#colors
#=======
export black=`tput setaf 0`
export red=`tput setaf 1`
export green=`tput setaf 2`
export yellow=`tput setaf 3`
export blue=`tput setaf 4`
export magenta=`tput setaf 5`
export cyan=`tput setaf 6`
export white=`tput setaf 7`

# reset to default bash text style
export reset=`tput sgr0`

# make actual text bold
export bold=`tput bold`

# make background color on text
export bold_mode=`tput smso`

# remove background color on text
export exit_bold_mode=`tput rmso`


# Go into reports folder
cd ~/.reports
#check reports folder for file most recently created from monthend or alldata and send to google server
sshpass -p $SSHPASS scp `ls ~/.reports -t | head -n1` edulution@130.211.93.74:/home/edulution/reports
# if connection lost the script will exit with status 1 and output error message
if [ "$?" = "0" ]; then
	echo "${green}${bold}Report submitted successfully!${reset}"
else
	echo "${red}${bold}Report not submitted. Please check your internet connection and try again 1>&2${reset}"
	exit 1
fi

# Execute script tp semd db errorlog to cloud
#~/.scripts/backupdb/send_errorlog

