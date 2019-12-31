#!/bin/bash

# source script to check if database exists
source ~/.baseline_testing/scripts/check_db_exists.sh

#colors
#=======
export black=`tput setaf 0`
export red=`tput setaf 1`
export green=`tput setaf 2`
export yellow=`tput setaf 3`
export blue=`tput setaf 4`
export magenta=`tput setaf 5`
export cyan=`tput setaf 6`
export white=`tput setaf 7`

# reset to default bash text style
export reset=`tput sgr0`

# make actual text bold
export bold=`tput bold`

# make background color on text
export bold_mode=`tput smso`

# remove background color on text
export exit_bold_mode=`tput rmso`

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