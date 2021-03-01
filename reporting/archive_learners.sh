#!/bin/bash

# Check if postgresql is running before attempting to extract a Archive Learner report
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
       echo "${GREEN}Extracting data for Archive Learner $1${RESET}"

       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       cd ~/.scripts/reporting || exit
       Rscript archive_learners.R "$1"

        # After Rscript executes, execute send report script
        # ~/.scripts/reporting/send_report.sh

        # Send Archive Learner Report
        ~/.scripts/reporting/send_archive_learner_report.sh
       
       # submit baseline tests for the selected month
       # ~/.baseline_testing/scripts/reporting/archive_baseline.sh "$1"

    #    # Pull latest changes to baseline system
    #    ~/.scripts/upgrade_baseline.sh
   else 
       echo "${RED}Please enter a valid  Archive Learners month${RESET}"
       exit 1 
   fi
else
	echo "${RED}${BOLD}Error. Report NOT extracted Archive Learners. Please contact tech support ${RESET}" 1>&2
	exit 1
fi
