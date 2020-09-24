# Check if session logs exist for the dates supplied, and for all time
check_sessionlogs <- function(sessionlogs, dates, device_name, all_time = F) {
  year_month <- dates$year_month
  month_start <- dates$month_start
  month_end <- date$month_end
  
  
  if(all_time == T){
    # If all_time is set to True, check all session logs until the month_end supplied
    num_logs <- nrow(
      sessionlogs %>%
        filter(end_timestamp <= month_end)
    )
  }else{
    # If all_time is not set
    # Get check the session logs in the dates between month start and month end
    num_logs <- nrow(
      sessionlogs %>%
        filter(
          start_timestamp >= month_start,
          end_timestamp <= month_end)
    )
  }
  
  # If no session logs were found
  if (num_logs == 0) {
    # print a message to the console
    # return the list of users with all other fields blank
    system("echo No learner activity found for the dates supplied")
    system("echo Sending list of users instead")
    
    # Get the list of users
    report <- users
    # Add columns for first name and last name using helper functions
    report$first_name <- sapply(report$full_name, get_first_name)
    report$last_name <- sapply(report$full_name, get_last_name)
    
    report <- report %>%
      # convert id column from uuid to character string
      mutate(id = str_replace_all(id, '-', '')) %>%
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
    write.csv(
      report,
      file = generate_filename("monthend_", year_month, device_name),
      col.names = FALSE,
      row.names = FALSE,
      na = "0"
    )
    quit(save = "no")
  }
}