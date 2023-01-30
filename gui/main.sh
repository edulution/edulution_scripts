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
    "About...."
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
        selected_date=$(zenity --calendar \
            --text="Select any date in the month you would like to submit reports" \
            --title="Report Submission" \
            --date-format=%m-%y)
        echo "Selected date: $selected_date"
        # Display a question dialog box
                # Check the exit status of the zenity command
        if [ $? -eq 0 ]; then
        	zenity --question \
            --title="Confirm reports submission" \
            --text="You are about to submit reports for $selected_date. Do you want to continue?"

        	if [ $? -eq 0 ]; then
                check_internet_connection
                
                if [[ $? -eq 0 ]]; then
                    # Connection is successful. Begin submitting report
                    zenity --progress \
                    --pulsate \
                    --title="Report submission" \
                    --text="Extracting and submitting reports. Please wait..." \
                    --auto-close &

                    ~/.scripts/reporting/monthend.sh "$selected_date" &
                    
                    zenity --info \
                    --title="Reports submission complete" \
                    --text="Report submission complete"
                    
                else
                    # Connection is not successful
                    zenity --error --title="Internet connection not successful" --text="You are not connected to the internet."
                    echo "You are not connected to the internet"
                fi
        	else
        	    # If the user clicked the "No" button, exit the application
        	    exit 0
        	fi
        else
        	exit 0
        fi
        ;;
    "Fetch latest updates")
        zenity --question --title="Fetching latest updates" --text="You are about to fetch the latest updates. Do you want to continue?"

            if [ $? -eq 0 ]; then
                check_internet_connection
                
                if [[ $? -eq 0 ]]; then
                    # Connection is successful. Begin fetching updates

                    # Use Zenity to display a progress dialog
                    zenity --progress --pulsate --title="Updating code" --text="Please wait..." --auto-close &

                    # Save the PID of the Zenity process
                    ZENITY_PID=$!

                    # List of directories
                    directories=("~/.scripts" "~/.baseline_testing" "~/.kolibri_helper_scripts")

                    for dir in "${directories[@]}"; do
                      # Expand the tilde character
                      eval expanded_dir="$dir"

                      # Go to the directory
                      cd "$expanded_dir" || { kill $ZENITY_PID && zenity --error --title="Code update" --text="Error: Failed to change directory to $expanded_dir."; exit 1; }

                      # Pull the latest code from Github
                      git pull origin "$COUNTRY_BRANCH" > /dev/null || { kill $ZENITY_PID && zenity --error --title="Code update" --text="Error: Failed to pull the latest updates for $expanded_dir."; exit 1; }

                    done

                    # Close the progress dialog
                    kill $ZENITY_PID

                    # Show a message box indicating that the operation is completed successfully
                    zenity --info --title="Updates complete" --text="Updates have been fetched successfully"
                    
                else
                    # Connection is not successful
                    zenity --error --title="Internet connection not successful" --text="You are not connected to the internet."
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
        zenity --error --text="Invalid selection"
        exit 1
        ;;
esac



