# Import tables and generate filename script
#source('get_dbtables.R',chdir = T)
#source('generate_filename.R',chdir = T)
#prevent displaying warning messages from script on console(errors will still show)

# clear workspace
rm(list=ls())

options(warn=-1)
#suppress messages when loading package
suppressMessages(library(timeDate))

suppressMessages(library(tidyr))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))

# load new packages for kolibri data extraction
suppressMessages(library(tools))
suppressMessages(library(gsubfn))

# load postgresql library
suppressMessages(library(DBI))
suppressMessages(library(RPostgreSQL))



# connect to Kolibri database 
pg <- dbDriver("PostgreSQL")
db_name = Sys.getenv("KOLIBRI_DATABASE_NAME")
db_host = Sys.getenv("KOLIBRI_DATABASE_HOST")
db_user = Sys.getenv("KOLIBRI_DATABASE_USER")
db_passwd = Sys.getenv("KOLIBRI_DATABASE_PASSWORD")
db_port = Sys.getenv("KOLIBRI_DATABASE_PORT")

conn <-  dbConnect(pg, dbname=db_name, host = db_host, port = db_port, user=db_user, password=db_passwd)

# dev: connect to RPI database
conn <-  dbConnect(pg, dbname="kolibri", host = "192.168.100.130", port = 5432, user="kolibri", password="kolibri")


#facilityysers
facilityusers <- dbGetQuery(conn,"SELECT * FROM kolibriauth_facilityuser")

#collections
collections <- dbGetQuery(conn,"SELECT * FROM kolibriauth_collection")

#memberships
memberships <- dbGetQuery(conn,"SELECT * FROM kolibriauth_membership")

#roles
roles <- dbGetQuery(conn,"SELECT * FROM kolibriauth_role")


#filter out admins and coaches to get list of users
users <- facilityusers %>% filter(!id %in% roles$user_id)

#get the default facility id and from it get the device name(facility name)
default_facility_id <- dbGetQuery(conn,"SELECT default_facility_id FROM device_devicesettings")
default_facility_id <- default_facility_id$default_facility_id

facility_name <- collections %>% filter(id == default_facility_id) %>% select(name)
device_name <- facility_name$name

# get module for each channel
channel_module <- dbGetQuery(conn,"select * from channel_module")

#content session logs
content_sessionlogs <- dbGetQuery(conn,"select * from logger_contentsessionlog")

#get channel content
channel_contents <- dbGetQuery(conn,"select * from content_contentnode")

channel_metadata <- dbGetQuery(conn,"select * from content_channelmetadata")

#clean up and close database connection
dbDisconnect(conn)

# Simple function to generate filename of csv report in desired format
generate_filename <- function(report,date){
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <- paste("~/reports/",report,device_name,"_numeracy_",date,".csv",sep = "")
}

# Function to get data extract only for month that user inputs
monthend <- function(year_month) {
  #with user input from command line, create complete date by prefixing with 01
  upper_limit <- paste("01-",year_month,sep="")
  #regular expression to check if the user input is a valid month and year, and in the form mm-yy
  regexp <-'((?:(?:[0-2]?\\d{1})|(?:[3][01]{1}))[-:\\/.](?:[0]?[1-9]|[1][012])[-:\\/.](?:(?:\\d{1}\\d{1})))(?![\\d])'
  #check if its a valid date and correct number of characters. stops the program if input not fit
  if(!(grepl(pattern = regexp,x=upper_limit,perl = TRUE)) | (nchar(upper_limit) > 8)) stop("Please enter a valid month and year mm-yy e.g 02-17")
  # with variable from above date, parse into date and get last day in month then convert into proper date format
  upper_limit <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  
  # Need to get end of month in standard format for monthend column in final csv file
  monthend_column <- upper_limit
  
  # get month start and month end as correctly formatted strings
  month_end <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  month_start <- as.Date(timeFirstDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  
  #get total time spent by each user between month start and month end
  time_spent_by_user <- content_sessionlogs %>% filter(start_timestamp >= month_start & end_timestamp <= month_end) %>% group_by(user_id) %>% summarize(total_hours = sum(time_spent))
  
  # get the total number of completed exercises and videos between month start and month end
  completed_ex_vid_count <- content_sessionlogs %>% filter(start_timestamp >= month_start, end_timestamp <= month_end, progress >= 0.99) %>% group_by(user_id,kind) %>% summarize(count = n())
  
  # transpose the rows into columns by user_id
  # exercise and video counts become columns
  completed_ex_vid_count <- tidyr::spread(completed_ex_vid_count,count,kind)

  #summary of total hours by learner between month start and month end
  summary_rpt <- content_sessionlogs %>% filter(start_timestamp >= month_start & end_timestamp <= month_end) %>% group_by(user_id) %>% summarize(total_hours = sum(time_spent))
  
  complete_summary <- main_userlogsummary %>% filter(grepl(upper_limit,last_activity_datetime)) %>% group_by(user_id) %>% summarise(total_hours = sum(total_seconds)/3600, last_active_date = max(as.Date(last_activity_datetime))) %>% right_join(users, by = c("user_id" = "id")) %>% left_join(exercises_per_user, by = "user_id") %>% left_join(videos_per_user, by = "user_id") %>% left_join(facilities, by = c("facility_id" = "id")) %>% left_join(groups, by = c("group_id" = "id"))%>% mutate(month_end=rep(monthend_column))
  rpt <- complete_summary %>% select(user_id,first_name,last_name,username,name.y,total_hours,total_exercises,total_videos,month_end,exercises_attempted,name.x,last_active_date) %>% rename(centre = name.x, group = name.y, id = user_id) %>% mutate(month_active = ifelse(total_hours>0, 1, 0), module=rep("numeracy"))
  # Set total exercises and total videos to 0 if total hours is 0
  rpt <- rpt %>% mutate(total_exercises=replace(total_exercises, total_hours == 0, 0)) %>% mutate(total_videos=replace(total_videos, total_hours == 0, 0))
  rpt <- merge(rpt,id_login)
  
  #Write report to csv
  write.csv(rpt, file = generate_filename("monthend_",year_month) ,col.names = FALSE, row.names = FALSE,na="0")
  system("echo Report extracted successfully!")
  quit(save="no")
}


input<- commandArgs(TRUE)

monthend(input)