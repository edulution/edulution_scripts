#!/bin/bash


# mkdir Archive_Learner
# check if directories exist
DIRECTORIES=( ~/Archive_Learner/)
for DIRECTORY in "${DIRECTORIES[@]}"; do
  if [ ! -d "$DIRECTORY" ]; then
    mkdir "$DIRECTORY"
  else
    echo "${BLUE}Archive_Learner Directory already exists ON Center Laptop. Skipping this step${RESET}"
  fi
done


# Go into reports folder
cd ~/Archive_Learner || exit

#check reports folder for file most recently created from monthend or alldata and send to google server
MOST_REC_FILEPATH=$( ls ~/Archive_Learner -t | head -n1 )

# Get the name of the most recent file without path and extension
MOST_REC_FILENAME=$( basename "$MOST_REC_FILEPATH" .csv)

# Create a zip file with this file in the current directory
# Expected output is $MOST_REC_FILENAME.zip and the original csv file deleted
zip -jm "$MOST_REC_FILENAME" "$MOST_REC_FILEPATH" 

# if connection lost the script will exit with status 1 and output error message
# if sshpass -p "$SSHPASS" scp "$MOST_REC_FILENAME.zip" edulution@130.211.93.74:/home/edulution/reports/archive_learners/; then
# else
# 	echo "${GREEN}${BOLD}Archive_Learner Report submitted successfully!${RESET}"
# else
# 	echo "${RED}${BOLD}Archive_Learner Report not submitted. Please check your internet connection and try again 1>&2${RESET}"
# 	exit 1
# fi