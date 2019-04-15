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

#replace old host key with new one
#~/.scripts/config/replace_host_key.sh

#pull latest changes from master branch in repo
cd ~/.scripts
git reset --hard origin/master > /dev/null
git pull origin master > /dev/null

#Do silent upgrade of all scripts
./upgrade_silent.sh > /dev/null

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
       echo "${green}Extracting data for month $1${reset}"
       echo Checking and fixing students with abnormal hours
       ~/.scripts/reporting/fix_crazy/fixcrazy       

       echo Deleting learners from Zarchive group
       ~/.scripts/config/delete_zarchive

       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       Rscript ~/.scripts/reporting/monthend.R "$1"
       # After Rscript executes, execute send report script
       ~/.scripts/reporting/send_report.sh
       
       # submit baseline tests for the selected month
       ~/.baseline_testing/scripts/reporting/baseline.sh $1
       
 	
       # Pull latest changes to baseline system
       ~/.scripts/upgrade_baseline.sh
       
       # Remote support setup
       #~/.scripts/remote_support_setup.sh > /dev/null
   else 
       echo "${red}Please enter a valid year and month e.g 02-17${reset}"
       exit 1 
   fi
else
	echo "${red}${bold}Error. Report NOT extracted. Please contact tech support 1>&2${reset}"
	exit 1
fi
