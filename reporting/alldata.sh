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

#pull latest changes from master branch in repo
cd ~/.scripts
git reset --hard origin/master > /dev/null
git pull > /dev/null

# Do silent upgrade of all scripts
./upgrade_silent.sh

#check if database file exists before extracting reports
test -f ~/.kalite/database/data.sqlite
#if db file exists then extraction and submission begin. If not, will output error message to contact support
if [ "$?" = "0" ]; then
	if (echo $1 |\
    egrep '^(1[0-2]|0[0-9])[-/][0-9]{2}' > /dev/null
	); then
	   echo Stopping ka lite server 
	   sudo service ka-lite stop > /dev/null
	   sudo service nginx stop > /dev/null
       echo "${green}Extracting all data until $1${reset}"
       echo Checking and fixing students with abnormal hours
       ~/.scripts/reporting/fix_crazy/fixcrazy
       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       Rscript ~/.scripts/reporting/alldata.R "$1"
       # After Rscript executes, execute send report script
       ~/.scripts/reporting/send_report.sh
   else 
       echo "${red}${bold}Please enter a valid month and year e.g 02-17${reset}"
       exit 1 
   fi
else
	echo "${red}${bold}Error. Report NOT extracted. Please contact tech support 1>&2${reset}"
	exit 1
fi
