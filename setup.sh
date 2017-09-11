#!/bin/bash
#make files executable
chmod +x reporting/alldata.sh
chmod +x reporting/monthend.sh
chmod +x reporting/send_report.sh
chmod +x reporting/fix_crazy/fixcrazy
chmod +x backupdb/remove_old_backups.sh

#make backups and reports directories if they don't exist
DIRECTORIES=( ~/reports ~/backups )
for DIRECTORY in ${DIRECTORIES[@]}; do
	if [ ! -d "$DIRECTORY" ]; then
		mkdir "$DIRECTORY"
	else
		echo "$DIRECTORY already exists. Skipping this step"
	fi
done

#If backup.py script already exists, replace it with latest version. If not, create it
test -f ~/backups/backup.py
if [ "$?" = "0" ]; then
	rm ~/backups/backup.py
	echo "Removing old backup script"
	cp backupdb/backup.py ~/backups
	echo "Inserting latest backup script"
else
	echo "Backup script doesnt exist. Copying now..."
	cp backupdb/backup.py ~/backups
fi

#If bash aliases already exists, replace it with latest version. If not, create it
cd ~
test -f ~/.bash_aliases
if [ "$?" = "0" ]; then
	echo "Bash aliases file already exists. Replacing with latest version"
	sudo rm .bash_aliases
	echo "Replacing aliases with latest version"
	sudo cp .scripts/.bash_aliases ~
else
	echo "Aliases file does not exist. Inserting latest version"
	sudo cp ~/.scripts/.bash_aliases ~
fi

#test if upgrade script exists. If not add it
test -f ~/upgrade
if [ "$?" = "0" ]; then
	echo "Upgrade script already exists. Replacing with latest version"
	sudo rm upgrade
	echo "Replacing upgrade script with latest version"
	sudo cp .scripts/upgrade ~
else
	echo "Upgrade script does not exist. Inserting it now"
	sudo cp ~/.scripts/upgrade ~
fi

#reduce idle session timeout to 12.5 minutes
~/.scripts/config/reduce_session_timeout

#Send testfile to make sure scripts are correctly set up
touch ~/reports/test.R
echo "Testing report submission..."
sshpass -p $SSHPASS scp ~/reports/test.R edulution@130.211.93.74:/home/edulution/reports

# if connection lost the script will exit with status 1 and output error message
if [ "$?" = "0" ]; then
	echo "Report submitted successfully!"
	echo "Everything has been set up correctly"
else
	echo Something went wrong or internet connection was lost 1>&2
	exit 1
fi
