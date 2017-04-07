#!/bin/sh
#check if database file exists before extracting reports
test -f ~/.kalite/database/data.sqlite
#if db file exists then extraction and submission begin. If not, will output error message to contact support
if [ "$?" = "0" ]; then
	if (echo $1 |\
    egrep '^(1[0-2]|0[0-9])[-/][0-9]{2}' > /dev/null
	); then
	   echo Stopping ka lite server 
	   sudo service ka-lite stop
	   sudo service nginx stop
       echo "Extracting data for month $1"
       echo Checking and fixing students with abnormal hours
       ~/fixcrazy
       echo Beginning report extraction.....
       # fetch the first argument given on the command line and use it as an argument to the Rscript
       Rscript ~/month_end_scripts/monthend.R "$1"
       # After Rscript executes, execute send report script
       ~/month_end_scripts/send_report.sh
   else 
       echo Please enter a valid year and month e.g 02-17
       exit 1 
   fi
else
	echo Error. Report NOT extracted. Please contact tech support 1>&2
	exit 1
fi