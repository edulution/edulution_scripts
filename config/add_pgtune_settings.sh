#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "NAME"
  echo "   add_pgtune_settings - Postgres DB settings"
  echo
  echo "DESCRIPTION"
  echo "	This script is used to add tuning settings to a Postgres 13 database. It will check if the Postgres 13 has been set up and if"
  echo "	it has, the script will add the settings for 2 cores, 4GB RAM, HDD storage, data warehouse and then restart the postgresql service."
  echo "	The script also takes a backup of the postgresql.conf file before adding the tuning settings."
  echo 
  echo "NOTE:"
  echo "	sudo prevalages are required to run the script"
  exit 1
fi


DIRECTORY="/etc/postgresql/13/main"

# Store path to conf file in variable
CONF_FILE="$DIRECTORY/postgresql.conf"

if [ ! -d "$DIRECTORY" ]; then
	echo "Postgres 13 has not been set up. Skipping...."
else
	echo "Postgres 13 has been set up. Adding tuning settings"

	# Get backup of postgresql conf file
	# Remove all lines after the Add settings for extensions here line
	sudo sed -i.backup '1,/Add settings for extensions here/!d' "$CONF_FILE"

	# Add the settings for 2 cores, 4GB RAM, HDD storage, data warehouse

	echo "shared_preload_libraries = 'pg_stat_statements'" | sudo tee -a "$CONF_FILE"
	echo "max_connections = 200" | sudo tee -a "$CONF_FILE"
	echo "shared_buffers = 1GB" | sudo tee -a "$CONF_FILE"
	echo "effective_cache_size = 3GB" | sudo tee -a "$CONF_FILE"
	echo "maintenance_work_mem = 512MB" | sudo tee -a "$CONF_FILE"
	echo "checkpoint_completion_target = 0.9" | sudo tee -a "$CONF_FILE"
	echo "wal_buffers = 16MB" | sudo tee -a "$CONF_FILE"
	echo "default_statistics_target = 500" | sudo tee -a "$CONF_FILE"
	echo "random_page_cost = 4" | sudo tee -a "$CONF_FILE"
	echo "effective_io_concurrency = 2" | sudo tee -a "$CONF_FILE"
	echo "work_mem = 13107kB" | sudo tee -a "$CONF_FILE"
	echo "min_wal_size = 4GB" | sudo tee -a "$CONF_FILE"
	echo "max_wal_size = 16GB" | sudo tee -a "$CONF_FILE"
	echo "max_worker_processes = 2" | sudo tee -a "$CONF_FILE"
	echo "max_parallel_workers_per_gather = 1" | sudo tee -a "$CONF_FILE"
	echo "max_parallel_workers = 2" | sudo tee -a "$CONF_FILE"
	echo "max_parallel_maintenance_workers = 1" | sudo tee -a "$CONF_FILE"

	# restart the postgresql service
	sudo systemctl restart postgresql
fi