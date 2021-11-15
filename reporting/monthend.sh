#!/bin/bash

# Pull latest changes from master branch in repo
cd ~/.scripts || exit
git reset --hard origin/south_africa > /dev/null
git pull origin south_africa > /dev/null

# Do silent upgrade of all scripts
./upgrade_silent.sh > /dev/null

# Check if postgresql is running before attempting to extract a report
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

       # Delete any loose csv files in the reports directory before extraction
       cd ~/.reports
       find . -type f \( -name "*.csv" \) -exec rm {} \;

       echo "${GREEN}Extracting data for month $1${RESET}"
       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       cd ~/.scripts/reporting || exit
       Rscript monthend.R "$1"

       # After Rscript executes, execute send report script
       ~/.scripts/reporting/send_report.sh
       
       # submit baseline tests for the selected month
       ~/.baseline_testing/scripts/reporting/baseline.sh "$1"

       # Pull latest changes to baseline system
       ~/.scripts/upgrade_baseline.sh
   else 
       echo "${RED}Please enter a valid year and month e.g 02-17${RESET}"
       exit 1 
   fi
else
	echo "${RED}${BOLD}Error. Report NOT extracted. Please contact tech support ${RESET}" 1>&2
	exit 1
fi
