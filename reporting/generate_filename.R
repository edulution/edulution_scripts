# Simple function to generate filename of csv report in desired format
generate_filename <- function(report,date){
  # put generated file in a folder called reports in home directory, and generate filename based on name of report and user input
  filename <- paste("~/reports/",report,device_name,"_",date,".csv",sep = "")
}
