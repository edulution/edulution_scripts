suppressMessages(library(plyr))
suppressMessages(library(dplyr))

#get the default facility id and from it get the device name(facility name)
default_facility_id <<- default_facility_id %>%
  pull(default_facility_id)

# get a df of all of the facilities on the device
facilities <<- collections %>% filter(kind == "facility")

# keep the default facility as the device name (will be used to name the output file)
device_name <<- collections %>%
  filter(id == default_facility_id) %>%
  pull(name)

#join collections to memberships. (used for getting user groups)
memberships <<- memberships %>%
  left_join(collections,
            by = c("collection_id" = "id"))

# get dataframe containing learners and groups they belong to
learners_and_groups <<- memberships %>%
  filter(kind == 'learnergroup') %>%
  distinct(user_id, .keep_all = TRUE) %>%
  select(name, user_id)

#filter out admins and coaches to get list of users
# select only the relevant columns
users <<- facilityusers %>%
  filter(!id %in% roles$user_id)

if (nrow(users) == 0) {
  # If there are no users on the device, stop the program and inform the user
  stop('No users found. Nothing to extract')
} else{
  # select the relevant columns from the users df
  users <<- users %>%
    # join users to facilities,
    # rename the facility name to centre
    # then drop the facility_id column
    left_join(facilities, by = c("facility_id" = "id")) %>%
    rename(centre = name) %>%
    select(id,
           full_name,
           username,
           date_joined,
           last_login,
           centre,
           facility_id) %>%
    select(-facility_id)
}

# join channel metadata to channel_module
channel_metadata <<- channel_metadata %>%
  left_join(channel_module, by = c("id" = "channel_id")) %>%
  # create new column with module and abbreviated playlist name
  mutate(abbr_name = paste0(module, '_', abbreviate(name))) %>%
  # create new column with abbr name and the word progress
  # will be used as the column name for channel progress in final report
  mutate(abbr_name_progress = paste0(abbr_name, '_progress'))

#create named vector with channel_ids and abbreviated playlist names
course_name_id <- unlist(channel_metadata$abbr_name)
names(course_name_id) <- unlist(channel_metadata$id)

#create named vector with abbr_name_progress and make the channel ids the names of each of the elements
course_name_id_progress <-
  unlist(channel_metadata$abbr_name_progress)
names(course_name_id_progress) <- unlist(channel_metadata$id)

#get number of content items by channel.used to compute overall progress in channel
num_contents_by_channel <<- channel_contents %>%
  filter(!kind %in% c('topic', 'channel')) %>%
  count(channel_id, name = "total_items")

coach_content <<- channel_contents  %>% filter(coach_content == TRUE)