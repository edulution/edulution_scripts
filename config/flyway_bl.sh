#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   flyway_bl - Flyway Baseline  "
  echo
  echo "DESCRIPTION"
  echo "	This script contains a function 'flyway_bl' which is used to invoke flyway on a specific baseline testing database. "
  echo "	The function takes in a command line argument that should match any command that flyway accepts e.g info, migrate, etc."
  echo "	The function first switches to the baseline testing directory, resets the code to match the remote branch, replaces "
  echo "	placeholders in the migrations file with values from environment variables, and then invokes flyway with the supplied argument."
  echo "	The script then calls the function with the command line argument supplied."
  exit 1
fi

# Invoke flyway on baseline testing database

function flyway_bl(){
	# Location of baseline testing app
	BL_DIR=~/.baseline_testing
	
	# Switch to baseline testing directory
	cd $BL_DIR || exit
	# Reset the code to match the remote branch
	git reset --hard origin/zambia

	# path to migrations for baseline testing database
	BL_SQL_PATH=$BL_DIR/migrations

	# Replace placeholders with values in environment variables
	sed -i -e "s/localhost/${KOLIBRI_DATABASE_HOST}/g" $BL_SQL_PATH/V16__fdw_setup.sql
	sed -i -e "s/5432/${KOLIBRI_DATABASE_PORT}/g" $BL_SQL_PATH/V16__fdw_setup.sql
	sed -i -e "s/kolibri/${KOLIBRI_DATABASE_NAME}/g" $BL_SQL_PATH/V16__fdw_setup.sql
	sed -i -e "s/<user>/${BASELINE_DATABASE_NAME}/g" $BL_SQL_PATH/V16__fdw_setup.sql
	sed -i -e "s/<password>/${BASELINE_DATABASE_PASSWORD}/g" $BL_SQL_PATH/V16__fdw_setup.sql

	# invoke flyway with supplied argument
	sudo flyway -locations="filesystem:$BL_SQL_PATH" -url=jdbc:postgresql://$BASELINE_DATABASE_HOST:$BASELINE_DATABASE_PORT/$BASELINE_DATABASE_NAME -user=$BASELINE_DATABASE_USER  -password=$BASELINE_DATABASE_PASSWORD "$1"

	# Reset the code to match the remote branch once again
	git reset --hard origin/zambia
	# switch to the home directory or exit
	cd || exit
}

# Call the function above with the command line argument supplied
# e.g info - show information about all migrations that have been run on the database
#	  migrate - run migrations
flyway_bl "$1"