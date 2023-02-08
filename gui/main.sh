#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/functions.sh

VERSION=$(dirname "${BASH_SOURCE[0]}")/VERSION

COUNTRY_BRANCH="zambia"

# Create a list of options
options=(
    "Restart Kolibri"
    "Regenerate Kolibri quizzes"
    "Assign Learners"
    "Take database backup"
    "Submit reports"
    "Fetch latest updates"
    "Help"
    "About"
    "Quit"
    )

# Display the list of options in a dialog box
choice=$(zenity --list \
    --title="Select an option" \
    --column="Options" "${options[@]}")

# Check the user's choice and perform the corresponding action
case "$choice" in
    "Restart Kolibri")
        zenity --info --text="You selected option 1"
        ;;
    "Take database backup")
        # Ask the user if they would like to continue
        zenity --question \
        --title="Confirm taking backups" \
        --text="You are about to take database backups. Do you want to continue?"

            if [ $? -eq 0 ]; then
                # Run create backups function then pass the output to a zenity dialog
                create_database_backups 2>&1 | zenity --progress \
                --title="Database backups" \
                --text="Creating database backups. Please wait..." \
                --percentage=0 \
                --auto-kill \
                --auto-close &

                wait
                
                if [[ $? -eq 0 ]]; then
                    # Connection is successful. Begin submitting report
                    zenity --info \
                    --title="Database backups" \
                    --text="Backups created successfully."
                    
                else
                    # Connection is not successful
                    zenity --error \
                    --title="Database backups" \
                    --text="Backups not created successfully. Please try again or contact support"
                fi
            else
                # If the user clicked the "No" button, exit the application
                exit 0
            fi
        ;;
    "Submit reports")
        selected_date_full=$(zenity --calendar \
            --text="Select any date in the month you would like to submit reports" \
            --title="Report Submission" \
            --date-format='%Y-%m-%d')

        # Get month and year in full from selected date for display
        selected_month=$(date -d "$selected_date_full" +"%B %Y")
        echo "Selected date: $selected_month"

        # Get date in required format for report extraction
        date_report_extr=$(date -d "$selected_date_full" +"%m-%y")
        echo "$date_report_extr"
        
        # Display a question dialog box
                # Check the exit status of the zenity command
        if [ $? -eq 0 ]; then
        	zenity --question \
            --title="Confirm reports submission" \
            --text="You are about to submit reports for <b>$selected_month</b>. Do you want to continue?"
        	if [ $? -eq 0 ]; then
                check_internet_connection
                
                # Internet connection successful
                # Begin report extraction
                if [[ $? -eq 0 ]]; then
                    # Capture the output of the fetch latest updates function
                    # fetch_updates_output=$(fetch_latest_updates 2>&1)
                    # # Capture the exit code of the fetch latest updates function
                    # fetch_updates_exit_status=$?

                    # Pipe the output to zenity progress dialog
                    run_functions_with_progress function1 function2 function3 |
                    zenity --title="Running Functions" \
                    --progress\
                    --text="Please wait while functions are being executed"\
                    --percentage=0\
                    --auto-close

                    if [ $? -ne 0 ]; then
                      zenity --error --text="An error occurred while running functions"
                    else
                      zenity --info \
                      --title="Running functions" \
                      --text="Functions ran successfully."
                    fi

                    run_functions_with_progress function1 function2 function3 |
                    zenity --title="Running Functions" \
                    --progress\
                    --text="Please wait while functions are being executed"\
                    --percentage=0\
                    --auto-close

                    if [ $? -ne 0 ]; then
                      zenity --error --text="An error occurred while running functions"
                    else
                      zenity --info \
                      --title="Running functions" \
                      --text="Functions ran successfully."
                    fi

                # Internet connection not successful
                else
                    zenity --error \
                    --title="Internet connection not successful" \
                    --text="You are not connected to the internet."
                    echo "You are not connected to the internet"
                fi
            else
                # If the user clicked the "No" button, exit the application
                exit 0
            fi
        	else
        	    # If the user clicked the "No" button, exit the application
        	    exit 0
        	fi
        ;;
    "Fetch latest updates")
        zenity --question \
        --title="Fetching latest updates" \
        --text="You are about to fetch the latest updates. Do you want to continue?"

            if [ $? -eq 0 ]; then
                check_internet_connection
                
                if [[ $? -eq 0 ]]; then
                    # Capture the output of the fetch latest updates function
                    fetch_updates_output=$(fetch_latest_updates 2>&1)
                    # Capture the exit code of the fetch latest updates function
                    fetch_updates_exit_status=$?

                    # Pipe the output to zenity progress dialog
                    echo "$fetch_updates_output" 2>&1 | zenity --progress \
                    --title="Fetching updates" \
                    --text="Fetching updates..." \
                    --percentage=0 \
                    --auto-kill \
                    --auto-close &

                    wait
                    
                    if [[ $fetch_updates_exit_status -eq 0 ]]; then
                        zenity --info \
                        --title="Fetching updates" \
                        --text="Updates fetched successfully."
                        
                    else
                        zenity --error \
                        --title="Fetching updates" \
                        --text="Updates not fetched successfully. Please try again or contact support"
                    fi
                    
                else
                    # Connection is not successful
                    zenity --error \
                    --title="Internet connection not successful" \
                    --text="You are not connected to the internet."
                    echo "You are not connected to the internet"
                fi
            else
                # If the user clicked the "No" button, exit the application
                exit 0
            fi
        ;;
    "About")
        # About this application
        zenity --text-info \
               --title="About this application" \
               --filename="$VERSION"
        ;;
    "Quit")
        exit 0
        ;;
    *)
        zenity --error \
        --text="Invalid selection"
        exit 1
        ;;
esac



