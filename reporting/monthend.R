# Clear work space
rm(list = ls())

# Load libraries
suppressMessages(library(timeDate))
suppressMessages(library(tidyr))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(tools))
suppressMessages(library(gsubfn))
suppressMessages(library(stringr))
suppressMessages(library(rebus))
suppressMessages(library(dbhelpers))

# Source helper functions
source("helpers.R")
source("get_db_tables.R")
source("preproc_tables.R")
source("preproc_topics.R")
source("check_completed_ex_vid_count.R")
source("check_sessionlogs.R")
source("transforms.R")
source("process_dateinput.R")

# Prevent displaying warning messages from script on console(errors will still show)
options(warn = -1)

#' Function to get data extract only for month that user inputs
#'
#' @param dates 
#' @param sessionlogs 
#' @param summarylogs 
#' @param topics 
#' @param device_name 
#' @param include_coach_content 
#'
#' @return
#' @export
#'
#' @examples
monthend <- function(dates, sessionlogs, summarylogs, topics, device_name, include_coach_content = FALSE) {
  # Get the dates needed from the dates vector supplied
  year_month <- dates$year_month
  month_start <- dates$month_start
  month_end <- dates$month_end

  # Add start_date_only to session logs
  if (isTRUE(include_coach_content)) {
    sessionlogs <- sessionlogs %>%
      dplyr::mutate(start_date_only = strftime(start_timestamp, "%Y-%m-%d"))
  } else {
    sessionlogs <- sessionlogs %>%
      dplyr::filter(!content_id %in% coach_content$id) %>%
      dplyr::mutate(start_date_only = strftime(start_timestamp, "%Y-%m-%d"))

    summarylogs <- summarylogs %>%
      dplyr::filter(!content_id %in% coach_content$id)
  }


  # Get total time spent by each user between month start and month end
  time_spent_by_user <- get_time_spent_by_user(sessionlogs, month_start, month_end)

  # Get the number of distinct days a user logeed in using the start_timestamp date only
  logins_by_user <- get_logins_by_user(sessionlogs, month_start, month_end)

  # Get the total number of completed exercises and videos between month start and month end
  completed_ex_vid_count <- get_completed_ex_vid_count(sessionlogs, month_start, month_end)

  # get total time spent by channel
  time_by_channel <- get_time_by_channel(sessionlogs, month_start, month_end)

  # Get exercises and videos completed for each channel
  ex_vid_by_channel <- get_ex_vid_by_channel(sessionlogs, month_start, month_end)

  # get total_progress by channel_id for all time
  prog_by_user_by_channel <- get_prog_by_user_by_channel(sessionlogs)

  # Exercises and videos completed by topic for the dates supplied
  month_summary_exvid_by_topic <- get_month_summary_exvid_by_topic(
    sessionlogs,
    topics,
    month_start,
    month_end
  )

  # Time spent by topic for the dates supplied
  month_summary_time_by_topic <- get_month_summary_time_by_topic(
    sessionlogs,
    topics,
    month_start,
    month_end
  )

  # change the column names to be the name of the channel + _progress
  # names(prog_by_user_by_channel) <- c("user_id",recode(names(prog_by_user_by_channel)[-1],!!!course_name_id_progress))

  # Join all of the transformations together by user_id to make a complete report
  rpt <- users %>%
    left_join(time_spent_by_user, by = c("id" = "user_id")) %>%
    left_join(completed_ex_vid_count, by = c("id" = "user_id")) %>%
    left_join(logins_by_user, by = c("id" = "user_id")) %>%
    left_join(time_by_channel, by = c("id" = "user_id")) %>%
    left_join(prog_by_user_by_channel, by = c("id" = "user_id")) %>%
    left_join(ex_vid_by_channel, by = c("id" = "user_id")) %>%
    left_join(month_summary_exvid_by_topic, by = c("id" = "user_id")) %>%
    left_join(month_summary_time_by_topic, by = c("id" = "user_id")) %>%
    # add month active, module, and centre by mutation
    mutate(
      month_active = ifelse(total_hours > 0, 1, 0),
      module = rep("numeracy")
    ) %>%
    # Set total exercises and total videos to 0 if total hours is 0
    mutate(total_exercises = replace(total_exercises, total_hours == 0, 0)) %>%
    mutate(
      total_videos = replace(total_videos, total_hours == 0, 0),
      month_end = rep(strftime(month_end, "%Y-%m-%d"))
    )

  # Derive the first name and last name columns using helper functions
  rpt$first_name <- sapply(rpt$full_name, get_first_name)
  rpt$last_name <- sapply(rpt$full_name, get_last_name)

  # Convert id column from uuid to character string
  rpt <- rpt %>%
    mutate(id = str_replace_all(id, "-", "")) %>%
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
    file = generate_filename("monthend_", year_month, device_name),
    col.names = FALSE,
    row.names = FALSE,
    na = "0"
  )
  system("echo Report extracted successfully!")
  quit(save = "no")

  #return(rpt)
}

input <- commandArgs(TRUE)

# Process the user input and get a vector of dates
dates_vec <- process_dateinput(input)

# Check if content logs exist between the month start and month end
check_sessionlogs(content_sessionlogs, dates_vec, device_name)

# Extract the month end report
monthend(
  dates = dates_vec,
  sessionlogs = content_sessionlogs,
  summarylogs = content_summarylogs,
  topics = topics,
  device_name = device_name
)
