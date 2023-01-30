#!/bin/bash

# Function to check internet connection
check_internet_connection() {
    # Use Zenity to display a progress dialog
    zenity --progress --pulsate --title="Checking internet connection" --text="Checking your internet connection. Please wait..." --auto-close &

    # Save the PID of the Zenity process
    ZENITY_PID=$!

    # Check if there is an internet connection
    wget -q --tries=10 --timeout=20 --spider http://google.com

    local exit_code=$?
    kill $ZENITY_PID
    return $exit_code
}


create_database_backups(){
    local exit_code=$?

    # File extension for backup files is custom format with extension .backup
    file_extension=".backup"

    # Directory to store backups
    backups_dir=~/backups/

    # Get today's date and use it as timestamp for database backup file
    timestamp=$(date +"%Y%m%d")

    echo "# Preparing...."
    echo "5"
    echo "prepare variables"
    # Get database name using direct query on terminal. remove leading and trailing whitespace
    database_name=$(PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD psql -d "$KOLIBRI_DATABASE_NAME"\
     -U "$KOLIBRI_DATABASE_USER" \
     -h "$KOLIBRI_DATABASE_HOST" \
     -p "$KOLIBRI_DATABASE_PORT" \
     -t -c 'select name from kolibriauth_collection where id = (select default_facility_id from device_devicesettings);' | 
     sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Derive backup name by combining the dataabse name, timestamp and file extension
    kolibri_backup_name=${database_name}_kolibri_${timestamp}${file_extension}

    # name of baseline backup
    baseline_backup_name=${database_name}_baseline_${timestamp}${file_extension}

    # Name of zip file
    zip_file_name=${database_name}_backups_${timestamp}

    # Create database backup using credentials from environment variables 
    echo "# Creating Kolibri database backup...."
    echo "20"
    echo "Creating Kolibri backup"
    PGPASSWORD=$KOLIBRI_DATABASE_PASSWORD pg_dump "$KOLIBRI_DATABASE_NAME" \
     -U "$KOLIBRI_DATABASE_USER" \
     -h "$KOLIBRI_DATABASE_HOST"\
     -p "$KOLIBRI_DATABASE_PORT" \
     -Fc > "$backups_dir/$kolibri_backup_name"

    echo "# Creating Baseline database backup...."
    echo "60"
    echo "Creating baseline backup"
    PGPASSWORD=$BASELINE_DATABASE_PASSWORD pg_dump "$BASELINE_DATABASE_NAME" \
     -U "$BASELINE_DATABASE_USER" \
     -h "$BASELINE_DATABASE_HOST" \
     -p "$BASELINE_DATABASE_PORT" \
     -Fc > "$backups_dir/$baseline_backup_name"

    echo "# Compressing backups...."
    echo "80"
    echo "Create zip file with backups"
    # create zip file containing both backups taken above and remove the original files
    zip -jm "$backups_dir/$zip_file_name" "$backups_dir/$kolibri_backup_name" "$backups_dir/$baseline_backup_name"

    # Remove spaces from names of backups
    echo "# Cleaning up..."
    echo "90"
    echo "Clean up spaces in filenames"
    rename "s/ //g" "$backups_dir"*.backup

    # Call script to remove backups older than 40 days
    echo "Deleting backups more that 40 days old"
    ~/.scripts/backupdb/remove_old_backups.sh


    echo "# Sucessfully created backups"
    echo "100"
    return $exit_code
}