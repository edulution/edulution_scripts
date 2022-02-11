#' Check if the completion count of exercises and videos is valid
#' @param summary_df A \code{data.frame}
#' containing summary data extracted from ContentSummaryLog
#'
#' @return A cleaned version of the \code{data.frame} supplied,
#' or a A \code{data.frame} of zero values if the data supplied was not valid
#' @export
#'
check_completed_ex_vid_count <- function(summary_df) {
  # check if exercises and videos have been completed
  if (nrow(summary_df) == 0) {
    # if no exercises and videos were completed
    system("echo no exercises or videos have been completed")
    # print a message to the console to inform the user

    # create a df
    # populate it with zeroes on user_id, total_exercises, total_videos
    zeroes <- data.frame(users$id, rep(0, nrow(users)), rep(0, nrow(users)))
    names(zeroes) <- c("user_id", "total_exercises", "total_videos")

    summary_df <- zeroes
  } else {
    # transpose the rows into columns by user_id
    # exercise and video counts become columns
    summary_df <- summary_df %>%
      tidyr::pivot_wider(names_from = kind, values_from = count)

    # rename the columns to read total_exercises, total_videos

    if ("exercise" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% dplyr::rename(total_exercises = exercise)
    } else {
      summary_df <- summary_df %>% dplyr::mutate(total_exercises = 0)
    }

    if ("video" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% dplyr::rename(total_videos = video)
    } else {
      summary_df <- summary_df %>% dplyr::mutate(total_videos = 0)
    }

    if ("document" %in% colnames(summary_df)) {
      summary_df <- summary_df %>% dplyr::rename(total_documents = document)
    } else {
      summary_df <- summary_df %>% dplyr::mutate(total_documents = 0)
    }
  }
  return(summary_df)
}