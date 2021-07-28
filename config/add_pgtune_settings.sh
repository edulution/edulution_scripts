#!/bin/bash

# Get backup of postgresql conf file
# Remove all lines after the Add settings for extensions here line
sudo sed -i.backup '1,/Add settings for extensions here/!d' /etc/postgresql/11/main/postgresql.conf

# Add the settings for 4 cores, 4GB RAM, HDD storage

echo "max_connections = 200" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "shared_buffers = 1GB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "effective_cache_size = 3GB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "maintenance_work_mem = 256MB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "checkpoint_completion_target = 0.9" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "wal_buffers = 16MB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "default_statistics_target = 100" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "random_page_cost = 4" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "effective_io_concurrency = 2" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "work_mem = 2621kB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "min_wal_size = 1GB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "max_wal_size = 4GB" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "max_worker_processes = 4" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "max_parallel_workers_per_gather = 2" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "max_parallel_workers = 4" | sudo tee -a /etc/postgresql/11/main/postgresql.conf
echo "max_parallel_maintenance_workers = 2" | sudo tee -a /etc/postgresql/11/main/postgresql.conf

# restart the postgresql service
sudo systemctl restart postgresql