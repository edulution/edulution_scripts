suppressMessages(library(DBI))
suppressMessages(library(RPostgreSQL))

# Get database credentials from environment variables
db_name = Sys.getenv("KOLIBRI_DATABASE_NAME")
db_host = Sys.getenv("KOLIBRI_DATABASE_HOST")
db_user = Sys.getenv("KOLIBRI_DATABASE_USER")
db_passwd = Sys.getenv("KOLIBRI_DATABASE_PASSWORD")
db_port = Sys.getenv("KOLIBRI_DATABASE_PORT")

# connect to Kolibri database 
pg <- dbDriver("PostgreSQL")
conn <-  dbConnect(
  pg,
  dbname = db_name,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_passwd)

#facilityysers
facilityusers <- dbGetQuery(conn,"SELECT * FROM kolibriauth_facilityuser")

#collections
collections <- dbGetQuery(conn,"SELECT * FROM kolibriauth_collection")

#memberships
memberships <- dbGetQuery(conn,"SELECT * FROM kolibriauth_membership")

#roles
roles <- dbGetQuery(conn,"SELECT * FROM kolibriauth_role")

#get the default facility id and from it get the device name(facility name)
default_facility_id <- dbGetQuery(conn,"SELECT default_facility_id FROM device_devicesettings")

# get module for each channel
channel_module <- dbGetQuery(conn,"select * from channel_module")

#content summary logs
content_summarylogs <- dbGetQuery(conn,"select * from logger_contentsummarylog")

#content session logs
content_sessionlogs <- dbGetQuery(conn,"select * from logger_contentsessionlog")

#get channel content
channel_contents <- dbGetQuery(conn,"select * from content_contentnode")

channel_metadata <- dbGetQuery(conn,"select * from content_channelmetadata")

#clean up and close database connection
dbDisconnect(conn)