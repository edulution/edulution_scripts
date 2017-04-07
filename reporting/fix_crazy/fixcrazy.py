#!/usr/bin/env python
import sqlite3
from os.path import expanduser

ka_database = expanduser("~/.kalite/database/data.sqlite")
crazyhours_log = expanduser("~/.scripts/reporting/fix_crazy/crazyhours.txt")

if __name__ == '__main__':
    db = sqlite3.connect(ka_database)
    c = db.cursor()
    c.execute('''SELECT l.start_datetime, u.username, f.name, l.total_seconds
FROM
	main_userlogsummary l
	JOIN securesync_facilityuser u ON u.id = l.user_id
	JOIN securesync_facilitygroup f ON f.id = u.group_id
WHERE l.total_seconds > 720000''')
    results = c.fetchall()
    c.execute("UPDATE main_userlogsummary SET total_seconds = 54000 WHERE total_seconds>720000")
    db.commit()
	
#keep log of students with abnormal hours	
    crazies = open(crazyhours_log,'w')
    for row in results:
	    crazies.write(str(row))
		
    print str(len(results)) +" record(s) corrected"
	