#!/bin/sh
cd ~/reports
#check reports folder for file most recently created from monthend or alldata and send to google server
sshpass -p "*ismahan" scp `ls ~/reports -t | head -n1` edulution@130.211.93.74:/home/edulution/reports
# if connection lost the script will exit with status 1 and output error message
if [ "$?" = "0" ]; then
	echo Report submitted successfully!
else
	echo Report not submitted. Please check your internet connection and try again 1>&2
	exit 1
fi

