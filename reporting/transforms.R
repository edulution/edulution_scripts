# Get total time spent by each user between month start and month end
get_time_spent_by_user <- function(sessionlogs, lower_lim, upper_lim) {
    time_spent_by_user <- sessionlogs %>%
      filter(start_timestamp >= lower_lim,
             end_timestamp <= upper_lim) %>%
      group_by(user_id) %>%
      summarize(total_hours = sum(time_spent) / 3600)
    
    return(time_spent_by_user)
}

# Get the number of distinct days a user logged in using the start_timestamp date only
get_logins_by_user <- function(sessionlogs, lower_lim, upper_lim) {
  logins_by_user <- sessionlogs %>%
    filter(start_timestamp >= lower_lim,
           end_timestamp <= upper_lim) %>%
    distinct(user_id, start_date_only) %>%
    count(user_id, name = "total_logins")
  
  return(logins_by_user)
}


# Get the total number of completed exercises and videos between month start and month end
get_completed_ex_vid_count <- function(sessionlogs) {
  completed_ex_vid_count <- sessionlogs %>%
    filter(start_timestamp >= lower_lim,
           end_timestamp <= upper_lim,
           progress >= 0.99) %>%
    count(user_id, kind, name = "count") %>%
    check_completed_ex_vid_count()
  
  return(completed_ex_vid_count)
}


# get total time spent by channel
get_time_by_channel <- function(sessionlogs, lower_lim, upper_lim) {
    time_by_channel <- sessionlogs %>%
      filter(start_timestamp >= lower_lim,
             end_timestamp <= upper_lim) %>%
      group_by(user_id, channel_id) %>%
      summarise(total_time = sum(time_spent) / 3600) %>%
      spread(channel_id, total_time) %>%
      rename_at(vars(-user_id),
                function(x)
                  paste0(x, "_playlist_timespent")) %>%
      ungroup()
    
    return(time_by_channel)
    # result of above is a data frame
    # time spent on each channel as a separate column with the channel id as the column name
    
    # change column names which are channel_ids from channel_ids to readable course names
    # using the named vector created outside the function
    # names(time_by_channel) <- c("user_id",recode(names(time_by_channel)[-1],!!!course_name_id))
    
  }


# Get exercises and videos completed for each channel
get_ex_vid_by_channel <- function(sessionlogs, lower_lim, upper_lim) {
  ex_vid_by_channel <- sessionlogs %>%
    filter(start_timestamp >= lower_lim,
           end_timestamp <= upper_lim,
           progress >= 0.99) %>%
    group_by(user_id, channel_id) %>%
    count(user_id, kind, name = "count") %>%
    unite("act_channel", c(channel_id, kind)) %>%
    spread(act_channel, count) %>%
    rename_at(vars(-user_id),
              function(x)
                str_replace(x, "_exercise", "_playlist_exercise") %>%
                str_replace("_video", "_playlist_video") %>%
                str_replace("_document", "_playlist_document")) %>%
    ungroup()
  
  return(ex_vid_by_channel)
}


# get total_progress by channel_id for all time
get_prog_by_user_by_channel <- function(sessionlogs) {
  prog_by_user_by_channel <- sessionlogs %>%
    group_by(user_id, channel_id, content_id) %>%
    summarise(max_prog = max(progress)) %>%
    group_by(user_id, channel_id) %>%
    summarise(total_prog = sum(max_prog)) %>%
    # join total prog by channel to number of items by channel
    # used to get percent progress in channel
    left_join(num_contents_by_channel) %>%
    # create a column for the percent progress by channel
    mutate(pct_progress = total_prog / total_items) %>%
    # get rid of the columns for total prog and total_items
    # turn the progress for each channel into a separate column
    select(-c(total_prog, total_items)) %>%
    spread(channel_id, pct_progress) %>%
    rename_at(vars(-user_id),
              function(x)
                paste0(x, "_playlist_progress")) %>%
    ungroup()
  
  return(prog_by_user_by_channel)
}