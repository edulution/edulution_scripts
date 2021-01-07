check_completed_ex_vid_count <- function(summary_df) {
  # check if exercises and videos have been completed
  if (nrow(summary_df) == 0) {
    # if no exercises and videos were completed
    system("echo no exercises or videos have been completed")
    # print a message to the console to inform the user

    # create a df and populate it with zeroes on user_id, total_exercises, total_videos
    zeroes <- data.frame(users$id, rep(0, nrow(users)), rep(0, nrow(users)))
    names(zeroes) <- c("user_id", "total_exercises", "total_videos")

    summary_df <- zeroes
  } else {
    # transpose the rows into columns by user_id
    # exercise and video counts become columns
    summary_df <- summary_df %>% pivot_wider(names_from = kind, values_from = count)

    # rename the columns to read total_exercises, total_videos

    if ("exercise" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% rename(total_exercises = exercise)
    } else {
      summary_df <- summary_df %>% mutate(total_exercises = 0)
    }

    if ("video" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% rename(total_videos = video)
    } else {
      summary_df <- summary_df %>% mutate(total_videos = 0)
    }

    if ("document" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% rename(total_documents = document)
    } else {
      summary_df <- summary_df %>% mutate(total_documents = 0)
    }
  }
  return(summary_df)
}
