library(googleCloudStorageR)
library(gargle)

#' Upload file to google cloud bucket
#'
#' @param filename The path to the file to be uploaded
#' @param bucketname Name of the bucket to upload to
#' @param auth_file Path to auth json file
#' @param ...  Miscelaneous args passed to googleCloudStorageR
#'
#' @return None
#' @export
#'
upload_file_to_gcloud <- function(filename, bucketname = "reportsupload.edulution.org", auth_file = "/opt/edu-connect-777-3a25d4846944.json", ...) {
  Sys.setenv("GCS_AUTH_FILE" = auth_file)
  Sys.setenv("GCS_DEFAULT_BUCKET" = bucketname)
  googleCloudStorageR::gcs_global_bucket(Sys.getenv("GCS_DEFAULT_BUCKET"))

  tryCatch(
    {
      gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
    },
    warning = function(w) {
      print(w)
    },
    error = function(e) {
      print(paste(e, ":", "Possibly auth file does not exist or did not successfully authenticate"))
    }
  )

  tryCatch(
    {
      gcs_upload(file = filename, name = basename(filename), predefinedAcl='bucketLevel')
    },
    warning = function(w) {
      print(w)
    },
    error = function(e) {
      print(paste(e, ":", "Failed to upload file to google cloud bucket"))
    }
  )

}


input_filename <- commandArgs(TRUE)
upload_file_to_gcloud(filename = input_filename)