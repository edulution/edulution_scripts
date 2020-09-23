# TODO:
# Install rebus on all devices
# Rewrite with rebus for easier readability
check_date_valid <- function(input_date) {
  regexp <- '((?:(?:[0-2]?\\d{1})|(?:[3][01]{1}))[-:\\/.](?:[0]?[1-9]|[1][012])[-:\\/.](?:(?:\\d{1}\\d{1})))(?![\\d])'
  
  # Check if the inputted date satisfies the regex
  if (!(str_detect(input_date, regexp)) | (nchar(input_date) > 8)) {
    # If the regex is not satisfied
    # Stop the program and print out an error message to the console
    stop("Please enter a valid month and year mm-yy e.g 02-17")
  }
}

# helper function to get last name given a full name
get_last_name <- function(full_name) {
  # if the full name is blank or there is only one name
  if (nchar(full_name) == 0 ||
      length(strsplit(full_name, ' ')[[1]]) == 1) {
    last_name <- ''
  }
  
  else{
    last_name <- paste(strsplit(full_name, ' ')[[1]][-1], collapse = ' ')
  }
  return(last_name)
}


# helper function to get first name given a full name
get_first_name <- function(full_name) {
  if (nchar(full_name) == 0 ||
      length(strsplit(full_name, ' ')[[1]]) == 1) {
    first_name <- ''
  }
  else{
    first_name <- paste(strsplit(full_name, ' ')[[1]][1], collapse = ' ')
  }
  return(toString(first_name))
}


# Simple function to generate filename of csv report in desired format
generate_filename <- function(report, date) {
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <-
    paste("~/.reports/",
          report,
          device_name,
          "_numeracy_",
          date,
          ".csv",
          sep = "")
}
