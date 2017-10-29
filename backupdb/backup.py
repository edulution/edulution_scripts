# This file should reside in the same directory as the backups i.e ~/backups
import shutil
import datetime
import sqlite3
import os
from os.path import expanduser

ka_database = expanduser("~/.kalite/database/data.sqlite")
timestamp = datetime.datetime.now().strftime("%Y%m%d")
remove_old_backups =expanduser("~/.scripts/backupdb/remove_old_backups.sh")

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

  os.system(remove_old_backups)
  print("Deleting old backups")
  backup_name = device_name + "_" + timestamp +".sqlite"

  # Lock database before getting backup
  c.execute("begin immediate;")

  # Create backup by simply copying the file
  shutil.copyfile(ka_database,backup_name)

  # Unlock db after taking backup
  db.rollback()
  
  # Give user feedback
  print("Creating backup of database...")