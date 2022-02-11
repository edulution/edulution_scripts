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
conn <- pool::dbPool(
  pg,
  dbname = db_name,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_passwd
)

# facilityysers
facilityusers <<- conn %>%
  dplyr::tbl("kolibriauth_facilityuser") %>%
  dplyr::collect()

# collections
collections <<- conn %>%
  dplyr::tbl("kolibriauth_collection") %>%
  dplyr::collect()

# memberships
memberships <<- conn %>%
  dplyr::tbl("kolibriauth_membership") %>%
  dplyr::collect()

# roles
roles <<- conn %>%
  dplyr::tbl("kolibriauth_role") %>%
  dplyr::collect()

# get the default facility id and from it get the device name(facility name)
default_facility_id <<- conn %>%
  dplyr::tbl("device_devicesettings") %>%
  dplyr::select(default_facility_id) %>%
  dplyr::collect()

# get module for each channel
channel_module <<- conn %>%
  dplyr::tbl("channel_module") %>%
  dplyr::collect()

# content summary logs
content_summarylogs <<- conn %>%
  dplyr::tbl("logger_contentsummarylog") %>%
  dplyr::collect()

# content session logs
content_sessionlogs <<- conn %>%
  dplyr::tbl("logger_contentsessionlog") %>%
  dplyr::collect()

# get channel content
channel_contents <<- conn %>%
  dplyr::tbl("content_contentnode") %>%
  dplyr::collect()

channel_metadata <<- conn %>%
  dplyr::tbl("content_channelmetadata") %>%
  dplyr::collect()

# clean up and close database connection
pool::poolClose(conn)
