#!/usr/bin/env python
import sqlite3
from os.path import expanduser
import subprocess

ka_database = expanduser("~/.kalite/database/data.sqlite")
#get top 3 lines of git log to get id and date of most recent commit
latest_update = subprocess.check_output("cd ..;git log | head -n 3", shell=True)

# connect to kalite database file
db = sqlite3.connect(ka_database)
c = db.cursor()

#get device name and version from kalite database
results = c.execute(""" 
select d.name,version from securesync_device d
join securesync_devicemetadata s
where s.device_id = d.id
and s.is_own_device = 1 """)
for row in results:
       device = row[0]
       version = row[1]

#Print device name, version, and most recent commit to screen
print 'Device:', device
print 'Version:', version
print 'Latest Update:', latest_update

