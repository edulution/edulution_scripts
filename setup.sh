#!/bin/sh
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x reporting/fix_crazy/fixcrazy
chmod +x backupdb/remove_old_backups.sh


#make backups directory
mkdir ~/backups
# copy backup script to backups directory
cp backup.py ~/backups

#make reports directory
mkdir ~/reports

#Update bash aliases
cd ~
sudo rm .bash_aliases
sudo cat newaliases > .bash_aliases

#Send testfile to make sure scripts are correctly set up
touch ~/reports/test.R
sshpass -p $SSHPASS scp ~/reports/test.R edulution@130.211.93.74:/home/edulution/reports
# if connection lost the script will exit with status 1 and output error message
if [ "$?" = "0" ]; then
	echo Report submitted successfully!
	echo Everything has been set up correctly
else
	echo Something went wrong or internet connection was lost 1>&2
	exit 1
fi
