#!/bin/bash

# source script to check if database exists
source ~/.baseline_testing/scripts/check_db_exists.sh

KOLIBRI_SWAP_DB="kolibri_swap"
BASELINE_SWAP_DB="baseline_testing_swap"
#check if database file exists before extracting reports
if db_exists $KOLIBRI_SWAP_DB && db_exists $BASELINE_SWAP_DB ; then
  # Let the user know that the database already exists and skip
  echo "Stopping Kolibri Server"

  kolibri stop

  echo "Stopping Baseline Testing Server"

  forever stopall
  fuser -k 8888/tcp

  echo "${blue}Swap database exists.Skipping...${reset}"
  echo "Swapping Database....."

  export KOLIBRI_DATABASE_NAME=$KOLIBRI_SWAP_DB
  export BASELINE_DATABASE_NAME=$BASELINE_SWAP_DB

  #if db file exists then extraction and submission begin. If not, will output error message to contact support

else
	echo "${red}${bold}Error. The swap database does not exist{reset}"
	exit 1
fi


echo "Restarting Kolibri Server"
kolibri start

echo "Restarting Baseline Testing Server"

KOLIBRI_DATABASE_NAME=$KOLIBRI_SWAP_DB
BASELINE_DATABASE_NAME=$BASELINE_SWAP_DB

~/.baseline_testing/scripts/startup_script
forever start ~/.baseline_testing/index.js

echo "${green}${bold}Database Swapped"
echo "Details of the swapped database are:${reset}"

python ~/.scripts/identify/identify.py
# python identify.py

echo "${green}Close the terminal and open it again to revert to the default database"
echo "or run restartko to revert to the default database${reset}"