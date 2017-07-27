#!/usr/bin/env python
# Script to restore learner flagged as deleted in database

import sqlite3
from os.path import expanduser

ka_database = expanduser("~/.kalite/database/data.sqlite")
#get top 3 lines of git log to get id and date of most recent commit
#latest_update = subprocess.check_output("cd ..;git log | head -n 3", shell=True)

# connect to kalite database file
db = sqlite3.connect(ka_database)
c = db.cursor()
#get user input to get username of learner to restore
learner_to_restore = str(raw_input("Please enter the username of the learner to restore:"))

#get device name and version from kalite database
def restore_learner(learner):
	c.execute("update securesync_facilityuser set deleted = 0 where username = '%s'" % learner)
	db.commit()
	print("Learner restored successfully!\n Please restart the server for changes to take effect")
#Print device name, version, and most recent commit to screen
restore_learner(learner_to_restore)
