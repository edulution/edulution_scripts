#!/bin/bash

#pull latest changes from master branch in repo
cd ~/.scripts
git reset --hard origin/zambia > /dev/null
git pull origin zambia > /dev/null

# Do silent upgrade of all scripts
./upgrade_silent.sh

# check if postgresql is running before attempting to extract a report
ps_out=`ps -ef | grep $1 | grep -v 'grep' | grep -v $0`
result=$(echo $ps_out | grep "$1")

if [[ "$result" != "" ]];then
	if (echo $1 |\
    egrep '^(1[0-2]|0[0-9])[-/][0-9]{2}' > /dev/null
	); then
	   echo Stopping ka lite server 
	   sudo service ka-lite stop > /dev/null
	   sudo service nginx stop > /dev/null
       echo "${green}Extracting all data until $1${reset}"
       #echo Checking and fixing students with abnormal hours
       #~/.scripts/reporting/fix_crazy/fixcrazy
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
