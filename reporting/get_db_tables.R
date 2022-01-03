suppressMessages(library(DBI))
suppressMessages(library(pool))
suppressMessages(library(dplyr))
suppressMessages(library(dbplyr))
suppressMessages(library(RPostgres))

# Get database credentials from environment variables
db_name <- Sys.getenv("KOLIBRI_DATABASE_NAME")
db_host <- Sys.getenv("KOLIBRI_DATABASE_HOST")
db_user <- Sys.getenv("KOLIBRI_DATABASE_USER")
db_passwd <- Sys.getenv("KOLIBRI_DATABASE_PASSWORD")
db_port <- Sys.getenv("KOLIBRI_DATABASE_PORT")

# connect to Kolibri database
pg <- RPostgres::Postgres()
conn <- dbPool(
  pg,
  dbname = db_name,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_passwd
)

# facilityysers
facilityusers <<- conn %>%
  tbl("kolibriauth_facilityuser") %>%
  collect()

# collections
collections <<- conn %>%
  tbl("kolibriauth_collection") %>%
  collect()

# memberships
memberships <<- conn %>%
  tbl("kolibriauth_membership") %>%
  collect()

# roles
roles <<- conn %>%
  tbl("kolibriauth_role") %>%
  collect()

# get the default facility id and from it get the device name(facility name)
default_facility_id <<- conn %>%
  tbl("device_devicesettings") %>%
  select(default_facility_id) %>%
  collect()

# get module for each channel
channel_module <<- conn %>%
  tbl("channel_module") %>%
  collect()

# content summary logs
content_summarylogs <<- conn %>%
  tbl("logger_contentsummarylog") %>%
  collect()

# content session logs
content_sessionlogs <<- conn %>%
  tbl("logger_contentsessionlog") %>%
  collect()

# get channel content
channel_contents <<- conn %>%
  tbl("content_contentnode") %>%
  collect()

channel_metadata <<- conn %>%
  tbl("content_channelmetadata") %>%
  collect()

# clean up and close database connection
poolClose(conn)
