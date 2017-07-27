# Get all relevant database tables from ka database

#prevent displaying warning messages from script on console(errors will still show)
options(warn=-1)
#suppress messages when loading package
suppressMessages(library(timeDate))
library(plyr)
#suppress messages when loading package
suppressMessages(library(dplyr))
library(RSQLite)


# connect to KA database 
sqlite <- dbDriver("SQLite")
dbfile <- "~/.kalite/database/data.sqlite"
conn <- dbConnect(sqlite, dbfile)

#get users
users_query <- dbSendQuery(conn,"SELECT * FROM securesync_facilityuser where(deleted == 0 and is_teacher == 0)")
  #filter out deleted users and coaches, then select only columns needed for joins later in script
users <- dbFetch(users_query) %>% select(id,username,first_name,last_name,group_id,facility_id)

#get facilities - All centres have only 1 facility on centralserver except CI
facility_query <- dbSendQuery(conn,"SELECT * FROM securesync_facility")
  #
facilities <- dbFetch(facility_query) %>% select(id,name)

#get main_videolog
groups_query <- dbSendQuery(conn,"SELECT * FROM securesync_facilitygroup")
groups <- dbFetch(groups_query) %>% select(id,name,facility_id)

#get main_userlogsummary - The most important table for month end reports. Contains user login time for each login
ulogsummary_query <- dbSendQuery(conn,"SELECT * FROM main_userlogsummary")
main_userlogsummary <- dbFetch(ulogsummary_query) %>% filter(deleted == 0)

#get main_userlog
ulog_query <- dbSendQuery(conn,"SELECT * FROM main_userlog")
main_userlog <- dbFetch(ulog_query)

#get main_exerciselog
elog_query <- dbSendQuery(conn,"SELECT * FROM main_exerciselog")
main_exerciselog <- dbFetch(elog_query) %>% filter(deleted == 0)

#get main_videolog
vlog_query <- dbSendQuery(conn,"SELECT * FROM main_videolog")
main_videolog <- dbFetch(vlog_query) %>% filter(deleted == 0)

#get device name
#device name derived by getting id of own device from metadata, then joining to devices config table
device_query <- dbSendQuery(conn,"SELECT * FROM securesync_device")
device <- dbFetch(device_query) %>% select(id,name)

meta_query <- dbSendQuery(conn,"SELECT * FROM securesync_devicemetadata")
device_meta <- dbFetch(meta_query) %>% select(id,device_id,is_own_device)

device_name <- device_meta %>% filter(is_own_device == 1) %>% left_join(device,by=c("device_id" = "id"))
device_name <- substring(device_name$name,1,3)

#clean up and close database connection
dbDisconnect(conn)
