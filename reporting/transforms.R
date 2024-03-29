#' Get total time spent by each user between month start and month end
#'
#' @param sessionlogs A \code{data.frame} of ContentSessionlogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range#'
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_time_spent_by_user <- function(sessionlogs, lower_lim, upper_lim) {
  time_spent_by_user <- sessionlogs %>%
    dplyr::mutate(
      start_timestamp = as.Date(start_timestamp),
      end_timestamp = as.Date(end_timestamp)
    ) %>%
    dplyr::filter(
      between(start_timestamp, lower_lim, upper_lim),
      between(end_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarize(total_hours = sum(time_spent) / 3600)

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
#' @param usersessionlogs A \code{data.frame} of UserSessionlogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return
#' @export
#'
#' @examples
get_logins_by_user <- function(usersessionlogs, lower_lim, upper_lim) {
  logins_by_user <- usersessionlogs %>%
    dplyr::mutate(
      start_timestamp = as.Date(start_timestamp),
      last_interaction_timestamp = as.Date(last_interaction_timestamp)
    ) %>%
    dplyr::filter(
      between(start_timestamp, lower_lim, upper_lim),
      between(last_interaction_timestamp, lower_lim, upper_lim)
    ) %>%
    mutate(start_date_only = strftime(start_timestamp, "%Y-%m-%d")) %>%
    dplyr::distinct(user_id, start_date_only) %>%
    dplyr::count(user_id, name = "total_logins")

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
#' @param summarylogs A \code{data.frame} of ContentSummarylogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_completed_ex_vid_count <- function(summarylogs, lower_lim, upper_lim) {
  completed_ex_vid_count <- summarylogs %>%
    dplyr::mutate(
      completion_timestamp = as.Date(completion_timestamp)
    ) %>%
    dplyr::filter(
      between(completion_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::count(user_id, kind, name = "count") %>%
    check_completed_ex_vid_count()

  print(paste(
    "Sucessfully retrieved exercises and videos completed by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(completed_ex_vid_count)
}


#' Get number of unique attempted exercise and videos between a date range
#'
#' @param sessionlogs A \code{data.frame} of the ContentSessionlogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
get_attempted_ex_vid_count <- function(sessionlogs, lower_lim, upper_lim) {
  attempted_ex_vid_count <- sessionlogs %>%
    dplyr::mutate(
      start_timestamp = as.Date(start_timestamp),
      end_timestamp = as.Date(end_timestamp)
    ) %>%
    dplyr::filter(
      between(start_timestamp, lower_lim, upper_lim),
      between(end_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::distinct(content_id, .keep_all = T) %>%
    dplyr::count(user_id, kind, name = "count") %>%
    check_completed_ex_vid_count()

  print(paste(
    "Sucessfully retrieved exercises and videos completed by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(attempted_ex_vid_count)
}

#' Get total time spent by channel
#'
#' @param sessionlogs A \code{data.frame} of ContentSessionlogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_time_by_channel <- function(sessionlogs, lower_lim, upper_lim) {
  time_by_channel <- sessionlogs %>%
    dplyr::mutate(
      start_timestamp = as.Date(start_timestamp),
      end_timestamp = as.Date(end_timestamp)
    ) %>%
    dplyr::filter(
      between(start_timestamp, lower_lim, upper_lim),
      between(end_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::group_by(user_id, channel_id) %>%
    dplyr::summarise(total_time = sum(time_spent) / 3600) %>%
    tidyr::pivot_wider(
      names_from = channel_id,
      names_glue = "{channel_id}_playlist_timespent",
      values_from = total_time,
      values_fill = 0
    ) %>%
    dplyr::ungroup()

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
#' @param summarylogs A \code{data.frame} of ContentSummarylogs
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_ex_vid_by_channel <- function(summarylogs, lower_lim, upper_lim) {
  ex_vid_by_channel <- summarylogs %>%
    dplyr::mutate(
      completion_timestamp = as.Date(completion_timestamp)
    ) %>%
    dplyr::filter(
      between(completion_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::count(user_id, channel_id, kind, name = "count") %>%
    tidyr::pivot_wider(
      names_from = c(channel_id, kind),
      names_glue = "{channel_id}_playlist_{kind}",
      values_from = count,
      values_fill = 0
    )

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
#' @param sessionlogs A \code{data.frame} of ContentSessionlogs
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_prog_by_user_by_channel <- function(sessionlogs) {
  prog_by_user_by_channel <- sessionlogs %>%
    dplyr::group_by(user_id, channel_id, content_id) %>%
    dplyr::summarise(max_prog = max(progress)) %>%
    dplyr::group_by(user_id, channel_id) %>%
    dplyr::summarise(total_prog = sum(max_prog)) %>%
    # join total prog by channel to number of items by channel
    # used to get percent progress in channel
    dplyr::left_join(num_contents_by_channel) %>%
    # create a column for the percent progress by channel
    dplyr::mutate(pct_progress = total_prog / total_items) %>%
    # get rid of the columns for total prog and total_items
    # turn the progress for each channel into a separate column
    dplyr::select(-c(total_prog, total_items)) %>%
    tidyr::pivot_wider(
      names_from = channel_id,
      names_glue = "{channel_id}_playlist_progress",
      values_from = pct_progress,
      values_fill = 0
    ) %>%
    dplyr::ungroup()

  print("Sucessfully retrieved summary channel progress by user")

  return(prog_by_user_by_channel)
}


#' Summary timespent and progress by topic and content kind for all time
#'
#' @param summarylogs A \code{data.frame} of ContentSummarylogs
#' @param topics A \code{data.frame} of the topics, from the get_topics \code{function}
#' @param topic_nodes_count A \code{data.frame} of the topic_nodes_count, from the get_topic_nodes_count \code{function}
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_summary_act_by_topic <- function(summarylogs, topics, topic_nodes_count) {
  summary_act_by_topic <- summarylogs %>%
    dplyr::left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    tidyr::unite(
      "topic_act_type",
      c("channel_id", "topic_id", "kind"),
      sep = "_"
    ) %>%
    dplyr::group_by(user_id, topic_act_type) %>%
    dplyr::summarise(
      topic_act_timespent = sum(time_spent),
      topic_act_totalprog = sum(progress)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(
      topic_nodes_count,
      by = c("topic_act_type" = "channel_topic_kind")
    ) %>%
    dplyr::mutate(
      topic_act_progpct = topic_act_totalprog / nodes_count
    ) %>%
    # Only get user_id, topic_act_type and progpct
    dplyr::select(
      user_id,
      topic_act_type,
      topic_act_progpct
    ) %>%
    tidyr::pivot_wider(names_from = topic_act_type, values_from = topic_act_progpct, values_fill = 0)

  print("Sucessfully retrieved summary activity by topic")

  return(summary_act_by_topic)
}



#' Get summary of time spent by topic for each user
#'
#' @param sessionlogs A \code{data.frame} of ContentSessionlogs
#' @param topics A \code{data.frame} of the topics, from the get_topics \code{function}
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_month_summary_time_by_topic <- function(sessionlogs, topics, lower_lim, upper_lim) {
  month_summary_time_by_topic <- sessionlogs %>%
    dplyr::mutate(
      start_timestamp = as.Date(start_timestamp),
      end_timestamp = as.Date(end_timestamp)
    ) %>%
    dplyr::filter(
      between(start_timestamp, lower_lim, upper_lim),
      between(end_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    tidyr::unite(
      "topic_act_type",
      c("channel_id", "topic_id", "kind"),
      sep = "_"
    ) %>%
    dplyr::group_by(user_id, topic_act_type) %>%
    dplyr::summarise(
      topic_act_timespent = sum(time_spent) / 3600
    ) %>%
    dplyr::ungroup() %>%
    tidyr::pivot_wider(
      names_from = topic_act_type,
      names_glue = "{topic_act_type}timespent",
      values_from = topic_act_timespent,
      values_fill = 0
    )

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
#' @param sessionlogs A \code{data.frame} of ContentSessionlogs
#' @param topics A \code{data.frame} of the topics, from the get_topics \code{function}
#' @param lower_lim Lower bound of date range
#' @param upper_lim Upper bound of date range
#'
#' @return A \code{data.frame}
#' @export
#'
#' @examples
get_month_summary_exvid_by_topic <- function(summarylogs, topics, lower_lim, upper_lim) {
  month_summary_exvid_by_topic <- summarylogs %>%
    dplyr::mutate(
      completion_timestamp = as.Date(completion_timestamp)
    ) %>%
    dplyr::filter(
      between(completion_timestamp, lower_lim, upper_lim)
    ) %>%
    dplyr::left_join(
      topics,
      by = c("content_id", "channel_id", "kind")
    ) %>%
    dplyr::count(
      user_id,
      channel_id,
      topic_id, kind,
      name = "num_completed"
    ) %>%
    tidyr::pivot_wider(
      names_from = c(channel_id, topic_id, kind),
      names_glue = "{channel_id}_{topic_id}_{kind}completed",
      values_from = num_completed,
      values_fill = 0
    )

  print(paste(
    "Sucessfully retrieved summary exercises and videos by topic by user between",
    lower_lim,
    "and",
    upper_lim
  ))

  return(month_summary_exvid_by_topic)
}
