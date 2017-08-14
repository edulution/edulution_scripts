# Import tables and generate filename script
source('get_dbtables.R',chdir = T)
source('generate_filename.R',chdir = T)

# Function to get data extract only for month that user inputs
monthend <- function(year_month) {
  #with user input from command line, create complete date by prefixing with 01
  upper_limit <- paste("01-",year_month,sep="")
  #regular expression to check if the user input is a valid month and year, and in the form mm-yy
  regexp <-'((?:(?:[0-2]?\\d{1})|(?:[3][01]{1}))[-:\\/.](?:[0]?[1-9]|[1][012])[-:\\/.](?:(?:\\d{1}\\d{1})))(?![\\d])'
  #check if its a valid date and correct number of characters. stops the program if input not fit
  if(!(grepl(pattern = regexp,x=upper_limit,perl = TRUE)) | (nchar(upper_limit) > 8)) stop("Please enter a valid month and year mm-yy e.g 02-17")
  # with variable from above date, parse into date and get last day in month then convert into proper date format
  upper_limit <- as.Date(timeLastDayInMonth(strftime(upper_limit,"%d-%m-%y"),format = "%y-%m-%d"))
  # Need to get end of month in standard format before chopping it up for grepping. Need it for monthend column in final csv file
  monthend_column <- strftime(upper_limit,format = "%d-%m-%y")
  upper_limit <- substring(upper_limit,1,7)
  exercises_per_user <- main_exerciselog %>% filter(grepl(upper_limit, completion_timestamp)) %>% group_by(user_id) %>% summarize(exercises_attempted = n(), total_exercises = sum(complete))
  videos_per_user <- main_videolog %>% filter(grepl(upper_limit, latest_activity_timestamp)) %>% group_by(user_id) %>% summarize(total_videos = n())
  complete_summary <- main_userlogsummary %>% filter(grepl(upper_limit,last_activity_datetime)) %>% group_by(user_id) %>% summarise(total_hours = sum(total_seconds)/3600, total_logins = n(), last_active_date = max(as.Date(last_activity_datetime))) %>% right_join(users, by = c("user_id" = "id")) %>% left_join(exercises_per_user, by = "user_id") %>% left_join(videos_per_user, by = "user_id") %>% left_join(facilities, by = c("facility_id" = "id")) %>% left_join(groups, by = c("group_id" = "id"))%>% mutate(month_end=rep(monthend_column))
  rpt <- complete_summary %>% select(user_id,first_name,last_name,username,name.y,total_logins,total_hours,total_exercises,total_videos,month_end,exercises_attempted,name.x,last_active_date) %>% rename(centre = name.x, group = name.y, id = user_id)
  write.csv(rpt, file = generate_filename("monthend_",year_month) ,col.names = FALSE, row.names = FALSE,na="0")
  system("echo Report extracted successfully!")
  quit(save="no")
}



input<- commandArgs(TRUE)

monthend(input)
