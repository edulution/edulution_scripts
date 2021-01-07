# Clear workspace
rm(list = ls())

# Source helper functions
source("helpers.R")
source("preproc_tables.R")

# prevent displaying warning messages from script on console(errors will still show)
options(warn = -1)

# suppress messages when loading packages
suppressMessages(library(timeDate))
suppressMessages(library(tidyr))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(tools))
suppressMessages(library(gsubfn))
suppressMessages(library(stringr))
suppressMessages(library(rebus))


# Function to get all data in db from beginning of time until month that user specifies
alldata <- function(year_month) {
  # with user input from command line, create complete date by prefixing with 01
  upper_limit <- paste("01-", year_month, sep = "")

  # Check if the user input is a valid month and year, and in the form mm-yy
  check_date_valid(upper_limit)

  # get month start and month end as correctly formatted strings
  month_end <- as.Date(timeLastDayInMonth(strftime(upper_limit, "%d-%m-%y"), format = "%y-%m-%d"))
  month_start <- as.Date(timeFirstDayInMonth(strftime(upper_limit, "%d-%m-%y"), format = "%y-%m-%d"))

  content_summarylogs <- content_summarylogs %>%
    mutate(start_date_only = strftime(start_timestamp, "%Y-%m-%d"))

  # get total time spent by each user between month start and month end
  num_logs <- nrow(content_summarylogs %>% filter(end_timestamp <= month_end))
  if (num_logs == 0) {
    system("echo No learner activity found for the requested month")
    system("echo Sending list of users instead")

    time_spent_by_user <- content_summarylogs %>%
      filter(end_timestamp <= month_end) %>%
      group_by(user_id) %>%
      summarize(total_hours = sum(time_spent) / 3600)
  }

  # get the number of distinct days a user logeed in using the start_timestamp date only
  logins_by_user <- content_summarylogs %>%
    distinct(user_id, start_date_only) %>%
    count(user_id, name = "total_logins")

  # get the total number of completed exercises and videos between month start and month end
  filter(progress >= 0.99) %>%
    count(user_id, kind, name = "count")

  # transpose the rows into columns by user_id
  # exercise and video counts become columns
  completed_ex_vid_count <- completed_ex_vid_count %>% tidyr::pivot_wider(names_from = kind, values_from = count)

  # rename the columns to read total_exercises, total_videos
  if ("video" %in% colnames(completed_ex_vid_count)) {
    completed_ex_vid_count <- completed_ex_vid_count %>%
      rename(
        total_exercises = exercise,
        total_videos = video
      )
  }

  else {
    completed_ex_vid_count <- completed_ex_vid_count %>%
      rename(total_exercises = exercise) %>%
      mutate(total_videos = 0)
  }

  # get total time spent by channel
  time_by_channel <- content_summarylogs %>%
    group_by(user_id, channel_id) %>%
    summarise(total_time = sum(time_spent) / 3600) %>%
    pivot_wider(names_from = channel_id, values_from = total_time)
  # this produces a data frame with time spent on each channel as a separate column with the channel id as the column name

  # change column names which are channel_ids from channel_ids to readable course names
  # using the named vector created outside the function
  names(time_by_channel) <- c("user_id", recode(names(time_by_channel)[-1], !!!course_name_id))

  # get total_progress by channel_id (no need to filter for the month requested)
  prog_by_user_by_channel <- content_summarylogs %>%
    group_by(user_id, channel_id, content_id) %>%
    summarise(max_prog = max(progress)) %>%
    group_by(user_id, channel_id) %>%
    summarise(total_prog = sum(max_prog)) %>%
    # join total prog by channel to number of items by channel.
    # used to get percent progress in channel
    left_join(num_contents_by_channel) %>%
    # create a column for the percent progress by channel
    mutate(pct_progress = total_prog / total_items) %>%
    # get rid of the columns for total prog and total_items
    # then turn the progress for each channel into a separate column
    select(-c(total_prog, total_items)) %>%
    pivot_wider(names_from = channel_id, values_from = pct_progress)

  # change the column names to be the name of the channel + _progress
  names(prog_by_user_by_channel) <- c("user_id", recode(names(prog_by_user_by_channel)[-1], !!!course_name_id_progress))

  # everything together to make a complete report
  rpt <- users %>%
    left_join(
      time_spent_by_user,
      by = c("id" = "user_id")
    ) %>%
    left_join(
      completed_ex_vid_count,
      by = c("id" = "user_id")
    ) %>%
    left_join(
      logins_by_user,
      by = c("id" = "user_id")
    ) %>%
    left_join(
      time_by_channel,
      by = c("id" = "user_id")
    ) %>%
    left_join(
      prog_by_user_by_channel,
      by = c("id" = "user_id")
    ) %>%
    left_join(
      learners_and_groups,
      by = c("id" = "user_id")
    ) %>%
    # add month active, module, and centre by mutation
    mutate(
      month_active = ifelse(total_hours > 0, 1, 0),
      module = rep("numeracy"), centre = rep(device_name)
    ) %>%
    # Set total exercises and total videos to 0 if total hours is 0
    mutate(
      total_exercises = replace(total_exercises, total_hours == 0, 0)
    ) %>%
    mutate(
      total_videos = replace(total_videos, total_hours == 0, 0),
      month_end = rep(strftime(month_end, "%Y-%m-%d"))
    )

  # derive the first name and last name columns using helper functions
  rpt$first_name <- sapply(rpt$full_name, get_first_name)
  rpt$last_name <- sapply(rpt$full_name, get_last_name)

  # convert id column from uuid to character string
  rpt <- rpt %>%
    mutate(id = str_replace_all(id, "-", "")) %>%
    # reorder columns. put familiar columns first, all new columns last
    select(
      id,
      first_name,
      last_name,
      username,
      group,
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

  # Write report to csv
  write.csv(
    rpt,
    file = generate_filename("alldata_", year_month),
    col.names = FALSE,
    row.names = FALSE,
    na = "0"
  )
  system("echo Report extracted successfully!")
  quit(save = "no")
}


# fetch user input from the command line
input <- commandArgs(TRUE)

# run function with user input as argument
alldata(input)
