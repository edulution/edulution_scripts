#!/bin/bash

DIRECTORY="/etc/postgresql/14/main"

# Store path to conf file in variable
CONF_FILE="$DIRECTORY/postgresql.conf"

if [ ! -d "$DIRECTORY" ]; then
	echo "Postgres 14 has not been set up. Skipping...."
else
	echo "Postgres 14 has been set up. Adding tuning settings"

	# Get backup of postgresql conf file
	# Remove all lines after the Add settings for extensions here line
	sudo sed -i.backup '1,/Add settings for extensions here/!d' "$CONF_FILE"

	# Add the settings for 12 cores, 8GB RAM, SSD storage, data warehouse

	echo "shared_preload_libraries = 'pg_stat_statements'" | sudo tee -a "$CONF_FILE"
	echo "max_connections = 200" | sudo tee -a "$CONF_FILE"
	echo "shared_buffers = 2GB" | sudo tee -a "$CONF_FILE"
	echo "effective_cache_size = 6GB" | sudo tee -a "$CONF_FILE"
	echo "maintenance_work_mem = 1GB" | sudo tee -a "$CONF_FILE"
	echo "checkpoint_completion_target = 0.9" | sudo tee -a "$CONF_FILE"
	echo "wal_buffers = 16MB" | sudo tee -a "$CONF_FILE"
	echo "default_statistics_target = 500" | sudo tee -a "$CONF_FILE"
	echo "random_page_cost = 1.1" | sudo tee -a "$CONF_FILE"
	echo "effective_io_concurrency = 200" | sudo tee -a "$CONF_FILE"
	echo "huge_pages = off" | sudo tee -a "$CONF_FILE"
	echo "work_mem = 4369kB" | sudo tee -a "$CONF_FILE"
	echo "min_wal_size = 4GB" | sudo tee -a "$CONF_FILE"
	echo "max_wal_size = 16GB" | sudo tee -a "$CONF_FILE"
	echo "max_worker_processes = 12" | sudo tee -a "$CONF_FILE"
	echo "max_parallel_workers_per_gather = 6" | sudo tee -a "$CONF_FILE"
	echo "max_ parallel_workers = 12" | sudo tee -a "$CONF_FILE"
	echo "max_ parallel_maintenance_workers = 4" | sudo tee -a "$CONF_FILE"

	# restart the postgresql service
	sudo systemctl restart postgresql
fi