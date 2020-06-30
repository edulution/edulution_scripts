# Clear workspace
rm(list=ls())

# Source helper functions
source("helpers.R")
source("get_db_tables.R")
source("preproc_tables.R")

# Prevent displaying warning messages from script on console(errors will still show)
options(warn=-1)

# Suppress messages when loading packages
suppressMessages(library(timeDate))
suppressMessages(library(tidyr))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(tools))
suppressMessages(library(gsubfn))
suppressMessages(library(stringr))


# Function to check if userlogs exist for the current month
check_content_logs_in_curr_month <- function(year_month,month_start,month_end){
  # Get the number of sessionlogs in the dates between month start and month end
  num_logs <- nrow(content_sessionlogs %>%
    filter(
      start_timestamp >= month_start,
      end_timestamp <= month_end
      )
    )

  # If no sessionlogs were found
  if(num_logs == 0){
    # print a message to the console
    # return the list of users with all other fields blank
    system("echo No learner activity found for the requested month")
    system("echo Sending list of users instead")

    # Get the list of users
    report <- users
    # Add columns for first name and last name using helper functions
    report$first_name <- sapply(report$full_name,get_first_name)
    report$last_name <- sapply(report$full_name,get_last_name)

    report <- report %>%
      # convert id column from uuid to character string
      mutate(
        id = str_replace_all(id,'-','')
        ) %>%
      # Add columns for month_end and device name
      # Add other required columns and set to 0
      mutate(
        total_hours = 0,
        total_exercises = 0,
        total_videos = 0,
        month_end = month_end,
        centre = device_name,
        month_active = 0,
        module = '',
        total_logins = 0
        ) %>%
      # Put the columns in order
      # Familiar columns first and everything else at the end
      select(
        id,
        first_name,
        last_name,
        username,
        total_hours,
        total_exercises,
        total_videos,
        month_end,
        centre,
        last_login,
        month_active,
        module,
        total_logins,
        everything()
        )

    # Write to csv and exit the script
    write.csv(report, file = generate_filename("monthend_",year_month) ,col.names = FALSE, row.names = FALSE,na="0")
    quit(save="no")
  }
}

check_completed_ex_vid_count <- function(summary_df){
  # check if exercises and videos have been completed
  if(nrow(summary_df) == 0){
    # if no exercises and videos were completed
    system("echo no exercises or videos have been completed")
    # print a message to the console to inform the user

    # create a df and populate it with zeroes on user_id, total_exercises, total_videos
    zeroes <- data.frame(users$id,rep(0,nrow(users)),rep(0,nrow(users)))
    names(zeroes) <- c('user_id','total_exercises','total_videos')

    summary_df <- zeroes


  }else{
    # transpose the rows into columns by user_id
    # exercise and video counts become columns
    summary_df <- tidyr::spread(summary_df,kind,count)
    
    # rename the columns to read total_exercises, total_videos
    
    if("exercise" %in% colnames(summary_df)){
     summary_df <- summary_df %>% rename(total_exercises = exercise) 
    } else{
      summary_df <- summary_df %>% mutate(total_exercises = 0)
    }

    if("video" %in% colnames(summary_df)){
     summary_df <- summary_df %>% rename(total_videos = video) 
    } else{
      summary_df <- summary_df %>% mutate(total_videos = 0)
    }
    
  }
  return(summary_df)
}


