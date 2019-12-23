# Import tables and generate filename script
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
suppressMessages(library(stringr))


# helper function to get last name
get_last_name <- function(full_name) {
  # if the full name is blank or there is only one name
  if(nchar(full_name) == 0 || length(strsplit(full_name,' ')[[1]]) == 1){
    last_name <- ''  
  }
  
  else{
    last_name <- paste(strsplit(full_name,' ')[[1]][-1],collapse = ' ')
  }
  return(last_name)
}

# helper function to get first name
get_first_name <- function(full_name) {
  
  if(nchar(full_name) == 0 || length(strsplit(full_name,' ')[[1]]) == 1){
    first_name <- ''  
  }
  else{
    first_name <- paste(strsplit(full_name,' ')[[1]][1],collapse = ' ')
  }
  return(toString(first_name))
}


# Get database credentials from environment variables
db_name = Sys.getenv("KOLIBRI_DATABASE_NAME")
db_host = Sys.getenv("KOLIBRI_DATABASE_HOST")
db_user = Sys.getenv("KOLIBRI_DATABASE_USER")
db_passwd = Sys.getenv("KOLIBRI_DATABASE_PASSWORD")
db_port = Sys.getenv("KOLIBRI_DATABASE_PORT")

# connect to Kolibri database 
pg <- dbDriver("PostgreSQL")
conn <-  dbConnect(pg, dbname=db_name, host = db_host, port = db_port, user=db_user, password=db_passwd)

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

#content session logs
content_sessionlogs <- dbGetQuery(conn,"select * from logger_contentsessionlog")

#get channel content
channel_contents <- dbGetQuery(conn,"select * from content_contentnode")

channel_metadata <- dbGetQuery(conn,"select * from content_channelmetadata")

#clean up and close database connection
dbDisconnect(conn)


#get the default facility id and from it get the device name(facility name)
default_facility_id <- default_facility_id$default_facility_id

facility_name <- collections %>% filter(id == default_facility_id) %>% select(name)
device_name <- facility_name$name


#filter out admins and coaches to get list of users
# select only the relevant columns
users <- facilityusers %>% filter(!id %in% roles$user_id) %>% select(id,full_name,username,date_joined,last_login)

#join collections to memberships. (used for getting user groups)
memberships <- memberships %>% left_join(collections,by=c("collection_id"= "id"))

# get dataframe containing learners and groups they belong to
learners_and_groups <- memberships %>% filter(kind == 'learnergroup') %>% distinct(user_id,.keep_all = TRUE) %>% select(c(name,user_id))

# select only the name of the group and the user_id
learners_and_groups <- learners_and_groups %>% select(c(name,user_id)) %>% rename(group = name)

#create column in content_sessionlogs of start_timestamp with date only which will be used to get number of logins
content_sessionlogs <- content_sessionlogs %>% mutate(start_date_only = strftime(start_timestamp,"%Y-%m-%d"))

#join channel metadata to channel_module
channel_metadata <- channel_metadata %>% left_join(channel_module,by=c("id" = "channel_id"))
# create new column with module and abbreviated playlist name
channel_metadata <- channel_metadata %>% mutate(abbr_name = paste(module,'_',abbreviate(name)))

#create new column with abbr name and the word progress which will be used as the column name for channel progress in final report
channel_metadata <- channel_metadata %>% mutate(abbr_name_progress = paste(abbr_name,'_progress'))

#create named vector with channel_ids and abbreviated playlist names
course_name_id <- unlist(channel_metadata$abbr_name)
names(course_name_id) <- unlist(channel_metadata$id)

#create named vector with abbr_name_progress and make the channel ids the names of each of the elements
course_name_id_progress <- unlist(channel_metadata$abbr_name_progress)
names(course_name_id_progress) <- unlist(channel_metadata$id)

#get number of content items by channel.used to compute overall progress in channel
#filter 
num_contents_by_channel <- channel_contents %>% filter(!kind %in% c('topic','channel')) %>% group_by(channel_id) %>% summarise(total_items = n())


# Simple function to generate filename of csv report in desired format
generate_filename <- function(report,date){
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <- paste("~/.reports/",report,device_name,"_numeracy_",date,".csv",sep = "")
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

  # convert id column from uuid to character string
  rpt <- rpt %>% mutate(id = str_replace_all(id,'-',''))

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
