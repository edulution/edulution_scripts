# Import tables and generate filename script
#source('get_dbtables.R',chdir = T)
#source('generate_filename.R',chdir = T)
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

# Simple function to generate filename of csv report in desired format
generate_filename <- function(report,date){
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <- paste("~/reports/",report,device_name,"_numeracy_",date,".csv",sep = "")
}

# Function to get all data in db from beginning of time until month that user specifies
alldata <- function(year_month) {
  #with user input from command line, create complete date by prefixing with 01
  upper_limit <- paste("01-",year_month,sep="")
  #regular expression to check if the user input is a valid month and year, and in the form mm-yy
  regexp <-'((?:(?:[0-2]?\\d{1})|(?:[3][01]{1}))[-:\\/.](?:[0]?[1-9]|[1][012])[-:\\/.](?:(?:\\d{1}\\d{1})))(?![\\d])'
  #check if its a valid date and correct number of characters. stops the program if input not fit
  if(!(grepl(pattern = regexp,x=upper_limit,perl = TRUE)) | (nchar(upper_limit) > 8)) stop("Please enter a valid month and year mm-yy e.g '12-16'")
  # with variable from above date, parse into date and get last day in month then convert into proper date format
  upper_limit <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  # get exercises per user - group userlog rows by user_id then get max last active date and summarize total exercises, exercises complete
  #exercises_per_user <- main_exerciselog %>% filter(upper_limit >= as.Date(latest_activity_timestamp)) %>% group_by(user_id) %>% summarize(exercises_attempted = n(), total_exercises = sum(complete))
  exercises_per_user <- main_exerciselog %>% group_by(user_id) %>% summarize(exercises_attempted = n(), total_exercises = sum(complete))
  #almost the same as query above, except we dont care about anything except total videos watched
  #videos_per_user <- main_videolog %>% filter(upper_limit >= as.Date(latest_activity_timestamp)) %>% group_by(user_id) %>% summarize(total_videos = n())
  videos_per_user <- main_videolog %>% filter(total_seconds_watched > 180) %>% group_by(user_id) %>% summarize(total_videos = n())
  #first summarizes user activity from userlog summary, then produces complete aggregation of data after joining users(r_join),exercises per user,videos per user, facility, group
  complete_summary <- main_userlogsummary %>% group_by(user_id) %>% summarise(total_hours = sum(total_seconds)/3600, total_logins = n(), last_active_date = max(as.Date(last_activity_datetime))) %>% right_join(users, by = c("user_id" = "id")) %>% left_join(exercises_per_user, by = "user_id") %>% left_join(videos_per_user, by = "user_id") %>% left_join(facilities, by = c("facility_id" = "id")) %>% left_join(groups, by = c("group_id" = "id")) %>% mutate(month_end=rep(upper_limit))
  # selecting fields to be written to csv file and changing column names appropriately
  rpt <- complete_summary %>% select(user_id,first_name,last_name,username,name.y,total_logins,total_hours,total_exercises,total_videos,month_end,exercises_attempted,last_active_date) %>% rename(group = name.y, id = user_id) %>% mutate(centre = rep(device_name), month_active = ifelse(total_hours>0, 1, 0), module=rep("numeracy"))
   # Set total exercises and total videos to 0 if total hours is 0
  rpt <- rpt %>% mutate(total_exercises=replace(total_exercises, total_hours == 0, 0)) %>% mutate(total_videos=replace(total_videos, total_hours == 0, 0))
  # create csv file with filename generated by based on name of report and user input
  write.csv(rpt, file = generate_filename("data.all_",year_month) ,col.names = FALSE, row.names = FALSE,na="0")
  #print success messgae
  system("echo Report extracted successfully!")
  #dont save workspace
  quit(save="no")
}

# fetch user input from the command line
input<- commandArgs(TRUE)

# run function with user input as argument
alldata(input)
