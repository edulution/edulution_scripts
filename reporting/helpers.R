#' Check that the resulting date after pasting 01 to the front of the input is valid
#' e.g December 2020 would be 01-12-20
#'
#' @param input_date The data supplied, usually from command line input
#'
#' @return None. A success message is printed to the screen confirming the date is valid, or function execution is halted if it is not
#' @export
#'
check_date_valid <- function(input_date) {
  regexp <- START %R%
    # starts with 01
    "01" %R%
    # followed by "-"
    "-" %R%
    # followed by 0 then 0-9
    # or 1 then 0-2 (01-12 are the only valid months of the year)
    or(
      "0" %R% char_class("0-9"),
      "1" %R% char_class("0-2")
    ) %R%
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
  } else {
    print("Date is valid")
  }
}


#' Generate file name of a report in desired format
#'
#' @param report_name Name of the report
#' @param date The date of the report
#' @param device_name The name of the device the report is coming from
#' @param reports_dir The directory in which reports are stored. Default is .reports folder in the home directory
#' @param file_extension The file extension for the report. Default is ".csv"
#' @param module The module for which the report is for. Default is "_numeracy_"
#' @param separator The directory in which reports are stored. Default is .reports folder in the home directory
#'
#' @return A vector containing the filename
#' @export
#'
generate_filename <- function(report_name, date, device_name, file_extension = ".csv", module = "_numeracy_", separator = "", reports_dir = "~/.reports/") {
  # Derive report filename by pasting the inputs in the right order
  filename <- paste(
    reports_dir,
    report_name,
    device_name,
    module,
    date,
    file_extension,
    sep = separator
  )

  return(filename)
}