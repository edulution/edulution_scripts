#!/bin/bash

# Create a list of options
options=(
    "Restart Kolibri"
    "Regenerate Kolibri quizzes"
    "Assign Learners"
    "Take database backup"
    "Submit reports"
    "Fetch latest updates"
    "Help"
    "Quit"
    )

# Display the list of options in a dialog box
choice=$(zenity --list --title="Select an option" --column="Options" "${options[@]}")

# Check the user's choice and perform the corresponding action
case "$choice" in
    "Restart Kolibri")
        zenity --info --text="You selected option 1"
        ;;
    "Take database backup")
        zenity --info --text="You selected option 2"
        ;;
    "Submit Reports")
        selected_date=$(zenity --calendar --text="Select any date in the month you would like to submit reports" --title="Report Submission" --date-format=%m-%y)
        echo "Selected date: $selected_date"
        # Display a question dialog box
                # Check the exit status of the zenity command
        if [ $? -eq 0 ]; then
        	zenity --question --title="Confirm reports submission" --text="You are about to submit reports for $selected_date. Do you want to continue?"

        	if [ $? -eq 0 ]; then
        		echo "Submitting reports for $selected_date"

        	else
        	    # If the user clicked the "No" button, perform action B
        	    exit 0
        	fi
        else
        	exit 0
        fi
        ;;
    "Quit")
        exit 0
        ;;
    *)
        zenity --error --text="Invalid selection"
        exit 1
        ;;
esac



