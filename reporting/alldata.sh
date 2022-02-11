#!/bin/bash

#pull latest changes from master branch in repo
cd ~/.scripts || exit
git reset --hard origin/south_africa > /dev/null
git pull origin south_africa > /dev/null

# Do silent upgrade of all scripts
./upgrade_silent.sh

# check if postgresql is running before attempting to extract a report
function check_process_running () {
ps_out=$(ps -ef | grep "$1" | grep -v 'grep' | grep -v "$0")
result=$(echo "$ps_out" | grep "$1")
if [[ "$result" != "" ]];then
    echo "Running"
else
    echo "Not Running"
fi
}


psql_running=$( check_process_running postgresql )

if [[ "$psql_running" == 'Running' ]];then
  if (echo "$1" |\
    grep -E '^(1[0-2]|0[0-9])[-/][0-9]{2}' > /dev/null
  ); then
     echo Stopping Kolibri server 
     python -m kolibri stop > /dev/null
     sudo service nginx stop > /dev/null
       echo "${GREEN}Extracting data for month $1${RESET}"
       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       Rscript ~/.scripts/reporting/alldata.R "$1"
       # After Rscript executes, execute send report script
       ~/.scripts/reporting/send_report.sh
   else 
       echo "${RED}${BOLD}Please enter a valid month and year e.g 02-17${RESET}"
       exit 1 
   fi
else
    echo "${RED}${BOLD}Error. Report NOT extracted. Please contact tech support 1>&2${RESET}"
    exit 1
fi