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


# connect to Kolibri database 
pg <- dbDriver("PostgreSQL")
db_name = Sys.getenv("KOLIBRI_DATABASE_NAME")
db_host = Sys.getenv("KOLIBRI_DATABASE_HOST")
db_user = Sys.getenv("KOLIBRI_DATABASE_USER")
db_passwd = Sys.getenv("KOLIBRI_DATABASE_PASSWORD")
db_port = Sys.getenv("KOLIBRI_DATABASE_PORT")

# create database connections
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

# get total num_contents for specific channel id)
#as.integer(num_items_by_channel[num_items_by_channel$channel_id=='3d6c9d72-a2e0-47d4-b7a0-ed20699e1b1f',"total_items"])

# Simple function to generate filename of csv report in desired format
generate_filename <- function(report,date){
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <- paste("~/.reports/",report,device_name,"_numeracy_",date,".csv",sep = "")
}

# Function to get data extract only for month that user inputs
monthend <- function(year_month) {
  #with user input from command line, create complete date by prefixing with 01
  upper_limit <- paste("01-",year_month,sep="")
  #regular expression to check if the user input is a valid month and year, and in the form mm-yy
  regexp <-'((?:(?:[0-2]?\\d{1})|(?:[3][01]{1}))[-:\\/.](?:[0]?[1-9]|[1][012])[-:\\/.](?:(?:\\d{1}\\d{1})))(?![\\d])'
  #check if its a valid date and correct number of characters. stops the program if input not fit
  if(!(grepl(pattern = regexp,x=upper_limit,perl = TRUE)) | (nchar(upper_limit) > 8)) stop("Please enter a valid month and year mm-yy e.g 02-17")
  
  # get month start and month end as correctly formatted strings
  month_end <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  month_start <- as.Date(timeFirstDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  
  #get total time spent by each user between month start and month end
  time_spent_by_user <- content_sessionlogs %>% filter(start_timestamp >= month_start & end_timestamp <= month_end) %>% group_by(user_id) %>% summarize(total_hours = sum(time_spent)/3600)
  
  # get the number of distinct days a user logeed in using the start_timestamp date only
  logins_by_user <- content_sessionlogs %>% filter(start_timestamp >= month_start & end_timestamp <= month_end) %>% distinct(user_id,start_date_only) %>% group_by(user_id) %>% summarize(total_logins = n())
  
  # get the total number of completed exercises and videos between month start and month end
  completed_ex_vid_count <- content_sessionlogs %>% filter(start_timestamp >= month_start, end_timestamp <= month_end, progress >= 0.99) %>% group_by(user_id,kind) %>% summarize(count = n())
  
  # transpose the rows into columns by user_id
  # exercise and video counts become columns
  completed_ex_vid_count <- tidyr::spread(completed_ex_vid_count,kind,count)
  
  # rename the columns to read total_exercises, total_videos
  if("video" %in% colnames(completed_ex_vid_count)){
    completed_ex_vid_count <- completed_ex_vid_count %>% rename(total_exercises = exercise, total_videos = video)
  }
  else{
    completed_ex_vid_count <- completed_ex_vid_count %>% rename(total_exercises = exercise) %>% mutate(total_videos = 0)
  }
  
  # get total time spent by channel
  time_by_channel <- content_sessionlogs %>% filter(start_timestamp >= month_start & end_timestamp <= month_end) %>% group_by(user_id,channel_id) %>% summarise(total_time = sum(time_spent)/3600) %>% spread(channel_id, total_time)
  # this produces a data frame with time spent on each channel as a separate column with the channel id as the column name
  
  # change column names which are channel_ids from channel_ids to readable course names
  # using the named vector created outside the function
  names(time_by_channel) <- c("user_id",recode(names(time_by_channel)[-1],!!!course_name_id))
  
  # get total_progress by channel_id (no need to filter for the month requested)
  prog_by_user_by_channel <- content_sessionlogs %>% group_by(user_id,channel_id,content_id) %>% summarise(max_prog = max(progress)) %>% group_by(user_id,channel_id) %>% summarise(total_prog=sum(max_prog))
  
  # join total prog by channel to number of items by channel. used to get percent progress in channel
  prog_by_user_by_channel <- prog_by_user_by_channel %>% left_join(num_contents_by_channel)
  
  # create a column for the percent progress by channel
  prog_by_user_by_channel <- prog_by_user_by_channel %>% mutate(pct_progress = total_prog/total_items)
  
  # get rid of the columns for total prog and total_items then turn the progress for each channel into a separate column
  prog_by_user_by_channel <- prog_by_user_by_channel %>% select(-c(total_prog,total_items)) %>% spread(channel_id, pct_progress)
  
  # change the column names to be the name of the channel + _progress
  names(prog_by_user_by_channel) <- c("user_id",recode(names(prog_by_user_by_channel)[-1],!!!course_name_id_progress))
  
  # everything together to make a complete report
  rpt <- users %>% left_join(time_spent_by_user,by=c("id"="user_id")) %>% left_join(completed_ex_vid_count,by=c("id"="user_id")) %>% left_join(logins_by_user,by=c("id"="user_id")) %>% left_join(time_by_channel,by=c("id"="user_id")) %>% left_join(prog_by_user_by_channel,by=c("id"="user_id")) %>% left_join(learners_and_groups,by=c("id"="user_id"))
  
  # add month active, module, and centre by mutation
  rpt <- rpt %>% mutate(month_active = ifelse(total_hours>0, 1, 0), module=rep("numeracy"), centre=rep(device_name))

  # Set total exercises and total videos to 0 if total hours is 0
  rpt <- rpt %>% mutate(total_exercises=replace(total_exercises, total_hours == 0, 0)) %>% mutate(total_videos=replace(total_videos, total_hours == 0, 0), month_end=rep(strftime(month_end,"%Y-%m-%d")))

  #derive the first name and last name columns using helper functions
  rpt$first_name <- sapply(rpt$full_name,get_first_name)
  rpt$last_name <- sapply(rpt$full_name,get_last_name)

  # convert id column from uuid to character string
  rpt <- rpt %>% mutate(id = str_replace_all(id,'-',''))

  #reorder columns. put familiar columns first
  rpt <- rpt %>% select(c(id, first_name, last_name, username, group, total_hours, total_exercises, total_videos, month_end, centre, last_login, month_active, module, total_logins),everything())
  
  #Write report to csv
  write.csv(rpt, file = generate_filename("monthend_",year_month) ,col.names = FALSE, row.names = FALSE,na="0")
  system("echo Report extracted successfully!")
  quit(save="no")
}


input<- commandArgs(TRUE)

monthend(input)