# Function to get data extract only for month that user inputs
monthend <- function(year_month) {
  # With user input from the command line, create complete date by prefixing with 01
  upper_limit <- paste("01-",year_month,sep="")
  
  # Check if the user input is a valid month and year, and in the form mm-yy
  check_date_valid(upper_limit)
    
  # Get month start and month end as correctly formatted strings
  month_end <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  month_start <- as.Date(timeFirstDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))

  # Check if content logs exist between the month start and month end
  check_content_logs_in_curr_month(year_month,month_start,month_end)
    
  # Get total time spent by each user between month start and month end
  time_spent_by_user <- content_sessionlogs %>%
    filter(
      start_timestamp >= month_start,
      end_timestamp <= month_end
      ) %>%
    group_by(user_id) %>%
    summarize(total_hours = sum(time_spent)/3600)
    
  # Get the number of distinct days a user logeed in using the start_timestamp date only
  logins_by_user <- content_sessionlogs %>%
    filter(
      start_timestamp >= month_start,
      end_timestamp <= month_end
      ) %>%
    distinct(user_id,start_date_only) %>%
    count(user_id, name = "total_logins")
    
  # Get the total number of completed exercises and videos between month start and month end
  completed_ex_vid_count <- content_sessionlogs %>%
    filter(
      start_timestamp >= month_start,
      end_timestamp <= month_end,
      progress >= 0.99
      ) %>%
    count(user_id,kind, name = "count") %>%
    check_completed_ex_vid_count()

  # get total time spent by channel
  time_by_channel <- content_sessionlogs %>%
    filter(
      start_timestamp >= month_start,
      end_timestamp <= month_end
      ) %>%
    group_by(user_id,channel_id) %>%
    summarise(total_time = sum(time_spent)/3600) %>%
    spread(channel_id, total_time)
  # result of above is a data frame
  # time spent on each channel as a separate column with the channel id as the column name
  
  # change column names which are channel_ids from channel_ids to readable course names
  # using the named vector created outside the function
  names(time_by_channel) <- c("user_id",recode(names(time_by_channel)[-1],!!!course_name_id))
  
  # get total_progress by channel_id for all time
  prog_by_user_by_channel <- content_sessionlogs %>%
    group_by(user_id,channel_id,content_id) %>%
    summarise(max_prog = max(progress)) %>%
    group_by(user_id,channel_id) %>%
    summarise(total_prog=sum(max_prog)) %>%
    # join total prog by channel to number of items by channel
    # used to get percent progress in channel
    left_join(num_contents_by_channel) %>%
    # create a column for the percent progress by channel
    mutate(pct_progress = total_prog/total_items) %>%
    # get rid of the columns for total prog and total_items
    # turn the progress for each channel into a separate column
    select(-c(total_prog,total_items)) %>%
    spread(channel_id, pct_progress)
  
  # change the column names to be the name of the channel + _progress
  names(prog_by_user_by_channel) <- c("user_id",recode(names(prog_by_user_by_channel)[-1],!!!course_name_id_progress))
  
  # everything together to make a complete report
  #rpt <- users %>% left_join(time_spent_by_user,by=c("id"="user_id")) %>% left_join(completed_ex_vid_count,by=c("id"="user_id")) %>% left_join(logins_by_user,by=c("id"="user_id")) %>% left_join(time_by_channel,by=c("id"="user_id")) %>% left_join(prog_by_user_by_channel,by=c("id"="user_id")) %>% left_join(learners_and_groups,by=c("id"="user_id"))
  rpt <- users %>%
    left_join(time_spent_by_user,by=c("id"="user_id")) %>%
    left_join(completed_ex_vid_count,by=c("id"="user_id")) %>%
    left_join(logins_by_user,by=c("id"="user_id")) %>%
    left_join(time_by_channel,by=c("id"="user_id")) %>%
    left_join(prog_by_user_by_channel,by=c("id"="user_id")) %>%
  # add month active, module, and centre by mutation
    mutate(
      month_active = ifelse(total_hours>0, 1, 0),
      module=rep("numeracy")
      ) %>%
  # Set total exercises and total videos to 0 if total hours is 0
    mutate(total_exercises=replace(total_exercises, total_hours == 0, 0)) %>%
    mutate(
      total_videos=replace(total_videos, total_hours == 0, 0),
      month_end=rep(strftime(month_end,"%Y-%m-%d"))
    )

  # Derive the first name and last name columns using helper functions
  rpt$first_name <- sapply(rpt$full_name,get_first_name)
  rpt$last_name <- sapply(rpt$full_name,get_last_name)

  # Convert id column from uuid to character string
  rpt <- rpt %>%
    mutate(id = str_replace_all(id,'-','')) %>%
    # Reorder columns. put familiar columns first
    select(
      id,
      first_name,
      last_name,
      username,
      centre,
      total_hours,
      total_exercises,
      total_videos,
      month_end,
      last_login,
      month_active,
      module,
      total_logins,
      everything()
    )
  
  # Write report to csv
  write.csv(
    rpt,
    file = generate_filename("monthend_",year_month),
    col.names = FALSE,
    row.names = FALSE,
    na="0"
  )
  system("echo Report extracted successfully!")
  quit(save="no")
}


# select only the name of the group and the user_id
if(nrow(learners_and_groups) == 0){
  learners_and_groups$user_id <- users$user_id
  learners_and_groups$group <- rep('ungrouped',nrow(learners_and_groups))
} else{
  learners_and_groups <- learners_and_groups %>%
    select(c(name,user_id)) %>%
    rename(group = name)
}

#create column in content_sessionlogs of start_timestamp with date only which will be used to get number of logins
if(nrow(content_sessionlogs) == 0){
  system("echo No session logs found")
  system("echo Sending list of users instead")
  report <- users
  report$first_name <- sapply(report$full_name,get_first_name)
  report$last_name <- sapply(report$full_name,get_last_name)

  report <- report %>% mutate(id = str_replace_all(id,'-',''))
  write.csv(report, file = generate_filename("users_",Sys.Date()) ,col.names = FALSE, row.names = FALSE,na="0")
  quit(save="no")
} else{
  content_sessionlogs <- content_sessionlogs %>% mutate(start_date_only = strftime(start_timestamp,"%Y-%m-%d"))
}


input<- commandArgs(TRUE)

monthend(input)
