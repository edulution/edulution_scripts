#!/bin/bash

# Invoke flyway on baseline testing database

function flyway_bl(){
	# Location of baseline testing app
	BL_DIR=~/.baseline_testing
	
	# Switch to baseline testing directory
	cd $BL_DIR || exit
	# Reset the code to match the remote branch
	git reset --hard origin/develop

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
	git reset --hard origin/develop
	# switch to the home directory or exit
	cd || exit
}

# Call the function above with the command line argument supplied
# e.g info - show information about all migrations that have been run on the database
#	  migrate - run migrations
flyway_bl "$1"