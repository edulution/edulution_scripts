# Check that the resulting date after pasting 01 to the front of the input is valid
# e.g December 2020 would be 01-12-20
check_date_valid <- function(input_date) {
  regexp <- START %R%
    # starts with 01
    "01" %R%
    # followed by "-"
    "-" %R%
    # followed by 0 then 0-9
    # or 1 then 0-2 (01-12 are the only valid months of the year)
    or("0" %R% char_class("0-9"),
       "1" %R% char_class("0-2")) %R%
    # followed by "-"
    "-" %R%
    # followed by any two digits (year)
    # it is assumed that the year is in the 21st century
    repeated(DIGIT, 2, 2) %R%
    # end of the string
    END

  # Check if the inputted date satisfies the regex
  if (!(str_detect(input_date, regexp)) | (nchar(input_date) > 8)) {
    # If the regex is not satisfied
    # Stop the program and print out an error message to the console
    stop("Please enter a valid month and year mm-yy e.g 02-17")
  }else{
    print("Date is valid")
  }
}

# helper function to get last name given a full name
get_last_name <- function(full_name) {
  # if the full name is blank or there is only one name
  if (nchar(full_name) == 0 ||
    length(strsplit(full_name, " ")[[1]]) == 1) {
    last_name <- ""
  }

  else {
    last_name <- paste(strsplit(full_name, " ")[[1]][-1], collapse = " ")
  }
  return(last_name)
}


# helper function to get first name given a full name
get_first_name <- function(full_name) {
  if (nchar(full_name) == 0 ||
    length(strsplit(full_name, " ")[[1]]) == 1) {
    first_name <- ""
  }
  else {
    first_name <- paste(strsplit(full_name, " ")[[1]][1], collapse = " ")
  }
  return(toString(first_name))
}


# Simple function to generate file name of csv report in desired format
generate_filename <- function(report_name, date, device_name, reports_dir = "~/.reports/") {
  # generate file name based on name of report and date the user supplies
  # default reports dir is ~/.reports

  filename <- paste(
    reports_dir,
    report_name,
    device_name,
    "_numeracy_",
    date,
    ".csv",
    sep = ""
  )

  return(filename)
}
