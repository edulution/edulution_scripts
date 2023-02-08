#!/bin/bash

# Function to check internet connection
check_internet_connection() {
    # Use Zenity to display a progress dialog
    zenity --progress \
    --pulsate \
    --title="Checking internet connection" \
    --text="Checking your internet connection. Please wait..." \
    --auto-close &

    # Save the PID of the Zenity process
    ZENITY_PID=$!

    # Check if there is an internet connection
    wget -q --tries=10 --timeout=20 --spider http://google.com

    local exit_code=$?
    kill $ZENITY_PID
    return $exit_code
}

# Function to create database backups
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


# Function to check if a process is running
check_process_running () {
    ps_out=$(ps -ef | grep "$1" | grep -v 'grep' | grep -v "$0")
    result=$(echo "$ps_out" | grep "$1")
    if [[ "$result" != "" ]];then
        # Process is running
        return 0
    else
        # Process is not running
        return 1
    fi
}


# Function to fetch latest code updates
fetch_latest_updates(){
    directories=("~/.scripts" "~/.baseline_testing" "~/.kolibri_helper_scripts")
    total_dirs=${#directories[@]}
    progress=0
    progress_step=$((100 / total_dirs))

    for dir in "${directories[@]}"; do
      # Expand the tilde character
      eval expanded_dir="$dir"

      # Go to the directory
      cd "$expanded_dir" ||
      { echo "Error: Failed to change directory to $expanded_dir."; return 1; }

      # Pull the latest code from Github
      git reset --hard origin/"$COUNTRY_BRANCH" &
      git pull origin "$COUNTRY_BRANCH" > /dev/null ||
      { echo "Error: Failed to pull the latest updates for $expanded_dir."; return 1; }

      progress=$((progress + progress_step))
      echo "# Fetching updates for $dir"
      echo $progress
    done

    return 0
}


# Run a series of functions and output percentage progress
run_functions_with_progress() {
  # Define variables
  local functions=("$@")
  local function_count=$#
  
  local progress=0
  local log_file="error_$(date +'%Y%m%d_%H%M%S').log"

  # Loop through each function and run it
  for ((i=0; i<$function_count; i++)); do
    current_function=${functions[i]}

    # Echo name of function that is running
    echo "# Running function ${functions[i]}"

    # Direct standard error to an error log file
    "$current_function" 2> >(tee -a "$ERROR_LOG")
    # "${functions[i]}" &> /dev/null

    # Check exit code of function
    exit_code=$?
    
    # If the exit code is not 0, tell the user there is an error and break the loop
    if [[ $exit_code -ne 0 ]]; then
      echo "# Error in function ${functions[i]}" >> "$log_file"
      break
    fi

    # Increment progress
    progress=$((progress + 100 / function_count))
    # Update progress bar
    echo "$progress"
  done

  # Check if there were any errors in the log file
  if [[ -f "$log_file" ]]; then
    # Inform the user and exit with code 1
    echo "# Error: see $log_file for details"
    return 1
  else
    return 0
  fi
}


# Clean up loose csv files from the reports directory
cleanup_loose_reports(){
    local reports_dir="~/.reports"
    eval expanded_dir="$reports_dir"

    # Go into the directory
    cd "$expanded_dir" ||
    { echo "Error: Failed to change directory to $expanded_dir."; return 1; }

    # Delete all loose csv files
    find . -type f \( -name "*.csv" \) -exec rm {} \; ||
    { echo "Error: Failed to delete loose files in $expanded_dir."; return 1; }
    
    return 0
}