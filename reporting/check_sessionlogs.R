library(dbhelpers)
#' Check if session logs exist for the dates supplied, and for all time
#'
#' @param sessionlogs A \code{data.frame} containing all session logs
#' @param dates A named vector of dates (year_month, month_start, month_end)
#' @param device_name A string of the device name. Required to produce a report if the script fails
#' @param all_time A \code{logical} indicating whether or not to check session logs for all time. Default FALSe
#'
#' @return None. Success message if session logs found. Error message and terminate script if not
#' @export
check_sessionlogs <- function(sessionlogs, dates, device_name, all_time = FALSE) {
  year_month <- dates$year_month
  month_start <- dates$month_start
  month_end <- dates$month_end


  if (all_time == T) {
    # If all_time is set to True, check all session logs until the month_end supplied
    num_logs <- nrow(
      sessionlogs %>%
        dplyr::filter(end_timestamp <= month_end)
    )
  } else {
    # If all_time is not set
    # Get check the session logs in the dates between month start and month end
    num_logs <- nrow(
      sessionlogs %>%
        dplyr::filter(
          start_timestamp >= month_start,
          end_timestamp <= month_end
        )
    )
  }

  # If no session logs were found,
  # print a message to the console
  # return the list of users with all other fields blank
  if (num_logs == 0) {
    system("echo No learner activity found for the dates supplied")
    system("echo Sending list of users instead")

    # Get the list of users

    report <- users %>%
      # convert id column from uuid to character string
      dplyr::mutate(id = str_replace_all(id, "-", "")) %>%
      # Add columns for month_end and device name
      # Add other required columns and set to 0
      dplyr::mutate(
        # Add columns for first name and last name using helper functions
        first_name = dbhelpers::get_first_name(full_name),
        last_name = dbhelpers::get_last_name(full_name),
        total_hours = 0,
        total_exercises = 0,
        total_videos = 0,
        month_end = month_end,
        centre = device_name %>% pull(name),
        month_active = 0,
        module = "",
        total_logins = 0
      ) %>%
      # Put the columns in order
      # Familiar columns first and everything else at the end
      dplyr::select(
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
  } else {
    print("Session logs found for the dates supplied")
  }
}
