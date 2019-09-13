import os
import psycopg2
import pkg_resources
import subprocess

# get database connection credentials from environment variables
dbname = os.environ['KOLIBRI_DATABASE_NAME']
dbpass = os.environ['KOLIBRI_DATABASE_PASSWORD']
dbuser = os.environ['KOLIBRI_DATABASE_USER']
dbhost = os.environ['KOLIBRI_DATABASE_HOST']
dbport = os.environ['KOLIBRI_DATABASE_PORT']

# create a connection to the database using the credentials gathered
conn = psycopg2.connect(dbname = dbname,user=dbuser,password=dbpass,host=dbhost,port=dbport)
curr = conn.cursor()
curr.execute("""select name from kolibriauth_collection where id = (select default_facility_id from device_devicesettings)""")
res = curr.fetchall()
facility_name = res[0][0]

# get kolibri version
kolibri_version = pkg_resources.get_distribution("kolibri").version

# get top 3 lines of git log to get latest scripts update
latest_update = subprocess.check_output("cd ~/.scripts;git log | head -n 4", shell=True)

# print out the facility name, kolibri version, and latest update
print 'Device:', facility_name
print 'Version:', kolibri_version
print 'Last Updated:', latest_update