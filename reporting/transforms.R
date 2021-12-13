#' Get total time spent by each user between month start and month end
#'
#' @param sessionlogs A dataframe of contentsessionlogs
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_time_spent_by_user <- function(sessionlogs, lower_lim, upper_lim) {
  time_spent_by_user <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim
    ) %>%
    group_by(user_id) %>%
    summarize(total_hours = sum(time_spent) / 3600)

  print(paste(
    "Sucessfully retrieved time spent by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(time_spent_by_user)
}

#' Get the number of distinct days a user logged in using the start_timestamp date only
#'
#' @param sessionlogs 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_logins_by_user <- function(sessionlogs, lower_lim, upper_lim) {
  logins_by_user <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim
    ) %>%
    distinct(user_id, start_date_only) %>%
    count(user_id, name = "total_logins")

  print(paste(
    "Sucessfully retrieved logins by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(logins_by_user)
}


#' Get the total number of completed exercises and videos between month start and month end
#'
#' @param sessionlogs 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_completed_ex_vid_count <- function(sessionlogs, lower_lim, upper_lim) {
  completed_ex_vid_count <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim,
      progress >= 0.99
    ) %>%
    count(user_id, kind, name = "count") %>%
    check_completed_ex_vid_count()

  print(paste(
    "Sucessfully retrieved exercises and videos completed by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(completed_ex_vid_count)
}


#' Get total time spent by channel
#'
#' @param sessionlogs 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_time_by_channel <- function(sessionlogs, lower_lim, upper_lim) {
  time_by_channel <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim
    ) %>%
    group_by(user_id, channel_id) %>%
    summarise(total_time = sum(time_spent) / 3600) %>%
    pivot_wider(names_from = channel_id, values_from = total_time) %>% 
    rename_at(
      vars(-user_id),
      function(x) {
        paste0(x, "_playlist_timespent")
      }
    ) %>%
    ungroup()

  print(paste(
    "Sucessfully retrieved total time by channel by user between",
    lower_lim,
    "and",
    upper_lim
  ))


  return(time_by_channel)
  # result of above is a data frame
  # time spent on each channel as a separate column with the channel id as the column name

  # change column names which are channel_ids from channel_ids to readable course names
  # using the named vector created outside the function
  # names(time_by_channel) <- c("user_id",recode(names(time_by_channel)[-1],!!!course_name_id))
}


#' Get exercises and videos completed for each channel
#'
#' @param sessionlogs 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_ex_vid_by_channel <- function(sessionlogs, lower_lim, upper_lim) {
  ex_vid_by_channel <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim,
      progress >= 0.99
    ) %>%
    group_by(user_id, channel_id) %>%
    count(user_id, kind, name = "count") %>%
    unite("act_channel", c(channel_id, kind)) %>%
    pivot_wider(names_from = act_channel, values_from = count) %>%
    rename_at(
      vars(-user_id),
      function(x) {
        str_replace(x, "_exercise", "_playlist_exercise") %>%
          str_replace("_video", "_playlist_video") %>%
          str_replace("_document", "_playlist_document")
      }
    ) %>%
    ungroup()

  print(paste(
    "Sucessfully retrieved exercises and videos by channel by user between",
    lower_lim,
    "and",
    upper_lim
  ))


  return(ex_vid_by_channel)
}


#' Get total_progress by channel_id for all time
#'
#' @param sessionlogs 
#'
#' @return
#' @export
#'
#' @examples
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
    pivot_wider(names_from = channel_id, values_from = pct_progress) %>%
    rename_at(
      vars(-user_id),
      function(x) {
        paste0(x, "_playlist_progress")
      }
    ) %>%
    ungroup()

  print("Sucessfully retrieved summary channel progress by user")

  return(prog_by_user_by_channel)
}


#' Summary timespent and progress by topic and content kind for all time
#'
#' @param summarylogs 
#' @param topics 
#' @param topic_nodes_count 
#'
#' @return
#' @export
#'
#' @examples
get_summary_act_by_topic <- function(summarylogs, topics, topic_nodes_count) {
  summary_act_by_topic <- summarylogs %>%
    left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    unite(
      "topic_act_type",
      c("channel_id", "topic_id", "kind"),
      sep = "_"
    ) %>%
    group_by(user_id, topic_act_type) %>%
    summarise(
      topic_act_timespent = sum(time_spent),
      topic_act_totalprog = sum(progress)
    ) %>%
    ungroup() %>%
    left_join(
      topic_nodes_count,
      by = c("topic_act_type" = "channel_topic_kind")
    ) %>%
    mutate(
      topic_act_progpct = topic_act_totalprog / nodes_count
    ) %>%
    # Only get user_id, topic_act_type and progpct
    select(
      user_id,
      topic_act_type,
      topic_act_progpct
    ) %>%
    replace_na(list(topic_act_progpct = 0L))

  print("Sucessfully retrieved summary activity by topic")

  return(summary_act_by_topic)
}



#' Get summary of time spent by topic for each user
#'
#' @param sessionlogs 
#' @param topics 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_month_summary_time_by_topic <- function(sessionlogs, topics, lower_lim, upper_lim) {
  month_summary_time_by_topic <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim
    ) %>%
    left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    unite(
      "topic_act_type",
      c("channel_id", "topic_id", "kind"),
      sep = "_"
    ) %>%
    group_by(user_id, topic_act_type) %>%
    summarise(
      topic_act_timespent = sum(time_spent) / 3600
    ) %>%
    ungroup() %>%
    mutate(topic_act_type = str_c(
      # Add the word time spent to topic_act_type
      topic_act_type, "timespent"
    )) %>%
    pivot_wider(names_from = topic_act_type, values_from = topic_act_timespent)

  print(paste(
    "Sucessfully retrieved summary_progress by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(month_summary_time_by_topic)
}



#' Get summary of exercises done and videos watched by each user
#'
#' @param sessionlogs 
#' @param topics 
#' @param lower_lim 
#' @param upper_lim 
#'
#' @return
#' @export
#'
#' @examples
get_month_summary_exvid_by_topic <- function(sessionlogs, topics, lower_lim, upper_lim) {
  month_summary_exvid_by_topic <- sessionlogs %>%
    filter(
      start_timestamp >= lower_lim,
      end_timestamp <= upper_lim,
      progress >= 0.99
    ) %>%
    left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    unite(
      "topic_act_type",
      c("channel_id", "topic_id", "kind"),
      sep = "_"
    ) %>%
    count(user_id, topic_act_type, name = "num_completed") %>%
    ungroup() %>%
    mutate(topic_act_type = str_c(
      # Add the word completed to topic_act_type
      topic_act_type, "completed"
    )) %>%
    pivot_wider(names_from = topic_act_type, values_from = num_completed)

  print(paste(
    "Sucessfully retrieved summary exercises and videos by topic by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(month_summary_exvid_by_topic)
}
