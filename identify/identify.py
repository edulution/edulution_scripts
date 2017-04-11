#!/usr/bin/env python
import sqlite3
#import version
from os.path import expanduser


ka_database = expanduser("~/.kalite/database/data.sqlite")
id_file = expanduser("~/.scripts/identify/id.txt")

if __name__ == '__main__':
    db = sqlite3.connect(ka_database)
    c = db.cursor()
    results = c.execute(""" 
select d.name from securesync_device d
join securesync_devicemetadata s
where s.device_id = d.id
and s.is_own_device = 1 """)
    for row in results:
       device = row[0]

    version = max([tuple(map(int, v.split('.'))) for v in version.VERSION_INFO.keys()])
    print 'Device:', device
    print 'Version:', '.'.join(map(str, version))

    with open(id_file) as idfile:
       lines = map(lambda s: s.strip(), idfile.readlines())
       for row in lines:
           if len(row) > 0:
              print row
