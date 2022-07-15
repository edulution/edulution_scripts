suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(lubridate))

centre_timezone <- "Africa/Windhoek"

# get the default facility id and from it get the device name(facility name)
default_facility_id <<- default_facility_id %>%
  dplyr::pull(default_facility_id)

# get a df of all of the facilities on the device
facilities <<- collections %>% dplyr::filter(kind == "facility")

# keep the default facility as the device name (will be used to name the output file)
device_name <<- collections %>%
  dplyr::filter(id == default_facility_id) %>%
  # Get only the first 5 characters of the name
  dplyr::mutate(name = str_sub(name, 1, 5)) %>%
  # Select only the name column
  dplyr::select(name)

# join collections to memberships. (used for getting user groups)
memberships <<- memberships %>%
  dplyr::left_join(collections,
    by = c("collection_id" = "id")
  )

# get dataframe containing learners and groups they belong to
learners_and_groups <<- memberships %>%
  dplyr::filter(kind == "learnergroup") %>%
  dplyr::distinct(user_id, .keep_all = TRUE) %>%
  dplyr::select(name, user_id)

# Get learners and the classrooms (grades) they belong to
learners_and_grades <- memberships %>%
  # filter out memberships of type learnergroup
  dplyr::filter(kind == "classroom") %>%
  dplyr::group_by(user_id) %>%
  # If a learner belongs to multiple classes, separate them with commas
  dplyr::mutate(name = paste(name, collapse = ",") %>% stringr::str_trim()) %>%
  dplyr::ungroup() %>%
  dplyr::distinct(user_id, .keep_all = T) %>%
  dplyr::select("class_name" = name, user_id)


# filter out admins and coaches to get list of users
# select only the relevant columns
users <<- facilityusers %>%
  dplyr::filter(!id %in% roles$user_id)

if (nrow(users) == 0) {
  # If there are no users on the device, stop the program and inform the user
  stop("No users found. Nothing to extract")
} else {
  # select the relevant columns from the users df
  users <<- users %>%
    # join users to facilities,
    # rename the facility name to centre
    # then drop the facility_id column
    dplyr::left_join(facilities, by = c("facility_id" = "id")) %>%
    dplyr::rename(centre = name) %>%
    dplyr::left_join(learners_and_grades, by = c("id" = "user_id")) %>%
    # Convert the last login to the nearest timezone for the centre location
    dplyr::mutate(
      last_login = lubridate::ymd_hms(last_login) %>% lubridate::with_tz(centre_timezone)
    ) %>%
    dplyr::select(
      id,
      full_name,
      username,
      date_joined,
      last_login,
      class_name,
      centre,
      facility_id
    ) %>%
    dplyr::select(-facility_id)
}

# join channel metadata to channel_module
channel_metadata <<- channel_metadata %>%
  dplyr::left_join(channel_module, by = c("id" = "channel_id")) %>%
  # create new column with module and abbreviated playlist name
  dplyr::mutate(abbr_name = paste0(module, "_", abbreviate(name))) %>%
  # create new column with abbr name and the word progress
  # will be used as the column name for channel progress in final report
  dplyr::mutate(abbr_name_progress = paste0(abbr_name, "_progress"))

# create named vector with channel_ids and abbreviated playlist names
course_name_id <- unlist(channel_metadata$abbr_name)
names(course_name_id) <- unlist(channel_metadata$id)

# create named vector with abbr_name_progress and make the channel ids the names of each of the elements
course_name_id_progress <-
  unlist(channel_metadata$abbr_name_progress)

names(course_name_id_progress) <- unlist(channel_metadata$id)

# get number of content items by channel.used to compute overall progress in channel
num_contents_by_channel <<- channel_contents %>%
  dplyr::filter(!kind %in% c("topic", "channel")) %>%
  dplyr::count(channel_id, name = "total_items")

coach_content <<- channel_contents %>% dplyr::filter(coach_content == TRUE)
