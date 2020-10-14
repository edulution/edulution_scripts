# Turn the user date input into a named vector
# containing year_month, month_start and month_end
process_dateinput <- function(dateinput){
  year_month <- dateinput
  
  # With user input from the command line, create complete date by prefixing with 01
  upper_limit <- paste("01-", year_month, sep = "")
  
  # Check if the user input is a valid month and year, and in the form mm-yy
  check_date_valid(upper_limit)
  
  # Get month start and month end as correctly formatted strings
  month_end <- as.Date(
    timeLastDayInMonth(strftime(upper_limit, "%d-%m-%y"), format = "%y-%m-%d"))
  
  month_start <- as.Date(
    timeFirstDayInMonth(strftime(upper_limit, "%d-%m-%y"), format = "%y-%m-%d"))
  
  # return a named vector containing year_month, month_start and month_end
  dates_vec <- list(
    year_month = year_month,
    month_start = month_start,
    month_end = month_end)
  
  return(dates_vec)
}
