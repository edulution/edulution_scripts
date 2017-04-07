#!/usr/bin/env python
import sqlite3
import datetime
import shutil
import os
from os.path import expanduser

ka_database = expanduser("~/.kalite/database/data.sqlite")
sync_command = "kalite manage syncmodels --verbose"
stop_server_command = "sudo service nginx stop"
stop_ka_command = "sudo service ka-lite stop"
timestamp = datetime.datetime.now().strftime("%Y%m%d")

# connect to database and create cursor
db = sqlite3.connect(ka_database)
c = db.cursor()  

if __name__ == '__main__':
  def get_device_name():
        device_data = c.execute("SELECT d.name FROM securesync_device d JOIN securesync_devicemetadata s WHERE s.device_id = d.id AND s.is_own_device = 1")
        for row in device_data:
          device_name = row[0]

        return device_name
# get device name
  device_name = get_device_name()
  print("Device name is: "+ device_name)
# stop ka-lite and nginx before any operations
  os.system(stop_ka_command)
  os.system(stop_server_command)
  print ("Stopping KA Lite server...")
# make backup of database with timestamp
  backup_name = device_name + "_" + timestamp
  shutil.copyfile(ka_database,backup_name)
  print("Creating backup of database...")
# create attemptlog_dump table
  create_attemptlog_dump = "CREATE TABLE if not exists attemptlog_dump (context_id varchar(100) NOT NULL, response_log text NOT NULL, signed_by_id varchar(32), seed integer NOT NULL, id varchar(32) NOT NULL UNIQUE, user_id varchar(32) NOT NULL, version varchar(100) NOT NULL, correct bool NOT NULL, signed_version integer NOT NULL, complete bool NOT NULL, deleted bool NOT NULL, timestamp datetime NOT NULL, assessment_item_id varchar(100) NOT NULL, response_count integer NOT NULL, zone_fallback_id varchar(32), time_taken integer, language varchar(8) NOT NULL, context_type varchar(20) NOT NULL, counter integer, points integer NOT NULL, exercise_id varchar(200) NOT NULL, signature varchar(360), answer_given text NOT NULL)"
  c.execute(create_attemptlog_dump)
  print ("Creating attemptlog_dump...")
#insert all rows from main_attemptlog into attemptlog_dump
  c.execute("INSERT OR IGNORE INTO attemptlog_dump SELECT * FROM main_attemptlog")
  print ("Inserting into attemptlog_dump...")
#delete all rows from main_attemptlog
  c.execute("DELETE FROM main_attemptlog")
  print ("Deleting main_attemptlog...")
#delete all contentratings
  c.execute("DELETE FROM main_contentrating")
  print ("Deleting contentrating...")
  db.commit()
#sync the database
  os.system(sync_command)
#replace all rows from attemptlog_dump to main_attemptlog
  c.execute("INSERT OR IGNORE INTO main_attemptlog SELECT * FROM attemptlog_dump")
  print ("Replacing main_attemptlog...")
#drop attemptlog_dump
  c.execute("DROP TABLE attemptlog_dump")
  print ("Dropping attemptlog_dump...")
  print ("SYNCING COMPLETE!")
  db.commit()





